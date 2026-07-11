import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import PageHeader from '../components/PageHeader';
import {
  Box,
  Typography,
  Button,
  TextField,
  Grid,
  Card,
  CardContent,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Divider,
} from '@mui/material';
import Send from '@mui/icons-material/Send';
import Notifications from '@mui/icons-material/Notifications';
import toast from 'react-hot-toast';
import { format } from 'date-fns';

const NotificationsPage: React.FC = () => {
  const queryClient = useQueryClient();
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [targetRole, setTargetRole] = useState('ALL');

  const { data: notifications = [] } = useQuery({
    queryKey: ['notifications'],
    queryFn: () => adminService.getNotifications(),
  });

  const sendMutation = useMutation({
    mutationFn: (data: { title: string; body: string; targetRole: string }) =>
      adminService.sendNotification(data),
    onSuccess: () => {
      toast.success('Notification sent successfully');
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
      setTitle('');
      setBody('');
      setTargetRole('ALL');
    },
    onError: () => {
      toast.error('Failed to send notification');
    },
  });

  const handleSend = () => {
    if (!title.trim() || !body.trim()) {
      toast.error('Title and body are required');
      return;
    }
    sendMutation.mutate({ title, body, targetRole });
  };

  const getNotificationIcon = (type?: string) => {
    return <Notifications color={type === 'PROMOTION' ? 'primary' : 'action'} />;
  };

  const recentNotifications = Array.isArray(notifications) ? notifications.slice(0, 5) : [];

  return (
    <Box>
      <PageHeader title="Notification Management" />

      <Grid container spacing={3}>
        <Grid item xs={12} md={8}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Send Notification
              </Typography>
              <Divider sx={{ mb: 3 }} />
              <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
                <TextField
                  fullWidth
                  label="Title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Enter notification title"
                />
                <TextField
                  fullWidth
                  label="Body"
                  multiline
                  rows={4}
                  value={body}
                  onChange={(e) => setBody(e.target.value)}
                  placeholder="Enter notification message"
                />
                <FormControl fullWidth>
                  <InputLabel>Target Role</InputLabel>
                  <Select
                    value={targetRole}
                    label="Target Role"
                    onChange={(e) => setTargetRole(e.target.value)}
                  >
                    <MenuItem value="ALL">All Users</MenuItem>
                    <MenuItem value="CUSTOMER">Customers</MenuItem>
                    <MenuItem value="FARMER">Farmers</MenuItem>
                    <MenuItem value="DELIVERY_PARTNER">Delivery Partners</MenuItem>
                  </Select>
                </FormControl>
                <Button
                  variant="contained"
                  startIcon={<Send />}
                  onClick={handleSend}
                  disabled={sendMutation.isPending}
                  sx={{ alignSelf: 'flex-start' }}
                >
                  {sendMutation.isPending ? 'Sending...' : 'Send Notification'}
                </Button>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Recent Notifications
              </Typography>
              <Divider sx={{ mb: 2 }} />
              {recentNotifications.length === 0 ? (
                <Typography variant="body2" color="text.secondary">
                  No notifications sent yet
                </Typography>
              ) : (
                recentNotifications.map((notification: any, index: number) => (
                  <Box key={notification.id || index} sx={{ mb: 2 }}>
                    <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 1 }}>
                      {getNotificationIcon(notification.type)}
                      <Box sx={{ flex: 1 }}>
                        <Typography variant="subtitle2">{notification.title}</Typography>
                        <Typography variant="body2" color="text.secondary" noWrap>
                          {notification.body?.length > 60
                            ? `${notification.body.substring(0, 60)}...`
                            : notification.body}
                        </Typography>
                        <Box sx={{ display: 'flex', justifyContent: 'space-between', mt: 0.5 }}>
                          <Typography variant="caption" color="primary">
                            {notification.targetRole}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {notification.createdAt
                              ? format(new Date(notification.createdAt), 'MMM dd, yyyy')
                              : 'N/A'}
                          </Typography>
                        </Box>
                      </Box>
                    </Box>
                    {index < recentNotifications.length - 1 && <Divider sx={{ mt: 2 }} />}
                  </Box>
                ))
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default NotificationsPage;
