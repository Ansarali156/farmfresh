import { useQuery } from '@tanstack/react-query';
import { Bar, Doughnut } from 'react-chartjs-2';
import 'chart.js/auto';
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
} from '@mui/material';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import AgricultureIcon from '@mui/icons-material/Agriculture';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import PeopleIcon from '@mui/icons-material/People';
import InventoryIcon from '@mui/icons-material/Inventory';
import AssignmentTurnedInIcon from '@mui/icons-material/AssignmentTurnedIn';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import { adminService } from '../services/admin.service';
import StatsCard from '../components/StatsCard';
import StatusChip from '../components/StatusChip';
import LoadingState from '../components/LoadingState';
import EmptyState from '../components/EmptyState';
import type { DashboardStats } from '../types';

const f = (v: number) => '₹' + v.toLocaleString('en-IN');

const statCards: {
  title: string;
  dataKey: keyof DashboardStats;
  icon: React.ReactElement;
  color: string;
  bg: string;
  format?: (v: number) => string;
}[] = [
  { title: 'Total Revenue', dataKey: 'totalRevenue', icon: <CurrencyRupeeIcon />, color: '#2E7D32', bg: '#E8F5E9', format: f },
  { title: "Today's Sales", dataKey: 'todaySales', icon: <ShoppingCartIcon />, color: '#1565C0', bg: '#E3F2FD', format: f },
  { title: 'Monthly Sales', dataKey: 'monthlySales', icon: <CurrencyRupeeIcon />, color: '#2E7D32', bg: '#E8F5E9', format: f },
  { title: 'Total Orders', dataKey: 'totalOrders', icon: <ShoppingCartIcon />, color: '#1565C0', bg: '#E3F2FD' },
  { title: 'Active Customers', dataKey: 'activeCustomers', icon: <PeopleIcon />, color: '#7B1FA2', bg: '#F3E5F5' },
  { title: 'Active Farmers', dataKey: 'activeFarmers', icon: <AgricultureIcon />, color: '#E65100', bg: '#FFF3E0' },
  { title: 'Delivery Partners', dataKey: 'deliveryPartners', icon: <LocalShippingIcon />, color: '#1565C0', bg: '#E3F2FD' },
  { title: 'Pending Product Approvals', dataKey: 'pendingProductApprovals', icon: <InventoryIcon />, color: '#F57F17', bg: '#FFF8E1' },
  { title: 'Pending Farmer Approvals', dataKey: 'pendingFarmerApprovals', icon: <AssignmentTurnedInIcon />, color: '#F57F17', bg: '#FFF8E1' },
  { title: 'Low Inventory', dataKey: 'lowInventory', icon: <WarningAmberIcon />, color: '#D32F2F', bg: '#FFEBEE' },
  { title: 'Active Deliveries', dataKey: 'activeDeliveries', icon: <LocalShippingIcon />, color: '#7B1FA2', bg: '#F3E5F5' },
];

const DOUGHNUT_COLORS = ['#4CAF50', '#FF9800', '#2196F3', '#9C27B0', '#f44336', '#00BCD4', '#FF5722', '#607D8B'];

