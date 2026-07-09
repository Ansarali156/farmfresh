import { useNavigate } from 'react-router-dom';
import { Box, Card, CardContent, Typography, Button } from '@mui/material';

export default function LoginPage() {
  const navigate = useNavigate();

  const handleLogin = () => {
    localStorage.setItem('isLoggedIn', 'true');
    navigate('/', { replace: true });
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: 'linear-gradient(160deg, #e8f5e9 0%, #f1f8e9 30%, #ffffff 70%, #f5f7fa 100%)',
        position: 'relative',
        overflow: 'hidden',
        '&::before': {
          content: '""',
          position: 'absolute',
          width: 500,
          height: 500,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(46,125,50,0.07) 0%, transparent 70%)',
          top: -120,
          right: -100,
        },
        '&::after': {
          content: '""',
          position: 'absolute',
          width: 400,
          height: 400,
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(10,37,64,0.05) 0%, transparent 70%)',
          bottom: -80,
          left: -60,
        },
      }}
    >
      <Card
        elevation={0}
        className="page-fade-in"
        sx={{
          width: '100%',
          maxWidth: 420,
          border: '1px solid rgba(0,0,0,0.08)',
          bgcolor: 'rgba(255,255,255,0.92)',
          backdropFilter: 'blur(16px)',
          zIndex: 1,
        }}
      >
        <CardContent sx={{ p: 5, textAlign: 'center' }}>
          {/* Branding */}
          <Typography variant="h4" fontWeight={700} color="#0A2540" mb={0.5}>
            🌿 FarmFresh
          </Typography>
          <Typography variant="body2" color="text.secondary" mb={4}>
            Sign in to your admin dashboard
          </Typography>

          {/* Single login button */}
          <Button
            onClick={handleLogin}
            variant="contained"
            fullWidth
            size="large"
            sx={{ py: 1.5, fontSize: 16 }}
          >
            Login as Admin
          </Button>

          {/* Demo note */}
          <Typography variant="caption" color="text.secondary" display="block" mt={2.5}>
            Demo login — authentication will be added once backend is ready.
          </Typography>
        </CardContent>
      </Card>
    </Box>
  );
}
