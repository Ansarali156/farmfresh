const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const bcrypt = require('bcryptjs');

const categoriesToSeed = [
  { name: 'Vegetables', slug: 'vegetables', description: 'Farm fresh organic & natural vegetables' },
  { name: 'Fruits', slug: 'fruits', description: 'Fresh, juicy, naturally ripened fruits' },
  { name: 'Dairy', slug: 'dairy', description: 'Pure milk, ghee, paneer, curd and butter' },
  { name: 'Grains & Cereals', slug: 'grains-cereals', description: 'Nutritious rice, wheat, millets and cereals' },
  { name: 'Pulses', slug: 'pulses', description: 'High-protein lentils, dals and legumes' },
  { name: 'Eggs', slug: 'eggs', description: 'Farm fresh and free range eggs' },
  { name: 'Herbs & Greens', slug: 'herbs-greens', description: 'Fresh leafy greens and aromatic herbs' },
  { name: 'Spices', slug: 'spices', description: 'Aromatic whole and fresh spices' },
];

const farmerProfilesToSeed = [
  {
    email: 'ramesh.farmer@farmfresh.com',
    name: 'Ramesh Patel',
    phone: '+919876543210',
    farmName: 'Green Valley Organic Farms',
    farmAddress: 'Plot 42, Anand Agro Zone, Gujarat',
  },
  {
    email: 'kaveri.farmer@farmfresh.com',
    name: 'Lakshmi Devi',
    phone: '+919876543211',
    farmName: 'Kaveri Delta Natural Farms',
    farmAddress: 'Thanjavur Road, Tamil Nadu',
  },
  {
    email: 'swarna.farmer@farmfresh.com',
    name: 'John Farmer',
    phone: '+919876543212',
    farmName: 'Swarna Bharat Agriculture',
    farmAddress: 'Guntur District, Andhra Pradesh',
  },
];

