import {
  Box,
  Button,
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
import AddIcon from '@mui/icons-material/Add';

const coupons = [
  { id: '1', code: 'FRESH20', discount: 20, validUntil: '31 Jul 2026', status: 'active' as const },
  { id: '2', code: 'FARM10', discount: 10, validUntil: '15 Aug 2026', status: 'active' as const },
  { id: '3', code: 'WELCOME50', discount: 50, validUntil: '30 Jun 2026', status: 'expired' as const },
  { id: '4', code: 'MONSOON15', discount: 15, validUntil: '30 Sep 2026', status: 'active' as const },
  { id: '5', code: 'DIWALI25', discount: 25, validUntil: '10 Nov 2026', status: 'inactive' as const },
];

const statusColor: Record<string, 'success' | 'default' | 'error'> = {
  active: 'success',
  inactive: 'default',
  expired: 'error',
};

export default function CouponsPage() {
  return (
    <Box>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>
          Coupons
        </Typography>
        <Button variant="contained" startIcon={<AddIcon />}>
          Add Coupon
        </Button>
      </Box>

      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Code</TableCell>
              <TableCell align="right">Discount %</TableCell>
              <TableCell>Valid Until</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {coupons.map((c) => (
              <TableRow key={c.id} hover>
                <TableCell sx={{ fontFamily: '"Roboto Mono", monospace', fontWeight: 600 }}>{c.code}</TableCell>
                <TableCell align="right">{c.discount}%</TableCell>
                <TableCell>{c.validUntil}</TableCell>
                <TableCell>
                  <Chip
                    label={c.status.charAt(0).toUpperCase() + c.status.slice(1)}
                    color={statusColor[c.status]}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
