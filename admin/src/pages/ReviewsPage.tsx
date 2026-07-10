import { useState } from 'react';
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
  IconButton,
  MenuItem,
  TextField,
  Rating,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  Snackbar,
  Alert,
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';

const initialReviews = [
  { id: '1', customer: 'Ananya Sharma', product: 'Organic Tomatoes', rating: 5, comment: 'Super fresh and tasty! Will order again.', date: '07 Jul 2026' },
  { id: '2', customer: 'Rahul Verma', product: 'Basmati Rice (5 kg)', rating: 4, comment: 'Good quality, packaging could be better.', date: '06 Jul 2026' },
  { id: '3', customer: 'Priya Patel', product: 'A2 Cow Milk (1 L)', rating: 3, comment: 'Decent but expected better freshness.', date: '05 Jul 2026' },
  { id: '4', customer: 'Vikram Singh', product: 'Alphonso Mangoes', rating: 5, comment: 'Best mangoes I have ever had!', date: '05 Jul 2026' },
  { id: '5', customer: 'Neha Gupta', product: 'Groundnut Oil', rating: 2, comment: 'Received wrong variant. Disappointing.', date: '04 Jul 2026' },
  { id: '6', customer: 'Arun Mehta', product: 'Fresh Spinach', rating: 1, comment: 'Arrived wilted and unusable.', date: '03 Jul 2026' },
  { id: '7', customer: 'Kavita Rao', product: 'Raw Honey (500 g)', rating: 4, comment: 'Authentic taste, love it.', date: '02 Jul 2026' },
];

type FilterValue = 'all' | '5' | '4' | 'flagged';

export default function ReviewsPage() {
  const [reviews, setReviews] = useState(initialReviews);
  const [filter, setFilter] = useState<FilterValue>('all');
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [snackOpen, setSnackOpen] = useState(false);

  const filtered = reviews.filter((r) => {
    if (filter === '5') return r.rating === 5;
    if (filter === '4') return r.rating === 4;
    if (filter === 'flagged') return r.rating <= 2;
    return true;
  });

  const handleRemove = () => {
    setReviews((prev) => prev.filter((r) => r.id !== deleteId));
    setDeleteId(null);
    setSnackOpen(true);
  };

  return (
    <Box>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Typography variant="h5" fontWeight={700}>
          Reviews
        </Typography>
        <TextField
          select
          size="small"
          value={filter}
          onChange={(e) => setFilter(e.target.value as FilterValue)}
          sx={{ minWidth: 180 }}
          label="Filter by Rating"
          variant="outlined"
        >
          <MenuItem value="all">All Ratings</MenuItem>
          <MenuItem value="5">⭐ 5 Star</MenuItem>
          <MenuItem value="4">⭐ 4 Star</MenuItem>
          <MenuItem value="flagged">⚠️ 1–2 Star (Flagged)</MenuItem>
        </TextField>
      </Box>

      {/* Table */}
      <TableContainer component={Paper} elevation={0}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Customer</TableCell>
              <TableCell>Product</TableCell>
              <TableCell>Rating</TableCell>
              <TableCell>Comment</TableCell>
              <TableCell>Date</TableCell>
              <TableCell align="center">Action</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filtered.map((r) => (
              <TableRow
                key={r.id}
                hover
                sx={{
                  bgcolor: r.rating <= 2 ? 'rgba(211,47,47,0.04)' : 'transparent',
                }}
              >
                <TableCell sx={{ fontWeight: 500 }}>{r.customer}</TableCell>
                <TableCell>{r.product}</TableCell>
                <TableCell>
                  <Rating value={r.rating} readOnly size="small" />
                </TableCell>
                <TableCell sx={{ maxWidth: 280, whiteSpace: 'normal' }}>{r.comment}</TableCell>
                <TableCell>{r.date}</TableCell>
                <TableCell align="center">
                  <IconButton
                    size="small"
                    color="error"
                    sx={{ transition: 'all 0.2s ease' }}
                    onClick={() => setDeleteId(r.id)}
                  >
                    <DeleteIcon sx={{ fontSize: 20 }} />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
            {filtered.length === 0 && (
              <TableRow>
                <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                  <Typography color="text.secondary">No reviews match this filter.</Typography>
                </TableCell>
              </TableRow>
            )}
          </TableBody>
        </Table>
      </TableContainer>

      {/* ── Remove Confirmation Dialog ── */}
      <Dialog open={!!deleteId} onClose={() => setDeleteId(null)} maxWidth="xs" fullWidth>
        <DialogTitle sx={{ fontWeight: 600, color: '#0A2540' }}>Remove Review</DialogTitle>
        <DialogContent>
          <Typography>Are you sure you want to remove this review? This action cannot be undone.</Typography>
        </DialogContent>
        <DialogActions sx={{ px: 3, py: 2 }}>
          <Button onClick={() => setDeleteId(null)}>Cancel</Button>
          <Button variant="contained" color="error" onClick={handleRemove}>Remove</Button>
        </DialogActions>
      </Dialog>

      {/* ── Snackbar ── */}
      <Snackbar
        open={snackOpen}
        autoHideDuration={3000}
        onClose={() => setSnackOpen(false)}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert onClose={() => setSnackOpen(false)} severity="success" variant="filled" sx={{ borderRadius: 2 }}>
          Review removed (demo only)
        </Alert>
      </Snackbar>
    </Box>
  );
}