const productsData = [
  // VEGETABLES (1-15)
  {
    name: 'Fresh Tomato',
    categoryName: 'Vegetables',
    price: 40,
    originalPrice: 50,
    unit: '1 kg',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Fresh, juicy farm-grown tomatoes ideal for curries, salads and everyday cooking.',
    imageUrl: 'https://images.unsplash.com/photo-1595855759920-86582396756a?w=600',
  },
  {
    name: 'Potato',
    categoryName: 'Vegetables',
    price: 35,
    originalPrice: 42,
    unit: '1 kg',
    stock: 150,
    organic: false,
    seasonal: false,
    description: 'Fresh Indian potatoes suitable for curries, fries, snacks and everyday meals.',
    imageUrl: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=600',
  },
  {
    name: 'Red Onion',
    categoryName: 'Vegetables',
    price: 45,
    originalPrice: 55,
    unit: '1 kg',
    stock: 130,
    organic: false,
    seasonal: false,
    description: 'Fresh red onions with strong flavour, sourced directly from farms.',
    imageUrl: 'https://images.unsplash.com/photo-1618228476711-23094cfb8356?w=600',
  },
  {
    name: 'Carrot',
    categoryName: 'Vegetables',
    price: 60,
    originalPrice: 70,
    unit: '1 kg',
    stock: 80,
    organic: false,
    seasonal: false,
    description: 'Fresh crunchy carrots suitable for salads, curries, juices and snacks.',
    imageUrl: 'https://images.unsplash.com/photo-1598170845058-12ef4a457939?w=600',
  },
  {
    name: 'Cauliflower',
    categoryName: 'Vegetables',
    price: 50,
    originalPrice: 60,
    unit: '1 piece',
    stock: 60,
    organic: false,
    seasonal: false,
    description: 'Fresh farm-grown cauliflower with firm white florets.',
    imageUrl: 'https://images.unsplash.com/photo-1568584711075-3d021a7c3ecf?w=600',
  },
  {
    name: 'Cabbage',
    categoryName: 'Vegetables',
    price: 40,
    originalPrice: 48,
    unit: '1 piece',
    stock: 70,
    organic: false,
    seasonal: false,
    description: 'Fresh green cabbage ideal for curries, salads and stir-fries.',
    imageUrl: 'https://images.unsplash.com/photo-1581078426775-802b15746ad4?w=600',
  },
  {
    name: 'Brinjal',
    categoryName: 'Vegetables',
    price: 55,
    originalPrice: 65,
    unit: '1 kg',
    stock: 75,
    organic: false,
    seasonal: false,
    description: 'Fresh tender brinjal sourced directly from local farms.',
    imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600',
  },
  {
    name: 'Lady Finger',
    categoryName: 'Vegetables',
    price: 65,
    originalPrice: 75,
    unit: '1 kg',
    stock: 70,
    organic: false,
    seasonal: false,
    description: 'Fresh and tender okra suitable for traditional Indian dishes.',
    imageUrl: 'https://images.unsplash.com/photo-1425543103986-22bad73d3858?w=600',
  },
  {
    name: 'Green Capsicum',
    categoryName: 'Vegetables',
    price: 80,
    originalPrice: 95,
    unit: '1 kg',
    stock: 50,
    organic: false,
    seasonal: false,
    description: 'Crisp green capsicum ideal for stir-fries, curries, salads and pizzas.',
    imageUrl: 'https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=600',
  },
  {
    name: 'Cucumber',
    categoryName: 'Vegetables',
    price: 45,
    originalPrice: 55,
    unit: '1 kg',
    stock: 90,
    organic: false,
    seasonal: false,
    description: 'Fresh hydrating cucumbers perfect for salads and juices.',
    imageUrl: 'https://images.unsplash.com/photo-1449300079323-02e209d9d3a6?w=600',
  },
  {
    name: 'Beetroot',
    categoryName: 'Vegetables',
    price: 55,
    originalPrice: 65,
    unit: '1 kg',
    stock: 65,
    organic: false,
    seasonal: false,
    description: 'Fresh beetroot with naturally earthy flavour and vibrant colour.',
    imageUrl: 'https://images.unsplash.com/photo-1593105544559-ecb03bf76f82?w=600',
  },
  {
    name: 'Bottle Gourd',
    categoryName: 'Vegetables',
    price: 45,
    originalPrice: 55,
    unit: '1 kg',
    stock: 60,
    organic: false,
    seasonal: false,
    description: 'Tender fresh bottle gourd suitable for healthy home-cooked dishes.',
    imageUrl: 'https://images.unsplash.com/photo-1590868309235-ea34bed7bd7f?w=600',
  },
  {
    name: 'Bitter Gourd',
    categoryName: 'Vegetables',
    price: 70,
    originalPrice: 80,
    unit: '1 kg',
    stock: 45,
    organic: false,
    seasonal: false,
    description: 'Fresh bitter gourd harvested from local farms.',
    imageUrl: 'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=600',
  },
  {
    name: 'Drumstick',
    categoryName: 'Vegetables',
    price: 90,
    originalPrice: 105,
    unit: '1 kg',
    stock: 40,
    organic: false,
    seasonal: false,
    description: 'Fresh drumsticks ideal for sambar, curries and traditional South Indian dishes.',
    imageUrl: 'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=600',
  },
  {
    name: 'Green Chilli',
    categoryName: 'Vegetables',
    price: 80,
    originalPrice: 95,
    unit: '1 kg',
    stock: 45,
    organic: false,
    seasonal: false,
    description: 'Fresh spicy green chillies for everyday Indian cooking.',
    imageUrl: 'https://images.unsplash.com/photo-1588252303782-cb80119abd6d?w=600',
  },

  // FRUITS (16-25)
  {
    name: 'Banana',
    categoryName: 'Fruits',
    price: 60,
    originalPrice: 70,
    unit: '1 dozen',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Naturally sweet and fresh bananas sourced directly from growers.',
    imageUrl: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=600',
  },
  {
    name: 'Alphonso Mango',
    categoryName: 'Fruits',
    price: 220,
    originalPrice: 260,
    unit: '1 kg',
    stock: 60,
    organic: false,
    seasonal: true,
    description: 'Premium aromatic Alphonso mangoes with naturally rich sweetness.',
    imageUrl: 'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600',
  },
  {
    name: 'Banganapalli Mango',
    categoryName: 'Fruits',
    price: 140,
    originalPrice: 170,
    unit: '1 kg',
    stock: 80,
    organic: false,
    seasonal: true,
    description: 'Sweet and juicy Banganapalli mangoes sourced from Indian orchards.',
    imageUrl: 'https://images.unsplash.com/photo-1601493700631-2b16ec4b4716?w=600',
  },
  {
    name: 'Apple',
    categoryName: 'Fruits',
    price: 180,
    originalPrice: 210,
    unit: '1 kg',
    stock: 80,
    organic: false,
    seasonal: false,
    description: 'Crisp fresh apples suitable for snacking, salads and juices.',
    imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600',
  },
  {
    name: 'Pomegranate',
    categoryName: 'Fruits',
    price: 190,
    originalPrice: 220,
    unit: '1 kg',
    stock: 60,
    organic: false,
    seasonal: false,
    description: 'Fresh pomegranates packed with juicy ruby-red seeds.',
    imageUrl: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?w=600',
  },
  {
    name: 'Papaya',
    categoryName: 'Fruits',
    price: 60,
    originalPrice: 70,
    unit: '1 kg',
    stock: 70,
    organic: false,
    seasonal: false,
    description: 'Naturally ripened fresh papaya with soft and sweet flesh.',
    imageUrl: 'https://images.unsplash.com/photo-1517260739337-6799d239ce83?w=600',
  },
  {
    name: 'Watermelon',
    categoryName: 'Fruits',
    price: 35,
    originalPrice: 42,
    unit: '1 kg',
    stock: 80,
    organic: false,
    seasonal: true,
    description: 'Refreshing and naturally sweet watermelon perfect for hot weather.',
    imageUrl: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=600',
  },
  {
    name: 'Sweet Orange',
    categoryName: 'Fruits',
    price: 100,
    originalPrice: 120,
    unit: '1 kg',
    stock: 75,
    organic: false,
    seasonal: false,
    description: 'Fresh juicy oranges with a naturally sweet citrus flavour.',
    imageUrl: 'https://images.unsplash.com/photo-1547514701-42782101795e?w=600',
  },
  {
    name: 'Guava',
    categoryName: 'Fruits',
    price: 80,
    originalPrice: 95,
    unit: '1 kg',
    stock: 65,
    organic: false,
    seasonal: false,
    description: 'Fresh aromatic guavas sourced directly from growers.',
    imageUrl: 'https://images.unsplash.com/photo-1536511135882-73a77a9c8f38?w=600',
  },
  {
    name: 'Green Grapes',
    categoryName: 'Fruits',
    price: 120,
    originalPrice: 145,
    unit: '1 kg',
    stock: 60,
    organic: false,
    seasonal: false,
    description: 'Fresh seedless green grapes with crisp and sweet flavour.',
    imageUrl: 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600',
  },

  // DAIRY (26-31)
  {
    name: 'Farm Fresh Cow Milk',
    categoryName: 'Dairy',
    price: 65,
    originalPrice: 70,
    unit: '1 litre',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Fresh cow milk sourced from trusted local dairy farms.',
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600',
  },
  {
    name: 'Buffalo Milk',
    categoryName: 'Dairy',
    price: 80,
    originalPrice: 85,
    unit: '1 litre',
    stock: 80,
    organic: false,
    seasonal: false,
    description: 'Rich and creamy fresh buffalo milk.',
    imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=600',
  },
  {
    name: 'Fresh Curd',
    categoryName: 'Dairy',
    price: 70,
    originalPrice: 80,
    unit: '1 kg',
    stock: 60,
    organic: false,
    seasonal: false,
    description: 'Thick and creamy fresh curd prepared from quality milk.',
    imageUrl: 'https://images.unsplash.com/photo-1571244856353-fb0b1f2efb4d?w=600',
  },
  {
    name: 'Fresh Paneer',
    categoryName: 'Dairy',
    price: 360,
    originalPrice: 400,
    unit: '1 kg',
    stock: 40,
    organic: false,
    seasonal: false,
    description: 'Soft fresh paneer suitable for curries, grilling and snacks.',
    imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=600',
  },
  {
    name: 'Farm Fresh Butter',
    categoryName: 'Dairy',
    price: 280,
    originalPrice: 310,
    unit: '500g',
    stock: 35,
    organic: false,
    seasonal: false,
    description: 'Creamy farm-fresh butter made from quality dairy milk.',
    imageUrl: 'https://images.unsplash.com/photo-1589985270826-4b7bb135bc9d?w=600',
  },
  {
    name: 'Pure Cow Ghee',
    categoryName: 'Dairy',
    price: 650,
    originalPrice: 720,
    unit: '1 litre',
    stock: 30,
    organic: false,
    seasonal: false,
    description: 'Traditional pure cow ghee with rich aroma and flavour.',
    imageUrl: 'https://images.unsplash.com/photo-1627998826726-2580790757a6?w=600',
  },

  // GRAINS & CEREALS (32-37)
  {
    name: 'Sona Masoori Rice',
    categoryName: 'Grains & Cereals',
    price: 65,
    originalPrice: 72,
    unit: '1 kg',
    stock: 200,
    organic: false,
    seasonal: false,
    description: 'Premium Sona Masoori rice suitable for everyday South Indian meals.',
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
  },
  {
    name: 'Brown Rice',
    categoryName: 'Grains & Cereals',
    price: 95,
    originalPrice: 110,
    unit: '1 kg',
    stock: 100,
    organic: true,
    seasonal: false,
    description: 'Nutritious minimally processed brown rice with natural bran.',
    imageUrl: 'https://images.unsplash.com/photo-1536304929831-ee1ca9d44906?w=600',
  },
  {
    name: 'Whole Wheat',
    categoryName: 'Grains & Cereals',
    price: 50,
    originalPrice: 58,
    unit: '1 kg',
    stock: 180,
    organic: false,
    seasonal: false,
    description: 'Quality whole wheat grains suitable for freshly milled atta.',
    imageUrl: 'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=600',
  },
  {
    name: 'Finger Millet Ragi',
    categoryName: 'Grains & Cereals',
    price: 70,
    originalPrice: 80,
    unit: '1 kg',
    stock: 100,
    organic: true,
    seasonal: false,
    description: 'Farm-grown ragi suitable for traditional and nutritious recipes.',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600',
  },
  {
    name: 'Pearl Millet Bajra',
    categoryName: 'Grains & Cereals',
    price: 60,
    originalPrice: 70,
    unit: '1 kg',
    stock: 90,
    organic: false,
    seasonal: false,
    description: 'Natural pearl millet suitable for rotis and traditional meals.',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=600',
  },
  {
    name: 'Jowar',
    categoryName: 'Grains & Cereals',
    price: 65,
    originalPrice: 75,
    unit: '1 kg',
    stock: 90,
    organic: false,
    seasonal: false,
    description: 'Farm-grown sorghum grain suitable for rotis and healthy meals.',
    imageUrl: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=600',
  },

  // PULSES (38-42)
  {
    name: 'Toor Dal',
    categoryName: 'Pulses',
    price: 160,
    originalPrice: 175,
    unit: '1 kg',
    stock: 120,
    organic: false,
    seasonal: false,
    description: 'Quality pigeon pea dal suitable for dal, sambar and everyday cooking.',
    imageUrl: 'https://images.unsplash.com/photo-1547849186-e8e7a6857f12?w=600',
  },
  {
    name: 'Moong Dal',
    categoryName: 'Pulses',
    price: 145,
    originalPrice: 160,
    unit: '1 kg',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Clean yellow moong dal ideal for dal, khichdi and light meals.',
    imageUrl: 'https://images.unsplash.com/photo-1585994191611-72ec0153ac89?w=600',
  },
  {
    name: 'Chana Dal',
    categoryName: 'Pulses',
    price: 110,
    originalPrice: 125,
    unit: '1 kg',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Quality split Bengal gram suitable for traditional Indian dishes.',
    imageUrl: 'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=600',
  },
  {
    name: 'Urad Dal',
    categoryName: 'Pulses',
    price: 150,
    originalPrice: 165,
    unit: '1 kg',
    stock: 90,
    organic: false,
    seasonal: false,
    description: 'Quality urad dal suitable for idli, dosa, vada and curries.',
    imageUrl: 'https://images.unsplash.com/photo-1585994191611-72ec0153ac89?w=600',
  },
  {
    name: 'Whole Green Gram',
    categoryName: 'Pulses',
    price: 130,
    originalPrice: 145,
    unit: '1 kg',
    stock: 85,
    organic: true,
    seasonal: false,
    description: 'Whole green gram suitable for sprouts, curries and healthy meals.',
    imageUrl: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600',
  },

  // EGGS (43-44)
  {
    name: 'Farm Fresh Eggs',
    categoryName: 'Eggs',
    price: 90,
    originalPrice: 100,
    unit: '12 eggs',
    stock: 120,
    organic: false,
    seasonal: false,
    description: 'Fresh eggs sourced from trusted local poultry farms.',
    imageUrl: 'https://images.unsplash.com/photo-1506976785307-8732e854ad03?w=600',
  },
  {
    name: 'Free Range Country Eggs',
    categoryName: 'Eggs',
    price: 150,
    originalPrice: 170,
    unit: '12 eggs',
    stock: 60,
    organic: true,
    seasonal: false,
    description: 'Free-range country eggs sourced from locally raised hens.',
    imageUrl: 'https://images.unsplash.com/photo-1516467508483-a7212febe31a?w=600',
  },

  // HERBS & GREENS (45-48)
  {
    name: 'Fresh Coriander',
    categoryName: 'Herbs & Greens',
    price: 20,
    originalPrice: 25,
    unit: '1 bunch',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Aromatic fresh coriander leaves harvested from local farms.',
    imageUrl: 'https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=600',
  },
  {
    name: 'Mint Leaves',
    categoryName: 'Herbs & Greens',
    price: 25,
    originalPrice: 30,
    unit: '1 bunch',
    stock: 80,
    organic: false,
    seasonal: false,
    description: 'Fresh aromatic mint leaves suitable for chutneys, drinks and cooking.',
    imageUrl: 'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?w=600',
  },
  {
    name: 'Spinach',
    categoryName: 'Herbs & Greens',
    price: 35,
    originalPrice: 40,
    unit: '1 bunch',
    stock: 90,
    organic: true,
    seasonal: false,
    description: 'Fresh green spinach leaves harvested from local farms.',
    imageUrl: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=600',
  },
  {
    name: 'Curry Leaves',
    categoryName: 'Herbs & Greens',
    price: 15,
    originalPrice: 20,
    unit: '1 bunch',
    stock: 100,
    organic: false,
    seasonal: false,
    description: 'Fresh aromatic curry leaves for authentic Indian cooking.',
    imageUrl: 'https://images.unsplash.com/photo-1618160702438-9b02ab6515c9?w=600',
  },

  // SPICES (49-50)
  {
    name: 'Fresh Ginger',
    categoryName: 'Spices',
    price: 140,
    originalPrice: 160,
    unit: '1 kg',
    stock: 60,
    organic: false,
    seasonal: false,
    description: 'Fresh aromatic ginger suitable for cooking, tea and traditional recipes.',
    imageUrl: 'https://images.unsplash.com/photo-1599940824399-b87987ceb72a?w=600',
  },
  {
    name: 'Fresh Garlic',
    categoryName: 'Spices',
    price: 180,
    originalPrice: 210,
    unit: '1 kg',
    stock: 70,
    organic: false,
    seasonal: false,
    description: 'Fresh garlic bulbs with strong natural flavour.',
    imageUrl: 'https://images.unsplash.com/photo-1540148426945-6cf22a6b2383?w=600',
  },
];

