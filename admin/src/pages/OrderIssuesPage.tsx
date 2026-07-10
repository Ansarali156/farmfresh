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
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Snackbar,
  Alert,
} from '@mui/material';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';

export interface OrderIssue {
  id: string;
  order: string;
  customer: string;
  issue: 'Wrong Item' | 'Damaged' | 'Late Delivery';
  status: 'open' | 'resolved';
  date: string;
}

const initialIssues: OrderIssue[] = [
  { id: '1', order: 'ORD-1022', customer: 'Priya Patel', issue: 'Wrong Item', status: 'open', date: '06 Jul 2026' },
  { id: '2', order: 'ORD-1018', customer: 'Neha Gupta', issue: 'Damaged', status: 'open', date: '05 Jul 2026' },
  { id: '3', order: 'ORD-1015', customer: 'Arun Mehta', issue: 'Late Delivery', status: 'resolved', date: '04 Jul 2026' },
  { id: '4', order: 'ORD-1012', customer: 'Vikram Singh', issue: 'Wrong Item', status: 'open', date: '03 Jul 2026' },
  { id: '5', order: 'ORD-1010', customer: 'Kavita Rao', issue: 'Late Delivery', status: 'open', date: '02 Jul 2026' },
  { id: '6', order: 'ORD-1008', customer: 'Rahul Verma', issue: 'Damaged', status: 'resolved', date: '01 Jul 2026' },
  { id: '7', order: 'ORD-1005', customer: 'Ananya Sharma', issue: 'Late Delivery', status: 'open', date: '30 Jun 2026' },
];

const issueColor: Record<string, 'error' | 'warning' | 'info'> = {
  'Wrong Item': 'error',
  'Damaged': 'warning',
  'Late Delivery': 'info',
};

export default function OrderIssuesPage() {
  const [issues, setIssues] = useState(initialIssues);
  const [resolveId, setResolveId] = useState<string | null>(null);
  const [snackOpen, setSnackOpen] = useState(false);

  const openCount = issues.filter((i) => i.status === 'open').length;

  const handleResolve = () => {
    setIssues((prev) =>
      prev.map((i) => (i.id === resolveId ? { ...i, status: 'resolved' } : i))
    );
    setResolveId(null);
    setSnackOpen(true);
  };

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Order Issues
      </Typography>

      {/* ── Summary Card ── */}
      <Card sx={{ mb: 3 }}>
        <CardContent
          sx={{ display: 'flex', alignItems: 'center', gap: 2.5, p: 3, '&:last-child': { pb: 3 } }}
        >
          <Box
            sx={{
              width: 48, height: 48, borderRadius: '10px',
              display: 'flex', alignItems: 'center', justifyContent: 'center',
              bgcolor: '#FFEBEE', color: '#C62828',
              '& .MuiSvgIcon-root': { fontSize: 24 },
            }}
          >
            <ReportProblemIcon />
          </Box>
          <Box>
            <Typography variant="body2" color="text.secondary" sx={{ fontSize: 13 }}>
              Open Issues
            </Typography>
            <Typography variant="h5" fontWeight={700} sx={{ lineHeight: 1.3 }}>
              {openCount} open issue{openCount !== 1 ? 's' : ''} need attention
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* ── Issues Table ── */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Order ID</TableCell>
              <TableCell>Customer</TableCell>
              <TableCell>Issue Type</TableCell>
              <TableCell>Status</TableCell>
              <TableCell>Date Reported</TableCell>
              <TableCell align="center">Action</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {issues.map((i) => (
              <TableRow key={i.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{i.order}</TableCell>
                <TableCell>{i.customer}</TableCell>
                <TableCell>
                  <Chip label={i.issue} color={issueColor[i.issue]} size="small" variant="outlined" />
                </TableCell>
                <TableCell>
                  <Chip
                    label={i.status === 'open' ? 'Open' : 'Resolved'}
                    color={i.status === 'open' ? 'warning' : 'success'}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>{i.date}</TableCell>
                <TableCell align="center">
                  {i.status === 'open' ? (
                    <Button size="small" variant="contained" color="success" onClick={() => setResolveId(i.id)}>
                      Mark Resolved
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

      {/* ── Resolve Confirmation Dialog ── */}
      <Dialog open={!!resolveId} onClose={() => setResolveId(null)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Resolve Issue</DialogTitle>
        <DialogContent>
          <Typography>Mark this issue as resolved? The customer will be notified.</Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setResolveId(null)}>Cancel</Button>
          <Button variant="contained" color="success" onClick={handleResolve}>Confirm</Button>
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
          Issue resolved (demo only)
        </Alert>
      </Snackbar>
    </Box>
  );
}
