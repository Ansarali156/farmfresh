import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
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
  Drawer,
  List,
  ListItem,
  ListItemText,
  Divider,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
} from '@mui/material';
import InfoIcon from '@mui/icons-material/Info';
import CancelIcon from '@mui/icons-material/Cancel';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import { format } from 'date-fns';

const ORDER_STATUSES = [
  'PENDING',
  'CONFIRMED',
  'PREPARING',
  'READY_FOR_PICKUP',
  'OUT_FOR_DELIVERY',
  'DELIVERED',
  'CANCELLED',
];

function formatCurrency(amount: number): string {
  return `₹${amount.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

function formatDate(dateStr: string): string {
  return format(new Date(dateStr), 'dd MMM yyyy, hh:mm a');
}

export default function OrdersPage() {
  const queryClient = useQueryClient();

  const [page, setPage] = useState(1);
  const [limit] = useState(10);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [selectedOrder, setSelectedOrder] = useState<any>(null);
  const [detailDrawerOpen, setDetailDrawerOpen] = useState(false);
  const [updateStatusDialogOpen, setUpdateStatusDialogOpen] = useState(false);
  const [newStatus, setNewStatus] = useState('');
  const [cancelDialogOpen, setCancelDialogOpen] = useState(false);

  const { data, isLoading } = useQuery({
    queryKey: ['orders', { page, limit, search, status: statusFilter }],
    queryFn: () =>
      adminService.getOrders({ page, limit, search, status: statusFilter }),
  });

  const updateStatusMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminService.updateOrderStatus(id, status),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      setUpdateStatusDialogOpen(false);
      setNewStatus('');
      setSelectedOrder(null);
    },
  });

  const cancelOrderMutation = useMutation({
    mutationFn: (id: string) => adminService.cancelOrder(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orders'] });
      setCancelDialogOpen(false);
      setSelectedOrder(null);
    },
  });

  const handleViewDetail = (order: any) => {
    setSelectedOrder(order);
    setDetailDrawerOpen(true);
  };

  const handleUpdateStatus = (order: any) => {
    setSelectedOrder(order);
    setNewStatus(order.status);
    setUpdateStatusDialogOpen(true);
  };

  const handleCancelOrder = (order: any) => {
    setSelectedOrder(order);
    setCancelDialogOpen(true);
  };

  const handleConfirmUpdateStatus = () => {
    if (selectedOrder && newStatus) {
      updateStatusMutation.mutate({ id: selectedOrder.id, status: newStatus });
    }
  };

  const handleConfirmCancel = () => {
    if (selectedOrder) {
      cancelOrderMutation.mutate(selectedOrder.id);
    }
  };

  const columns = [
    {
      key: 'orderNumber',
      label: 'Order ID',
      render: (row: any) => (
        <Typography variant="body2" sx={{ fontWeight: 600 }}>
          {row.orderNumber}
        </Typography>
      ),
    },
    {
      key: 'customer.name',
      label: 'Customer',
      render: (row: any) => (
        <Box>
          <Typography variant="body2">{row.customer.name}</Typography>
          <Typography variant="caption" color="text.secondary">
            {row.customer.email}
          </Typography>
        </Box>
      ),
    },
    {
      key: 'itemCount',
      label: 'Items',
      render: (row: any) => <Typography variant="body2">{row.itemCount}</Typography>,
    },
    {
      key: 'total',
      label: 'Total (₹)',
      render: (row: any) => (
        <Typography variant="body2" sx={{ fontWeight: 600 }}>
          {formatCurrency(row.total)}
        </Typography>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (row: any) => (
        <StatusChip status={row.status} />
      ),
    },
    {
      key: 'paymentStatus',
      label: 'Payment',
      render: (row: any) => (
        <StatusChip status={row.paymentStatus} />
      ),
    },
    {
      key: 'createdAt',
      label: 'Date',
      render: (row: any) => (
        <Typography variant="body2">{formatDate(row.createdAt)}</Typography>
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (row: any) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title="View Details">
            <IconButton size="small" onClick={() => handleViewDetail(row)}>
              <InfoIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Update Status">
            <IconButton size="small" onClick={() => handleUpdateStatus(row)}>
              <LocalShippingIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          <Tooltip title="Cancel Order">
            <IconButton
              size="small"
              color="error"
              onClick={() => handleCancelOrder(row)}
              disabled={row.status === 'DELIVERED' || row.status === 'CANCELLED'}
            >
              <CancelIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  const availableStatuses = selectedOrder
    ? ORDER_STATUSES.filter((s) => {
        const flow: Record<string, string[]> = {
          PENDING: ['CONFIRMED', 'CANCELLED'],
          CONFIRMED: ['PREPARING', 'CANCELLED'],
          PREPARING: ['READY_FOR_PICKUP'],
          READY_FOR_PICKUP: ['OUT_FOR_DELIVERY'],
          OUT_FOR_DELIVERY: ['DELIVERED'],
          DELIVERED: [],
          CANCELLED: [],
        };
        return flow[selectedOrder.status]?.includes(s);
      })
    : ORDER_STATUSES;

  return (
    <Box>
      <PageHeader title="Order Management" />

      <SearchFilter
        searchPlaceholder="Search by Order ID or Customer Name..."
        searchValue={search}
        onSearchChange={setSearch}
        filters={[
          {
            key: 'status',
            label: 'Status',
            value: statusFilter,
            options: ORDER_STATUSES.map((s) => ({ label: s.replace(/_/g, ' '), value: s })),
          },
        ]}
        onFilterChange={(key: string, value: string) => {
          if (key === 'status') {
            setStatusFilter(value);
            setPage(1);
          }
        }}
      />

      <DataTable
        columns={columns}
        data={data?.items || []}
        loading={isLoading}
        page={page}
        rowsPerPage={limit}
        total={data?.total || 0}
        onPageChange={setPage}
      />

      <Drawer
        anchor="right"
        open={detailDrawerOpen}
        onClose={() => setDetailDrawerOpen(false)}
        PaperProps={{ sx: { width: 400 } }}
      >
        {selectedOrder && (
          <Box sx={{ p: 3 }}>
            <Typography variant="h6" sx={{ mb: 2 }}>
              Order {selectedOrder.orderNumber}
            </Typography>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Customer
            </Typography>
            <Typography variant="body2">{selectedOrder.customer.name}</Typography>
            <Typography variant="body2" color="text.secondary">
              {selectedOrder.customer.email}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {selectedOrder.customer.phone}
            </Typography>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Items
            </Typography>
            <TableContainer component={Paper} variant="outlined">
              <Table size="small">
                <TableHead>
                  <TableRow>
                    <TableCell>Item</TableCell>
                    <TableCell align="right">Qty</TableCell>
                    <TableCell align="right">Price</TableCell>
                    <TableCell align="right">Total</TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {selectedOrder.items.map((item: any) => (
                    <TableRow key={item.id}>
                      <TableCell>
                        <Typography variant="body2">{item.name}</Typography>
                        <Typography variant="caption" color="text.secondary">
                          {item.unit}
                        </Typography>
                      </TableCell>
                      <TableCell align="right">{item.quantity}</TableCell>
                      <TableCell align="right">{formatCurrency(item.price)}</TableCell>
                      <TableCell align="right">{formatCurrency(item.total)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>

            <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between' }}>
              <Typography variant="subtitle2">Total</Typography>
              <Typography variant="h6" sx={{ fontWeight: 700 }}>
                {formatCurrency(selectedOrder.total)}
              </Typography>
            </Box>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Shipping Address
            </Typography>
            <Typography variant="body2">
              {selectedOrder.shippingAddress.street}
            </Typography>
            <Typography variant="body2">
              {selectedOrder.shippingAddress.city}, {selectedOrder.shippingAddress.state}{' '}
              {selectedOrder.shippingAddress.zipCode}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Phone: {selectedOrder.shippingAddress.phone}
            </Typography>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Status Timeline
            </Typography>
            <List dense>
              {selectedOrder.statusHistory?.map((entry: any, index: number) => (
                <ListItem key={index} sx={{ px: 0 }}>
                  <ListItemText
                    primary={
                      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <StatusChip
                          status={entry.status.replace(/_/g, ' ')}
                        />
                        <Typography variant="caption" color="text.secondary">
                          {formatDate(entry.timestamp)}
                        </Typography>
                      </Box>
                    }
                    secondary={entry.note}
                  />
                </ListItem>
              ))}
            </List>

            <Divider sx={{ my: 2 }} />

            <Box sx={{ display: 'flex', gap: 1 }}>
              <Button
                variant="outlined"
                color="error"
                fullWidth
                startIcon={<CancelIcon />}
                onClick={() => {
                  setDetailDrawerOpen(false);
                  handleCancelOrder(selectedOrder);
                }}
                disabled={
                  selectedOrder.status === 'DELIVERED' || selectedOrder.status === 'CANCELLED'
                }
              >
                Cancel Order
              </Button>
            </Box>
          </Box>
        )}
      </Drawer>

      <Dialog
        open={updateStatusDialogOpen}
        onClose={() => setUpdateStatusDialogOpen(false)}
        maxWidth="xs"
        fullWidth
      >
        <DialogTitle>Update Order Status</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            Current Status: <strong>{selectedOrder?.status.replace(/_/g, ' ')}</strong>
          </Typography>
          <TextField
            select
            fullWidth
            label="New Status"
            value={newStatus}
            onChange={(e) => setNewStatus(e.target.value)}
            SelectProps={{ native: true }}
            sx={{ mt: 1 }}
          >
            <option value="">Select Status</option>
            {availableStatuses.map((s) => (
              <option key={s} value={s}>
                {s.replace(/_/g, ' ')}
              </option>
            ))}
          </TextField>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setUpdateStatusDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            onClick={handleConfirmUpdateStatus}
            disabled={!newStatus || newStatus === selectedOrder?.status || updateStatusMutation.isPending}
          >
            {updateStatusMutation.isPending ? 'Updating...' : 'Update Status'}
          </Button>
        </DialogActions>
      </Dialog>

      <ConfirmDialog
        open={cancelDialogOpen}
        title="Cancel Order"
        message={`Are you sure you want to cancel order ${selectedOrder?.orderNumber}? This action cannot be undone.`}
        confirmText="Cancel Order"
        severity="error"
        onConfirm={handleConfirmCancel}
        onCancel={() => setCancelDialogOpen(false)}
        loading={cancelOrderMutation.isPending}
      />
    </Box>
  );
}
