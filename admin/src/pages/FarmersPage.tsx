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
  Drawer,
  Grid,
  Divider,
  Avatar,
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import BlockIcon from '@mui/icons-material/Block';
import InfoIcon from '@mui/icons-material/Info';

const FARMER_STATUSES = ['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'];
const KYC_STATUSES = ['NOT_SUBMITTED', 'PENDING', 'VERIFIED', 'REJECTED'];

interface BankAccount {
  accountHolder: string;
  accountNumber: string;
  ifscCode: string;
  bankName: string;
}

interface FarmDetails {
  name: string;
  location: string;
  size: string;
  crops: string[];
  certifications: string[];
}

interface Farmer {
  id: string;
  name: string;
  email: string;
  phone: string;
  avatar?: string;
  farmName: string;
  productCount: number;
  status: string;
  kycStatus: string;
  createdAt: string;
  farmDetails: FarmDetails;
  bankAccount: BankAccount;
  address: string;
  totalOrders: number;
  totalRevenue: number;
}

function formatDate(dateStr: string): string {
  const date = new Date(dateStr);
  return date.toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function formatCurrency(amount: number): string {
  return `₹${amount.toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
}

export default function FarmersPage() {
  const queryClient = useQueryClient();

  const [page, setPage] = useState(1);
  const [limit] = useState(10);
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [kycFilter, setKycFilter] = useState('');
  const [selectedFarmer, setSelectedFarmer] = useState<Farmer | null>(null);
  const [detailDrawerOpen, setDetailDrawerOpen] = useState(false);
  const [rejectDialogOpen, setRejectDialogOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');
  const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
  const [suspendReason, setSuspendReason] = useState('');
  const [approveDialogOpen, setApproveDialogOpen] = useState(false);

  const { data, isLoading } = useQuery({
    queryKey: ['farmers', { page, limit, search, status: statusFilter, kycStatus: kycFilter }],
    queryFn: () =>
      adminService.getFarmers({ page, limit, search, status: statusFilter, kycStatus: kycFilter }),
  });

  const approveMutation = useMutation({
    mutationFn: (id: string) => adminService.approveFarmer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['farmers'] });
      setApproveDialogOpen(false);
      setSelectedFarmer(null);
      setDetailDrawerOpen(false);
    },
  });

  const rejectMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) =>
      adminService.rejectFarmer(id, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['farmers'] });
      setRejectDialogOpen(false);
      setRejectReason('');
      setSelectedFarmer(null);
      setDetailDrawerOpen(false);
    },
  });

  const suspendMutation = useMutation({
    mutationFn: ({ id, reason }: { id: string; reason: string }) =>
      adminService.suspendFarmer(id, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['farmers'] });
      setSuspendDialogOpen(false);
      setSuspendReason('');
      setSelectedFarmer(null);
      setDetailDrawerOpen(false);
    },
  });

  const handleViewDetail = (farmer: Farmer) => {
    setSelectedFarmer(farmer);
    setDetailDrawerOpen(true);
  };

  const handleApprove = (farmer: Farmer) => {
    setSelectedFarmer(farmer);
    setApproveDialogOpen(true);
  };

  const handleReject = (farmer: Farmer) => {
    setSelectedFarmer(farmer);
    setRejectReason('');
    setRejectDialogOpen(true);
  };

  const handleSuspend = (farmer: Farmer) => {
    setSelectedFarmer(farmer);
    setSuspendReason('');
    setSuspendDialogOpen(true);
  };

  const columns = [
    {
      key: 'name',
      label: 'Name',
      render: (row: Farmer) => (
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
          <Avatar src={row.avatar} sx={{ width: 32, height: 32 }}>
            {row.name.charAt(0).toUpperCase()}
          </Avatar>
          <Typography variant="body2" sx={{ fontWeight: 600 }}>
            {row.name}
          </Typography>
        </Box>
      ),
    },
    {
      key: 'farmName',
      label: 'Farm Name',
      render: (row: Farmer) => <Typography variant="body2">{row.farmName}</Typography>,
    },
    {
      key: 'email',
      label: 'Email',
      render: (row: Farmer) => (
        <Typography variant="body2" color="text.secondary">
          {row.email}
        </Typography>
      ),
    },
    {
      key: 'phone',
      label: 'Phone',
      render: (row: Farmer) => <Typography variant="body2">{row.phone}</Typography>,
    },
    {
      key: 'productCount',
      label: 'Products',
      render: (row: Farmer) => <Typography variant="body2">{row.productCount}</Typography>,
    },
    {
      key: 'status',
      label: 'Status',
      render: (row: Farmer) => (
        <StatusChip status={row.status} />
      ),
    },
    {
      key: 'kycStatus',
      label: 'KYC',
      render: (row: Farmer) => (
        <StatusChip status={row.kycStatus} />
      ),
    },
    {
      key: 'actions',
      label: 'Actions',
      render: (row: Farmer) => (
        <Box sx={{ display: 'flex', gap: 0.5 }}>
          <Tooltip title="View Details">
            <IconButton size="small" onClick={() => handleViewDetail(row)}>
              <InfoIcon fontSize="small" />
            </IconButton>
          </Tooltip>
          {row.status === 'PENDING' && (
            <Tooltip title="Approve">
              <IconButton size="small" color="success" onClick={() => handleApprove(row)}>
                <CheckCircleIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          {row.status === 'PENDING' && (
            <Tooltip title="Reject">
              <IconButton size="small" color="error" onClick={() => handleReject(row)}>
                <CancelIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
          {row.status === 'APPROVED' && (
            <Tooltip title="Suspend">
              <IconButton size="small" color="warning" onClick={() => handleSuspend(row)}>
                <BlockIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
        </Box>
      ),
    },
  ];

  return (
    <Box>
      <PageHeader title="Farmer Management" />

      <SearchFilter
        searchPlaceholder="Search by name or email..."
        searchValue={search}
        onSearchChange={setSearch}
        filters={[
          {
            key: 'status',
            label: 'Status',
            value: statusFilter,
            options: FARMER_STATUSES.map((s) => ({ label: s, value: s })),
          },
          {
            key: 'kycStatus',
            label: 'KYC',
            value: kycFilter,
            options: KYC_STATUSES.map((s) => ({ label: s.replace(/_/g, ' '), value: s })),
          },
        ]}
        onFilterChange={(key: string, value: string) => {
          if (key === 'status') {
            setStatusFilter(value);
            setPage(1);
          }
          if (key === 'kycStatus') {
            setKycFilter(value);
            setPage(1);
          }
        }}
      />

      <DataTable
        columns={columns}
        data={(data?.items || []) as any}
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
        PaperProps={{ sx: { width: 450 } }}
      >
        {selectedFarmer && (
          <Box sx={{ p: 3 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
              <Avatar src={selectedFarmer.avatar} sx={{ width: 56, height: 56 }}>
                {selectedFarmer.name.charAt(0).toUpperCase()}
              </Avatar>
              <Box>
                <Typography variant="h6">{selectedFarmer.name}</Typography>
                <Typography variant="body2" color="text.secondary">
                  {selectedFarmer.email}
                </Typography>
              </Box>
            </Box>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Personal Information
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Phone
                </Typography>
                <Typography variant="body2">{selectedFarmer.phone}</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Status
                </Typography>
                <Box>
                  <StatusChip
                    status={selectedFarmer.status}
                  />
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  KYC Status
                </Typography>
                <Box>
                  <StatusChip
                    status={selectedFarmer.kycStatus}
                  />
                </Box>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Joined
                </Typography>
                <Typography variant="body2">{formatDate(selectedFarmer.createdAt)}</Typography>
              </Grid>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  Address
                </Typography>
                <Typography variant="body2">{selectedFarmer.address}</Typography>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Farm Details
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Farm Name
                </Typography>
                <Typography variant="body2">{selectedFarmer.farmDetails.name}</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Location
                </Typography>
                <Typography variant="body2">{selectedFarmer.farmDetails.location}</Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Farm Size
                </Typography>
                <Typography variant="body2">{selectedFarmer.farmDetails.size}</Typography>
              </Grid>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  Crops
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mt: 0.5 }}>
                  {selectedFarmer.farmDetails.crops.map((crop) => (
                    <Box
                      key={crop}
                      sx={{
                        px: 1,
                        py: 0.25,
                        borderRadius: 1,
                        bgcolor: 'primary.light',
                        color: 'primary.contrastText',
                        fontSize: '0.75rem',
                      }}
                    >
                      {crop}
                    </Box>
                  ))}
                </Box>
              </Grid>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  Certifications
                </Typography>
                <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5, mt: 0.5 }}>
                  {selectedFarmer.farmDetails.certifications.map((cert) => (
                    <Box
                      key={cert}
                      sx={{
                        px: 1,
                        py: 0.25,
                        borderRadius: 1,
                        bgcolor: 'success.light',
                        color: 'success.contrastText',
                        fontSize: '0.75rem',
                      }}
                    >
                      {cert}
                    </Box>
                  ))}
                </Box>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Bank Account
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  Account Holder
                </Typography>
                <Typography variant="body2">
                  {selectedFarmer.bankAccount.accountHolder}
                </Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Account Number
                </Typography>
                <Typography variant="body2">
                  {selectedFarmer.bankAccount.accountNumber}
                </Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  IFSC
                </Typography>
                <Typography variant="body2">
                  {selectedFarmer.bankAccount.ifscCode}
                </Typography>
              </Grid>
              <Grid item xs={12}>
                <Typography variant="caption" color="text.secondary">
                  Bank
                </Typography>
                <Typography variant="body2">{selectedFarmer.bankAccount.bankName}</Typography>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Typography variant="subtitle2" gutterBottom>
              Statistics
            </Typography>
            <Grid container spacing={1}>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Total Orders
                </Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>
                  {selectedFarmer.totalOrders}
                </Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Total Revenue
                </Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>
                  {formatCurrency(selectedFarmer.totalRevenue)}
                </Typography>
              </Grid>
              <Grid item xs={6}>
                <Typography variant="caption" color="text.secondary">
                  Products
                </Typography>
                <Typography variant="body2" sx={{ fontWeight: 600 }}>
                  {selectedFarmer.productCount}
                </Typography>
              </Grid>
            </Grid>

            <Divider sx={{ my: 2 }} />

            <Box sx={{ display: 'flex', gap: 1 }}>
              {selectedFarmer.status === 'PENDING' && (
                <>
                  <Button
                    variant="contained"
                    color="success"
                    fullWidth
                    startIcon={<CheckCircleIcon />}
                    onClick={() => {
                      setDetailDrawerOpen(false);
                      handleApprove(selectedFarmer);
                    }}
                  >
                    Approve
                  </Button>
                  <Button
                    variant="contained"
                    color="error"
                    fullWidth
                    startIcon={<CancelIcon />}
                    onClick={() => {
                      setDetailDrawerOpen(false);
                      handleReject(selectedFarmer);
                    }}
                  >
                    Reject
                  </Button>
                </>
              )}
              {selectedFarmer.status === 'APPROVED' && (
                <Button
                  variant="outlined"
                  color="warning"
                  fullWidth
                  startIcon={<BlockIcon />}
                  onClick={() => {
                    setDetailDrawerOpen(false);
                    handleSuspend(selectedFarmer);
                  }}
                >
                  Suspend
                </Button>
              )}
            </Box>
          </Box>
        )}
      </Drawer>

      <Dialog open={approveDialogOpen} onClose={() => setApproveDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Approve Farmer</DialogTitle>
        <DialogContent>
          <Typography variant="body2">
            Are you sure you want to approve farmer <strong>{selectedFarmer?.name}</strong>?
            They will be able to list products and receive orders.
          </Typography>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setApproveDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            color="success"
            onClick={() => {
              if (selectedFarmer) {
                approveMutation.mutate(selectedFarmer.id);
              }
            }}
            disabled={approveMutation.isPending}
          >
            {approveMutation.isPending ? 'Approving...' : 'Approve'}
          </Button>
        </DialogActions>
      </Dialog>

      <Dialog open={rejectDialogOpen} onClose={() => setRejectDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Reject Farmer</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            Please provide a reason for rejecting <strong>{selectedFarmer?.name}</strong>.
          </Typography>
          <TextField
            fullWidth
            multiline
            rows={3}
            label="Rejection Reason"
            value={rejectReason}
            onChange={(e) => setRejectReason(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setRejectDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            color="error"
            onClick={() => {
              if (selectedFarmer) {
                rejectMutation.mutate({ id: selectedFarmer.id, reason: rejectReason });
              }
            }}
            disabled={!rejectReason.trim() || rejectMutation.isPending}
          >
            {rejectMutation.isPending ? 'Rejecting...' : 'Reject'}
          </Button>
        </DialogActions>
      </Dialog>

      <Dialog open={suspendDialogOpen} onClose={() => setSuspendDialogOpen(false)} maxWidth="xs" fullWidth>
        <DialogTitle>Suspend Farmer</DialogTitle>
        <DialogContent>
          <Typography variant="body2" sx={{ mb: 2 }}>
            Please provide a reason for suspending <strong>{selectedFarmer?.name}</strong>.
            Their account will be deactivated until reactivated.
          </Typography>
          <TextField
            fullWidth
            multiline
            rows={3}
            label="Suspension Reason"
            value={suspendReason}
            onChange={(e) => setSuspendReason(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setSuspendDialogOpen(false)}>Cancel</Button>
          <Button
            variant="contained"
            color="warning"
            onClick={() => {
              if (selectedFarmer) {
                suspendMutation.mutate({ id: selectedFarmer.id, reason: suspendReason });
              }
            }}
            disabled={!suspendReason.trim() || suspendMutation.isPending}
          >
            {suspendMutation.isPending ? 'Suspending...' : 'Suspend'}
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}
