import { useState, useEffect } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import type { Product } from '../types';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
import StatusChip from '../components/StatusChip';
import ConfirmDialog from '../components/ConfirmDialog';
import PageHeader from '../components/PageHeader';
import {
  Box, Typography, IconButton, Tooltip, Dialog, DialogTitle, DialogContent,
  DialogActions, Button, TextField, Grid, FormControl, InputLabel, Select, MenuItem,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';

const currencyFormat = (value: number) =>
  new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(value);

const statusFilterOptions = [
  { value: 'PENDING_APPROVAL', label: 'Pending Approval' },
  { value: 'APPROVED', label: 'Approved' },
  { value: 'REJECTED', label: 'Rejected' },
];

interface EditForm {
  name: string;
  description: string;
  price: number;
  stock: number;
  status: string;
}

const emptyForm: EditForm = { name: '', description: '', price: 0, stock: 0, status: 'DRAFT' };

export default function ProductsPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');

  const [editOpen, setEditOpen] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [editForm, setEditForm] = useState<EditForm>(emptyForm);

  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<() => void>(() => {});
  const [confirmTitle, setConfirmTitle] = useState('');
  const [confirmMessage, setConfirmMessage] = useState('');

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 400);
    return () => clearTimeout(timer);
  }, [search]);

  const { data, isLoading } = useQuery({
    queryKey: ['products', { page: page + 1, limit, search: debouncedSearch, status: statusFilter }],
    queryFn: () => adminService.getProducts({ page: page + 1, limit, search: debouncedSearch || undefined, status: statusFilter || undefined }),
  });

  const { data: categoriesData } = useQuery({
    queryKey: ['categories-list'],
    queryFn: () => adminService.getCategories({ limit: 100 }),
  });

  const categories = categoriesData?.items ?? [];

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['products'] });

  const updateMutation = useMutation({
    mutationFn: ({ id, data: formData }: { id: string; data: Partial<EditForm> }) =>
      adminService.updateProduct(id, { ...formData, status: formData.status as Product['status'] }),
    onSuccess: invalidate,
  });

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminService.updateProductStatus(id, status),
    onSuccess: invalidate,
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminService.deleteProduct(id),
    onSuccess: invalidate,
  });

  const showConfirm = (title: string, message: string, action: () => void) => {
    setConfirmTitle(title);
    setConfirmMessage(message);
    setConfirmAction(() => action);
    setConfirmOpen(true);
  };

  const handleEdit = (product: any) => {
    setEditId(product.id);
    setEditForm({
      name: product.name || '',
      description: product.description || '',
      price: product.price || 0,
      stock: product.stock || 0,
      status: product.status || 'DRAFT',
    });
    setEditOpen(true);
  };

  const handleEditSave = () => {
    if (!editId) return;
    updateMutation.mutate({ id: editId, data: editForm });
    setEditOpen(false);
    setEditId(null);
  };

  const handleToggleVisibility = (product: any) => {
    updateMutation.mutate({ id: product.id, data: { isActive: !product.isActive } as any });
  };

  const handleApprove = (id: string) => {
    updateStatusMutation.mutate({ id, status: 'APPROVED' });
  };

  const handleReject = (id: string) => {
    updateStatusMutation.mutate({ id, status: 'REJECTED' });
  };

  const handleDelete = (id: string) => {
    deleteMutation.mutate(id);
    setConfirmOpen(false);
  };

  const columns = [
    {
      key: 'name',
      label: 'Product Name',
      render: (row: any) => (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
          {row.imageUrl && (
            <Box
              component="img"
              src={row.imageUrl}
              alt=""
              sx={{ width: 40, height: 40, borderRadius: 1, objectFit: 'cover' }}
            />
          )}
          <Typography variant="body2" fontWeight={600}>
            {row.name}
          </Typography>
        </Box>
      ),
    },
    { key: 'category', label: 'Category' },
    {
      key: 'price',
      label: 'Price (₹)',
      render: (row: any) => currencyFormat(row.price),
    },
    {
      key: 'stock',
      label: 'Stock',
      render: (row: any) => (
        <Typography variant="body2" color={row.stock <= 0 ? 'error' : 'text.primary'}>
          {row.stock} {row.unit || ''}
        </Typography>
      ),
    },
    { key: 'farmerName', label: 'Farmer' },
    {
      key: 'status',
      label: 'Status',
      render: (row: any) => <StatusChip status={row.status} />,
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (row: any) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title={row.isActive ? 'Deactivate' : 'Activate'}>
            <IconButton size="small" onClick={() => handleToggleVisibility(row)}>
              {row.isActive ? <VisibilityOffIcon fontSize="small" /> : <VisibilityIcon fontSize="small" />}
            </IconButton>
          </Tooltip>
          <Tooltip title="Edit">
            <IconButton size="small" onClick={() => handleEdit(row)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          {row.status === 'PENDING_APPROVAL' && (
            <>
              <Tooltip title="Approve">
                <IconButton size="small" color="success" onClick={() => showConfirm('Approve Product', `Are you sure you want to approve "${row.name}"?`, () => handleApprove(row.id))}>
                  <Typography variant="caption" fontWeight={700}>✓</Typography>
                </IconButton>
              </Tooltip>
              <Tooltip title="Reject">
                <IconButton size="small" color="error" onClick={() => showConfirm('Reject Product', `Are you sure you want to reject "${row.name}"?`, () => handleReject(row.id))}>
                  <Typography variant="caption" fontWeight={700}>✕</Typography>
                </IconButton>
              </Tooltip>
            </>
          )}
          <Tooltip title="Delete">
            <IconButton size="small" color="error" onClick={() => showConfirm('Delete Product', `Are you sure you want to delete "${row.name}"? This action cannot be undone.`, () => handleDelete(row.id))}>
              <DeleteIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const filters = [
    {
      key: 'status',
      label: 'Status',
      options: statusFilterOptions,
      value: statusFilter,
    },
    {
      key: 'category',
      label: 'Category',
      options: categories.map((c: any) => ({ value: c.name, label: c.name })),
      value: categoryFilter,
    },
  ];

  const handleFilterChange = (key: string, value: string) => {
    if (key === 'status') setStatusFilter(value);
    else if (key === 'category') setCategoryFilter(value);
    setPage(0);
  };

  return (
    <Box>
      <PageHeader
        title="Product Management"
        action={{ label: 'Add Product', onClick: () => {}, icon: <AddIcon /> }}
      />
      <SearchFilter
        searchValue={search}
        searchPlaceholder="Search products by name..."
        onSearchChange={(v) => { setSearch(v); setPage(0); }}
        filters={filters}
        onFilterChange={handleFilterChange}
      />
      <DataTable
        columns={columns}
        data={data?.items ?? []}
        total={data?.total ?? 0}
        page={page}
        rowsPerPage={limit}
        onPageChange={setPage}
        onRowsPerPageChange={(l) => { setLimit(l); setPage(0); }}
        loading={isLoading}
        emptyMessage="No products found"
      />
      <Dialog open={editOpen} onClose={() => setEditOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle fontWeight={600}>Edit Product</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 0.5 }}>
            <Grid item xs={12}>
              <TextField
                label="Product Name"
                fullWidth
                size="small"
                value={editForm.name}
                onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                label="Description"
                fullWidth
                size="small"
                multiline
                rows={3}
                value={editForm.description}
                onChange={(e) => setEditForm({ ...editForm, description: e.target.value })}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                label="Price (₹)"
                fullWidth
                size="small"
                type="number"
                value={editForm.price}
                onChange={(e) => setEditForm({ ...editForm, price: Number(e.target.value) })}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                label="Stock"
                fullWidth
                size="small"
                type="number"
                value={editForm.stock}
                onChange={(e) => setEditForm({ ...editForm, stock: Number(e.target.value) })}
              />
            </Grid>
            <Grid item xs={12}>
              <FormControl fullWidth size="small">
                <InputLabel>Status</InputLabel>
                <Select
                  value={editForm.status}
                  label="Status"
                  onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                >
                  <MenuItem value="DRAFT">Draft</MenuItem>
                  <MenuItem value="PENDING_APPROVAL">Pending Approval</MenuItem>
                  <MenuItem value="APPROVED">Approved</MenuItem>
                  <MenuItem value="REJECTED">Rejected</MenuItem>
                </Select>
              </FormControl>
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setEditOpen(false)}>Cancel</Button>
          <Button onClick={handleEditSave} variant="contained" disabled={updateMutation.isPending}>
            {updateMutation.isPending ? 'Saving...' : 'Save'}
          </Button>
        </DialogActions>
      </Dialog>
      <ConfirmDialog
        open={confirmOpen}
        title={confirmTitle}
        message={confirmMessage}
        onConfirm={confirmAction}
        onCancel={() => setConfirmOpen(false)}
        loading={updateStatusMutation.isPending || deleteMutation.isPending}
      />
    </Box>
  );
}
