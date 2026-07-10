import {
  Box,
  Card,
  CardContent,
  Grid,
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
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import AgricultureIcon from '@mui/icons-material/Agriculture';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';

/* ── Stat cards data ── */
const stats = [
  { label: 'Total Orders', value: '1,248', icon: <ShoppingCartIcon />, color: '#1565C0', bg: '#E3F2FD' },
  { label: 'Total Revenue', value: '₹4,35,600', icon: <CurrencyRupeeIcon />, color: '#2E7D32', bg: '#E8F5E9' },
  { label: 'Active Farmers', value: '64', icon: <AgricultureIcon />, color: '#E65100', bg: '#FFF3E0' },
  { label: 'Pending Deliveries', value: '38', icon: <LocalShippingIcon />, color: '#7B1FA2', bg: '#F3E5F5' },
];

/* ── Recent orders dummy data ── */
const recentOrders = [
  { id: 'ORD-1024', customer: 'Ananya Sharma', status: 'delivered' as const, amount: '₹1,250' },
  { id: 'ORD-1023', customer: 'Rahul Verma', status: 'shipped' as const, amount: '₹780' },
  { id: 'ORD-1022', customer: 'Priya Patel', status: 'pending' as const, amount: '₹2,100' },
  { id: 'ORD-1021', customer: 'Vikram Singh', status: 'confirmed' as const, amount: '₹460' },
];

const statusColor: Record<string, 'success' | 'info' | 'warning' | 'default'> = {
  delivered: 'success',
  shipped: 'info',
  pending: 'warning',
  confirmed: 'default',
};

export default function DashboardPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Dashboard
      </Typography>

      {/* ── Stat Cards ── */}
      <Grid container spacing={3} mb={5}>
        {stats.map(({ label, value, icon, color, bg }) => (
          <Grid item xs={12} sm={6} md={3} key={label}>
            <Card>
              <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2.5, p: 3, '&:last-child': { pb: 3 } }}>
                <Box
                  sx={{
                    width: 48,
                    height: 48,
                    borderRadius: '10px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    bgcolor: bg,
                    color,
                    '& .MuiSvgIcon-root': { fontSize: 24 },
                  }}
                >
                  {icon}
                </Box>
                <Box>
                  <Typography variant="body2" color="text.secondary" sx={{ fontSize: 13 }}>
                    {label}
                  </Typography>
                  <Typography variant="h5" fontWeight={700} sx={{ lineHeight: 1.3 }}>
                    {value}
                  </Typography>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        ))}
      </Grid>

      {/* ── Recent Orders Table ── */}
      <Typography variant="h6" fontWeight={600} mb={2}>
        Recent Orders
      </Typography>

      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Order ID</TableCell>
              <TableCell>Customer</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Amount</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {recentOrders.map((order) => (
              <TableRow key={order.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{order.id}</TableCell>
                <TableCell>{order.customer}</TableCell>
                <TableCell>
                  <Chip
                    label={order.status.charAt(0).toUpperCase() + order.status.slice(1)}
                    color={statusColor[order.status]}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell align="right" sx={{ fontWeight: 500 }}>{order.amount}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
