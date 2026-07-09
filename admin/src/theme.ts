import { createTheme } from '@mui/material/styles';

const theme = createTheme({
  palette: {
    primary: {
      main: '#0A2540',
      light: '#1a3a5c',
      dark: '#061a2e',
    },
    secondary: {
      main: '#2E7D32',
      light: '#4CAF50',
    },
    background: {
      default: '#F5F7FA',
      paper: '#FFFFFF',
    },
    divider: 'rgba(0,0,0,0.08)',
  },
  typography: {
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h4: {
      fontWeight: 600,
      letterSpacing: '-0.02em',
    },
    h5: {
      fontWeight: 700,
      letterSpacing: '-0.01em',
    },
    h6: {
      fontWeight: 600,
      letterSpacing: '-0.01em',
    },
    subtitle1: {
      fontWeight: 600,
    },
    body1: {
      fontSize: 15,
    },
    body2: {
      fontSize: 14,
    },
    caption: {
      fontSize: 12,
    },
  },
  shape: {
    borderRadius: 12,
  },
  shadows: [
    'none',
    '0 1px 3px rgba(0,0,0,0.04)',
    '0 2px 6px rgba(0,0,0,0.06)',
    '0 4px 12px rgba(0,0,0,0.06)',
    '0 6px 16px rgba(0,0,0,0.08)',
    '0 8px 24px rgba(0,0,0,0.08)',
    '0 12px 32px rgba(0,0,0,0.10)',
    '0 14px 36px rgba(0,0,0,0.10)',
    '0 16px 40px rgba(0,0,0,0.12)',
    ...Array(16).fill('0 16px 40px rgba(0,0,0,0.12)'),
  ] as any,
  components: {
    /* ── Cards ── */
    MuiCard: {
      defaultProps: { elevation: 0 },
      styleOverrides: {
        root: {
          borderRadius: 12,
          border: '1px solid rgba(0,0,0,0.08)',
          boxShadow: '0 1px 3px rgba(0,0,0,0.04)',
          transition: 'box-shadow 0.2s ease, transform 0.2s ease',
          '&:hover': {
            boxShadow: '0 4px 12px rgba(0,0,0,0.06)',
          },
        },
      },
    },
    MuiPaper: {
      styleOverrides: {
        rounded: {
          borderRadius: 12,
        },
      },
    },
    /* ── Buttons ── */
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          textTransform: 'none' as const,
          fontWeight: 600,
          transition: 'all 0.2s ease',
        },
        containedPrimary: {
          backgroundColor: '#0A2540',
          '&:hover': {
            backgroundColor: '#1a3a5c',
            boxShadow: '0 4px 12px rgba(10,37,64,0.25)',
          },
        },
      },
    },
    /* ── Text Fields ── */
    MuiOutlinedInput: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          transition: 'border-color 0.2s ease, box-shadow 0.2s ease',
          '&:hover .MuiOutlinedInput-notchedOutline': {
            borderColor: '#0A2540',
          },
          '&.Mui-focused .MuiOutlinedInput-notchedOutline': {
            borderColor: '#0A2540',
          },
        },
      },
    },
    /* ── Tables ── */
    MuiTableCell: {
      styleOverrides: {
        root: {
          fontSize: 14,
          padding: '14px 16px',
        },
        head: {
          fontWeight: 600,
          backgroundColor: '#F5F7FA',
          color: '#0A2540',
          fontSize: 13,
          textTransform: 'uppercase' as const,
          letterSpacing: '0.04em',
        },
      },
    },
    MuiTableRow: {
      styleOverrides: {
        root: {
          transition: 'background-color 0.15s ease',
          '&.MuiTableRow-hover:hover': {
            backgroundColor: 'rgba(10,37,64,0.02)',
          },
        },
      },
    },
    /* ── Chips ── */
    MuiChip: {
      styleOverrides: {
        root: {
          fontWeight: 500,
          fontSize: 12,
          borderRadius: 6,
        },
        sizeSmall: {
          height: 26,
        },
      },
    },
    /* ── Dialogs ── */
    MuiDialog: {
      styleOverrides: {
        paper: {
          borderRadius: 12,
        },
      },
    },
  },
});

export default theme;
