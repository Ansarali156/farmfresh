const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const vegetables = [
  'Organic Red Spinach', 'Green Cabbage', 'Fresh Cauliflower', 'Hybrid Tomatoes', 'Red Onions',
  'Organic Potatoes', 'English Cucumber', 'Local Ginger', 'Fresh Garlic', 'Green Chillies',
  'Lady Finger (Okra)', 'Bottle Gourd', 'Bitter Gourd', 'Ridge Gourd', 'Sweet Pumpkin',
  'French Beans', 'Green Peas', 'Raw Banana', 'Organic Beetroot', 'Fresh Carrots',
  'Sweet Potato', 'Colocasia Root', 'Ivy Gourd (Tindora)', 'Drumsticks', 'Fresh Coriander Leaves',
  'Mint Leaves', 'Curry Leaves', 'Lemongrass', 'Spring Onions', 'Capsicum Green'
];

const fruits = [
  'Kesar Mango', 'Banganapalli Mango', 'Robusta Banana', 'Elaichi Banana',
  'Nagpur Oranges', 'Sweet Lime (Mosambi)', 'Pomegranate (Anar)', 'Kashmiri Red Apple', 'Green Apple',
  'Papaya (Semi-Ripe)', 'Guava (Pink)', 'Black Grapes (Seedless)', 'Green Grapes', 'Watermelon',
  'Muskmelon', 'Pineapple', 'Custard Apple', 'Sapota (Chikoo)', 'Fresh Figs',
  'Plums', 'Peaches', 'Strawberries', 'Blueberries', 'Avocado',
  'Kiwi Fruit', 'Dragon Fruit', 'Pear', 'Sweet Tamarind', 'Jackfruit'
];

const grains = [
  'Premium Basmati Rice', 'Sona Masuri Rice', 'Kolam Rice', 'Brown Rice', 'Black Rice',
  'Whole Wheat Atta', 'Multi-grain Atta', 'Pearl Millet (Bajra)', 'Finger Millet (Ragi)', 'Foxtail Millet',
  'Sorghum (Jowar)', 'Barley (Jau)', 'Organic Quinoa', 'Rolled Oats', 'Semolina (Suji)',
  'Broken Wheat (Daliya)', 'Chana Dal', 'Toor Dal', 'Urad Dal Split', 'Moong Dal Yellow'
];

const dairy = [
  'Fresh Cow Milk', 'Buffalo Milk', 'Organic Curd', 'Greek Yogurt', 'Desi Cow Ghee',
  'Buffalo Ghee', 'Fresh Paneer', 'Salted Butter', 'Unsalted Butter', 'Cheese Slices',
  'Mozzarella Cheese', 'Fresh Cream', 'Buttermilk (Chaas)', 'Sweet Lassi', 'Condensed Milk',
  'Organic Eggs (Pack of 6)', 'Free Range Eggs (Pack of 10)', 'Brown Eggs (Pack of 12)', 'Soy Milk', 'Almond Milk'
];

const imageMapping = {
  spinach: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=500',
  cabbage: 'https://images.unsplash.com/photo-1581078426775-802b15746ad4?w=500',
  cauliflower: 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ecf?w=500',
  tomato: 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=500',
  onion: 'https://images.unsplash.com/photo-1618228476711-23094cfb8356?w=500',
  potato: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=500',
  cucumber: 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=500',
  ginger: 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=500',
  garlic: 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=500',
  chilli: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=500',
  mango: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=500',
  banana: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=500',
  orange: 'https://images.unsplash.com/photo-1547514701-42782101795e?w=500',
  apple: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=500',
  grapes: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=500',
  watermelon: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=500',
  pineapple: 'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=500',
  rice: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=500',
  atta: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
  wheat: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=500',
  millet: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500',
  dal: 'https://images.unsplash.com/photo-1547849186-e8e7a6857f12?w=500',
  milk: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500',
  curd: 'https://images.unsplash.com/photo-1571244856353-fb0b1f2efb4d?w=500',
  ghee: 'https://images.unsplash.com/photo-1627998826726-2580790757a6?w=500',
  paneer: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500',
  butter: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=500',
  eggs: 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=500',
  avocado: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=500',
  jackfruit: 'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=500'
};

