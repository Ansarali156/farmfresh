const fs = require('fs');
const path = require('path');

// Load env
try {
  const envPath = path.join(__dirname, '.env');
  if (fs.existsSync(envPath)) {
    const envFile = fs.readFileSync(envPath, 'utf8');
    envFile.split('\n').forEach(line => {
      const match = line.match(/^\s*([^#=]+)\s*=\s*(.*)$/);
      if (match) {
        const key = match[1].trim();
        let val = match[2].trim().replace(/\r$/, '');
        if (val.startsWith('"') && val.endsWith('"')) {
          val = val.substring(1, val.length - 1);
        } else if (val.startsWith("'") && val.endsWith("'")) {
          val = val.substring(1, val.length - 1);
        }
        process.env[key] = val;
      }
    });
  }
} catch (e) {
  console.error('Failed to load .env file:', e);
}

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

async function main() {
  const prisma = new PrismaClient({ datasources: { db: { url: process.env.DATABASE_URL } } });

  console.log('🌱 Starting insertion of 10 organic products...');

  // 1. Ensure a Farmer User & FarmerProfile exists
  let farmerUser = await prisma.user.findFirst({ where: { role: 'FARMER' } });
  if (!farmerUser) {
    const passwordHash = await bcrypt.hash('password123', 12);
    farmerUser = await prisma.user.create({
      data: {
        name: 'Ramesh Patel (Swarna Farms)',
        email: 'ramesh.farmer@farmfresh.com',
        phone: '+919876543210',
        passwordHash,
        role: 'FARMER',
      },
    });
  }

  let farmerProfile = await prisma.farmerProfile.findFirst({ where: { userId: farmerUser.id } });
  if (!farmerProfile) {
    farmerProfile = await prisma.farmerProfile.create({
      data: {
        userId: farmerUser.id,
        farmName: 'Swarna Organic Harvest',
        farmAddress: 'Farm No. 42, Guntur, Andhra Pradesh',
        kycStatus: 'APPROVED',
      },
    });
  }

  // 2. Ensure Categories exist
  const categoryMap = {};
  const categoriesData = [
    { name: 'Fruits', slug: 'fruits', description: 'Fresh orchard fruits' },
    { name: 'Vegetables', slug: 'vegetables', description: 'Fresh green vegetables' },
    { name: 'Dairy & Honey', slug: 'dairy-honey', description: 'Fresh dairy and raw honey' },
    { name: 'Spices & Herbs', slug: 'spices-herbs', description: 'Pure organic spices' },
    { name: 'Grains & Millets', slug: 'grains-millets', description: 'Wholesome grains' },
  ];

  for (const cat of categoriesData) {
    let category = await prisma.category.findFirst({ where: { slug: cat.slug } });
    if (!category) {
      category = await prisma.category.create({
        data: {
          name: cat.name,
          slug: cat.slug,
          description: cat.description,
          status: 'ACTIVE',
        },
      });
    }
    categoryMap[cat.name] = category.id;
  }

  // 3. Define 10 Products
  const productsToSeed = [
    {
      name: 'Fresh Organic Alphonso Mangoes',
      slug: 'fresh-organic-alphonso-mangoes',
      description: 'Naturally ripened, sweet and aromatic Ratnagiri Alphonso mangoes, grown 100% organically without synthetic ripening agents.',
      price: 450.00,
      discountPrice: 390.00,
      unit: '1 kg',
      category: 'Fruits',
      organic: true,
      featured: true,
      seasonal: true,
      stock: 50,
      image: 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Fresh Farm Spinach (Palak)',
      slug: 'fresh-farm-spinach-palak',
      description: 'Crisp, iron-rich fresh green spinach leaves harvested daily from our chemical-free farms.',
      price: 40.00,
      discountPrice: 35.00,
      unit: '250 g',
      category: 'Vegetables',
      organic: true,
      featured: false,
      seasonal: false,
      stock: 80,
      image: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Pure Raw Himalayan Forest Honey',
      slug: 'pure-raw-himalayan-forest-honey',
      description: 'Unprocessed, unpasteurized wild forest honey directly extracted from high-altitude Himalayan wild hives.',
      price: 380.00,
      discountPrice: 340.00,
      unit: '500 g',
      category: 'Dairy & Honey',
      organic: true,
      featured: true,
      seasonal: false,
      stock: 40,
      image: 'https://images.unsplash.com/photo-1587049352846-4a222e784d38?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Crisp Kashmiri Red Apples',
      slug: 'crisp-kashmiri-red-apples',
      description: 'Juicy, naturally sweet red apples handpicked from traditional apple orchards in Kashmir.',
      price: 220.00,
      discountPrice: 195.00,
      unit: '1 kg',
      category: 'Fruits',
      organic: true,
      featured: true,
      seasonal: true,
      stock: 65,
      image: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Fresh Farm A2 Desi Cow Milk',
      slug: 'fresh-farm-a2-desi-cow-milk',
      description: 'Pure, whole A2 Desi Gir cow milk, pasteurized and delivered fresh within hours of milking.',
      price: 75.00,
      discountPrice: 70.00,
      unit: '1 Liter',
      category: 'Dairy & Honey',
      organic: true,
      featured: false,
      seasonal: false,
      stock: 100,
      image: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Vine-Ripened Organic Red Tomatoes',
      slug: 'vine-ripened-organic-red-tomatoes',
      description: 'Plump, flavor-packed farm tomatoes grown naturally under sunshine without synthetic pesticides.',
      price: 35.00,
      discountPrice: 30.00,
      unit: '1 kg',
      category: 'Vegetables',
      organic: true,
      featured: false,
      seasonal: false,
      stock: 120,
      image: 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Organic High-Curcumin Turmeric Powder',
      slug: 'organic-high-curcumin-turmeric-powder',
      description: 'Traditional Lakadong turmeric powder with >7% curcumin content, stone-ground for maximum aroma.',
      price: 120.00,
      discountPrice: 105.00,
      unit: '200 g',
      category: 'Spices & Herbs',
      organic: true,
      featured: true,
      seasonal: false,
      stock: 60,
      image: 'https://images.unsplash.com/photo-1615485290382-441e4d049cb5?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Fresh Creamy Hass Avocados',
      slug: 'fresh-creamy-hass-avocados',
      description: 'Rich, nutrient-dense green avocados grown organically in cool Nilgiri hill plantations.',
      price: 290.00,
      discountPrice: 260.00,
      unit: '500 g',
      category: 'Fruits',
      organic: true,
      featured: false,
      seasonal: true,
      stock: 35,
      image: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Traditional Aromatic Basmati Rice',
      slug: 'traditional-aromatic-basmati-rice',
      description: 'Extra-long grain aged Basmati rice with rich natural fragrance, grown along Punjab river plains.',
      price: 160.00,
      discountPrice: 145.00,
      unit: '1 kg',
      category: 'Grains & Millets',
      organic: true,
      featured: false,
      seasonal: false,
      stock: 90,
      image: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
    },
    {
      name: 'Fresh Farm Broccoli Florets',
      slug: 'fresh-farm-broccoli-florets',
      description: 'Crisp, bright green broccoli heads packed with antioxidants, harvested fresh from cold hill farms.',
      price: 85.00,
      discountPrice: 75.00,
      unit: '300 g',
      category: 'Vegetables',
      organic: true,
      featured: false,
      seasonal: false,
      stock: 45,
      image: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?auto=format&fit=crop&w=600&q=80',
    },
  ];

  let addedCount = 0;
  for (const prod of productsToSeed) {
    const existing = await prisma.product.findFirst({ where: { slug: prod.slug } });
    if (!existing) {
      const created = await prisma.product.create({
        data: {
          farmerId: farmerProfile.id,
          categoryId: categoryMap[prod.category],
          name: prod.name,
          slug: prod.slug,
          description: prod.description,
          price: prod.price,
          discountPrice: prod.discountPrice,
          unit: prod.unit,
          organic: prod.organic,
          featured: prod.featured,
          seasonal: prod.seasonal,
          status: 'APPROVED',
          images: {
            create: [
              {
                imageUrl: prod.image,
                isPrimary: true,
              },
            ],
          },
          inventory: {
            create: {
              farmerId: farmerProfile.id,
              currentStock: prod.stock,
              reservedStock: 0,
              minStockLevel: 5,
              status: 'IN_STOCK',
            },
          },
        },
      });
      console.log(`✅ Added product (${addedCount + 1}/10): ${created.name} - ₹${created.price}`);
      addedCount++;
    } else {
      console.log(`ℹ️ Product already exists: ${prod.name}`);
    }
  }

  console.log(`\n🎉 Completed! ${addedCount} products successfully inserted into Railway PostgreSQL Database.`);
  await prisma.$disconnect();
}

main().catch(async (e) => {
  console.error('❌ Error seeding 10 products:', e);
  process.exit(1);
});