async function seed() {
  console.log('--- STARTING 50 PRODUCTS SEEDING ---');
  let insertedCount = 0;
  let updatedCount = 0;
  let skippedCount = 0;
  const categoriesMap = {};
  const farmersList = [];

  // 1. Ensure Categories
  for (const cat of categoriesToSeed) {
    const existingCat = await prisma.category.upsert({
      where: { name: cat.name },
      update: { description: cat.description },
      create: {
        name: cat.name,
        slug: cat.slug,
        description: cat.description,
        status: 'ACTIVE',
      },
    });
    categoriesMap[cat.name] = existingCat.id;
  }
  // Map existing 'Grains & Millets' to 'Grains & Cereals' if present
  const existingGrains = await prisma.category.findFirst({ where: { slug: 'grains-millets' } });
  if (existingGrains) {
    categoriesMap['Grains & Cereals'] = existingGrains.id;
  }

  // 2. Ensure Farmers
  const passwordHash = await bcrypt.hash('FarmerPassword123!', 10);
  for (const farmerData of farmerProfilesToSeed) {
    let user = await prisma.user.findUnique({ where: { email: farmerData.email } });
    if (!user) {
      user = await prisma.user.create({
        data: {
          name: farmerData.name,
          email: farmerData.email,
          phone: farmerData.phone,
          passwordHash: passwordHash,
          role: 'FARMER',
        },
      });
    }

    let farmerProfile = await prisma.farmerProfile.findUnique({ where: { userId: user.id } });
    if (!farmerProfile) {
      farmerProfile = await prisma.farmerProfile.create({
        data: {
          userId: user.id,
          farmName: farmerData.farmName,
          farmAddress: farmerData.farmAddress,
          kycStatus: 'APPROVED',
        },
      });
    }
    farmersList.push(farmerProfile);
  }

  console.log(`Available Farmers count: ${farmersList.length}`);
  console.log(`Available Categories count: ${Object.keys(categoriesMap).length}`);

  // 3. Upsert Products
  for (let i = 0; i < productsData.length; i++) {
    const p = productsData[i];
    const farmer = farmersList[i % farmersList.length]; // Distribute evenly
    const categoryId = categoriesMap[p.categoryName];

    if (!categoryId) {
      console.error(`Category not found for product: ${p.name}`);
      skippedCount++;
      continue;
    }

    const slug = p.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');

    const existingProduct = await prisma.product.findFirst({
      where: { slug: slug },
    });

    let productObj;
    if (existingProduct) {
      productObj = await prisma.product.update({
        where: { id: existingProduct.id },
        data: {
          name: p.name,
          description: p.description,
          price: p.price,
          discountPrice: p.originalPrice > p.price ? p.price : null,
          unit: p.unit,
          organic: p.organic,
          seasonal: p.seasonal,
          status: 'APPROVED',
          categoryId: categoryId,
          farmerId: farmer.id,
        },
      });
      updatedCount++;
    } else {
      productObj = await prisma.product.create({
        data: {
          name: p.name,
          slug: slug,
          description: p.description,
          price: p.price,
          discountPrice: p.originalPrice > p.price ? p.price : null,
          unit: p.unit,
          organic: p.organic,
          seasonal: p.seasonal,
          status: 'APPROVED',
          categoryId: categoryId,
          farmerId: farmer.id,
        },
      });
      insertedCount++;
    }

    // Upsert Product Image
    const existingImage = await prisma.productImage.findFirst({
      where: { productId: productObj.id },
    });

    if (existingImage) {
      await prisma.productImage.update({
        where: { id: existingImage.id },
        data: { imageUrl: p.imageUrl, isPrimary: true },
      });
    } else {
      await prisma.productImage.create({
        data: {
          productId: productObj.id,
          imageUrl: p.imageUrl,
          isPrimary: true,
        },
      });
    }

    // Upsert Product Inventory
    const existingInventory = await prisma.inventory.findUnique({
      where: { productId: productObj.id },
    });

    if (existingInventory) {
      await prisma.inventory.update({
        where: { id: existingInventory.id },
        data: {
          currentStock: p.stock,
          farmerId: farmer.id,
          status: p.stock > 0 ? 'IN_STOCK' : 'OUT_OF_STOCK',
        },
      });
    } else {
      await prisma.inventory.create({
        data: {
          productId: productObj.id,
          farmerId: farmer.id,
          currentStock: p.stock,
          minStockLevel: 5,
          maxStockLevel: 1000,
          reorderLevel: 10,
          status: 'IN_STOCK',
        },
      });
    }
  }

  console.log('\n========================================');
  console.log('SEEDING SUMMARY REPORT');
  console.log('========================================');
  console.log(`- Number of products inserted: ${insertedCount}`);
  console.log(`- Number of products updated: ${updatedCount}`);
  console.log(`- Total target products: ${productsData.length}`);
  console.log(`- Products skipped: ${skippedCount}`);
  console.log(`- Categories used: ${Object.keys(categoriesMap).join(', ')}`);
  console.log(`- Farmers assigned: ${farmersList.map(f => f.farmName).join(', ')}`);
  console.log('========================================\n');
}

seed()
  .catch((e) => {
    console.error('Error during seeding:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
