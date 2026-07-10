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
} from '@mui/material';
import CheckIcon from '@mui/icons-material/Check';
import CloseIcon from '@mui/icons-material/Close';

const farmers = [
  { id: '1', name: 'Ramesh Kumar', phone: '+91 98765 43210', products: 12, kyc: 'approved' as const, joined: '12 Jan 2026' },
  { id: '2', name: 'Sunil Reddy', phone: '+91 87654 32109', products: 8, kyc: 'pending' as const, joined: '03 Mar 2026' },
  { id: '3', name: 'Anita Desai', phone: '+91 76543 21098', products: 15, kyc: 'approved' as const, joined: '18 Nov 2025' },
  { id: '4', name: 'Meera Patel', phone: '+91 65432 10987', products: 5, kyc: 'rejected' as const, joined: '22 May 2026' },
  { id: '5', name: 'Harish Joshi', phone: '+91 54321 09876', products: 3, kyc: 'pending' as const, joined: '01 Jul 2026' },
];

const kycColor: Record<string, 'success' | 'warning' | 'error'> = {
  approved: 'success',
  pending: 'warning',
  rejected: 'error',
};

export default function FarmersPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Farmers
      </Typography>

      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Phone</TableCell>
              <TableCell align="right">Products</TableCell>
              <TableCell>KYC Status</TableCell>
              <TableCell>Joined</TableCell>
              <TableCell align="center">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {farmers.map((f) => (
              <TableRow key={f.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{f.name}</TableCell>
                <TableCell>{f.phone}</TableCell>
                <TableCell align="right">{f.products}</TableCell>
                <TableCell>
                  <Chip
                    label={f.kyc.charAt(0).toUpperCase() + f.kyc.slice(1)}
                    color={kycColor[f.kyc]}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell>{f.joined}</TableCell>
                <TableCell align="center">
                  {f.kyc === 'pending' ? (
                    <Box display="flex" gap={1} justifyContent="center">
                      <Button size="small" variant="contained" color="success" startIcon={<CheckIcon />}>
                        Approve
                      </Button>
                      <Button size="small" variant="outlined" color="error" startIcon={<CloseIcon />}>
                        Reject
                      </Button>
                    </Box>
                  ) : (
                    <Typography variant="body2" color="text.secondary">—</Typography>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}
