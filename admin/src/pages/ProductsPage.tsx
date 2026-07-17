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
  Snackbar, Alert, InputAdornment, CircularProgress, Autocomplete
} from '@mui/material';
import { useTheme } from '@mui/material/styles';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import VisibilityIcon from '@mui/icons-material/Visibility';
import VisibilityOffIcon from '@mui/icons-material/VisibilityOff';
import AutoAwesomeIcon from '@mui/icons-material/AutoAwesome';
import PhotoCameraIcon from '@mui/icons-material/PhotoCamera';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';

const currencyFormat = (value: number) =>
  new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(value);

const statusFilterOptions = [
  { value: 'PENDING_APPROVAL', label: 'Pending Approval' },
  { value: 'APPROVED', label: 'Approved' },
  { value: 'REJECTED', label: 'Rejected' },
];

const AVAILABILITY_OPTIONS = [
  { value: 'ACTIVE', label: 'Active (Visible & Approved)' },
  { value: 'IN_STOCK', label: 'In Stock' },
  { value: 'OUT_OF_STOCK', label: 'Out of Stock' },
  { value: 'HIDDEN', label: 'Hidden (Archived)' }
];

interface EditForm {
  name: string;
  description: string;
  price: number;
  stock: number;
  status: string;
  categoryId?: string;
  categoryName?: string;
  farmerId?: string;
  farmerName?: string;
  unit?: string;
  imageUrl?: string;
}

const emptyForm: EditForm = { name: '', description: '', price: 0, stock: 0, status: 'IN_STOCK', categoryId: '', categoryName: '', farmerId: '', farmerName: '', unit: '1 kg', imageUrl: '' };

const suggestImage = (name: string) => {
  const lower = name.toLowerCase();
  if (lower.includes('tomato')) return 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=400';
  if (lower.includes('onion')) return 'https://images.unsplash.com/photo-1618512496248-a07fe83766a5?w=400';
  if (lower.includes('mango')) return 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=400';
  if (lower.includes('rice')) return 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400';
  if (lower.includes('apple')) return 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400';
  if (lower.includes('carrot')) return 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=400';
  if (lower.includes('milk')) return 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400';
  if (lower.includes('egg')) return 'https://images.unsplash.com/photo-1516448424440-9dbca97779c1?w=400';
  if (lower.includes('banana')) return 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400';
  if (lower.includes('potato')) return 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400';
  if (lower.includes('orange')) return 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=400';
  if (lower.includes('lemon')) return 'https://images.unsplash.com/photo-1590502593747-42a996133562?w=400';
  if (lower.includes('strawberry')) return 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=400';
  if (lower.includes('grapes')) return 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=400';
  if (lower.includes('watermelon')) return 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400';
  if (lower.includes('chili') || lower.includes('chilli')) return 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400';
  if (lower.includes('cabbage')) return 'https://images.unsplash.com/photo-1582515073490-39981397c445?w=400';
  if (lower.includes('spinach')) return 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400';
  return 'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=400'; // Default organic veggies
};

