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
} from '@mui/material';

const orders = [
  { id: 'ORD-1024', customer: 'Ananya Sharma', partner: 'Deepak M.', status: 'delivered' as const, amount: '₹1,250', date: '07 Jul 2026' },
  { id: 'ORD-1023', customer: 'Rahul Verma', partner: 'Suresh K.', status: 'shipped' as const, amount: '₹780', date: '07 Jul 2026' },
  { id: 'ORD-1022', customer: 'Priya Patel', partner: '—', status: 'pending' as const, amount: '₹2,100', date: '06 Jul 2026' },
  { id: 'ORD-1021', customer: 'Vikram Singh', partner: 'Anil R.', status: 'confirmed' as const, amount: '₹460', date: '06 Jul 2026' },
  { id: 'ORD-1020', customer: 'Neha Gupta', partner: 'Deepak M.', status: 'cancelled' as const, amount: '₹930', date: '05 Jul 2026' },
];

const statusColor: Record<string, 'success' | 'info' | 'warning' | 'default' | 'error'> = {
  delivered: 'success',
  shipped: 'info',
  pending: 'warning',
  confirmed: 'default',
  cancelled: 'error',
};

export default function OrdersPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Orders
      </Typography>

      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Order ID</TableCell>
              <TableCell>Customer</TableCell>
              <TableCell>Delivery Partner</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Amount</TableCell>
              <TableCell>Date</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {orders.map((o) => (
              <TableRow key={o.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{o.id}</TableCell>
                <TableCell>{o.customer}</TableCell>
                <TableCell>{o.partner}</TableCell>
                <TableCell>
                  <Chip
                    label={o.status.charAt(0).toUpperCase() + o.status.slice(1)}
                    color={statusColor[o.status]}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell align="right" sx={{ fontWeight: 500 }}>{o.amount}</TableCell>
                <TableCell>{o.date}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
