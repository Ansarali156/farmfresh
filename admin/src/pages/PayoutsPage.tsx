import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
import StatusChip from '../components/StatusChip';
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
} from '@mui/material';
import { Payment as PaymentIcon, CheckCircle as CheckCircleIcon } from '@mui/icons-material';
import toast from 'react-hot-toast';
import { format } from 'date-fns';

const statusOptions = [
  { value: 'PENDING', label: 'Pending' },
  { value: 'PROCESSING', label: 'Processing' },
  { value: 'COMPLETED', label: 'Completed' },
  { value: 'FAILED', label: 'Failed' },
];

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    minimumFractionDigits: 0,
    maximumFractionDigits: 0,
  }).format(amount);
};

export default function PayoutsPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [limit] = useState(10);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [processDialogOpen, setProcessDialogOpen] = useState(false);
  const [selectedPayout, setSelectedPayout] = useState<any>(null);

  const { data, isLoading } = useQuery({
    queryKey: ['payouts', { page, limit, search, status }],
    queryFn: () => adminService.getPayouts({ page, limit, search, status }),
  });

  const processMutation = useMutation({
    mutationFn: (id: string) => adminService.processPayout(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['payouts'] });
      toast.success('Payout processed successfully');
      setProcessDialogOpen(false);
    },
    onError: () => {
      toast.error('Failed to process payout');
    },
  });

  const handleProcessPayment = (payout: any) => {
    setSelectedPayout(payout);
    setProcessDialogOpen(true);
  };

  const confirmProcessPayment = () => {
    if (selectedPayout) {
      processMutation.mutate(selectedPayout.id);
    }
  };

  const columns = [
    { key: 'id', label: 'ID', width: 100 },
    { key: 'farmerName', label: 'Farmer Name', width: 150 },
    {
      key: 'amount',
      label: 'Amount',
      width: 120,
      render: (row: any) => formatCurrency(row.amount),
    },
    {
      key: 'period',
      label: 'Period',
      width: 150,
      render: (row: any) => `${format(new Date(row.periodStart), 'MMM dd')} - ${format(new Date(row.periodEnd), 'MMM dd, yyyy')}`,
    },
    {
      key: 'status',
      label: 'Status',
      width: 120,
      render: (row: any) => (
        <StatusChip status={row.status} />
      ),
    },
    {
      key: 'createdAt',
      label: 'Created',
      width: 150,
      render: (row: any) => format(new Date(row.createdAt), 'MMM dd, yyyy HH:mm'),
    },
    {
      key: 'actions',
      label: 'Actions',
      width: 120,
      render: (row: any) => (
        <Box sx={{ display: 'flex', gap: 1 }}>
          {row.status === 'PENDING' && (
            <Tooltip title="Process Payment">
              <IconButton
                size="small"
                color="primary"
                onClick={() => handleProcessPayment(row)}
              >
                <PaymentIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          <Tooltip title="View Details">
            <IconButton size="small">
              <CheckCircleIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  return (
    <Box sx={{ p: 3 }}>
      <PageHeader title="Payout Management" />
      <SearchFilter
        searchValue={search}
        onSearchChange={setSearch}
        searchPlaceholder="Search by farmer name..."
        filters={[{ key: 'status', label: 'Status', options: statusOptions, value: status }]}
        onFilterChange={(_, val) => setStatus(val)}
      />
      <DataTable
        columns={columns}
        data={data?.items || []}
        total={data?.total || 0}
        page={page}
        rowsPerPage={limit}
        onPageChange={setPage}
        loading={isLoading}
      />

      <Dialog open={processDialogOpen} onClose={() => setProcessDialogOpen(false)}>
        <DialogTitle>Confirm Payment Processing</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to process the payout of{' '}
            {selectedPayout && formatCurrency(selectedPayout.amount)} for{' '}
            {selectedPayout?.farmerName}?
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setProcessDialogOpen(false)}>Cancel</Button>
          <Button
            onClick={confirmProcessPayment}
            variant="contained"
            disabled={processMutation.isPending}
          >
            {processMutation.isPending ? 'Processing...' : 'Confirm'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
