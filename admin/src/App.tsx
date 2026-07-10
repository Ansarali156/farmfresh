import { Routes, Route } from 'react-router-dom';
import DashboardLayout from './layouts/DashboardLayout';
import ProtectedRoute from './components/ProtectedRoute';
import LoginPage from './pages/LoginPage';
import DashboardPage from './pages/DashboardPage';
import AnalyticsPage from './pages/AnalyticsPage';
import ProductsPage from './pages/ProductsPage';
import ProductApprovalPage from './pages/ProductApprovalPage';
import CategoriesPage from './pages/CategoriesPage';
import OrdersPage from './pages/OrdersPage';
import OrderIssuesPage from './pages/OrderIssuesPage';
import FarmersPage from './pages/FarmersPage';
import DeliveryPartnersPage from './pages/DeliveryPartnersPage';
import PayoutsPage from './pages/PayoutsPage';
import ReviewsPage from './pages/ReviewsPage';
import CouponsPage from './pages/CouponsPage';
import InventoryAlertsPage from './pages/InventoryAlertsPage';
import SettingsPage from './pages/SettingsPage';

export default function App() {
  return (
    <Routes>
      {/* Public route */}
      <Route path="/login" element={<LoginPage />} />

      {/* Protected routes */}
      <Route
        element={
          <ProtectedRoute>
            <DashboardLayout />
          </ProtectedRoute>
        }
      >
        <Route path="/" element={<DashboardPage />} />
        <Route path="/analytics" element={<AnalyticsPage />} />
        <Route path="/products" element={<ProductsPage />} />
        <Route path="/product-approval" element={<ProductApprovalPage />} />
        <Route path="/categories" element={<CategoriesPage />} />
        <Route path="/orders" element={<OrdersPage />} />
        <Route path="/order-issues" element={<OrderIssuesPage />} />
        <Route path="/farmers" element={<FarmersPage />} />
        <Route path="/delivery-partners" element={<DeliveryPartnersPage />} />
        <Route path="/payouts" element={<PayoutsPage />} />
        <Route path="/reviews" element={<ReviewsPage />} />
        <Route path="/coupons" element={<CouponsPage />} />
        <Route path="/inventory-alerts" element={<InventoryAlertsPage />} />
        <Route path="/settings" element={<SettingsPage />} />
      </Route>
    </Routes>
  );
}
