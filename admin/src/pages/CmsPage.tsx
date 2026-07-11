import React, { useState, useEffect } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { adminService } from '../services/admin.service';
import PageHeader from '../components/PageHeader';
import {
  Box,
  Typography,
  Card,
  CardContent,
  TextField,
  Button,
  Tabs,
  Tab,
  Divider,
} from '@mui/material';
import Save from '@mui/icons-material/Save';
import toast from 'react-hot-toast';

interface CmsContent {
  id: string;
  key: string;
  title: string;
  content: string;
}

const TAB_KEYS = [
  { key: 'about_us', label: 'About Us' },
  { key: 'contact_us', label: 'Contact Us' },
  { key: 'faq', label: 'FAQ' },
  { key: 'privacy_policy', label: 'Privacy Policy' },
  { key: 'terms_conditions', label: 'Terms & Conditions' },
];

const CmsPage: React.FC = () => {
  const [activeTab, setActiveTab] = useState(0);
  const [editedContent, setEditedContent] = useState<Record<string, { title: string; content: string }>>({});

  const { data: cmsData = [], isLoading } = useQuery({
    queryKey: ['cms'],
    queryFn: () => adminService.getCmsContent(),
  });

  useEffect(() => {
    if (Array.isArray(cmsData) && cmsData.length > 0) {
      const initial: Record<string, { title: string; content: string }> = {};
      cmsData.forEach((item: CmsContent) => {
        initial[item.key] = { title: item.title, content: item.content };
      });
      setEditedContent(initial);
    }
  }, [cmsData]);

  const updateMutation = useMutation({
    mutationFn: ({ key, data }: { key: string; data: { title: string; content: string } }) =>
      adminService.updateCmsContent(key, data),
    onSuccess: () => {
      toast.success('Content updated successfully');
    },
    onError: () => {
      toast.error('Failed to update content');
    },
  });

  const currentTabKey = TAB_KEYS[activeTab]?.key || '';
  const currentData = editedContent[currentTabKey] || { title: '', content: '' };

  const handleTitleChange = (value: string) => {
    setEditedContent((prev) => ({
      ...prev,
      [currentTabKey]: { ...prev[currentTabKey], title: value },
    }));
  };

  const handleContentChange = (value: string) => {
    setEditedContent((prev) => ({
      ...prev,
      [currentTabKey]: { ...prev[currentTabKey], content: value },
    }));
  };

  const handleSave = () => {
    updateMutation.mutate({
      key: currentTabKey,
      data: {
        title: currentData.title,
        content: currentData.content,
      },
    });
  };

  return (
    <Box>
      <PageHeader title="Content Management" />

      <Card>
        <CardContent>
          <Tabs
            value={activeTab}
            onChange={(_, newValue) => setActiveTab(newValue)}
            variant="scrollable"
            scrollButtons="auto"
          >
            {TAB_KEYS.map((tab) => (
              <Tab key={tab.key} label={tab.label} />
            ))}
          </Tabs>

          <Divider sx={{ my: 2 }} />

          {isLoading ? (
            <Typography>Loading content...</Typography>
          ) : (
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
              <TextField
                fullWidth
                label="Title"
                value={currentData.title}
                onChange={(e) => handleTitleChange(e.target.value)}
              />
              <TextField
                fullWidth
                label="Content"
                multiline
                rows={10}
                value={currentData.content}
                onChange={(e) => handleContentChange(e.target.value)}
              />
              <Box sx={{ display: 'flex', justifyContent: 'flex-end' }}>
                <Button
                  variant="contained"
                  startIcon={<Save />}
                  onClick={handleSave}
                  disabled={updateMutation.isPending}
                >
                  {updateMutation.isPending ? 'Saving...' : 'Save'}
                </Button>
              </Box>
            </Box>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};

export default CmsPage;
