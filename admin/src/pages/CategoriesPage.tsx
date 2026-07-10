import { useState } from 'react';
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
  Chip,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Stack,
  MenuItem,
  Snackbar,
  Alert,
} from '@mui/material';
import AddIcon from '@mui/icons-material/Add';
import EditIcon from '@mui/icons-material/Edit';
import DeleteIcon from '@mui/icons-material/Delete';

const iconOptions = [
  { value: '🥦', label: '🥦 Vegetables' },
  { value: '🍎', label: '🍎 Fruits' },
  { value: '🌾', label: '🌾 Grains' },
  { value: '🥛', label: '🥛 Dairy' },
  { value: '🫒', label: '🫒 Oils' },
  { value: '🍯', label: '🍯 Honey & Preserves' },
  { value: '🌿', label: '🌿 Herbs' },
  { value: '🥜', label: '🥜 Nuts & Seeds' },
];

const initialCategories = [
  { id: '1', name: 'Vegetables', products: 34, icon: '🥦', status: 'active' as const },
  { id: '2', name: 'Fruits', products: 22, icon: '🍎', status: 'active' as const },
  { id: '3', name: 'Grains & Cereals', products: 18, icon: '🌾', status: 'active' as const },
  { id: '4', name: 'Dairy', products: 12, icon: '🥛', status: 'active' as const },
  { id: '5', name: 'Oils', products: 8, icon: '🫒', status: 'inactive' as const },
  { id: '6', name: 'Honey & Preserves', products: 5, icon: '🍯', status: 'active' as const },
];

export default function CategoriesPage() {
  const [categories, setCategories] = useState(initialCategories);
  const [addOpen, setAddOpen] = useState(false);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [snackMsg, setSnackMsg] = useState('');

  /* form state */
  const [formName, setFormName] = useState('');
  const [formDesc, setFormDesc] = useState('');
  const [formIcon, setFormIcon] = useState('🥦');

  const handleAdd = () => {
    setCategories((prev) => [
      ...prev,
      { id: String(Date.now()), name: formName || 'New Category', products: 0, icon: formIcon, status: 'active' as const },
    ]);
    setAddOpen(false);
    setFormName('');
    setFormDesc('');
    setFormIcon('🥦');
    setSnackMsg('Category added (demo only)');
  };

  const handleDelete = () => {
    setCategories((prev) => prev.filter((c) => c.id !== deleteId));
    setDeleteId(null);
    setSnackMsg('Category deleted (demo only)');
  };

  return (
    <Box>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>
          Categories
        </Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => setAddOpen(true)}>
          Add Category
        </Button>
      </Box>

      {/* Table */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Icon</TableCell>
              <TableCell>Name</TableCell>
              <TableCell align="right">Products</TableCell>
              <TableCell>Status</TableCell>
              <TableCell align="center">Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {categories.map((c) => (
              <TableRow key={c.id} hover>
                <TableCell sx={{ fontSize: 24, width: 60 }}>{c.icon}</TableCell>
                <TableCell sx={{ fontWeight: 500 }}>{c.name}</TableCell>
                <TableCell align="right">{c.products}</TableCell>
                <TableCell>
                  <Chip
                    label={c.status === 'active' ? 'Active' : 'Inactive'}
                    color={c.status === 'active' ? 'success' : 'default'}
                    size="small"
                    variant="outlined"
                  />
                </TableCell>
                <TableCell align="center">
                  <IconButton size="small" color="primary" sx={{ transition: 'all 0.2s ease' }}>
                    <EditIcon sx={{ fontSize: 20 }} />
                  </IconButton>
                  <IconButton
                    size="small"
                    color="error"
                    sx={{ transition: 'all 0.2s ease' }}
                    onClick={() => setDeleteId(c.id)}
                  >
                    <DeleteIcon sx={{ fontSize: 20 }} />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ── Add Category Dialog ── */}
      <Dialog open={addOpen} onClose={() => setAddOpen(false)} fullWidth maxWidth="sm">
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Add New Category</DialogTitle>
        <DialogContent dividers>
          <Stack spacing={3} sx={{ pt: 1 }}>
            <TextField
              label="Category Name"
              variant="outlined"
              fullWidth
              value={formName}
              onChange={(e) => setFormName(e.target.value)}
            />
            <TextField
              label="Description"
              variant="outlined"
              fullWidth
              multiline
              rows={2}
              value={formDesc}
              onChange={(e) => setFormDesc(e.target.value)}
            />
            <TextField
              label="Icon"
              variant="outlined"
              fullWidth
              select
              value={formIcon}
              onChange={(e) => setFormIcon(e.target.value)}
            >
              {iconOptions.map((opt) => (
                <MenuItem key={opt.value} value={opt.value} sx={{ fontSize: 16 }}>
                  {opt.label}
                </MenuItem>
              ))}
            </TextField>
          </Stack>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setAddOpen(false)}>Cancel</Button>
          <Button variant="contained" onClick={handleAdd}>Save</Button>
        </DialogActions>
      </Dialog>

      {/* ── Delete Confirmation Dialog ── */}
      <Dialog open={!!deleteId} onClose={() => setDeleteId(null)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Delete Category</DialogTitle>
        <DialogContent>
          <Typography>
            Are you sure you want to delete this category? This action cannot be undone.
          </Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setDeleteId(null)}>Cancel</Button>
          <Button variant="contained" color="error" onClick={handleDelete}>Delete</Button>
        </DialogActions>
      </Dialog>

      {/* ── Snackbar ── */}
      <Snackbar
        open={!!snackMsg}
        autoHideDuration={3000}
        onClose={() => setSnackMsg('')}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert onClose={() => setSnackMsg('')} severity="success" variant="filled" sx={{ borderRadius: 2 }}>
          {snackMsg}
        </Alert>
      </Snackbar>
    </Box>
  );
}
