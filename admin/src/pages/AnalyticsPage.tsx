import { useQuery } from '@tanstack/react-query';
import { Line, Bar } from 'react-chartjs-2';
import 'chart.js/auto';
import { Box, Card, CardContent, Grid, Typography } from '@mui/material';
import CurrencyRupeeIcon from '@mui/icons-material/CurrencyRupee';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import TrendingUpIcon from '@mui/icons-material/TrendingUp';
import { adminService } from '../services/admin.service';
import LoadingState from '../components/LoadingState';
import EmptyState from '../components/EmptyState';

const f = (v: number) => '₹' + v.toLocaleString('en-IN');

const CHART_GREEN = 'rgba(46, 125, 50, 0.7)';
const CHART_ORANGE = 'rgba(230, 81, 0, 0.7)';

const lineOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, ticks: { callback: (v: any) => '₹' + Number(v).toLocaleString('en-IN') } },
    x: { grid: { display: false } },
  },
  elements: { line: { tension: 0.4 }, point: { radius: 3 } },
};

const barOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, ticks: { callback: (v: any) => '₹' + Number(v).toLocaleString('en-IN') } },
    x: { grid: { display: false } },
  },
};

const statusBarOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, ticks: { stepSize: 1 } },
    x: { grid: { display: false } },
  },
};

export default function AnalyticsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['analytics'],
    queryFn: adminService.getStatistics,
  });

  if (isLoading) return <LoadingState rows={6} />;

  if (!data) return <EmptyState message="No analytics data available" />;

  const totalRevenue = data.totalRevenue ?? 0;
  const totalOrders = data.totalOrders ?? 0;
  const avgOrderValue = data.avgOrderValue ?? 0;
  const monthlyRevenue = data.monthlyRevenue ?? [];
  const ordersByStatus = data.ordersByStatus ?? [];
  const monthlySales = data.monthlySales ?? [];

  const lineData = {
    labels: monthlyRevenue.map((m: any) => m.month),
    datasets: [
      {
        label: 'Revenue',
        data: monthlyRevenue.map((m: any) => m.revenue),
        borderColor: '#2E7D32',
        backgroundColor: CHART_GREEN,
        fill: true,
      },
    ],
  };

  const ordersByStatusData = {
    labels: ordersByStatus.map((o: any) => o.status),
    datasets: [
      {
        label: 'Orders',
        data: ordersByStatus.map((o: any) => o.count),
        backgroundColor: ['#4CAF50', '#FF9800', '#2196F3', '#9C27B0', '#f44336', '#00BCD4'],
        borderRadius: 4,
      },
    ],
  };

  const monthlySalesData = {
    labels: monthlySales.map((m: any) => m.month),
    datasets: [
      {
        label: 'Sales',
        data: monthlySales.map((m: any) => m.sales),
        backgroundColor: CHART_ORANGE,
        borderRadius: 4,
      },
    ],
  };

  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>Business Analytics</Typography>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={4}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={1}>
                <Typography variant="h6" color="text.secondary">Total Revenue</Typography>
                <CurrencyRupeeIcon sx={{ color: '#2E7D32' }} />
              </Box>
              <Typography variant="h4" fontWeight={700}>{f(totalRevenue)}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={1}>
                <Typography variant="h6" color="text.secondary">Total Orders</Typography>
                <ShoppingCartIcon sx={{ color: '#1565C0' }} />
              </Box>
              <Typography variant="h4" fontWeight={700}>{totalOrders.toLocaleString('en-IN')}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={4}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center" mb={1}>
                <Typography variant="h6" color="text.secondary">Average Order Value</Typography>
                <TrendingUpIcon sx={{ color: '#E65100' }} />
              </Box>
              <Typography variant="h4" fontWeight={700}>{f(avgOrderValue)}</Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Grid container spacing={3} mb={4}>
        <Grid item xs={12} md={6}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>Revenue Trend</Typography>
              <Box sx={{ height: 300 }}>
                {monthlyRevenue.length ? (
                  <Line data={lineData} options={lineOptions} />
                ) : (
                  <EmptyState message="No revenue trend data" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={6}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>Orders by Status</Typography>
              <Box sx={{ height: 300 }}>
                {ordersByStatus.length ? (
                  <Bar data={ordersByStatusData} options={statusBarOptions} />
                ) : (
                  <EmptyState message="No order status data" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Grid container spacing={3}>
        <Grid item xs={12} md={6}>
          <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2 }}>
            <CardContent>
              <Typography variant="h6" fontWeight={600} mb={2}>Monthly Sales</Typography>
              <Box sx={{ height: 300 }}>
                {monthlySales.length ? (
                  <Bar data={monthlySalesData} options={barOptions} />
                ) : (
                  <EmptyState message="No monthly sales data" />
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
