import { Box, Skeleton } from '@mui/material';

export default function LoadingState({ rows = 5 }: { rows?: number }) {
  return (
    <Box>
      <Skeleton variant="rounded" width="40%" height={40} sx={{ mb: 3 }} />
      <Box sx={{ display: 'flex', gap: 2, mb: 3 }}>
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} variant="rounded" width={200} height={120} sx={{ borderRadius: 2, flex: 1 }} />
        ))}
      </Box>
      {Array.from({ length: rows }).map((_, i) => (
        <Skeleton key={i} variant="rounded" width="100%" height={52} sx={{ mb: 1, borderRadius: 1 }} />
      ))}
    </Box>
  );
}
