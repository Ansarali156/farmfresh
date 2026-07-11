import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import StatusChip from '../components/StatusChip';
import ConfirmDialog from '../components/ConfirmDialog';
import PageHeader from '../components/PageHeader';
import {
  Box,
  Typography,
  IconButton,
  Tooltip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  Grid,
  Switch,
  FormControlLabel,
  Card,
  CardMedia,
  CardContent,
} from '@mui/material';
import Add from '@mui/icons-material/Add';
import Edit from '@mui/icons-material/Edit';
import Delete from '@mui/icons-material/Delete';
import Image from '@mui/icons-material/Image';
import toast from 'react-hot-toast';

const BannersPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editingBanner, setEditingBanner] = useState<any>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [deletingId, setDeletingId] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    title: '',
    subtitle: '',
    imageUrl: '',
    linkUrl: '',
    displayOrder: 0,
    isActive: true,
    startDate: '',
    endDate: '',
  });

  const { data, isLoading } = useQuery({
    queryKey: ['banners'],
    queryFn: () => adminService.getBanners(),
  });

  const banners = data?.items || [];

  const createMutation = useMutation({
    mutationFn: (data: any) => adminService.createBanner(data),
    onSuccess: () => {
      toast.success('Banner created successfully');
      queryClient.invalidateQueries({ queryKey: ['banners'] });
      setDialogOpen(false);
      resetForm();
    },
    onError: () => {
      toast.error('Failed to create banner');
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) => adminService.updateBanner(id, data),
    onSuccess: () => {
      toast.success('Banner updated successfully');
      queryClient.invalidateQueries({ queryKey: ['banners'] });
      setDialogOpen(false);
      resetForm();
    },
    onError: () => {
      toast.error('Failed to update banner');
    },
  });

  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminService.deleteBanner(id),
    onSuccess: () => {
      toast.success('Banner deleted successfully');
      queryClient.invalidateQueries({ queryKey: ['banners'] });
      setDeleteDialogOpen(false);
      setDeletingId(null);
    },
    onError: () => {
      toast.error('Failed to delete banner');
    },
  });

  const toggleActiveMutation = useMutation({
    mutationFn: ({ id, isActive }: { id: string; isActive: boolean }) =>
      adminService.updateBanner(id, { isActive }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['banners'] });
    },
  });

  const resetForm = () => {
    setFormData({
      title: '',
      subtitle: '',
      imageUrl: '',
      linkUrl: '',
      displayOrder: 0,
      isActive: true,
      startDate: '',
      endDate: '',
    });
    setEditingBanner(null);
  };

  const handleOpenDialog = (banner?: any) => {
    if (banner) {
      setEditingBanner(banner);
      setFormData({
        title: banner.title || '',
        subtitle: banner.subtitle || '',
        imageUrl: banner.imageUrl || '',
        linkUrl: banner.linkUrl || '',
        displayOrder: banner.displayOrder || 0,
        isActive: banner.isActive ?? true,
        startDate: banner.startDate ? banner.startDate.split('T')[0] : '',
        endDate: banner.endDate ? banner.endDate.split('T')[0] : '',
      });
    } else {
      resetForm();
    }
    setDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setDialogOpen(false);
    resetForm();
  };

  const handleSubmit = () => {
    if (editingBanner) {
      updateMutation.mutate({ id: editingBanner.id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const handleDelete = (id: string) => {
    setDeletingId(id);
    setDeleteDialogOpen(true);
  };

  const confirmDelete = () => {
    if (deletingId) {
      deleteMutation.mutate(deletingId);
    }
  };

  const handleToggleActive = (banner: any) => {
    toggleActiveMutation.mutate({ id: banner.id, isActive: !banner.isActive });
  };

  return (
    <Box>
      <PageHeader
        title="Banner Management"
        action={{
          label: 'Add Banner',
          onClick: () => handleOpenDialog(),
          icon: <Add />,
        }}
      />

      {isLoading ? (
        <Typography>Loading banners...</Typography>
      ) : (
        <Grid container spacing={3}>
          {banners.map((banner: any) => (
            <Grid item xs={12} sm={6} md={4} key={banner.id}>
              <Card>
                {banner.imageUrl ? (
                  <CardMedia
                    component="img"
                    height="160"
                    image={banner.imageUrl}
                    alt={banner.title}
                  />
                ) : (
                  <Box
                    sx={{
                      height: 160,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      bgcolor: 'grey.200',
                    }}
                  >
                    <Image sx={{ fontSize: 48, color: 'grey.400' }} />
                  </Box>
                )}
                <CardContent>
                  <Typography variant="h6" gutterBottom>
                    {banner.title}
                  </Typography>
                  {banner.subtitle && (
                    <Typography variant="body2" color="text.secondary" gutterBottom>
                      {banner.subtitle}
                    </Typography>
                  )}
                  <Typography variant="caption" display="block" gutterBottom>
                    Display Order: {banner.displayOrder}
                  </Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 1 }}>
                    <Typography variant="caption">Status:</Typography>
                    <StatusChip status={banner.isActive ? 'active' : 'inactive'} />
                  </Box>
                  <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
                    <Tooltip title="Edit">
                      <IconButton
                        size="small"
                        color="primary"
                        onClick={() => handleOpenDialog(banner)}
                      >
                        <Edit />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title={banner.isActive ? 'Deactivate' : 'Activate'}>
                      <IconButton
                        size="small"
                        color={banner.isActive ? 'warning' : 'success'}
                        onClick={() => handleToggleActive(banner)}
                      >
                        <Switch checked={banner.isActive} size="small" />
                      </IconButton>
                    </Tooltip>
                    <Tooltip title="Delete">
                      <IconButton
                        size="small"
                        color="error"
                        onClick={() => handleDelete(banner.id)}
                      >
                        <Delete />
                      </IconButton>
                    </Tooltip>
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      )}

      <Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="sm" fullWidth>
        <DialogTitle>{editingBanner ? 'Edit Banner' : 'Add Banner'}</DialogTitle>
        <DialogContent>
          <Grid container spacing={2} sx={{ mt: 1 }}>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Title"
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Subtitle"
                value={formData.subtitle}
                onChange={(e) => setFormData({ ...formData, subtitle: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Image URL"
                value={formData.imageUrl}
                onChange={(e) => setFormData({ ...formData, imageUrl: e.target.value })}
              />
            </Grid>
            <Grid item xs={12}>
              <TextField
                fullWidth
                label="Link URL"
                value={formData.linkUrl}
                onChange={(e) => setFormData({ ...formData, linkUrl: e.target.value })}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Display Order"
                type="number"
                value={formData.displayOrder}
                onChange={(e) =>
                  setFormData({ ...formData, displayOrder: parseInt(e.target.value) || 0 })
                }
              />
            </Grid>
            <Grid item xs={6}>
              <FormControlLabel
                control={
                  <Switch
                    checked={formData.isActive}
                    onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                  />
                }
                label="Active"
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="Start Date"
                type="date"
                value={formData.startDate}
                onChange={(e) => setFormData({ ...formData, startDate: e.target.value })}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
            <Grid item xs={6}>
              <TextField
                fullWidth
                label="End Date"
                type="date"
                value={formData.endDate}
                onChange={(e) => setFormData({ ...formData, endDate: e.target.value })}
                InputLabelProps={{ shrink: true }}
              />
            </Grid>
          </Grid>
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseDialog}>Cancel</Button>
          <Button
            onClick={handleSubmit}
            variant="contained"
            disabled={createMutation.isPending || updateMutation.isPending}
          >
            {editingBanner ? 'Update' : 'Create'}
          </Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={deleteDialogOpen}
        title="Delete Banner"
        message="Are you sure you want to delete this banner?"
        onConfirm={confirmDelete}
        onCancel={() => {
          setDeleteDialogOpen(false);
          setDeletingId(null);
        }}
      />
    </Box>
  );
};

export default BannersPage;
