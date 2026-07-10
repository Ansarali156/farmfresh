import { useState } from 'react';
import {
  Box,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Button,
  Card,
  CardContent,
  Grid,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Snackbar,
  Alert,
} from '@mui/material';
import PaymentsIcon from '@mui/icons-material/Payments';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const initialPayouts = [
  { id: '1', farmer: 'Ramesh Kumar', amount: 12500, lastPayout: '28 Jun 2026', status: 'pending' as const },
  { id: '2', farmer: 'Sunil Reddy', amount: 8700, lastPayout: '30 Jun 2026', status: 'processed' as const },
  { id: '3', farmer: 'Anita Desai', amount: 18200, lastPayout: '25 Jun 2026', status: 'pending' as const },
  { id: '4', farmer: 'Meera Patel', amount: 6400, lastPayout: '01 Jul 2026', status: 'processed' as const },
  { id: '5', farmer: 'Harish Joshi', amount: 9300, lastPayout: '22 Jun 2026', status: 'pending' as const },
  { id: '6', farmer: 'Lakshmi Nair', amount: 4100, lastPayout: '03 Jul 2026', status: 'processed' as const },
];

export default function PayoutsPage() {
  const [payouts, setPayouts] = useState(initialPayouts);
  const [confirmId, setConfirmId] = useState<string | null>(null);
  const [snackOpen, setSnackOpen] = useState(false);

  const pendingTotal = payouts
    .filter((p) => p.status === 'pending')
    .reduce((sum, p) => sum + p.amount, 0);
  const processedTotal = payouts
    .filter((p) => p.status === 'processed')
    .reduce((sum, p) => sum + p.amount, 0);

  const handleProcess = () => {
    setPayouts((prev) =>
      prev.map((p) => (p.id === confirmId ? { ...p, status: 'processed' as const } : p))
    );
    setConfirmId(null);
    setSnackOpen(true);
  };

  const fmt = (n: number) => '₹' + n.toLocaleString('en-IN');

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Payouts
      </Typography>

      {/* ── Summary Cards ── */}
      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} sm={6} md={4}>
          <Card>
            <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2.5, p: 3, '&:last-child': { pb: 3 } }}>
              <Box
                sx={{
                  width: 48, height: 48, borderRadius: '10px',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  bgcolor: '#FFF3E0', color: '#E65100',
                  '& .MuiSvgIcon-root': { fontSize: 24 },
                }}
              >
                <PaymentsIcon />
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary" sx={{ fontSize: 13 }}>
                  Total Pending Payouts
                </Typography>
                <Typography variant="h5" fontWeight={700} sx={{ lineHeight: 1.3 }}>
                  {fmt(pendingTotal)}
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={4}>
          <Card>
            <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2.5, p: 3, '&:last-child': { pb: 3 } }}>
              <Box
                sx={{
                  width: 48, height: 48, borderRadius: '10px',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  bgcolor: '#E8F5E9', color: '#2E7D32',
                  '& .MuiSvgIcon-root': { fontSize: 24 },
                }}
              >
                <CheckCircleIcon />
              </Box>
              <Box>
                <Typography variant="body2" color="text.secondary" sx={{ fontSize: 13 }}>
                  Processed This Month
                </Typography>
                <Typography variant="h5" fontWeight={700} sx={{ lineHeight: 1.3 }}>
                  {fmt(processedTotal)}
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* ── Payouts Table ── */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Farmer Name</TableCell>
              <TableCell align="right">Amount Due</TableCell>
              <TableCell>Last Payout</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="center">Action</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {payouts.map((p) => (
              <TableRow key={p.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{p.farmer}</TableCell>
                <TableCell align="right" sx={{ fontWeight: 500 }}>{fmt(p.amount)}</TableCell>
                <TableCell>{p.lastPayout}</TableCell>
                <TableCell>
                  <Chip
                    label={p.status === 'pending' ? 'Pending' : 'Processed'}
                    color={p.status === 'pending' ? 'warning' : 'success'}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell align="center">
                  {p.status === 'pending' ? (
                    <Button
                      size="small"
                      variant="contained"
                      color="success"
                      onClick={() => setConfirmId(p.id)}
                    >
                      Process Payout
                    </Button>
                  ) : (
                    <Typography variant="body2" color="text.secondary">—</Typography>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ── Confirmation Dialog ── */}
      <Dialog open={!!confirmId} onClose={() => setConfirmId(null)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Confirm Payout</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to process this payout? This action will mark it as completed.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setConfirmId(null)}>Cancel</Button>
          <Button variant="contained" color="success" onClick={handleProcess}>Confirm</Button>
        </DialogActions>
      </Dialog>

      {/* ── Snackbar ── */}
      <Snackbar
        open={snackOpen}
        autoHideDuration={3000}
        onClose={() => setSnackOpen(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert onClose={() => setSnackOpen(false)} severity="success" variant="filled" sx={{ borderRadius: 2 }}>
          Payout processed (demo only)
        </Alert>
      </Snackbar>
    </Box>
  );
}
