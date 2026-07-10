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
  TextField,
} from '@mui/material';
import { CheckCircle as CheckCircleIcon, Feedback as FeedbackIcon } from '@mui/icons-material';
import toast from 'react-hot-toast';

const statusOptions = [
  { value: 'PENDING', label: 'Pending' },
  { value: 'IN_PROGRESS', label: 'In Progress' },
  { value: 'RESOLVED', label: 'Resolved' },
  { value: 'CLOSED', label: 'Closed' },
];

export default function OrderIssuesPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [limit] = useState(10);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [resolveDialogOpen, setResolveDialogOpen] = useState(false);
  const [selectedIssue, setSelectedIssue] = useState<any>(null);
  const [resolution, setResolution] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['orderIssues', { page, limit, search, status }],
    queryFn: () => adminService.getOrderIssues({ page, limit, search, status }),
  });

  const resolveMutation = useMutation({
    mutationFn: ({ id, resolution }: { id: string; resolution: string }) =>
      adminService.resolveIssue(id, resolution),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['orderIssues'] });
      toast.success('Issue resolved successfully');
      setResolveDialogOpen(false);
      setResolution('');
    },
    onError: () => {
      toast.error('Failed to resolve issue');
    },
  });

  const handleResolve = (issue: any) => {
    setSelectedIssue(issue);
    setResolution('');
    setResolveDialogOpen(true);
  };

  const confirmResolve = () => {
    if (selectedIssue && resolution.trim()) {
      resolveMutation.mutate({ id: selectedIssue.id, resolution: resolution.trim() });
    }
  };

  const columns = [
    { key: 'id', label: 'Issue ID', width: 100 },
    { key: 'orderId', label: 'Order ID', width: 100 },
    { key: 'customerName', label: 'Customer', width: 150 },
    { key: 'type', label: 'Type', width: 120 },
    {
      key: 'description',
      label: 'Description',
      width: 200,
      render: (row: any) => (
        <Tooltip title={row.description}>
          <Typography variant="body2" noWrap>
            {row.description.length > 50
              ? `${row.description.substring(0, 50)}...`
              : row.description}
          </Typography>
        </Tooltip>
      ),
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
      render: (row: any) => new Date(row.createdAt).toLocaleDateString(),
    },
    {
      key: 'actions',
      label: 'Actions',
      width: 120,
      render: (row: any) => (
        <Box sx={{ display: 'flex', gap: 1 }}>
          {row.status === 'PENDING' && (
            <Tooltip title="Resolve">
              <IconButton
                size="small"
                color="success"
                onClick={() => handleResolve(row)}
              >
                <CheckCircleIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          <Tooltip title="View Details">
            <IconButton size="small">
              <FeedbackIcon fontSize="small" />
            </IconButton>
          </Tooltip>
        </Box>
      ),
    },
  ];

  return (
    <Box sx={{ p: 3 }}>
      <PageHeader title="Order Issues & Support" />
      <SearchFilter
        searchValue={search}
        onSearchChange={setSearch}
        searchPlaceholder="Search by order ID or customer name..."
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

      <Dialog open={resolveDialogOpen} onClose={() => setResolveDialogOpen(false)}>
        <DialogTitle>Resolve Issue</DialogTitle>
        <DialogContent>
          <Typography gutterBottom>
            Please provide a resolution for this issue:
          </Typography>
          <TextField
            fullWidth
            multiline
            rows={4}
            value={resolution}
            onChange={(e) => setResolution(e.target.value)}
            placeholder="Enter resolution details..."
            sx={{ mt: 2 }}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setResolveDialogOpen(false)}>Cancel</Button>
          <Button
            onClick={confirmResolve}
            variant="contained"
            disabled={!resolution.trim() || resolveMutation.isPending}
          >
            {resolveMutation.isPending ? 'Resolving...' : 'Resolve'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
