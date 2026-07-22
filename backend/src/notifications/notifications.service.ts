import { Injectable } from '@nestjs/common';
import { PrismaService } from '../database/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  async getUserNotifications(userId: string, page: number = 1, limit: number = 20) {
    const skip = (page - 1) * limit;

    let count = await this.prisma.notification.count({ where: { userId } });
    if (count === 0) {
      // Create initial onboarding notifications for user
      const user = await this.prisma.user.findUnique({ where: { id: userId } });
      const role = user?.role || 'CUSTOMER';

      if (role === 'DELIVERY_PARTNER') {
        await this.prisma.notification.createMany({
          data: [
            {
              userId,
              title: 'Welcome to Express Fleet Logistics!',
              body: 'Your delivery partner account is active and verified. Turn your status ONLINE to start receiving route assignments.',
              type: 'ACCOUNT',
              isRead: false,
            },
            {
              userId,
              title: 'New Dispatch Standard Operating Procedure',
              body: 'Verify customer delivery OTP upon arrival to instantly mark orders as complete and release payouts.',
              type: 'ORDER_UPDATE',
              isRead: false,
            },
          ],
        });
      } else if (role === 'FARMER') {
        await this.prisma.notification.createMany({
          data: [
            {
              userId,
              title: 'Welcome to FarmFresh Farmer Portal!',
              body: 'Your farm profile is verified. Use the AI Assistant to list your organic produce with automated pricing recommendations.',
              type: 'ACCOUNT',
              isRead: false,
            },
            {
              userId,
              title: 'Admin Moderation Notice',
              body: 'Newly submitted crops will undergo swift Admin review before going live on the customer marketplace.',
              type: 'ORDER_UPDATE',
              isRead: false,
            },
          ],
        });
      } else {
        await this.prisma.notification.createMany({
          data: [
            {
              userId,
              title: 'Welcome to FarmFresh Marketplace!',
              body: 'Explore farm-fresh organic vegetables and fruit delivered straight from local farmers to your doorstep.',
              type: 'ACCOUNT',
              isRead: false,
            },
          ],
        });
      }

    }

    const [notifications, total] = await Promise.all([
      this.prisma.notification.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      this.prisma.notification.count({ where: { userId } }),
    ]);

    const unreadCount = await this.prisma.notification.count({
      where: { userId, isRead: false },
    });

    return {
      notifications: notifications.map(n => ({
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        isRead: n.isRead,
        createdAt: n.createdAt,
        data: null,
      })),
      total,
      unreadCount,
      hasMore: skip + notifications.length < total,
    };
  }


  async markAsRead(userId: string, notificationId: string) {
    return this.prisma.notification.updateMany({
      where: { id: notificationId, userId },
      data: { isRead: true },
    });
  }

  async markAllAsRead(userId: string) {
    return this.prisma.notification.updateMany({
      where: { userId, isRead: false },
      data: { isRead: true },
    });
  }
}
