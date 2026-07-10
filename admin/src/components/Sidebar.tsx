import { useLocation, useNavigate } from 'react-router-dom';
import {
  Box,
  List,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  Typography,
} from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import InventoryIcon from '@mui/icons-material/Inventory';
import ShoppingCartIcon from '@mui/icons-material/ShoppingCart';
import AgricultureIcon from '@mui/icons-material/Agriculture';
import LocalShippingIcon from '@mui/icons-material/LocalShipping';
import DiscountIcon from '@mui/icons-material/Discount';
import CategoryIcon from '@mui/icons-material/Category';
import WarningAmberIcon from '@mui/icons-material/WarningAmber';
import PaymentsIcon from '@mui/icons-material/Payments';
import BarChartIcon from '@mui/icons-material/BarChart';
import StarIcon from '@mui/icons-material/Star';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';
import SettingsIcon from '@mui/icons-material/Settings';
import PendingActionsIcon from '@mui/icons-material/PendingActions';

const SIDEBAR_WIDTH = 260;

const navItems = [
  { label: 'Dashboard', icon: <DashboardIcon />, path: '/' },
  { label: 'Analytics', icon: <BarChartIcon />, path: '/analytics' },
  { label: 'Products', icon: <InventoryIcon />, path: '/products' },
  { label: 'Product Approval', icon: <PendingActionsIcon />, path: '/product-approval' },
  { label: 'Categories', icon: <CategoryIcon />, path: '/categories' },
  { label: 'Orders', icon: <ShoppingCartIcon />, path: '/orders' },
  { label: 'Order Issues', icon: <ReportProblemIcon />, path: '/order-issues' },
  { label: 'Farmers', icon: <AgricultureIcon />, path: '/farmers' },
  { label: 'Delivery Partners', icon: <LocalShippingIcon />, path: '/delivery-partners' },
  { label: 'Payouts', icon: <PaymentsIcon />, path: '/payouts' },
  { label: 'Reviews', icon: <StarIcon />, path: '/reviews' },
  { label: 'Coupons', icon: <DiscountIcon />, path: '/coupons' },
  { label: 'Inventory Alerts', icon: <WarningAmberIcon />, path: '/inventory-alerts' },
  { label: 'Settings', icon: <SettingsIcon />, path: '/settings' },
];

export { SIDEBAR_WIDTH };

export default function Sidebar() {
  const { pathname } = useLocation();
  const navigate = useNavigate();

  return (
    <Box
      sx={{
        width: SIDEBAR_WIDTH,
        height: '100vh',
        position: 'fixed',
        top: 0,
        left: 0,
        bgcolor: '#0A2540',
        color: '#fff',
        display: 'flex',
        flexDirection: 'column',
        zIndex: (theme) => theme.zIndex.drawer + 1,
        borderRight: '1px solid rgba(255,255,255,0.06)',
        boxShadow: '2px 0 12px rgba(0,0,0,0.15)',
      }}
    >
      {/* Brand */}
      <Box sx={{ px: 3, py: 3.5, borderBottom: '1px solid rgba(255,255,255,0.08)' }}>
        <Typography variant="h6" fontWeight={700} letterSpacing={0.5} sx={{ fontSize: 20 }}>
          🌿 FarmFresh
        </Typography>
        <Typography variant="caption" sx={{ color: 'rgba(255,255,255,0.45)', mt: 0.25, display: 'block' }}>
          Admin Panel
        </Typography>
      </Box>

      {/* Navigation — scrollable */}
      <List
        sx={{
          flex: 1,
          px: 1.5,
          pt: 2,
          pb: 2,
          overflowY: 'auto',
          '&::-webkit-scrollbar': {
            width: 4,
          },
          '&::-webkit-scrollbar-track': {
            background: 'transparent',
          },
          '&::-webkit-scrollbar-thumb': {
            background: 'rgba(255,255,255,0.15)',
            borderRadius: 2,
          },
          '&::-webkit-scrollbar-thumb:hover': {
            background: 'rgba(255,255,255,0.25)',
          },
          scrollbarWidth: 'thin',
          scrollbarColor: 'rgba(255,255,255,0.15) transparent',
        }}
      >
        {navItems.map(({ label, icon, path }) => {
          const active = pathname === path;
          return (
            <ListItemButton
              key={path}
              onClick={() => navigate(path)}
              sx={{
                borderRadius: '8px',
                mb: 0.5,
                py: 1.2,
                color: '#fff',
                bgcolor: active ? 'rgba(255,255,255,0.12)' : 'transparent',
                transition: 'all 0.2s ease',
                '&:hover': {
                  bgcolor: active ? 'rgba(255,255,255,0.15)' : 'rgba(255,255,255,0.06)',
                },
              }}
            >
              <ListItemIcon
                sx={{
                  color: active ? '#4CAF50' : 'rgba(255,255,255,0.55)',
                  minWidth: 40,
                  transition: 'color 0.2s ease',
                  '& .MuiSvgIcon-root': { fontSize: 22 },
                }}
              >
                {icon}
              </ListItemIcon>
              <ListItemText
                primary={label}
                primaryTypographyProps={{
                  fontSize: 14,
                  fontWeight: active ? 600 : 400,
                  letterSpacing: '0.01em',
                }}
              />
              {active && (
                <Box
                  sx={{
                    width: 4,
                    height: 20,
                    borderRadius: 2,
                    bgcolor: '#4CAF50',
                    position: 'absolute',
                    right: 8,
                  }}
                />
              )}
            </ListItemButton>
          );
        })}
      </List>
    </Box>
  );
}
