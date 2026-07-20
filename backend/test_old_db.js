const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: "postgresql://postgres:hefpFpUuLoiNXFgIhKDhLQpiqHHkvpMf@tokaido.proxy.rlwy.net:27364/railway"
    }
  }
});

async function main() {
  try {
    const user = await prisma.user.findFirst();
    console.log("Success! Found user:", user ? user.id : "None");
  } catch (err) {
    console.error("Prisma error:", err);
  } finally {
    await prisma.$disconnect();
  }
}
main();
