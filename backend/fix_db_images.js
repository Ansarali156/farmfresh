const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const categoryImages = {
  'fruits': [
    'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500', // Apples
    'https://images.unsplash.com/photo-1557800636-894a64c1696f?w=500', // Oranges
    'https://images.unsplash.com/photo-1528825871115-3581a5387919?w=500', // Bananas
    'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=500', // Pineapple
    'https://images.unsplash.com/photo-1587132137056-bfbf0166836e?w=500', // Mango
  ],
  'vegetables': [
    'https://images.unsplash.com/photo-1595855759920-86582396756a?w=500', // Tomatoes
    'https://images.unsplash.com/photo-1598170845058-12ef4a457939?w=500', // Carrots
    'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500', // Potatoes
    'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500', // Spinach
    'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=500', // Cucumber
  ],
  'dairy': [
    'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=500', // Milk
    'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500', // Cheese
    'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=500', // Butter
    'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=500', // Yogurt
  ],
  'meat': [
    'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=500', // Fresh Chicken
    'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500', // Beef/Meat
  ],
  'default': [
    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500', // Fresh Grocery
    'https://images.unsplash.com/photo-1610348725531-843dff563e2c?w=500', // Fresh produce
  ]
};

function getImageUrlForProduct(productName, categoryName) {
  const nameLower = (productName || '').toLowerCase();
  const catLower = (categoryName || '').toLowerCase();

  if (nameLower.includes('apple') || nameLower.includes('fruit') || catLower.includes('fruit')) {
    return categoryImages.fruits[Math.floor(Math.random() * categoryImages.fruits.length)];
  }
  if (nameLower.includes('tomato') || nameLower.includes('carrot') || nameLower.includes('potato') || catLower.includes('veg')) {
    return categoryImages.vegetables[Math.floor(Math.random() * categoryImages.vegetables.length)];
  }
  if (nameLower.includes('milk') || nameLower.includes('curd') || nameLower.includes('paneer') || nameLower.includes('butter') || catLower.includes('dairy')) {
    return categoryImages.dairy[Math.floor(Math.random() * categoryImages.dairy.length)];
  }
  if (nameLower.includes('chicken') || nameLower.includes('meat') || nameLower.includes('mutton') || catLower.includes('meat')) {
    return categoryImages.meat[Math.floor(Math.random() * categoryImages.meat.length)];
  }
  return categoryImages.default[Math.floor(Math.random() * categoryImages.default.length)];
}

async function fixBrokenImages() {
  console.log('Fixing broken product image URLs in database...');
  const products = await prisma.product.findMany({
    include: { images: true }
  });

  let count = 0;
  for (const product of products) {
    for (const image of product.images) {
      if (image.imageUrl.includes('storageapi.dev') || image.imageUrl.includes('forbidden') || image.imageUrl.includes('undefined')) {
        const newUrl = getImageUrlForProduct(product.name, product.category);
        await prisma.productImage.update({
          where: { id: image.id },
          data: { imageUrl: newUrl }
        });
        count++;
        console.log(`Updated product "${product.name}" (${product.id}) image -> ${newUrl}`);
      }
    }
  }
  console.log(`Successfully fixed ${count} broken product image URLs!`);
}

fixBrokenImages()
  .catch((err) => console.error(err))
  .finally(async () => {
    await prisma.$disconnect();
  });
