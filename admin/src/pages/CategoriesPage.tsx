import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import type { Category } from '../types';
import DataTable from '../components/DataTable';
import StatusChip from '../components/StatusChip';
import ConfirmDialog from '../components/ConfirmDialog';
import PageHeader from '../components/PageHeader';
import {
  Box, Typography, IconButton, Tooltip, Dialog, DialogTitle, DialogContent,
  DialogActions, Button, TextField, FormControl, InputLabel, Select, MenuItem,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

interface CategoryForm {
  name: string;
  slug: string;
  description: string;
  displayOrder: number;
  status: string;
}

const emptyForm: CategoryForm = { name: '', slug: '', description: '', displayOrder: 0, status: 'ACTIVE' };

export default function CategoriesPage() {
  const queryClient = useQueryClient();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [form, setForm] = useState<CategoryForm>(emptyForm);
  const [slugManuallyEdited, setSlugManuallyEdited] = useState(false);
  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<() => void>(() => {});
  const [confirmTitle, setConfirmTitle] = useState('');
  const [confirmMessage, setConfirmMessage] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['categories'],
    queryFn: () => adminService.getCategories(),
  });

  const categories = data?.items ?? [];

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['categories'] });

  const createMutation = useMutation({
    mutationFn: (formData: CategoryForm) => adminService.createCategory({ ...formData, status: formData.status as Category['status'] }),
    onSuccess: invalidate,
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, formData }: { id: string; formData: CategoryForm }) =>
      adminService.updateCategory(id, { ...formData, status: formData.status as Category['status'] }),
    onSuccess: invalidate,
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminService.deleteCategory(id),
    onSuccess: invalidate,
  });

  const toggleStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminService.updateCategoryStatus(id, status),
    onSuccess: invalidate,
  });

  const showConfirm = (title: string, message: string, action: () => void) => {
    setConfirmTitle(title);
    setConfirmMessage(message);
    setConfirmAction(() => action);
    setConfirmOpen(true);
  };

  const slugify = (text: string) =>
    text.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

  const handleNameChange = (name: string) => {
    setForm((prev) => ({
      ...prev,
      name,
      slug: slugManuallyEdited ? prev.slug : slugify(name),
    }));
  };

  const openAdd = () => {
    setEditId(null);
    setForm(emptyForm);
    setSlugManuallyEdited(false);
    setDialogOpen(true);
  };

  const openEdit = (category: any) => {
    setEditId(category.id);
    setForm({
      name: category.name || '',
      slug: category.slug || '',
      description: category.description || '',
      displayOrder: category.displayOrder ?? 0,
      status: category.status || 'ACTIVE',
    });
    setSlugManuallyEdited(true);
    setDialogOpen(true);
  };

  const handleSave = () => {
    if (editId) {
      updateMutation.mutate({ id: editId, formData: form });
    } else {
      createMutation.mutate(form);
    }
    setDialogOpen(false);
  };

  const handleToggleStatus = (category: any) => {
    const newStatus = category.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE';
    const action = newStatus === 'ACTIVE' ? 'Activate' : 'Deactivate';
    showConfirm(
      `${action} Category`,
      `Are you sure you want to ${action.toLowerCase()} "${category.name}"?`,
      () => {
        toggleStatusMutation.mutate({ id: category.id, status: newStatus });
        setConfirmOpen(false);
      }
    );
  };

  const handleDelete = (category: any) => {
    showConfirm(
      'Delete Category',
      `Are you sure you want to delete "${category.name}"? This action cannot be undone.`,
      () => {
        deleteMutation.mutate(category.id);
        setConfirmOpen(false);
      }
    );
  };

  const columns = [
    {
      key: 'icon',
      label: 'Icon',
      render: (row: any) => (
        <Typography variant="h5" sx={{ lineHeight: 1 }}>
          {row.icon || '📁'}
        </Typography>
      ),
    },
    { key: 'name', label: 'Category Name', render: (row: any) => <Typography fontWeight={600}>{row.name}</Typography> },
    {
      key: 'description',
      label: 'Description',
      render: (row: any) => (
        <Typography variant="body2" color="text.secondary" sx={{ maxWidth: 300, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
          {row.description || '—'}
        </Typography>
      ),
    },
    { key: 'productCount', label: 'Products Count' },
    { key: 'displayOrder', label: 'Display Order' },
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
          <Tooltip title="Edit">
            <IconButton size="small" onClick={() => openEdit(row)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title={row.status === 'ACTIVE' ? 'Deactivate' : 'Activate'}>
            <IconButton size="small" color={row.status === 'ACTIVE' ? 'warning' : 'success'} onClick={() => handleToggleStatus(row)}>
              <Typography variant="caption" fontWeight={700}>{row.status === 'ACTIVE' ? '⏸' : '▶'}</Typography>
            </IconButton>
          </Tooltip>
          <Tooltip title="Delete">
            <IconButton size="small" color="error" onClick={() => handleDelete(row)}>
              <DeleteIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  return (
    <Box>
      <PageHeader
        title="Category Management"
        action={{ label: 'Add Category', onClick: openAdd, icon: <AddIcon /> }}
      />
      <DataTable
        columns={columns}
        data={categories}
        loading={isLoading}
        emptyMessage="No categories found"
      />
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} maxWidth="sm" fullWidth>
        <DialogTitle fontWeight={600}>{editId ? 'Edit Category' : 'Add Category'}</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
            <TextField
              label="Category Name"
              fullWidth
              size="small"
              value={form.name}
              onChange={(e) => handleNameChange(e.target.value)}
            />
            <TextField
              label="Slug"
              fullWidth
              size="small"
              value={form.slug}
              onChange={(e) => {
                setForm({ ...form, slug: e.target.value });
                setSlugManuallyEdited(true);
              }}
            />
            <TextField
              label="Description"
              fullWidth
              size="small"
              multiline
              rows={3}
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
            />
            <TextField
              label="Display Order"
              fullWidth
              size="small"
              type="number"
              value={form.displayOrder}
              onChange={(e) => setForm({ ...form, displayOrder: Number(e.target.value) })}
            />
            <FormControl fullWidth size="small">
              <InputLabel>Status</InputLabel>
              <Select
                value={form.status}
                label="Status"
                onChange={(e) => setForm({ ...form, status: e.target.value })}
              >
                <MenuItem value="ACTIVE">Active</MenuItem>
                <MenuItem value="INACTIVE">Inactive</MenuItem>
              </Select>
            </FormControl>
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleSave} variant="contained" disabled={createMutation.isPending || updateMutation.isPending}>
            {createMutation.isPending || updateMutation.isPending ? 'Saving...' : 'Save'}
          </Button>
        </DialogActions>
      </Dialog>
      <ConfirmDialog
        open={confirmOpen}
        title={confirmTitle}
        message={confirmMessage}
        onConfirm={confirmAction}
        onCancel={() => setConfirmOpen(false)}
        loading={deleteMutation.isPending || toggleStatusMutation.isPending}
      />
    </Box>
  );
}
