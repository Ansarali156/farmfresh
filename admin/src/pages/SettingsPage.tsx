import { useState, useEffect } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { Box, Typography, Card, CardContent, TextField, Grid, Button, Divider, Tabs, Tab, Alert } from '@mui/material';
import SaveIcon from '@mui/icons-material/Save';
import toast from 'react-hot-toast';
import { adminService } from '../services/admin.service';
import PageHeader from '../components/PageHeader';
import type { PlatformSettings } from '../types';

export default function SettingsPage() {
  const [activeTab, setActiveTab] = useState(0);
  const [form, setForm] = useState<Partial<PlatformSettings>>({});

  const { data: settings, isLoading } = useQuery({
    queryKey: ['settings'],
    queryFn: () => adminService.getSettings(),
  });

  useEffect(() => {
    if (settings) {
      setForm(settings);
    }
  }, [settings]);

  const updateMutation = useMutation({
    mutationFn: (data: Partial<PlatformSettings>) => adminService.updateSettings(data),
    onSuccess: () => {
      toast.success('Settings saved successfully');
    },
    onError: (err: any) => toast.error(err?.response?.data?.message || 'Failed to save settings'),
  });

  const handleSaveGeneral = () => {
    updateMutation.mutate({
      marketplaceName: form.marketplaceName,
      marketplaceDescription: form.marketplaceDescription,
      supportEmail: form.supportEmail,
      supportPhone: form.supportPhone,
    });
  };

  const handleSaveFinancial = () => {
    updateMutation.mutate({
      commissionRate: Number(form.commissionRate),
      deliveryCharge: Number(form.deliveryCharge),
      freeDeliveryThreshold: Number(form.freeDeliveryThreshold),
      gstRate: Number(form.gstRate),
      platformFee: Number(form.platformFee),
      minOrderAmount: Number(form.minOrderAmount),
    });
  };

  const handleSaveSystem = () => {
    updateMutation.mutate({
      maxDeliveryDistance: Number(form.maxDeliveryDistance),
    });
  };

  const updateField = (key: keyof PlatformSettings, value: string) => {
    setForm((prev) => ({ ...prev, [key]: value }));
  };

  return (
    <Box>
      <PageHeader title="Platform Settings" />

      {updateMutation.isError && (
        <Alert severity="error" sx={{ mb: 2 }}>
          Failed to save settings. Please try again.
        </Alert>
      )}

      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs value={activeTab} onChange={(_, v) => setActiveTab(v)}>
          <Tab label="General" />
          <Tab label="Financial" />
          <Tab label="System" />
        </Tabs>
      </Box>

      {activeTab === 0 && (
        <Card>
          <CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>
              General Settings
            </Typography>
            <Typography variant="body2" color="text.secondary" mb={3}>
              Configure basic marketplace information and support contacts.
            </Typography>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Marketplace Name"
                  value={form.marketplaceName || ''}
                  onChange={(e) => updateField('marketplaceName', e.target.value)}
                  disabled={isLoading}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Support Email"
                  value={form.supportEmail || ''}
                  onChange={(e) => updateField('supportEmail', e.target.value)}
                  disabled={isLoading}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Support Phone"
                  value={form.supportPhone || ''}
                  onChange={(e) => updateField('supportPhone', e.target.value)}
                  disabled={isLoading}
                />
              </Grid>
              <Grid item xs={12}>
                <TextField
                  fullWidth
                  label="Marketplace Description"
                  value={form.marketplaceDescription || ''}
                  onChange={(e) => updateField('marketplaceDescription', e.target.value)}
                  multiline
                  rows={3}
                  disabled={isLoading}
                />
              </Grid>
            </Grid>
            <Divider sx={{ my: 3 }} />
            <Button
              variant="contained"
              color="success"
              startIcon={<SaveIcon />}
              onClick={handleSaveGeneral}
              disabled={updateMutation.isPending || isLoading}
            >
              {updateMutation.isPending ? 'Saving...' : 'Save General Settings'}
            </Button>
          </CardContent>
        </Card>
      )}

      {activeTab === 1 && (
        <Card>
          <CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>
              Financial Settings
            </Typography>
            <Typography variant="body2" color="text.secondary" mb={3}>
              Configure commission rates, delivery charges, and payment thresholds.
            </Typography>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Commission Rate (%)"
                  type="number"
                  value={form.commissionRate ?? ''}
                  onChange={(e) => updateField('commissionRate', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, max: 100, step: 0.1 }}
                  helperText="Percentage commission charged on each order"
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Delivery Charge (₹)"
                  type="number"
                  value={form.deliveryCharge ?? ''}
                  onChange={(e) => updateField('deliveryCharge', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, step: 1 }}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Free Delivery Threshold (₹)"
                  type="number"
                  value={form.freeDeliveryThreshold ?? ''}
                  onChange={(e) => updateField('freeDeliveryThreshold', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, step: 1 }}
                  helperText="Orders above this amount get free delivery"
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="GST Rate (%)"
                  type="number"
                  value={form.gstRate ?? ''}
                  onChange={(e) => updateField('gstRate', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, max: 100, step: 0.1 }}
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Platform Fee (₹)"
                  type="number"
                  value={form.platformFee ?? ''}
                  onChange={(e) => updateField('platformFee', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, step: 1 }}
                  helperText="Fixed platform fee per order"
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Minimum Order Amount (₹)"
                  type="number"
                  value={form.minOrderAmount ?? ''}
                  onChange={(e) => updateField('minOrderAmount', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, step: 1 }}
                />
              </Grid>
            </Grid>
            <Divider sx={{ my: 3 }} />
            <Button
              variant="contained"
              color="success"
              startIcon={<SaveIcon />}
              onClick={handleSaveFinancial}
              disabled={updateMutation.isPending || isLoading}
            >
              {updateMutation.isPending ? 'Saving...' : 'Save Financial Settings'}
            </Button>
          </CardContent>
        </Card>
      )}

      {activeTab === 2 && (
        <Card>
          <CardContent>
            <Typography variant="h6" fontWeight={600} mb={2}>
              System Settings
            </Typography>
            <Typography variant="body2" color="text.secondary" mb={3}>
              Configure delivery parameters and view system information.
            </Typography>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Max Delivery Distance (km)"
                  type="number"
                  value={form.maxDeliveryDistance ?? ''}
                  onChange={(e) => updateField('maxDeliveryDistance', e.target.value)}
                  disabled={isLoading}
                  inputProps={{ min: 0, step: 1 }}
                  helperText="Maximum distance for delivery operations"
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />

            <Typography variant="h6" fontWeight={600} mb={2}>
              Database Information
            </Typography>
            <Alert severity="info" sx={{ mb: 2 }}>
              Database configuration is managed through backend environment variables for security.
            </Alert>
            <Grid container spacing={3}>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Database Host"
                  value="postgres.railway.internal"
                  InputProps={{ readOnly: true }}
                  variant="filled"
                />
              </Grid>
              <Grid item xs={12} sm={6}>
                <TextField
                  fullWidth
                  label="Database Engine"
                  value="PostgreSQL"
                  InputProps={{ readOnly: true }}
                  variant="filled"
                />
              </Grid>
            </Grid>

            <Divider sx={{ my: 3 }} />
            <Button
              variant="contained"
              color="success"
              startIcon={<SaveIcon />}
              onClick={handleSaveSystem}
              disabled={updateMutation.isPending || isLoading}
            >
              {updateMutation.isPending ? 'Saving...' : 'Save System Settings'}
            </Button>
          </CardContent>
        </Card>
      )}
    </Box>
  );
}
