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

const partners = [
  { id: '1', name: 'Deepak Mehta', phone: '+91 99887 76655', deliveries: 342, status: 'active' as const },
  { id: '2', name: 'Suresh Kulkarni', phone: '+91 88776 65544', deliveries: 198, status: 'active' as const },
  { id: '3', name: 'Anil Rao', phone: '+91 77665 54433', deliveries: 85, status: 'inactive' as const },
  { id: '4', name: 'Pooja Nair', phone: '+91 66554 43322', deliveries: 410, status: 'active' as const },
  { id: '5', name: 'Kiran Thakur', phone: '+91 55443 32211', deliveries: 27, status: 'inactive' as const },
];

export default function DeliveryPartnersPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Delivery Partners
      </Typography>

      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Phone</TableCell>
              <TableCell align="right">Total Deliveries</TableCell>
              <TableCell>Status</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {partners.map((p) => (
              <TableRow key={p.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{p.name}</TableCell>
                <TableCell>{p.phone}</TableCell>
                <TableCell align="right">{p.deliveries}</TableCell>
                <TableCell>
                  <Chip
                    label={p.status === 'active' ? 'Active' : 'Inactive'}
                    color={p.status === 'active' ? 'success' : 'default'}
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
