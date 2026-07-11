import { Chip, type ChipProps } from '@mui/material';

const colorMap: Record<string, ChipProps['color']> = {
  ACTIVE: 'success', APPROVED: 'success', COMPLETED: 'success', DELIVERED: 'success',
  RESOLVED: 'success', PAID: 'success', VERIFIED: 'success', ENABLED: 'success',
  'Out of Stock': 'error', OUT_OF_STOCK: 'error', CANCELLED: 'error', REJECTED: 'error',
  FAILED: 'error', SUSPENDED: 'error', CLOSED: 'error', ARCHIVED: 'error',
  INACTIVE: 'default', DRAFT: 'default', PENDING: 'warning', PENDING_APPROVAL: 'warning',
  'Pending Review': 'warning', LOW_STOCK: 'warning', PROCESSING: 'info',
  CONFIRMED: 'info', PREPARING: 'info', READY_FOR_PICKUP: 'info', SHIPPED: 'info',
  OUT_FOR_DELIVERY: 'info', IN_PROGRESS: 'info', ON_DUTY: 'info', ACTIVE_ORDER: 'info',
  'On Duty': 'info', IN_TRANSIT: 'info', FLAGGED: 'warning', NOT_SUBMITTED: 'default',
};

export default function StatusChip({ status, label }: { status: string; label?: string }) {
  const normalized = status?.toUpperCase().replace(/ /g, '_');
  const color = colorMap[normalized] || colorMap[status] || 'default';
  return <Chip label={label || status} color={color} size="small" variant="outlined" />;
}
