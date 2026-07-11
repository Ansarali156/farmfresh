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
  Rating,
  IconButton,
  Tooltip,
} from '@mui/material';
import {
  CheckCircle as CheckCircleIcon,
  Cancel as CancelIcon,
  Flag as FlagIcon,
} from '@mui/icons-material';
import toast from 'react-hot-toast';

const statusOptions = [
  { value: 'PENDING', label: 'Pending' },
  { value: 'APPROVED', label: 'Approved' },
  { value: 'REJECTED', label: 'Rejected' },
  { value: 'FLAGGED', label: 'Flagged' },
];

export default function ReviewsPage() {
  const queryClient = useQueryClient();
  const [page, setPage] = useState(1);
  const [limit] = useState(10);
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [confirmDialogOpen, setConfirmDialogOpen] = useState(false);
  const [selectedReview, setSelectedReview] = useState<any>(null);
  const [actionType, setActionType] = useState<'REJECTED' | 'FLAGGED'>('REJECTED');

  const { data, isLoading } = useQuery({
    queryKey: ['reviews', { page, limit, search, status }],
    queryFn: () => adminService.getReviews({ page, limit, search, status }),
  });

  const moderateMutation = useMutation({
    mutationFn: ({ id, status }: { id: string; status: string }) =>
      adminService.moderateReview(id, status as 'approve' | 'reject' | 'flag'),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['reviews'] });
      toast.success('Review status updated successfully');
      setConfirmDialogOpen(false);
    },
    onError: () => {
      toast.error('Failed to update review status');
    },
  });

  const handleApprove = (review: any) => {
    moderateMutation.mutate({ id: review.id, status: 'APPROVED' });
  };

  const handleReject = (review: any) => {
    setSelectedReview(review);
    setActionType('REJECTED');
    setConfirmDialogOpen(true);
  };

  const handleFlag = (review: any) => {
    setSelectedReview(review);
    setActionType('FLAGGED');
    setConfirmDialogOpen(true);
  };

  const confirmAction = () => {
    if (selectedReview) {
      moderateMutation.mutate({ id: selectedReview.id, status: actionType });
    }
  };

  const columns = [
    {
      key: 'customerName',
      label: 'Customer',
      width: 150,
    },
    {
      key: 'productName',
      label: 'Product',
      width: 150,
    },
    {
      key: 'rating',
      label: 'Rating',
      width: 150,
      render: (row: any) => (
        <Rating value={row.rating} readOnly size="small" />
      ),
    },
    {
      key: 'comment',
      label: 'Comment',
      width: 200,
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
      label: 'Date',
      width: 120,
      render: (row: any) => new Date(row.createdAt).toLocaleDateString(),
    },
    {
      key: 'actions',
      label: 'Actions',
      width: 150,
      render: (row: any) => (
        <Box sx={{ display: 'flex', gap: 1 }}>
          {row.status === 'PENDING' && (
            <Tooltip title="Approve">
              <IconButton
                size="small"
                color="success"
                onClick={() => handleApprove(row)}
              >
                <CheckCircleIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          {row.status === 'PENDING' && (
            <Tooltip title="Reject">
              <IconButton
                size="small"
                color="error"
                onClick={() => handleReject(row)}
              >
                <CancelIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          {row.status !== 'FLAGGED' && (
            <Tooltip title="Flag">
              <IconButton
                size="small"
                color="warning"
                onClick={() => handleFlag(row)}
              >
                <FlagIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
        </Box>
      ),
    },
  ];

  return (
    <Box sx={{ p: 3 }}>
      <PageHeader title="Review Management" />
      <SearchFilter
        searchValue={search}
        onSearchChange={setSearch}
        searchPlaceholder="Search by customer or product name..."
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

      <ConfirmDialog
        open={confirmDialogOpen}
        title={`Confirm ${actionType === 'REJECTED' ? 'Rejection' : 'Flagging'}`}
        message={`Are you sure you want to ${actionType === 'REJECTED' ? 'reject' : 'flag'} this review?`}
        onConfirm={confirmAction}
        onCancel={() => setConfirmDialogOpen(false)}
        loading={moderateMutation.isPending}
      />
    </Box>
  );
}
