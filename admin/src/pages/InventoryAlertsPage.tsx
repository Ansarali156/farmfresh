import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Box, Typography, IconButton, Tooltip, Dialog, DialogTitle, DialogContent, DialogActions, Button, TextField, Tabs, Tab } from '@mui/material';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import RefreshIcon from '@mui/icons-material/Refresh';
import AddIcon from '@mui/icons-material/Add';
import RemoveIcon from '@mui/icons-material/Remove';
import EditIcon from '@mui/icons-material/Edit';
import toast from 'react-hot-toast';
import { adminService } from '../services/admin.service';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
import StatusChip from '../components/StatusChip';
import PageHeader from '../components/PageHeader';
import type { InventoryItem } from '../types';

export default function InventoryAlertsPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState(0);
  const [page, setPage] = useState(0);
  const [limit, setLimit] = useState(10);
  const [search, setSearch] = useState('');
  const [adjustItem, setAdjustItem] = useState<InventoryItem | null>(null);
  const [adjustQuantity, setAdjustQuantity] = useState('');

  const { data: inventoryData, isLoading: inventoryLoading } = useQuery({
    queryKey: ['inventory', { page: page + 1, limit, search }],
    queryFn: () => adminService.getInventory({ page: page + 1, limit, search }),
    enabled: activeTab === 0,
  });

  const { data: lowStockData, isLoading: lowStockLoading } = useQuery({
    queryKey: ['inventory-low-stock'],
    queryFn: () => adminService.getLowStock(),
    enabled: activeTab === 1,
  });

  const adjustMutation = useMutation({
    mutationFn: ({ id, quantity }: { id: string; quantity: number }) =>
      adminService.adjustStock(id, quantity),
    onSuccess: () => {
      toast.success('Stock adjusted successfully');
      queryClient.invalidateQueries({ queryKey: ['inventory'] });
      queryClient.invalidateQueries({ queryKey: ['inventory-low-stock'] });
      closeAdjustDialog();
    },
    onError: (err: any) => toast.error(err?.response?.data?.message || 'Failed to adjust stock'),
  });

  const closeAdjustDialog = () => {
    setAdjustItem(null);
    setAdjustQuantity('');
  };

  const handleAdjust = () => {
    if (!adjustItem || !adjustQuantity) return;
    const qty = Number(adjustQuantity);
    if (qty === 0 || isNaN(qty)) {
      toast.error('Enter a valid quantity');
      return;
    }
    adjustMutation.mutate({ id: adjustItem.id, quantity: qty });
  };

  const inventory = inventoryData?.items || [];
  const inventoryTotal = inventoryData?.total || 0;
  const lowStock = lowStockData || [];

  const inventoryColumns = [
    {
      key: 'productName',
      label: 'Product',
      render: (item: InventoryItem) => (
        <Typography fontWeight={600}>{item.productName || item.productId}</Typography>
      ),
    },
    { key: 'farmerName', label: 'Farmer', render: (item: InventoryItem) => item.farmerName || item.farmerId },
    {
      key: 'currentStock',
      label: 'Current Stock',
      render: (item: InventoryItem) => (
        <Typography fontWeight={600} color={item.currentStock <= item.reorderLevel ? 'error.main' : 'text.primary'}>
          {item.currentStock} {item.unit}
        </Typography>
      ),
    },
    {
      key: 'minStock',
      label: 'Min Stock',
      render: (item: InventoryItem) => `${item.minStock} ${item.unit}`,
    },
    {
      key: 'maxStock',
      label: 'Max Stock',
      render: (item: InventoryItem) => `${item.maxStock} ${item.unit}`,
    },
    {
      key: 'reorderLevel',
      label: 'Reorder Level',
      render: (item: InventoryItem) => `${item.reorderLevel} ${item.unit}`,
    },
    { key: 'unit', label: 'Unit' },
    {
      key: 'status',
      label: 'Status',
      render: (item: InventoryItem) => <StatusChip status={item.status} label={item.status.replace(/_/g, ' ')} />,
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: InventoryItem) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title="Adjust Stock">
            <IconButton size="small" onClick={() => setAdjustItem(item)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const lowStockColumns = [
    {
      key: 'productName',
      label: 'Product',
      render: (item: InventoryItem) => (
        <Typography fontWeight={600}>{item.productName || item.productId}</Typography>
      ),
    },
    { key: 'farmerName', label: 'Farmer', render: (item: InventoryItem) => item.farmerName || item.farmerId },
    {
      key: 'currentStock',
      label: 'Current Stock',
      render: (item: InventoryItem) => (
        <Typography fontWeight={600} color="error.main">
          {item.currentStock} {item.unit}
        </Typography>
      ),
    },
    {
      key: 'reorderLevel',
      label: 'Reorder Level',
      render: (item: InventoryItem) => `${item.reorderLevel} ${item.unit}`,
    },
    {
      key: 'severity',
      label: 'Severity',
      render: (item: InventoryItem) => {
        const severity = item.currentStock === 0 ? 'CRITICAL' : item.currentStock <= item.reorderLevel * 0.5 ? 'HIGH' : 'LOW';
        return <StatusChip status={severity} />;
      },
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (item: InventoryItem) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title="Adjust Stock">
            <IconButton size="small" onClick={() => setAdjustItem(item)}>
              <EditIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  return (
    <Box>
      <PageHeader
        title="Inventory Monitoring"
        action={{
          label: 'Refresh',
          onClick: () => {
            queryClient.invalidateQueries({ queryKey: ['inventory'] });
            queryClient.invalidateQueries({ queryKey: ['inventory-low-stock'] });
          },
          icon: <RefreshIcon />,
          color: 'primary',
        }}
      />

      {lowStockData && lowStockData.length > 0 && activeTab === 0 && (
        <Box
          sx={{
            display: 'flex',
            alignItems: 'center',
            gap: 1,
            mb: 2,
            p: 2,
            borderRadius: 2,
            bgcolor: 'warning.light',
            color: 'warning.contrastText',
          }}
        >
          <WarningAmberIcon />
          <Typography fontWeight={600}>
            {lowStockData.length} product(s) are running low on stock!
          </Typography>
        </Box>
      )}

      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs
          value={activeTab}
          onChange={(_, v) => {
            setActiveTab(v);
            setPage(0);
            setSearch('');
          }}
        >
          <Tab label="All Inventory" />
          <Tab
            label={
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                Low Stock Alerts
                {lowStockData && lowStockData.length > 0 && (
                  <Box
                    sx={{
                      bgcolor: 'error.main',
                      color: '#fff',
                      borderRadius: 1,
                      px: 0.8,
                      py: 0.1,
                      fontSize: 11,
                      fontWeight: 700,
                      lineHeight: '18px',
                    }}
                  >
                    {lowStockData.length}
                  </Box>
                )}
              </Box>
            }
          />
        </Tabs>
      </Box>

      {activeTab === 0 && (
        <>
          <SearchFilter
            searchValue={search}
            searchPlaceholder="Search inventory..."
            onSearchChange={(v) => { setSearch(v); setPage(0); }}
          />
          <DataTable
            columns={inventoryColumns}
            data={inventory}
            total={inventoryTotal}
            page={page}
            rowsPerPage={limit}
            onPageChange={setPage}
            onRowsPerPageChange={(v) => { setLimit(v); setPage(0); }}
            loading={inventoryLoading}
            emptyMessage="No inventory items found"
            keyExtractor={(item) => item.id}
          />
        </>
      )}

      {activeTab === 1 && (
        <DataTable
          columns={lowStockColumns}
          data={lowStock}
          total={lowStock.length}
          loading={lowStockLoading}
          emptyMessage="No low stock alerts. All products are well stocked!"
          keyExtractor={(item) => item.id}
        />
      )}

      <Dialog open={!!adjustItem} onClose={closeAdjustDialog} maxWidth="xs" fullWidth>
        <DialogTitle fontWeight={600}>Adjust Stock</DialogTitle>
        <DialogContent>
          {adjustItem && (
            <Box sx={{ mb: 2 }}>
              <Typography variant="body2" color="text.secondary">
                Product: <strong>{adjustItem.productName || adjustItem.productId}</strong>
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Current Stock: <strong>{adjustItem.currentStock} {adjustItem.unit}</strong>
              </Typography>
            </Box>
          )}
          <TextField
            fullWidth
            label="Adjustment Quantity"
            type="number"
            value={adjustQuantity}
            onChange={(e) => setAdjustQuantity(e.target.value)}
            placeholder="Use negative to decrease, positive to increase"
            helperText="Positive values add stock, negative values remove stock"
          />
          <Box sx={{ display: 'flex', gap: 1, mt: 2 }}>
            <Button
              variant="outlined"
              size="small"
              startIcon={<RemoveIcon />}
              onClick={() => {
                const curr = Number(adjustQuantity) || 0;
                setAdjustQuantity(String(curr - 1));
              }}
            >
              -1
            </Button>
            <Button
              variant="outlined"
              size="small"
              startIcon={<AddIcon />}
              onClick={() => {
                const curr = Number(adjustQuantity) || 0;
                setAdjustQuantity(String(curr + 1));
              }}
            >
              +1
            </Button>
          </Box>
        </DialogContent>
        <DialogActions sx={{ px: 3, pb: 2 }}>
          <Button onClick={closeAdjustDialog}>Cancel</Button>
          <Button
            variant="contained"
            color="primary"
            onClick={handleAdjust}
            disabled={adjustMutation.isPending || !adjustQuantity}
          >
            {adjustMutation.isPending ? 'Adjusting...' : 'Adjust Stock'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
