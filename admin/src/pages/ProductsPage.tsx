import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
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
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Stack,
  Snackbar,
  Alert,
  Chip,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

const products = [
  { id: '1', name: 'Organic Tomatoes', category: 'Vegetables', price: 60, stock: 120, farmer: 'Ramesh Kumar' },
  { id: '2', name: 'Basmati Rice (5 kg)', category: 'Grains', price: 450, stock: 45, farmer: 'Sunil Reddy' },
  { id: '3', name: 'Fresh Mangoes (Alphonso)', category: 'Fruits', price: 350, stock: 80, farmer: 'Anita Desai' },
  { id: '4', name: 'A2 Cow Milk (1 L)', category: 'Dairy', price: 75, stock: 200, farmer: 'Meera Patel' },
  { id: '5', name: 'Cold-Pressed Groundnut Oil', category: 'Oils', price: 280, stock: 30, farmer: 'Harish Joshi' },
];

export default function ProductsPage() {
  const navigate = useNavigate();
  const [dialogOpen, setDialogOpen] = useState(false);
  const [snackOpen, setSnackOpen] = useState(false);

  const handleSave = () => {
    setDialogOpen(false);
    setSnackOpen(true);
  };

  return (
    <Box>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box display="flex" alignItems="center" gap={1.5}>
          <Typography variant="h5" fontWeight={700}>
            Products
          </Typography>
          <Chip
            label="6 pending approval"
            size="small"
            onClick={() => navigate('/product-approval')}
            sx={{
              bgcolor: '#FFF3E0',
              color: '#E65100',
              fontWeight: 600,
              cursor: 'pointer',
              transition: 'all 0.2s ease',
              '&:hover': {
                bgcolor: '#FFE0B2',
                boxShadow: '0 2px 8px rgba(230,81,0,0.15)',
              },
            }}
          />
        </Box>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => setDialogOpen(true)}>
          Add Product
        </Button>
      </Box>

      {/* Table */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Name</TableCell>
              <TableCell>Category</TableCell>
              <TableCell align="right">Price (₹)</TableCell>
              <TableCell align="right">Stock</TableCell>
              <TableCell>Farmer</TableCell>
              <TableCell align="center">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {products.map((p) => (
              <TableRow key={p.id} hover>
                <TableCell sx={{ fontWeight: 500 }}>{p.name}</TableCell>
                <TableCell>{p.category}</TableCell>
                <TableCell align="right">{p.price}</TableCell>
                <TableCell align="right">{p.stock}</TableCell>
                <TableCell>{p.farmer}</TableCell>
                <TableCell align="center">
                  <IconButton size="small" color="primary" sx={{ transition: 'all 0.2s ease' }}>
                    <EditIcon sx={{ fontSize: 20 }} />
                  </IconButton>
                  <IconButton size="small" color="error" sx={{ transition: 'all 0.2s ease' }}>
                    <DeleteIcon sx={{ fontSize: 20 }} />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ── Add Product Dialog ── */}
      <Dialog open={dialogOpen} onClose={() => setDialogOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>
          Add New Product
        </DialogTitle>
        <DialogContent dividers>
          <Stack spacing={3} sx={{ pt: 1 }}>
            <TextField label="Product Name" variant="outlined" fullWidth />
            <TextField label="Category" variant="outlined" fullWidth />
            <TextField label="Price (₹)" variant="outlined" fullWidth type="number" />
            <TextField label="Stock" variant="outlined" fullWidth type="number" />
            <TextField label="Farmer Name" variant="outlined" fullWidth />
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setDialogOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>

      {/* ── Success Snackbar ── */}
      <Snackbar
        open={snackOpen}
        autoHideDuration={3000}
        onClose={() => setSnackOpen(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert onClose={() => setSnackOpen(false)} severity="success" variant="filled" sx={{ borderRadius: 2 }}>
          Product added (demo only, not saved to database yet)
        </Alert>
      </Snackbar>
    </Box>
  );
}
