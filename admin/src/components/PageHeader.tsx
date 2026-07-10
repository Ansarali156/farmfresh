import { Box, Typography, Button } from '@mui/material';
import type { ReactNode } from 'react';

interface Props {
  title: string;
  subtitle?: string;
  action?: { label: string; onClick: () => void; icon?: ReactNode; color?: 'primary' | 'success' | 'error' };
  children?: ReactNode;
}

export default function PageHeader({ title, subtitle, action, children }: Props) {
  return (
    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 3, gap: 2, flexWrap: 'wrap' }}>
      <Box>
        <Typography variant="h5" fontWeight={700}>{title}</Typography>
        {subtitle && <Typography variant="body2" color="text.secondary" sx={{ mt: 0.5 }}>{subtitle}</Typography>}
      </Box>
      <Box sx={{ display: 'flex', gap: 1 }}>
        {children}
        {action && (
          <Button variant="contained" color={action.color || 'primary'} startIcon={action.icon} onClick={action.onClick} sx={{ textTransform: 'none' }}>
            {action.label}
          </Button>
        )}
      </Box>
    </Box>
  );
}
