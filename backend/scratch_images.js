const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
  const images = await prisma.productImage.findMany({ take: 15 });
  console.log('Sample product images in database:');
  console.log(JSON.stringify(images, null, 2));
}

main()
  .catch((e) => console.error(e))
  .finally(async () => {
    await prisma.$disconnect();
  });
