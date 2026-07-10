import { Card, CardContent, Box, Typography } from '@mui/material';
import type { ReactNode } from 'react';

interface Props {
  title: string;
  value: string | number;
  icon: ReactNode;
  color: string;
  bg: string;
  subtitle?: string;
}

export default function StatsCard({ title, value, icon, color, bg, subtitle }: Props) {
  return (
    <Card elevation={0} sx={{ border: '1px solid', borderColor: 'divider', borderRadius: 2, transition: 'box-shadow 0.2s', '&:hover': { boxShadow: 3 } }}>
      <CardContent sx={{ display: 'flex', alignItems: 'center', gap: 2.5, p: 3, '&:last-child': { pb: 3 } }}>
        <Box sx={{ width: 48, height: 48, borderRadius: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center', bgcolor: bg, color, '& .MuiSvgIcon-root': { fontSize: 24 } }}>
          {icon}
        </Box>
        <Box>
          <Typography variant="body2" color="text.secondary" sx={{ fontSize: 13 }}>{title}</Typography>
          <Typography variant="h5" fontWeight={700} sx={{ lineHeight: 1.3 }}>{value}</Typography>
          {subtitle && <Typography variant="caption" color="text.secondary">{subtitle}</Typography>}
        </Box>
      </CardContent>
    </Card>
  );
}
