const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient({ datasources: { db: { url: 'postgresql://postgres@localhost:5433/farmfresh?schema=public' } } });

async function main() {
  await prisma.$executeRawUnsafe(`ALTER USER postgres WITH PASSWORD 'password123';`);
  console.log('Password updated successfully!');
  await prisma.$disconnect();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
