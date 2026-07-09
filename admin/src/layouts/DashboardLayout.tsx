import { Box, Toolbar } from '@mui/material';
import { Outlet } from 'react-router-dom';
import Sidebar, { SIDEBAR_WIDTH } from '../components/Sidebar';
import Topbar from '../components/Topbar';

export default function DashboardLayout() {
  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'background.default' }}>
      <Sidebar />
      <Topbar />

      {/* Main content area */}
      <Box
        component="main"
        className="page-fade-in"
        sx={{
          flexGrow: 1,
          ml: `${SIDEBAR_WIDTH}px`,
          p: 4,
        }}
      >
        {/* Spacer so content starts below the AppBar */}
        <Toolbar />
        <Outlet />
      </Box>
    </Box>
  );
}
