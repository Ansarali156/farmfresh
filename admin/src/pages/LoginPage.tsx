import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Box, Card, CardContent, Typography, Button, TextField, Alert } from '@mui/material';
import { useAuth } from '../contexts/AuthContext';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email || !password) {
      setError('Please enter email and password');
      return;
    }
    setLoading(true);
    setError('');
    try {
      await login(email, password);
      navigate('/', { replace: true });
    } catch (err: any) {
      const msg = err.response?.data?.message || err.message || 'Login failed';
      setError(msg);
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
        background: 'linear-gradient(160deg, #e8f5e9 0%, #f1f8e9 30%, #ffffff 70%, #f5f7fa 100%)',
        position: 'relative', overflow: 'hidden',
        '&::before': { content: '""', position: 'absolute', width: 500, height: 500, borderRadius: '50%', background: 'radial-gradient(circle, rgba(46,125,50,0.07) 0%, transparent 70%)', top: -120, right: -100 },
        '&::after': { content: '""', position: 'absolute', width: 400, height: 400, borderRadius: '50%', background: 'radial-gradient(circle, rgba(10,37,64,0.05) 0%, transparent 70%)', bottom: -80, left: -60 },
      }}
    >
      <Card
        elevation={0}
        className="page-fade-in"
        sx={{ width: '100%', maxWidth: 420, border: '1px solid rgba(0,0,0,0.08)', bgcolor: 'rgba(255,255,255,0.92)', backdropFilter: 'blur(16px)', zIndex: 1 }}
      >
        <CardContent sx={{ p: 5 }}>
          <Box sx={{ textAlign: 'center', mb: 4 }}>
            <Typography variant="h4" fontWeight={700} color="#0A2540" mb={0.5}>FarmFresh</Typography>
            <Typography variant="body2" color="text.secondary">Sign in to your admin dashboard</Typography>
          </Box>

          {error && <Alert severity="error" sx={{ mb: 2 }}>{error}</Alert>}

          <Box component="form" onSubmit={handleSubmit}>
            <TextField
              fullWidth label="Email Address" type="email" value={email}
              onChange={(e) => setEmail(e.target.value)} margin="normal" autoFocus
            />
            <TextField
              fullWidth label="Password" type="password" value={password}
              onChange={(e) => setPassword(e.target.value)} margin="normal"
            />
            <Button type="submit" variant="contained" fullWidth size="large" disabled={loading} sx={{ py: 1.5, fontSize: 16, mt: 3 }}>
              {loading ? 'Signing in...' : 'Sign In'}
            </Button>
          </Box>
        </CardContent>
      </Card>
    </Box>
  );
}