export default function ProductsPage() {
  const queryClient = useQueryClient();
  const theme = useTheme();
  const isDark = theme.palette.mode === 'dark';

  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('');

  const [editOpen, setEditOpen] = useState(false);
  const [editId, setEditId] = useState<string | null>(null);
  const [editForm, setEditForm] = useState<EditForm>(emptyForm);
  const [currency, setCurrency] = useState('₹');

  const [confirmOpen, setConfirmOpen] = useState(false);
  const [confirmAction, setConfirmAction] = useState<() => void>(() => {});
  const [confirmTitle, setConfirmTitle] = useState('');
  const [confirmMessage, setConfirmMessage] = useState('');

  const [snack, setSnack] = useState<{ open: boolean; message: string; severity: 'success' | 'error' }>({ open: false, message: '', severity: 'success' });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [generating, setGenerating] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedSearch(search), 400);
    return () => clearTimeout(timer);
  }, [search]);

  const { data, isLoading } = useQuery({
    queryKey: ['products', { page: page + 1, limit, search: debouncedSearch, status: statusFilter, category: categoryFilter }],
    queryFn: () => adminService.getProducts({ 
      page: page + 1, 
      limit, 
      search: debouncedSearch || undefined, 
      status: statusFilter || undefined,
      category: categoryFilter || undefined
    }),
  });

  const { data: categoriesData } = useQuery({
    queryKey: ['categories-list'],
    queryFn: () => adminService.getCategories({ limit: 100 }),
  });

  const categories = categoriesData?.items ?? [];

  const { data: farmersData } = useQuery({
    queryKey: ['farmers-list'],
    queryFn: () => adminService.getFarmers({ limit: 100 }),
  });

  const farmers = farmersData?.items ?? [];

  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['products'] });

  const createMutation = useMutation({
    mutationFn: (formData: any) => adminService.createProduct(formData),
    onSuccess: () => {
      invalidate();
      setSnack({ open: true, message: 'Product created successfully', severity: 'success' });
      setEditOpen(false);
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data: formData }: { id: string; data: Partial<EditForm> }) =>
      adminService.updateProduct(id, formData as any),
    onSuccess: () => {
      invalidate();
      setSnack({ open: true, message: 'Product updated successfully', severity: 'success' });
    },
  });

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminService.updateProductStatus(id, status),
    onSuccess: (_, variables) => {
      invalidate();
      setSnack({ open: true, message: `Product ${variables.status.toLowerCase()} successfully`, severity: 'success' });
    },
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

  const openAdd = () => {
    setEditId(null);
    setErrors({});
    setEditForm(emptyForm);
    setEditOpen(true);
  };

  const handleEdit = (product: any) => {
    setEditId(product.id);
    setErrors({});

    let availability = 'ACTIVE';
    if (product.status === 'ARCHIVED' || product.status === 'DRAFT') {
      availability = 'HIDDEN';
    } else if (product.stock === 0) {
      availability = 'OUT_OF_STOCK';
    } else {
      availability = 'IN_STOCK';
    }

    setEditForm({
      name: product.name || '',
      description: product.description || '',
      price: product.price || 0,
      stock: product.stock || 0,
      status: availability,
      categoryId: product.categoryId || '',
      categoryName: product.category || '',
      farmerId: product.farmerId || '',
      farmerName: product.farmerName || '',
      unit: product.unit || '1 kg',
      imageUrl: product.imageUrl || '',
    });
    setEditOpen(true);
  };

  const handleAutoGenerateDescription = () => {
    if (!editForm.name.trim()) {
      setSnack({ open: true, message: 'Please enter a product name first', severity: 'error' });
      return;
    }
    setGenerating(true);
    setTimeout(() => {
      const generated = `Fresh organic ${editForm.name.trim()}, hand-harvested directly from local farms. Naturally grown without harmful chemical pesticides, rich in essential vitamins, minerals, and flavor. Ideal for healthy daily meals, salads, or cooking.`;
      setEditForm(prev => ({ ...prev, description: generated }));
      setGenerating(false);
      setSnack({ open: true, message: 'Description generated successfully!', severity: 'success' });
    }, 850);
  };

  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const name = e.target.value;
    setEditForm(prev => {
      const updated = { ...prev, name };
      if (name.length > 2 && (!prev.imageUrl || prev.imageUrl.startsWith('https://images.unsplash.com'))) {
        updated.imageUrl = suggestImage(name);
      }
      return updated;
    });
  };

  const handleImageFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setEditForm(prev => ({ ...prev, imageUrl: reader.result as string }));
      };
      reader.readAsDataURL(file);
    }
  };

  const validateForm = () => {
    const errs: Record<string, string> = {};
    if (!editForm.name.trim()) errs.name = 'Product name is required';
    if (!editForm.description.trim()) errs.description = 'Description is required';
    if (editForm.price <= 0) errs.price = 'Price must be greater than zero';
    if (editForm.stock < 0) errs.stock = 'Stock must be non-negative';
    if (!editForm.categoryName?.trim()) errs.categoryName = 'Category is required';
    if (!editId) {
      if (!editForm.farmerName?.trim()) errs.farmerName = 'Farmer name is required';
    }
    if (!editForm.unit?.trim()) errs.unit = 'Unit quantity descriptor is required';
    
    setErrors(errs);
    return Object.keys(errs).length === 0;
  };

  const handleEditSave = async () => {
    if (!validateForm()) {
      setSnack({ open: true, message: 'Please fix validation errors first', severity: 'error' });
      return;
    }

    let dbFarmerId = editForm.farmerId;
    if (!editId) {
      const enteredName = (editForm.farmerName || '').trim().toLowerCase();
      const foundFarmer = farmers.find((f: any) => 
        (f.user?.name || '').toLowerCase() === enteredName || 
        (f.farmName || '').toLowerCase() === enteredName
      );
      if (!foundFarmer) {
        setErrors(prev => ({ ...prev, farmerName: 'Farmer not found. Please enter a registered farmer name (e.g. John Farmer)' }));
        setSnack({ open: true, message: 'Farmer not found. Please check spelling.', severity: 'error' });
        return;
      }
      dbFarmerId = foundFarmer.id;
    }

    const saveProduct = (resolvedCategoryId: string) => {
      let dbStatus = 'APPROVED';
      let dbStock = editForm.stock;

      if (editForm.status === 'HIDDEN') {
        dbStatus = 'ARCHIVED';
      } else if (editForm.status === 'OUT_OF_STOCK') {
        dbStatus = 'APPROVED';
        dbStock = 0;
      } else if (editForm.status === 'IN_STOCK') {
        dbStatus = 'APPROVED';
        if (dbStock <= 0) dbStock = 10; 
      } else if (editForm.status === 'ACTIVE') {
        dbStatus = 'APPROVED';
      }

      const payload = {
        name: editForm.name,
        description: editForm.description,
        price: editForm.price,
        stock: dbStock,
        categoryId: resolvedCategoryId,
        unit: editForm.unit,
      };

      if (editId) {
        updateMutation.mutate({ id: editId, data: payload }, {
          onSuccess: (data) => {
            updateStatusMutation.mutate({ id: editId, status: dbStatus }, {
              onSuccess: () => {
                if (editForm.imageUrl && editForm.imageUrl !== data.imageUrl) {
                  adminService.uploadProductImages(editId, [editForm.imageUrl]).then(() => {
                    invalidate();
                  });
                }
              }
            });
          }
        });
        setEditOpen(false);
        setEditId(null);
      } else {
        const createPayload = {
          ...payload,
          farmerId: dbFarmerId as string,
          stock: dbStock,
        };

        createMutation.mutate(createPayload, {
          onSuccess: (data) => {
            if (editForm.imageUrl) {
              adminService.uploadProductImages(data.id, [editForm.imageUrl]).then(() => {
                invalidate();
              });
            }
          }
        });
      }
    };

    const enteredCatName = (editForm.categoryName || '').trim();
    const existingCat = categories.find((c: any) => c.name.toLowerCase() === enteredCatName.toLowerCase());
    
    if (existingCat) {
      saveProduct(existingCat.id);
    } else {
      try {
        const newCat = await adminService.createCategory({ 
          name: enteredCatName,
          slug: enteredCatName.toLowerCase().replace(/[^a-z0-9]/g, '-'),
          description: `Custom category ${enteredCatName}`,
          status: 'ACTIVE'
        });
        queryClient.invalidateQueries({ queryKey: ['categories-list'] });
        saveProduct(newCat.id);
      } catch (err) {
        setSnack({ open: true, message: 'Failed to create new category', severity: 'error' });
      }
    }
  };

  const handleToggleVisibility = (product: any) => {
    const newStatus = product.isActive ? 'ARCHIVED' : 'APPROVED';
    updateStatusMutation.mutate({ id: product.id, status: newStatus });
  };

  const handleApprove = (id: string) => updateStatusMutation.mutate({ id, status: 'APPROVED' });
  const handleReject = (id: string) => updateStatusMutation.mutate({ id, status: 'REJECTED' });
  const handleDelete = (id: string) => deleteMutation.mutate(id);

  const columns = [
    { key: 'name', label: 'Name', render: (row: any) => (
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        {row.imageUrl ? (
          <Box component="img" src={row.imageUrl} sx={{ width: 32, height: 32, borderRadius: '8px', objectFit: 'cover' }} />
        ) : (
          <Box sx={{ width: 32, height: 32, borderRadius: '8px', bgcolor: 'action.hover', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14 }}>
            🌱
          </Box>
        )}
        <Typography variant="body2" fontWeight={600}>{row.name}</Typography>
      </Box>
    )},
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
        action={{ label: 'Add Product', onClick: openAdd, icon: <AddIcon /> }}
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
      <Dialog 
        open={editOpen} 
        onClose={() => setEditOpen(false)} 
        maxWidth="sm" 
        fullWidth
        PaperProps={{
          sx: {
            borderRadius: '24px',
            border: isDark ? '1px solid rgba(255, 255, 255, 0.08)' : '1px solid rgba(0, 0, 0, 0.06)',
            boxShadow: isDark ? '0 20px 50px rgba(0,0,0,0.4)' : '0 20px 50px rgba(15,23,42,0.08)',
            background: isDark ? 'rgba(12, 15, 34, 0.9)' : 'rgba(255, 255, 255, 0.95)',
            backdropFilter: 'blur(20px)',
            overflow: 'hidden'
          }
        }}
      >
        <DialogTitle 
          sx={{ 
            fontWeight: 800, 
            fontFamily: 'Outfit, sans-serif',
            fontSize: 20,
            background: 'linear-gradient(135deg, rgba(16,185,129,0.08) 0%, rgba(59,130,246,0.08) 100%)',
            borderBottom: '1px solid',
            borderColor: 'divider',
            py: 2.5,
            px: 3,
            display: 'flex',
            alignItems: 'center',
            gap: 1.5
          }}
        >
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: 36, height: 36, borderRadius: '10px', bgcolor: 'rgba(16,185,129,0.15)', color: 'primary.main' }}>
            <AutoAwesomeIcon sx={{ fontSize: 18 }} />
          </Box>
          {editId ? 'Modify Product Details' : 'Add New Product Crop'}
        </DialogTitle>
        <DialogContent sx={{ px: 3, py: 3 }}>
          <Grid container spacing={2.5}>
            {/* Image Preview & Upload Row */}
            <Grid item xs={12}>
              <Box sx={{ display: 'flex', gap: 3, alignItems: 'center', border: '1px dashed', borderColor: 'divider', borderRadius: '16px', p: 2, bgcolor: 'action.hover' }}>
                <Box 
                  sx={{ 
                    width: 90, 
                    height: 90, 
                    borderRadius: '16px', 
                    overflow: 'hidden', 
                    bgcolor: 'background.paper', 
                    border: '1px solid', 
                    borderColor: 'divider',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    position: 'relative'
                  }}
                >
                  {editForm.imageUrl ? (
                    <Box component="img" src={editForm.imageUrl} sx={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                  ) : (
                    <CloudUploadIcon sx={{ fontSize: 32, color: 'text.secondary' }} />
                  )}
                </Box>
                <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1 }}>
                  <Typography variant="subtitle2" fontWeight={700}>Product Cover Image</Typography>
                  <Typography variant="caption" color="text.secondary">Suggested automatically, or choose a custom file</Typography>
                  <Button
                    variant="outlined"
                    component="label"
                    size="small"
                    startIcon={<PhotoCameraIcon />}
                    sx={{ textTransform: 'none', borderRadius: '10px', width: 'fit-content' }}
                  >
                    Choose file
                    <input type="file" accept="image/*" hidden onChange={handleImageFileChange} />
                  </Button>
                </Box>
              </Box>
            </Grid>

            {!editId && (
              <>
                <Grid item xs={12} sm={6}>
                  <TextField
                    label="Farmer Name"
                    fullWidth
                    size="small"
                    placeholder="e.g. John Farmer"
                    value={editForm.farmerName || ''}
                    error={!!errors.farmerName}
                    helperText={errors.farmerName || 'Enter registered farmer name'}
                    onChange={(e) => setEditForm({ ...editForm, farmerName: e.target.value })}
                  />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <Autocomplete
                    freeSolo
                    size="small"
                    options={categories.map((c: any) => c.name)}
                    value={editForm.categoryName || ''}
                    onChange={(event, newValue) => {
                      setEditForm({ ...editForm, categoryName: newValue || '' });
                    }}
                    onInputChange={(event, newInputValue) => {
                      setEditForm({ ...editForm, categoryName: newInputValue || '' });
                    }}
                    renderInput={(params) => (
                      <TextField 
                        {...params} 
                        label="Category" 
                        error={!!errors.categoryName}
                        helperText={errors.categoryName || 'Select or type custom category'}
                      />
                    )}
                  />
                </Grid>
              </>
            )}

            <Grid item xs={12}>
              <TextField
                label="Product Name"
                fullWidth
                size="small"
                value={editForm.name}
                error={!!errors.name}
                helperText={errors.name}
                onChange={handleNameChange}
              />
            </Grid>

            <Grid item xs={12}>
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 0.5 }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 0.5 }}>
                  <Typography variant="body2" fontWeight={600} color="text.secondary">Product Description</Typography>
                  <Button
                    size="small"
                    variant="text"
                    color="primary"
                    onClick={handleAutoGenerateDescription}
                    disabled={generating}
                    startIcon={generating ? <CircularProgress size={12} /> : <AutoAwesomeIcon sx={{ fontSize: 14 }} />}
                    sx={{ textTransform: 'none', fontWeight: 700, fontSize: 12, py: 0 }}
                  >
                    {generating ? 'Generating...' : 'Auto-generate'}
                  </Button>
                </Box>
                <TextField
                  fullWidth
                  size="small"
                  multiline
                  rows={3}
                  value={editForm.description}
                  error={!!errors.description}
                  helperText={errors.description}
                  onChange={(e) => setEditForm({ ...editForm, description: e.target.value })}
                />
              </Box>
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                label="Price"
                fullWidth
                size="small"
                type="number"
                value={editForm.price || ''}
                error={!!errors.price}
                helperText={errors.price}
                onChange={(e) => setEditForm({ ...editForm, price: Number(e.target.value) })}
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Select
                        value={currency}
                        onChange={(e) => setCurrency(e.target.value)}
                        variant="standard"
                        sx={{ 
                          mr: 0.5, 
                          fontWeight: 700,
                          '&:before': { border: 'none' },
                          '&:after': { border: 'none' },
                          '& .MuiSelect-select': { paddingRight: '12px !important' }
                        }}
                      >
                        <MenuItem value="₹">₹</MenuItem>
                        <MenuItem value="$">$</MenuItem>
                        <MenuItem value="€">€</MenuItem>
                        <MenuItem value="£">£</MenuItem>
                      </Select>
                    </InputAdornment>
                  ),
                }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                label="Stock Level"
                fullWidth
                size="small"
                type="number"
                value={editForm.stock || ''}
                error={!!errors.stock}
                helperText={errors.stock}
                onChange={(e) => setEditForm({ ...editForm, stock: Number(e.target.value) })}
              />
            </Grid>

            <Grid item xs={12} sm={6}>
              <TextField
                label="Unit Size"
                fullWidth
                size="small"
                placeholder="e.g. 1 kg, 500 g, 1 Dozen"
                value={editForm.unit}
                error={!!errors.unit}
                helperText={errors.unit}
                onChange={(e) => setEditForm({ ...editForm, unit: e.target.value })}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth size="small">
                <InputLabel>Availability Status</InputLabel>
                <Select
                  value={editForm.status}
                  label="Availability Status"
                  onChange={(e) => setEditForm({ ...editForm, status: e.target.value })}
                >
                  {AVAILABILITY_OPTIONS.map((opt) => (
                    <MenuItem key={opt.value} value={opt.value}>{opt.label}</MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions sx={{ borderTop: '1px solid', borderColor: 'divider', px: 3, py: 2 }}>
          <Button onClick={() => setEditOpen(false)} sx={{ textTransform: 'none', fontWeight: 600 }}>Cancel</Button>
          <Button onClick={handleEditSave} variant="contained" disabled={updateMutation.isPending || createMutation.isPending} sx={{ textTransform: 'none', fontWeight: 700, borderRadius: '10px' }}>
            {updateMutation.isPending || createMutation.isPending ? 'Saving...' : 'Save Product'}
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
      <Snackbar open={snack.open} autoHideDuration={4000} onClose={() => setSnack({ ...snack, open: false })} anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}>
        <Alert onClose={() => setSnack({ ...snack, open: false })} severity={snack.severity} sx={{ width: '100%' }}>
          {snack.message}
        </Alert>
      </Snackbar>
    </Box>
  );
}
