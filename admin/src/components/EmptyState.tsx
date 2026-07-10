import { Box, Typography } from '@mui/material';
import InboxIcon from '@mui/icons-material/InboxOutlined';

export default function EmptyState({ message = 'No data found', icon }: { message?: string; icon?: React.ReactNode }) {
  return (
    <Box sx={{ textAlign: 'center', py: 8 }}>
      {icon || <InboxIcon sx={{ fontSize: 64, color: 'grey.300', mb: 2 }} />}
      <Typography color="text.secondary" variant="h6">{message}</Typography>
    </Box>
  );
}
