import { Box, Typography, Card, CardContent, Grid } from '@mui/material';
import {
  LineChart,
  Line,
  BarChart,
  Bar,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts';

/* ── Sales Trend (last 7 days) ── */
const salesData = [
  { day: 'Mon', sales: 12400 },
  { day: 'Tue', sales: 15800 },
  { day: 'Wed', sales: 13200 },
  { day: 'Thu', sales: 18600 },
  { day: 'Fri', sales: 22100 },
  { day: 'Sat', sales: 28400 },
  { day: 'Sun', sales: 19700 },
];

/* ── Top 5 Selling Products ── */
const topProducts = [
  { name: 'Organic Tomatoes', sold: 320 },
  { name: 'Basmati Rice', sold: 275 },
  { name: 'Alphonso Mangoes', sold: 240 },
  { name: 'A2 Cow Milk', sold: 210 },
  { name: 'Groundnut Oil', sold: 185 },
];

/* ── Revenue by Category ── */
const categoryRevenue = [
  { name: 'Vegetables', value: 32 },
  { name: 'Fruits', value: 24 },
  { name: 'Grains', value: 18 },
  { name: 'Dairy', value: 16 },
  { name: 'Oils', value: 10 },
];

const PIE_COLORS = ['#2E7D32', '#4CAF50', '#81C784', '#1565C0', '#E65100'];

export default function AnalyticsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Analytics
      </Typography>

      <Grid container spacing={3}>
        {/* ── Sales Trend ── */}
        <Grid item xs={12} lg={8}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" fontWeight={600} color="#0A2540" mb={2}>
                Sales Trend (Last 7 Days)
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={salesData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
                  <XAxis dataKey="day" tick={{ fontSize: 13 }} />
                  <YAxis tick={{ fontSize: 13 }} tickFormatter={(v) => `₹${(v / 1000).toFixed(0)}k`} />
                  <Tooltip formatter={(value: number) => [`₹${value.toLocaleString('en-IN')}`, 'Sales']} />
                  <Line
                    type="monotone"
                    dataKey="sales"
                    stroke="#2E7D32"
                    strokeWidth={2.5}
                    dot={{ r: 4, fill: '#2E7D32' }}
                    activeDot={{ r: 6 }}
                  />
                </LineChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* ── Revenue by Category ── */}
        <Grid item xs={12} lg={4}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" fontWeight={600} color="#0A2540" mb={2}>
                Revenue by Category
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={categoryRevenue}
                    cx="50%"
                    cy="50%"
                    innerRadius={60}
                    outerRadius={100}
                    paddingAngle={3}
                    dataKey="value"
                    label={({ name, value }) => `${name} ${value}%`}
                  >
                    {categoryRevenue.map((_, i) => (
                      <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip formatter={(value: number) => [`${value}%`, 'Share']} />
                </PieChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>

        {/* ── Top 5 Selling Products ── */}
        <Grid item xs={12}>
          <Card>
            <CardContent sx={{ p: 3 }}>
              <Typography variant="h6" fontWeight={600} color="#0A2540" mb={2}>
                Top 5 Selling Products
              </Typography>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={topProducts} layout="vertical" margin={{ left: 20 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.06)" />
                  <XAxis type="number" tick={{ fontSize: 13 }} />
                  <YAxis type="category" dataKey="name" tick={{ fontSize: 13 }} width={130} />
                  <Tooltip formatter={(value: number) => [`${value} units`, 'Sold']} />
                  <Legend />
                  <Bar
                    dataKey="sold"
                    name="Units Sold"
                    fill="#0A2540"
                    radius={[0, 6, 6, 0]}
                    barSize={28}
                  />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}
