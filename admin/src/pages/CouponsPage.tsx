import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Box, Typography, IconButton, Tooltip, Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField, Grid, FormControl, InputLabel, Select, MenuItem, Switch, FormControlLabel } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';
import { format } from 'date-fns';
import toast from 'react-hot-toast';
import { adminService } from '../services/admin.service';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
import StatusChip from '../components/StatusChip';
import ConfirmDialog from '../components/ConfirmDialog';
import PageHeader from '../components/PageHeader';
import type { Coupon } from '../types';

const emptyForm = {
  code: '',
  description: '',
  discountType: 'PERCENTAGE' as 'PERCENTAGE' | 'FLAT',
  discountValue: '',
  minOrderAmount: '',
  maxDiscountAmount: '',
  maxUses: '',
  expiresAt: '',
  isActive: true,
};

export default function CouponsPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [form, setForm] = useState(emptyForm);
  const [deleteTarget, setDeleteTarget] = useState<Coupon | null>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['coupons', { page: page + 1, limit, search }],
    queryFn: () => adminService.getCoupons({ page: page + 1, limit, search }),
  });

  const createMutation = useMutation({
    mutationFn: (payload: any) => adminService.createCoupon(payload),
    onSuccess: () => {
      toast.success('Coupon created');
      queryClient.invalidateQueries({ queryKey: ['coupons'] });
      closeDialog();
    },
    onError: (err: any) => toast.error(err?.response?.data?.message || 'Failed to create coupon'),
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, ...payload }: any) => adminService.updateCoupon(id, payload),
    onSuccess: () => {
      toast.success('Coupon updated');
      queryClient.invalidateQueries({ queryKey: ['coupons'] });
      closeDialog();
    },
    onError: (err: any) => toast.error(err?.response?.data?.message || 'Failed to update coupon'),
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminService.deleteCoupon(id),
    onSuccess: () => {
      toast.success('Coupon deleted');
      queryClient.invalidateQueries({ queryKey: ['coupons'] });
      setDeleteTarget(null);
    },
    onError: (err: any) => toast.error(err?.response?.data?.message || 'Failed to delete coupon'),
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      adminService.updateCoupon(id, { isActive }),
    onSuccess: () => {
      toast.success('Coupon status updated');
      queryClient.invalidateQueries({ queryKey: ['coupons'] });
    },
    onError: (err: any) => toast.error(err?.response?.data?.message || 'Failed to update status'),
  });

  const openCreate = () => {
    setEditingId(null);
    setForm(emptyForm);
    setDialogOpen(true);
  };

  const openEdit = (coupon: Coupon) => {
    setEditingId(coupon.id);
    setForm({
      code: coupon.code,
      description: coupon.description || '',
      discountType: coupon.discountType,
      discountValue: String(coupon.discountValue),
      minOrderAmount: String(coupon.minOrderAmount),
      maxDiscountAmount: coupon.maxDiscountAmount != null ? String(coupon.maxDiscountAmount) : '',
      maxUses: String(coupon.maxUses),
      expiresAt: coupon.expiresAt ? coupon.expiresAt.substring(0, 10) : '',
      isActive: coupon.isActive,
    });
    setDialogOpen(true);
  };

  const closeDialog = () => {
    setDialogOpen(false);
    setEditingId(null);
    setForm(emptyForm);
  };

  const handleSubmit = () => {
    const payload = {
      code: form.code.toUpperCase(),
      description: form.description,
      discountType: form.discountType,
      discountValue: Number(form.discountValue),
      minOrderAmount: Number(form.minOrderAmount),
      maxDiscountAmount: form.maxDiscountAmount ? Number(form.maxDiscountAmount) : undefined,
      maxUses: Number(form.maxUses),
      expiresAt: form.expiresAt || undefined,
      isActive: form.isActive,
    };

    if (editingId) {
      updateMutation.mutate({ id: editingId, ...payload });
    } else {
      createMutation.mutate(payload);
    }
  };

  const coupons = data?.items || [];
  const total = data?.total || 0;

  const columns = [
    {
      key: 'code',
      label: 'Code',
      render: (item: Coupon) => (
        <Typography fontWeight={700} color="success.main">
          {item.code}
        </Typography>
      ),
    },
    { key: 'discountType', label: 'Discount Type' },
    {
      key: 'discountValue',
      label: 'Discount Value',
      render: (item: Coupon) =>
        item.discountType === 'PERCENTAGE' ? `${item.discountValue}%` : `₹${item.discountValue}`,
    },
    {
      key: 'minOrderAmount',
      label: 'Min Order (₹)',
      render: (item: Coupon) => `₹${item.minOrderAmount.toLocaleString('en-IN')}`,
    },
    { key: 'maxUses', label: 'Max Uses' },
    { key: 'usedCount', label: 'Used' },
    {
      key: 'isActive',
      label: 'Status',
      render: (item: Coupon) => <StatusChip status={item.isActive ? 'ACTIVE' : 'INACTIVE'} />,
    },
    {
      key: 'expiresAt',
      label: 'Expires',
      render: (item: Coupon) =>
        item.expiresAt ? format(new Date(item.expiresAt), 'dd MMM yyyy') : 'N/A',
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: Coupon) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title="Edit">
            <IconButton size="small" onClick={() => openEdit(item)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title={item.isActive ? 'Deactivate' : 'Activate'}>
            <IconButton
              size="small"
              onClick={() =>
                toggleMutation.mutate({ id: item.id, isActive: !item.isActive })
              }
            >
              <Switch checked={item.isActive} size="small" color="success" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Delete">
            <IconButton size="small" color="error" onClick={() => setDeleteTarget(item)}>
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
        title="Coupon Management"
        action={{ label: 'Create Coupon', onClick: openCreate, icon: <AddIcon />, color: 'success' }}
      />

      <SearchFilter
        searchValue={search}
        searchPlaceholder="Search coupons..."
        onSearchChange={(v) => { setSearch(v); setPage(0); }}
      />

      <DataTable
        columns={columns}
        data={coupons}
        total={total}
        page={page}
        rowsPerPage={limit}
        onPageChange={setPage}
        onRowsPerPageChange={(v) => { setLimit(v); setPage(0); }}
        loading={isLoading}
        emptyMessage="No coupons found"
        keyExtractor={(item) => item.id}
      />

      <Dialog open={dialogOpen} onClose={closeDialog} maxWidth="sm" fullWidth>
        <DialogTitle fontWeight={600}>
          {editingId ? 'Edit Coupon' : 'Create Coupon'}
        </DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 0.5 }}>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Coupon Code"
                value={form.code}
                onChange={(e) => setForm({ ...form, code: e.target.value })}
                placeholder="e.g. SAVE50"
                inputProps={{ style: { textTransform: 'uppercase' } }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <FormControl fullWidth>
                <InputLabel>Discount Type</InputLabel>
                <Select
                  label="Discount Type"
                  value={form.discountType}
                  onChange={(e) => setForm({ ...form, discountType: e.target.value as any })}
                >
                  <MenuItem value="PERCENTAGE">Percentage (%)</MenuItem>
                  <MenuItem value="FLAT">Flat (₹)</MenuItem>
                </Select>
              </FormControl>
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Discount Value"
                type="number"
                value={form.discountValue}
                onChange={(e) => setForm({ ...form, discountValue: e.target.value })}
                inputProps={{ min: 0 }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Min Order Amount (₹)"
                type="number"
                value={form.minOrderAmount}
                onChange={(e) => setForm({ ...form, minOrderAmount: e.target.value })}
                inputProps={{ min: 0 }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Max Discount Amount (₹)"
                type="number"
                value={form.maxDiscountAmount}
                onChange={(e) => setForm({ ...form, maxDiscountAmount: e.target.value })}
                inputProps={{ min: 0 }}
                helperText="Optional. For percentage discounts."
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Max Uses"
                type="number"
                value={form.maxUses}
                onChange={(e) => setForm({ ...form, maxUses: e.target.value })}
                inputProps={{ min: 0 }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Expiry Date"
                type="date"
                value={form.expiresAt}
                onChange={(e) => setForm({ ...form, expiresAt: e.target.value })}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={12} sm={6}>
              <TextField
                fullWidth
                label="Description"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                multiline
                rows={2}
              />
            </Grid>
            <Grid item xs={12}>
              <FormControlLabel
                control={
                  <Switch
                    checked={form.isActive}
                    onChange={(e) => setForm({ ...form, isActive: e.target.checked })}
                    color="success"
                  />
                }
                label="Active"
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={closeDialog}>Cancel</Button>
          <Button
            variant="contained"
            color="success"
            onClick={handleSubmit}
            disabled={createMutation.isPending || updateMutation.isPending}
          >
            {createMutation.isPending || updateMutation.isPending
              ? 'Saving...'
              : editingId
              ? 'Update'
              : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete Coupon"
        message={`Are you sure you want to delete coupon "${deleteTarget?.code}"? This action cannot be undone.`}
        confirmText="Delete"
        severity="error"
        onConfirm={() => deleteTarget && deleteMutation.mutate(deleteTarget.id)}
        onCancel={() => setDeleteTarget(null)}
        loading={deleteMutation.isPending}
      />
    </Box>
  );
}
