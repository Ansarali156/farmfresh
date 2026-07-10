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
  Card,
  CardContent,
} from '@mui/material';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';

const alerts = [
  { id: '1', product: 'Organic Tomatoes', farmer: 'Ramesh Kumar', stock: 3, threshold: 20, category: 'Vegetables' },
  { id: '2', product: 'A2 Cow Milk (1 L)', farmer: 'Meera Patel', stock: 8, threshold: 50, category: 'Dairy' },
  { id: '3', product: 'Cold-Pressed Groundnut Oil', farmer: 'Harish Joshi', stock: 2, threshold: 10, category: 'Oils' },
  { id: '4', product: 'Fresh Spinach', farmer: 'Anita Desai', stock: 12, threshold: 30, category: 'Vegetables' },
  { id: '5', product: 'Brown Rice (5 kg)', farmer: 'Sunil Reddy', stock: 5, threshold: 15, category: 'Grains' },
  { id: '6', product: 'Alphonso Mangoes', farmer: 'Anita Desai', stock: 18, threshold: 25, category: 'Fruits' },
  { id: '7', product: 'Raw Honey (500 g)', farmer: 'Harish Joshi', stock: 4, threshold: 10, category: 'Honey' },
  { id: '8', product: 'Paneer (200 g)', farmer: 'Meera Patel', stock: 6, threshold: 20, category: 'Dairy' },
  { id: '9', product: 'Turmeric Powder', farmer: 'Ramesh Kumar', stock: 15, threshold: 25, category: 'Herbs' },
  { id: '10', product: 'Jowar Flour (1 kg)', farmer: 'Sunil Reddy', stock: 9, threshold: 15, category: 'Grains' },
  { id: '11', product: 'Coconut Oil (500 ml)', farmer: 'Harish Joshi', stock: 1, threshold: 10, category: 'Oils' },
  { id: '12', product: 'Curd (500 g)', farmer: 'Meera Patel', stock: 7, threshold: 20, category: 'Dairy' },
];

function getStockLevel(stock: number, threshold: number) {
  const ratio = stock / threshold;
  if (ratio <= 0.25) return 'critical';   // ≤ 25% — red
  if (ratio <= 0.6) return 'moderate';    // ≤ 60% — orange
  return 'low';                            // > 60% — normal row, still under threshold
}

const rowBg: Record<string, string> = {
  critical: 'rgba(211,47,47,0.06)',
  moderate: 'rgba(237,108,2,0.06)',
  low: 'transparent',
};

export default function InventoryAlertsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Inventory Alerts
      </Typography>

      {/* ── Summary Card ── */}
      <Card sx={{ mb: 3 }}>
        <CardContent
          sx={{
            display: 'flex',
            alignItems: 'center',
            gap: 2.5,
            p: 3,
            '&:last-child': { pb: 3 },
          }}
        >
          <Box
            sx={{
              width: 48,
              height: 48,
              borderRadius: '10px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              bgcolor: '#FFF3E0',
              color: '#E65100',
              '& .MuiSvgIcon-root': { fontSize: 24 },
            }}
          >
            <WarningAmberIcon />
          </Box>
          <Box>
            <Typography variant="body2" color="text.secondary" sx={{ fontSize: 13 }}>
              Products Needing Restock
            </Typography>
            <Typography variant="h5" fontWeight={700} sx={{ lineHeight: 1.3 }}>
              {alerts.length} products need restocking
            </Typography>
          </Box>
        </CardContent>
      </Card>

      {/* ── Alerts Table ── */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Product Name</TableCell>
              <TableCell>Farmer</TableCell>
              <TableCell align="right">Current Stock</TableCell>
              <TableCell align="right">Threshold</TableCell>
              <TableCell>Category</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {alerts.map((a) => {
              const level = getStockLevel(a.stock, a.threshold);
              return (
                <TableRow key={a.id} hover sx={{ bgcolor: rowBg[level] }}>
                  <TableCell sx={{ fontWeight: 500 }}>{a.product}</TableCell>
                  <TableCell>{a.farmer}</TableCell>
                  <TableCell
                    align="right"
                    sx={{
                      fontWeight: 600,
                      color: level === 'critical' ? '#d32f2f' : level === 'moderate' ? '#ed6c02' : 'inherit',
                    }}
                  >
                    {a.stock}
                  </TableCell>
                  <TableCell align="right">{a.threshold}</TableCell>
                  <TableCell>{a.category}</TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
