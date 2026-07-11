import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import DataTable from '../components/DataTable';
import SearchFilter from '../components/SearchFilter';
import PageHeader from '../components/PageHeader';
import { Box, Typography, Chip } from '@mui/material';
import { format } from 'date-fns';

const AuditLogsPage: React.FC = () => {
  const [page, setPage] = useState(1);
  const [limit, setLimit] = useState(25);
  const [search, setSearch] = useState('');
  const [entity, setEntity] = useState('ALL');
  const [action, setAction] = useState('ALL');

  const { data, isLoading } = useQuery({
    queryKey: ['auditLogs', { page, limit, search, entity, action }],
    queryFn: () =>
      adminService.getAuditLogs({
        page,
        limit,
        search,
        entity: entity === 'ALL' ? undefined : entity,
        action: action === 'ALL' ? undefined : action,
      }),
  });

  const logs = data?.items || [];
  const total = data?.total || logs.length;

  const getActionColor = (actionType: string): 'success' | 'error' | 'warning' | 'info' | 'default' => {
    switch (actionType?.toUpperCase()) {
      case 'CREATE':
        return 'success';
      case 'UPDATE':
        return 'info';
      case 'DELETE':
        return 'error';
      case 'APPROVE':
        return 'success';
      case 'REJECT':
        return 'error';
      default:
        return 'default';
    }
  };

  const columns = [
    {
      key: 'createdAt',
      label: 'Timestamp',
      render: (row: any) =>
        row.createdAt ? format(new Date(row.createdAt), 'MMM dd, yyyy HH:mm:ss') : 'N/A',
    },
    {
      key: 'userName',
      label: 'User',
      render: (row: any) => row.userName || row.user?.name || row.performedBy || 'N/A',
    },
    {
      key: 'action',
      label: 'Action',
      render: (row: any) => (
        <Chip
          label={row.action}
          color={getActionColor(row.action)}
          size="small"
        />
      ),
    },
    {
      key: 'entity',
      label: 'Entity',
    },
    {
      key: 'entityId',
      label: 'Entity ID',
      render: (row: any) => (
        <Typography variant="body2" sx={{ fontFamily: 'monospace', fontSize: '0.75rem' }}>
          {row.entityId || 'N/A'}
        </Typography>
      ),
    },
    {
      key: 'details',
      label: 'Details',
      render: (row: any) => (
        <Typography variant="body2" noWrap sx={{ maxWidth: 200 }}>
          {row.details || row.description || '-'}
        </Typography>
      ),
    },
    {
      key: 'ipAddress',
      label: 'IP Address',
      render: (row: any) => (
        <Typography variant="body2" sx={{ fontFamily: 'monospace' }}>
          {row.ipAddress || row.ip || 'N/A'}
        </Typography>
      ),
    },
  ];

  const entityOptions = [
    { value: 'ALL', label: 'All Entities' },
    { value: 'USER', label: 'User' },
    { value: 'PRODUCT', label: 'Product' },
    { value: 'ORDER', label: 'Order' },
    { value: 'DELIVERY', label: 'Delivery' },
    { value: 'INVENTORY', label: 'Inventory' },
    { value: 'CATEGORY', label: 'Category' },
  ];

  const actionOptions = [
    { value: 'ALL', label: 'All Actions' },
    { value: 'CREATE', label: 'Create' },
    { value: 'UPDATE', label: 'Update' },
    { value: 'DELETE', label: 'Delete' },
    { value: 'APPROVE', label: 'Approve' },
    { value: 'REJECT', label: 'Reject' },
  ];

  return (
    <Box>
      <PageHeader title="Audit Logs" />

      <SearchFilter
        searchValue={search}
        onSearchChange={setSearch}
        searchPlaceholder="Search by user or action..."
        onFilterChange={(key, value) => {
          if (key === 'entity') setEntity(value);
          if (key === 'action') setAction(value);
        }}
        filters={[
          {
            key: 'entity',
            label: 'Entity',
            value: entity,
            options: entityOptions,
          },
          {
            key: 'action',
            label: 'Action',
            value: action,
            options: actionOptions,
          },
        ]}
      />

      <Box sx={{ mt: 2 }}>
        <DataTable
          columns={columns}
          data={logs}
          loading={isLoading}
          page={page}
          total={total}
          rowsPerPage={limit}
          onPageChange={setPage}
          onRowsPerPageChange={(newLimit) => {
            setLimit(newLimit);
            setPage(1);
          }}
        />
      </Box>
    </Box>
  );
};

export default AuditLogsPage;