export default function DashboardPage() {
  const { data: dashboard, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: adminService.getDashboard,
  });

  if (isLoading) return <LoadingState rows={8} />;

  if (!dashboard) return <EmptyState message="No dashboard data available" />;

  const stats = dashboard.stats;

  const barData = {
    labels: dashboard.monthlyRevenue?.map((m) => m.month) ?? [],
    datasets: [
      {
        label: 'Revenue',
        data: dashboard.monthlyRevenue?.map((m) => m.revenue) ?? [],
        backgroundColor: 'rgba(46, 125, 50, 0.7)',
        borderColor: '#2E7D32',
        borderWidth: 1,
        borderRadius: 4,
      },
    ],
  };

  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      y: { beginAtZero: true, ticks: { callback: (v: any) => '₹' + Number(v).toLocaleString('en-IN') } },
    },
  };

  const doughnutData = {
    labels: dashboard.ordersByStatus?.map((o) => o.status) ?? [],
    datasets: [
      {
        data: dashboard.ordersByStatus?.map((o) => o.count) ?? [],
        backgroundColor: DOUGHNUT_COLORS.slice(0, dashboard.ordersByStatus?.length ?? 0),
        borderWidth: 0,
      },
    ],
  };

  const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { position: 'bottom' as const, labels: { padding: 16, usePointStyle: true } },
    },
  };

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>Dashboard</Typography>

      <Grid container spacing={3} mb={4}>
        {statCards.map(({ title, dataKey, icon, color, bg, format }) => (
          <Grid item xs={12} sm={6} md={4} key={dataKey}>
            <StatsCard
              title={title}
              value={format ? format(stats[dataKey]) : stats[dataKey]}
              icon={icon}
              color={color}
              bg={bg}
            />
          </Grid>
        ))}
      </Grid>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={6}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>Monthly Revenue</Typography>
              <Box sx={{ height: 280 }}>
                {dashboard.monthlyRevenue?.length ? (
                  <Bar data={barData} options={barOptions} />
                ) : (
                  <EmptyState message="No revenue data" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={6}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>Orders by Status</Typography>
              <Box sx={{ height: 280 }}>
                {dashboard.ordersByStatus?.length ? (
                  <Doughnut data={doughnutData} options={doughnutOptions} />
                ) : (
                  <EmptyState message="No status data" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={6}>
          <Typography variant="h6" fontWeight={600} mb={2}>Top Selling Products</Typography>
          <TableContainer component={Paper} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Rank</TableCell>
                  <TableCell>Product Name</TableCell>
                  <TableCell align="right">Orders</TableCell>
                  <TableCell align="right">Revenue</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {dashboard.topSellingProducts?.length ? (
                  dashboard.topSellingProducts.map((p, i) => (
                    <TableRow key={p.name} hover>
                      <TableCell>{i + 1}</TableCell>
                      <TableCell>{p.name}</TableCell>
                      <TableCell align="right">{p.count}</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 500 }}>{f(p.revenue)}</TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={4}><EmptyState message="No products data" /></TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>
        <Grid item xs={12} md={6}>
          <Typography variant="h6" fontWeight={600} mb={2}>Top Farmers</Typography>
          <TableContainer component={Paper} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Rank</TableCell>
                  <TableCell>Farmer Name</TableCell>
                  <TableCell align="right">Orders</TableCell>
                  <TableCell align="right">Revenue</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {dashboard.topFarmers?.length ? (
                  dashboard.topFarmers.map((farmer, i) => (
                    <TableRow key={farmer.name} hover>
                      <TableCell>{i + 1}</TableCell>
                      <TableCell>{farmer.name}</TableCell>
                      <TableCell align="right">{farmer.orders}</TableCell>
                      <TableCell align="right" sx={{ fontWeight: 500 }}>{f(farmer.revenue)}</TableCell>
                    </TableRow>
                  ))
                ) : (
                  <TableRow>
                    <TableCell colSpan={4}><EmptyState message="No farmer data" /></TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>
      </Grid>

      <Typography variant="h6" fontWeight={600} mb={2}>Recent Orders</Typography>
      <TableContainer component={Paper} elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Order ID</TableCell>
              <TableCell>Customer</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="right">Amount</TableCell>
              <TableCell>Date</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {dashboard.recentOrders?.length ? (
              dashboard.recentOrders.map((order) => (
                <TableRow key={order.id} hover>
                  <TableCell sx={{ fontWeight: 500 }}>{order.orderNumber ?? order.id.slice(0, 8)}</TableCell>
                  <TableCell>{order.customerName ?? 'N/A'}</TableCell>
                  <TableCell><StatusChip status={order.status} /></TableCell>
                  <TableCell align="right" sx={{ fontWeight: 500 }}>{f(order.totalAmount)}</TableCell>
                  <TableCell>{new Date(order.createdAt).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' })}</TableCell>
                </TableRow>
              ))
            ) : (
              <TableRow>
                <TableCell colSpan={5}><EmptyState message="No recent orders" /></TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
