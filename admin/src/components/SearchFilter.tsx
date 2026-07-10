import { TextField, MenuItem, InputAdornment, Box } from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';

interface FilterOption {
  value: string;
  label: string;
}

interface Props {
  searchValue?: string;
  searchPlaceholder?: string;
  onSearchChange?: (value: string) => void;
  filters?: { key: string; label: string; options: FilterOption[]; value: string }[];
  onFilterChange?: (key: string, value: string) => void;
}

export default function SearchFilter({ searchValue = '', searchPlaceholder = 'Search...', onSearchChange, filters, onFilterChange }: Props) {
  return (
    <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap', alignItems: 'center' }}>
      {onSearchChange && (
        <TextField
          size="small"
          placeholder={searchPlaceholder}
          value={searchValue}
          onChange={(e) => onSearchChange(e.target.value)}
          sx={{ minWidth: 280 }}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <SearchIcon fontSize="small" />
              </InputAdornment>
            ),
          }}
        />
      )}
      {filters?.map((filter) => (
        <TextField
          key={filter.key}
          size="small"
          select
          label={filter.label}
          value={filter.value}
          onChange={(e) => onFilterChange?.(filter.key, e.target.value)}
          sx={{ minWidth: 160 }}
        >
          <MenuItem value="">All</MenuItem>
          {filter.options.map((opt) => (
            <MenuItem key={opt.value} value={opt.value}>{opt.label}</MenuItem>
          ))}
        </TextField>
      ))}
    </Box>
  );
}