async function main() {
  console.log('Fetching active categories...');
  const dbCategories = await prisma.category.findMany();
  
  const vegCat = dbCategories.find(c => c.name.toLowerCase().includes('vegetable')) || dbCategories[0];
  const fruitCat = dbCategories.find(c => c.name.toLowerCase().includes('fruit')) || dbCategories[0];
  const grainCat = dbCategories.find(c => c.name.toLowerCase().includes('grain') || c.name.toLowerCase().includes('millet')) || dbCategories[0];
  const dairyCat = dbCategories.find(c => c.name.toLowerCase().includes('dairy') || c.name.toLowerCase().includes('egg')) || dbCategories[0];

  console.log('Fetching a registered farmer profile...');
  const farmerProfile = await prisma.farmerProfile.findFirst({
    include: { user: true }
  });

  if (!farmerProfile) {
    console.error('No farmer profile found in database. Please register a farmer first.');
    return;
  }

  console.log(`Generating bulk catalog items under farmer: ${farmerProfile.user.name} (${farmerProfile.farmName || 'Swarna Bharat Farms'})...`);

  const bulkProducts = [];

  // Helper to construct product data
  function addProductsFromList(list, categoryObj, basePriceMin, basePriceMax, unitStr) {
    for (const name of list) {
      const price = Math.floor(Math.random() * (basePriceMax - basePriceMin + 1)) + basePriceMin;
      const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, '-');
      bulkProducts.push({
        name,
        slug,
        description: `Farm fresh ${name} harvested organically with maximum care. Ready for same-day delivery.`,
        price: price.toString(),
        unit: unitStr,
        categoryId: categoryObj.id,
        farmerId: farmerProfile.id,
        organic: Math.random() > 0.3,
        featured: Math.random() > 0.7,
        seasonal: Math.random() > 0.8,
        status: 'APPROVED'
      });
    }
  }

  addProductsFromList(vegetables, vegCat, 15, 80, '1 kg');
  addProductsFromList(fruits, fruitCat, 40, 300, '1 kg');
  addProductsFromList(grains, grainCat, 50, 150, '1 kg');
  addProductsFromList(dairy, dairyCat, 25, 450, '500 ml');

  console.log(`Prepared ${bulkProducts.length} product payloads. Seeding into database...`);

  let seededCount = 0;
  for (const p of bulkProducts) {
    // Check if product already exists
    const exists = await prisma.product.findFirst({
      where: { slug: p.slug }
    });

    if (exists) continue;

    // Create Product
    const createdProduct = await prisma.product.create({
      data: p
    });

    // Determine Unsplash Image
    let matchedUrl = 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=500'; // global fallback
    const lowerName = p.name.toLowerCase();
    for (const [key, url] of Object.entries(imageMapping)) {
      if (lowerName.includes(key)) {
        matchedUrl = url;
        break;
      }
    }

    // Create Product Image
    await prisma.productImage.create({
      data: {
        productId: createdProduct.id,
        imageUrl: matchedUrl,
        isPrimary: true
      }
    });

    // Create Product Inventory
    const stock = Math.floor(Math.random() * 300) + 50; // 50 to 350 stock
    await prisma.inventory.create({
      data: {
        productId: createdProduct.id,
        farmerId: farmerProfile.id,
        currentStock: stock.toString(),
        reservedStock: '0',
        minStockLevel: '10',
        maxStockLevel: '1000',
        reorderLevel: '30',
        status: 'IN_STOCK'
      }
    });

    seededCount++;
  }

  console.log(`Seeding complete! Successfully added ${seededCount} new products, images, and inventory records.`);
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
