const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const imageMapping = {
  tomato: 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=500',
  onion: 'https://images.unsplash.com/photo-1618228476711-23094cfb8356?w=500',
  mango: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500',
  rice: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
  paneer: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500',
  coriander: 'https://images.unsplash.com/photo-1608797178974-15b35a61d121?w=500',
  cauliflower: 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ecf?w=500',
  atta: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
  wheat: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
  ginger: 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=500',
  spinach: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500',
  apple: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
  ghee: 'https://images.unsplash.com/photo-1627998826726-2580790757a6?w=500',
  potato: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500',
};

async function main() {
  console.log('Checking database products for missing images...');
  const products = await prisma.product.findMany({
    include: { images: true },
  });

  let createdCount = 0;
  for (const product of products) {
    if (product.images.length === 0) {
      // Find matching Unsplash image URL
      const lowerName = product.name.toLowerCase();
      let matchedUrl = 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500'; // fallback

      for (const [key, url] of Object.entries(imageMapping)) {
        if (lowerName.includes(key)) {
          matchedUrl = url;
          break;
        }
      }

      await prisma.productImage.create({
        data: {
          productId: product.id,
          imageUrl: matchedUrl,
          isPrimary: true,
        },
      });
      console.log(`Added image for product: ${product.name}`);
      createdCount++;
    }
  }

  console.log(`Seeding complete. Created ${createdCount} product image records.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
