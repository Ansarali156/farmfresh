import {
  Box,
  Typography,
  TextField,
  Button,
  Card,
  CardContent,
  Switch,
  FormControlLabel,
  Divider,
  InputAdornment,
  Stack,
} from '@mui/material';
import LockResetIcon from '@mui/icons-material/LockReset';

export default function SettingsPage() {
  return (
    <Box>
      <Typography variant="h5" fontWeight={700} mb={3}>
        Settings
      </Typography>

      <Box maxWidth={640}>
        {/* ── Profile Section ── */}
        <Card sx={{ mb: 3 }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h6" fontWeight={600} color="#0A2540" mb={3}>
              Profile
            </Typography>
            <Stack spacing={3}>
              <TextField label="Admin Name" defaultValue="Admin User" variant="outlined" fullWidth />
              <TextField label="Email" defaultValue="admin@farmfresh.in" variant="outlined" fullWidth type="email" />
              <TextField label="Phone Number" defaultValue="+91 98765 43210" variant="outlined" fullWidth type="tel" />
            </Stack>
          </CardContent>
        </Card>

        {/* ── Platform Settings Section ── */}
        <Card sx={{ mb: 3 }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h6" fontWeight={600} color="#0A2540" mb={3}>
              Platform Settings
            </Typography>
            <Stack spacing={3}>
              <TextField
                label="Delivery Charge"
                defaultValue={40}
                variant="outlined"
                fullWidth
                type="number"
                InputProps={{ startAdornment: <InputAdornment position="start">₹</InputAdornment> }}
              />
              <TextField
                label="Minimum Order Amount"
                defaultValue={200}
                variant="outlined"
                fullWidth
                type="number"
                InputProps={{ startAdornment: <InputAdornment position="start">₹</InputAdornment> }}
              />
              <TextField
                label="Commission Percentage"
                defaultValue={8}
                variant="outlined"
                fullWidth
                type="number"
                InputProps={{ endAdornment: <InputAdornment position="end">%</InputAdornment> }}
                helperText="Platform's cut from each farmer sale"
              />
            </Stack>
          </CardContent>
        </Card>

        {/* ── Notification Preferences Section ── */}
        <Card sx={{ mb: 3 }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h6" fontWeight={600} color="#0A2540" mb={3}>
              Notification Preferences
            </Typography>
            <Stack spacing={1}>
              <FormControlLabel control={<Switch defaultChecked color="primary" />} label="Email Notifications" />
              <FormControlLabel control={<Switch defaultChecked color="primary" />} label="SMS Notifications" />
              <Divider sx={{ my: 1.5 }} />
              <FormControlLabel control={<Switch defaultChecked color="primary" />} label="New Order Alerts" />
              <FormControlLabel control={<Switch color="primary" />} label="Low Stock Alerts" />
            </Stack>
          </CardContent>
        </Card>

        {/* ── Security Section ── */}
        <Card sx={{ mb: 4 }}>
          <CardContent sx={{ p: 4 }}>
            <Typography variant="h6" fontWeight={600} color="#0A2540" mb={3}>
              Security
            </Typography>
            <Stack spacing={2}>
              <Button variant="outlined" startIcon={<LockResetIcon />} sx={{ alignSelf: 'flex-start' }}>
                Change Password
              </Button>
              <FormControlLabel control={<Switch color="primary" />} label="Two-Factor Authentication" />
            </Stack>
          </CardContent>
        </Card>

        {/* ── Save Button ── */}
        <Button variant="contained" size="large" sx={{ px: 5 }}>
          Save Changes
        </Button>
      </Box>
    </Box>
  );
}
