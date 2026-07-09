// Global State Management
const STATE = {
    products: [
        {
            id: 'prod-1',
            name: 'Organic Vegetables Basket',
            price: 7.20,
            originalPrice: 12.00,
            discount: '40% OFF',
            origin: 'Santorini, Greece',
            category: 'vegetables',
            image: 'assets/basket_vegetables.jpg',
            description: 'Fresh hand-harvested organic vegetables directly from Santorini fields. A healthy mix of vine-ripened tomatoes, cucumbers, peppers, and green lettuce. Raised without pesticides.',
            calories: '320 kcal',
            protein: '12 gram',
            fat: '15 gram',
            weight: '1.5 Kg'
        },
        {
            id: 'prod-2',
            name: 'Crisp Red Apples',
            price: 3.99,
            originalPrice: 4.99,
            discount: '20% OFF',
            origin: 'Washington, US',
            category: 'fruits',
            image: '🍎',
            description: 'Deliciously sweet and crispy red delicious apples. Perfect for a healthy afternoon snack or baking apple pies. Handpicked with quality checks.',
            calories: '150 kcal',
            protein: '2 gram',
            fat: '0 gram',
            weight: '1.0 Kg'
        },
        {
            id: 'prod-3',
            name: 'Fresh English Cucumbers',
            price: 2.99,
            originalPrice: 4.29,
            discount: '30% OFF',
            origin: 'Crete, Greece',
            category: 'vegetables',
            image: '🥒',
            description: 'Cool and refreshing green cucumbers. Highly hydrating and crunchy, perfect for salads, dipping, or dynamic Greek tzatziki yogurt dip.',
            calories: '45 kcal',
            protein: '1 gram',
            fat: '0 gram',
            weight: '0.8 Kg'
        },
        {
            id: 'prod-4',
            name: 'Premium Ribeye Steak',
            price: 18.99,
            originalPrice: 18.99,
            discount: null,
            origin: 'Texas, US',
            category: 'meat',
            image: '🥩',
            description: 'Thick, beautifully marbled grade-A beef ribeye steak. Perfectly tender and juicy, ideal for pan-searing or grilling over wood fire.',
            calories: '820 kcal',
            protein: '64 gram',
            fat: '52 gram',
            weight: '0.5 Kg'
        },
        {
            id: 'prod-5',
            name: 'Organic Whole Milk',
            price: 3.49,
            originalPrice: 3.49,
            discount: null,
            origin: 'Wisconsin, US',
            category: 'dairy',
            image: '🥛',
            description: 'Creamy, farm-fresh pasteurized organic whole milk. Produced by grass-fed dairy cows, packed with rich vitamins and high calcium.',
            calories: '280 kcal',
            protein: '16 gram',
            fat: '18 gram',
            weight: '1.0 L'
        },
        {
            id: 'prod-6',
            name: 'Fresh Farm Eggs',
            price: 4.50,
            originalPrice: 4.50,
            discount: null,
            origin: 'Ohio, US',
            category: 'dairy',
            image: '🥚',
            description: 'One dozen pasture-raised organic brown eggs. Rich yellow yolks, collected daily from free-range hens.',
            calories: '180 kcal',
            protein: '14 gram',
            fat: '12 gram',
            weight: '0.7 Kg'
        }
    ],
    categories: [
        { id: 'all', label: 'All', icon: '🧺' },
        { id: 'fruits', label: 'Fruits', icon: '🍎' },
        { id: 'vegetables', label: 'Vegetables', icon: '🥒' },
        { id: 'meat', label: 'Meat', icon: '🥩' },
        { id: 'dairy', label: 'Dairy', icon: '🥛' }
    ],
    cart: [],
    orders: [],
    merchants: [
        { id: 'FARM-82', name: 'Organico Farm', earnings: 0.00, verified: true, activeOrders: 0 },
        { id: 'FARM-99', name: 'Valley Green Orchards', earnings: 0.00, verified: false, activeOrders: 0 }
    ],
    rider: {
        id: 'RIDER-45',
        name: 'Alex Rider',
        earnings: 0.00,
        trips: 0,
        activeOrderId: null
    },
    admin: {
        totalSales: 0.00,
        totalOrders: 0
    },
    activeCategory: 'all',
    searchQuery: '',
    selectedProductId: null,
    couponApplied: null,
    currentRole: 'customer',
    currentScreen: 'onboarding'
};

// Logger Utility
const Logger = {
    consoleEl: document.getElementById('logger-console-output'),
    log(message, role = 'system') {
        const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', second: '2-digit' });
        const logItem = document.createElement('div');
        logItem.className = `log-entry ${role}`;
        logItem.innerHTML = `<span class="log-time">[${time}]</span> <span style="font-weight: 700;">${role.toUpperCase()}:</span> ${message}`;
        this.consoleEl.appendChild(logItem);
        this.consoleEl.scrollTop = this.consoleEl.scrollHeight;
    },
    clear() {
        this.consoleEl.innerHTML = '';
        this.log('Debugger session re-initialized.', 'system');
    }
};

// Push Notification Simulation
const Notification = {
    el: document.getElementById('mock-notification'),
    titleEl: document.getElementById('notif-title'),
    bodyEl: document.getElementById('notif-body'),
    show(title, message) {
        this.titleEl.innerText = title;
        this.bodyEl.innerText = message;
        this.el.classList.add('visible');
        
        // Dynamic sound/vibration feedback simulation
        if (navigator.vibrate) {
            navigator.vibrate([100, 50, 100]);
        }
        
        setTimeout(() => {
            this.el.classList.remove('visible');
        }, 5000);
    }
};

// Dynamic Clock
function updateClock() {
    const timeEl = document.getElementById('phone-time');
    const now = new Date();
    timeEl.innerText = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });
}
setInterval(updateClock, 1000);
updateClock();

// Routing & View Screen Control
function switchScreen(screenId) {
    const screens = document.querySelectorAll('.app-screen');
    screens.forEach(s => s.classList.remove('active'));
    
    const targetScreen = document.getElementById(screenId);
    if (targetScreen) {
        targetScreen.classList.add('active');
        // Reset scroll position
        targetScreen.scrollTop = 0;
        
        // Hide/show bottom nav bar based on screen
        const customerNav = document.getElementById('phone-bottom-navbar');
        const farmerNav = document.getElementById('farmer-bottom-navbar');
        const deliveryNav = document.getElementById('delivery-bottom-navbar');
        const statusBar = document.getElementById('phone-status-bar');
        
        // Hide all navbars initially
        customerNav.style.display = 'none';
        farmerNav.style.display = 'none';
        deliveryNav.style.display = 'none';

        if (screenId === 'screen-onboarding') {
            statusBar.classList.remove('dark-mode-icons');
        } else {
            // Show appropriate navbar based on role
            if (STATE.currentRole === 'customer') {
                customerNav.style.display = 'flex';
            } else if (STATE.currentRole === 'farmer') {
                farmerNav.style.display = 'flex';
            } else if (STATE.currentRole === 'delivery') {
                deliveryNav.style.display = 'flex';
            }
            statusBar.classList.add('dark-mode-icons');
        }
        
        // Update active tab styling
        updateActiveBottomTab(screenId);
    }
}

function updateActiveBottomTab(screenId) {
    const tabs = document.querySelectorAll('.nav-tab-item');
    tabs.forEach(t => t.classList.remove('active'));
    
    if (screenId === 'screen-customer-home') {
        document.getElementById('tab-home').classList.add('active');
    } else if (screenId === 'screen-customer-cart') {
        document.getElementById('tab-cart').classList.add('active');
    } else if (screenId === 'screen-customer-tracking') {
        document.getElementById('tab-tracking').classList.add('active');
    } else if (screenId === 'screen-farmer-dashboard') {
        document.getElementById('tab-farmer-dashboard').classList.add('active');
    } else if (screenId === 'screen-farmer-products') {
        document.getElementById('tab-farmer-products').classList.add('active');
    } else if (screenId === 'screen-farmer-profile') {
        document.getElementById('tab-farmer-profile').classList.add('active');
    } else if (screenId === 'screen-delivery-dashboard') {
        document.getElementById('tab-delivery-dashboard').classList.add('active');
    } else if (screenId === 'screen-delivery-profile') {
        document.getElementById('tab-delivery-profile').classList.add('active');
    }
}

// Role Switcher Control
function switchRole(role) {
    STATE.currentRole = role;
    
    // UI update for role buttons
    document.querySelectorAll('.role-btn').forEach(btn => btn.classList.remove('active'));
    document.getElementById(`btn-role-${role}`).classList.add('active');
    
    Logger.log(`Swapped simulator viewpoint to ${role.toUpperCase()}`, 'system');
    
    // View Switch matching the role
    if (role === 'customer') {
        switchScreen('screen-customer-home');
    } else if (role === 'farmer') {
        switchScreen('screen-farmer-dashboard');
        renderFarmerOrders();
        updateFarmerStats();
        renderFarmerInventory();
    } else if (role === 'delivery') {
        switchScreen('screen-delivery-dashboard');
        renderRiderDashboard();
    } else if (role === 'admin') {
        switchScreen('screen-admin-dashboard');
        renderAdminDashboard();
    }
}

// Rendering Category Filters
function renderCategories() {
    const container = document.getElementById('categories-container');
    container.innerHTML = STATE.categories.map(c => `
        <div class="category-pill ${STATE.activeCategory === c.id ? 'active' : ''}" onclick="selectCategory('${c.id}')">
            <div class="category-icon-circle">${c.icon}</div>
            <span class="label">${c.label}</span>
        </div>
    `).join('');
}

function selectCategory(catId) {
    STATE.activeCategory = catId;
    renderCategories();
    renderProducts();
    Logger.log(`Filtered store products by category: "${catId}"`, 'customer');
}

// Rendering Products Grid
function renderProducts() {
    const container = document.getElementById('products-grid-container');
    
    // Filter logic
    let filtered = STATE.products;
    if (STATE.activeCategory !== 'all') {
        filtered = filtered.filter(p => p.category === STATE.activeCategory);
    }
    if (STATE.searchQuery.trim() !== '') {
        filtered = filtered.filter(p => p.name.toLowerCase().includes(STATE.searchQuery.toLowerCase()));
    }
    
    if (filtered.length === 0) {
        container.innerHTML = '<div style="grid-column: span 2; text-align:center; padding: 20px; color:var(--text-muted); font-size:12px;">No products found.</div>';
        return;
    }

    container.innerHTML = filtered.map(p => {
        const isDetailsImage = p.image.endsWith('.jpg');
        const imgContent = isDetailsImage 
            ? `<img src="${p.image}" alt="${p.name}">` 
            : `<div class="svg-placeholder">${p.image}</div>`;

        return `
            <div class="product-card" onclick="viewProductDetails('${p.id}')">
                ${p.discount ? `<span class="discount-tag">${p.discount}</span>` : ''}
                <button class="wishlist-btn" onclick="toggleWishlist(event, '${p.id}')">
                    <i class="fa-regular fa-heart"></i>
                </button>
                <div class="product-image-container">
                    ${imgContent}
                </div>
                <div class="product-title">${p.name}</div>
                <div class="product-meta-row">
                    <span class="product-price">$${p.price.toFixed(2)}</span>
                    <div class="product-card-add-btn" onclick="addToCart(event, '${p.id}')">
                        <i class="fa-solid fa-plus"></i>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

function toggleWishlist(e, prodId) {
    e.stopPropagation();
    const btn = e.currentTarget;
    const isAct = btn.classList.toggle('active');
    btn.innerHTML = isAct ? '<i class="fa-solid fa-heart"></i>' : '<i class="fa-regular fa-heart"></i>';
    
    const prod = STATE.products.find(p => p.id === prodId);
    Logger.log(`${isAct ? 'Added' : 'Removed'} product "${prod.name}" ${isAct ? 'to' : 'from'} customer wishlist.`, 'customer');
}

// VIEW PRODUCT DETAILS
window.viewProductDetails = function(prodId) {
    STATE.selectedProductId = prodId;
    const product = STATE.products.find(p => p.id === prodId);
    
    if (!product) return;
    
    document.getElementById('details-product-title').innerText = product.name;
    document.getElementById('details-product-price').innerText = `$${product.price.toFixed(2)}`;
    document.getElementById('details-product-origin').innerText = product.origin;
    document.getElementById('details-product-desc').innerText = product.description;
    
    document.getElementById('nutrition-calories').innerText = product.calories;
    document.getElementById('nutrition-protein').innerText = product.protein;
    document.getElementById('nutrition-fat').innerText = product.fat;
    document.getElementById('nutrition-weight').innerText = product.weight;
    
    const imgEl = document.getElementById('details-product-img');
    if (product.image.endsWith('.jpg')) {
        imgEl.src = product.image;
        imgEl.style.display = 'block';
    } else {
        // Fallback for emoji icons
        imgEl.src = `https://api.dicebear.com/7.x/initials/svg?seed=${encodeURIComponent(product.name)}&backgroundColor=c5e1a5`;
    }
    
    switchScreen('screen-customer-details');
    Logger.log(`Inspected product detail details page: "${product.name}"`, 'customer');
};

// CART LOGIC
window.addToCart = function(e, prodId) {
    if (e) e.stopPropagation();
    
    const product = STATE.products.find(p => p.id === prodId);
    const existing = STATE.cart.find(item => item.productId === prodId);
    
    if (existing) {
        existing.quantity += 1;
    } else {
        STATE.cart.push({ productId: prodId, quantity: 1 });
    }
    
    Logger.log(`Added "${product.name}" to cart (Quantity: ${existing ? existing.quantity : 1})`, 'customer');
    updateCartStats();
    Notification.show('Added to Cart', `${product.name} has been added to your shopping cart.`);
};

function updateCartStats() {
    const totalItems = STATE.cart.reduce((sum, item) => sum + item.quantity, 0);
    document.getElementById('cart-item-badge').innerText = `${totalItems} items`;
    
    // Update Onboarding screen mockup tags to match cart total for visual immersion
    if (totalItems > 0) {
        document.getElementById('onboard-items-count').innerText = totalItems;
        let sub = STATE.cart.reduce((sum, item) => {
            const p = STATE.products.find(prod => prod.id === item.productId);
            return sum + (p.price * item.quantity);
        }, 0);
        document.getElementById('onboard-total-price').innerText = `$${(sub + 3.99).toFixed(2)}`;
    }
    
    renderCart();
}

function renderCart() {
    const container = document.getElementById('cart-items-list-container');
    
    if (STATE.cart.length === 0) {
        container.innerHTML = '<div class="cart-empty-message">Your shopping cart is currently empty. Add fresh items from the store!</div>';
        updateCartTotals();
        return;
    }

    container.innerHTML = STATE.cart.map(item => {
        const prod = STATE.products.find(p => p.id === item.productId);
        const imageHtml = prod.image.endsWith('.jpg') 
            ? `<img class="cart-item-img" src="${prod.image}" alt="${prod.name}">` 
            : `<div class="cart-item-img" style="display:flex;align-items:center;justify-content:center;font-size:24px;background:#EAF6EC;">${prod.image}</div>`;

        return `
            <div class="cart-item-card">
                ${imageHtml}
                <div class="cart-item-details">
                    <div class="cart-item-name">${prod.name}</div>
                    <div class="cart-item-price">$${prod.price.toFixed(2)}</div>
                </div>
                <div class="cart-item-actions">
                    <div class="quantity-control">
                        <button class="quantity-btn" onclick="updateQty('${prod.id}', -1)">-</button>
                        <span class="quantity-val">${item.quantity}</span>
                        <button class="quantity-btn" onclick="updateQty('${prod.id}', 1)">+</button>
                    </div>
                    <button class="cart-item-remove-btn" onclick="removeCartItem('${prod.id}')">Remove</button>
                </div>
            </div>
        `;
    }).join('');
    
    updateCartTotals();
}

window.updateQty = function(prodId, delta) {
    const item = STATE.cart.find(i => i.productId === prodId);
    if (!item) return;
    
    item.quantity += delta;
    if (item.quantity <= 0) {
        removeCartItem(prodId);
    } else {
        updateCartStats();
    }
};

window.removeCartItem = function(prodId) {
    const prod = STATE.products.find(p => p.id === prodId);
    STATE.cart = STATE.cart.filter(item => item.productId !== prodId);
    Logger.log(`Removed "${prod.name}" from shopping cart.`, 'customer');
    updateCartStats();
};

function updateCartTotals() {
    let subtotal = 0;
    STATE.cart.forEach(item => {
        const prod = STATE.products.find(p => p.id === item.productId);
        subtotal += prod.price * item.quantity;
    });

    let discount = 0;
    if (STATE.couponApplied === 'SAVE50') {
        discount = subtotal * 0.50;
    }

    const delivery = subtotal > 0 ? 3.99 : 0;
    const total = subtotal - discount + delivery;

    document.getElementById('cart-summary-subtotal').innerText = `$${subtotal.toFixed(2)}`;
    document.getElementById('cart-summary-discount').innerText = `-$${discount.toFixed(2)}`;
    document.getElementById('cart-summary-delivery').innerText = `$${delivery.toFixed(2)}`;
    document.getElementById('cart-summary-total').innerText = `$${total.toFixed(2)}`;
}

// APPLY COUPONS
document.getElementById('btn-apply-coupon').addEventListener('click', () => {
    const code = document.getElementById('coupon-code-field').value.trim().toUpperCase();
    if (code === 'SAVE50') {
        STATE.couponApplied = 'SAVE50';
        Logger.log('Applied promotion coupon "SAVE50" (50% Off subtotal discount)!', 'customer');
        updateCartTotals();
    } else if (code === '') {
        STATE.couponApplied = null;
        updateCartTotals();
    } else {
        alert('Invalid Coupon Code! Try "SAVE50"');
        Logger.log(`Attempted invalid coupon code: "${code}"`, 'customer');
    }
});

// CHECKOUT & PLACE ORDER
document.getElementById('btn-cart-checkout').addEventListener('click', () => {
    if (STATE.cart.length === 0) {
        alert('Your cart is empty! Add products first.');
        return;
    }

    let subtotal = 0;
    const orderItems = STATE.cart.map(item => {
        const prod = STATE.products.find(p => p.id === item.productId);
        subtotal += prod.price * item.quantity;
        return {
            id: prod.id,
            name: prod.name,
            price: prod.price,
            quantity: item.quantity
        };
    });

    const discount = STATE.couponApplied === 'SAVE50' ? subtotal * 0.5 : 0;
    const delivery = 3.99;
    const total = subtotal - discount + delivery;
    const otp = Math.floor(1000 + Math.random() * 9000).toString();
    const orderId = `ORD-${Math.floor(100000 + Math.random() * 900000)}`;

    const newOrder = {
        id: orderId,
        items: orderItems,
        subtotal: subtotal,
        discount: discount,
        delivery: delivery,
        total: total,
        otp: otp,
        status: 'placed',
        timestamp: new Date().toLocaleTimeString()
    };

    STATE.orders.push(newOrder);
    
    // Clear Cart
    STATE.cart = [];
    STATE.couponApplied = null;
    document.getElementById('coupon-code-field').value = '';
    updateCartStats();

    Logger.log(`Successfully placed client order ${orderId} for a total of $${total.toFixed(2)}`, 'customer');
    
    // Prepare Tracking Screen
    document.getElementById('tracking-order-id').innerText = `#${orderId}`;
    document.getElementById('tracking-delivery-otp').innerText = otp;
    updateTrackingTimeline(newOrder);
    
    // Swap screen to tracking
    switchScreen('screen-customer-tracking');
    
    // Notify Farmer
    const activeFarmer = STATE.merchants[0]; // Organico Farm
    activeFarmer.activeOrders += 1;
    updateFarmerStats();
    
    Logger.log(`New incoming order alert sent to ${activeFarmer.name}`, 'system');
    Notification.show('Order Placed!', `Farm alert: Organico Farm has received order ${orderId}.`);
});

// ORDER STATUS TRACKING TIMELINE
function updateTrackingTimeline(order) {
    const steps = ['placed', 'accepted', 'prepared', 'transit', 'completed'];
    const currentIdx = steps.indexOf(order.status);
    
    steps.forEach((step, idx) => {
        const el = document.getElementById(`step-${step}`);
        if (!el) return;
        
        el.className = 'timeline-item';
        if (idx < currentIdx) {
            el.classList.add('completed');
        } else if (idx === currentIdx) {
            el.classList.add('active');
        }
    });
}

// FARMER CONSOLE LOGIC
function updateFarmerStats() {
    const farmer = STATE.merchants[0];
    document.getElementById('farmer-total-earnings').innerText = `$${farmer.earnings.toFixed(2)}`;
    document.getElementById('farmer-active-orders').innerText = farmer.activeOrders;
}

function renderFarmerOrders() {
    const container = document.getElementById('farmer-orders-list');
    const pending = STATE.orders.filter(o => o.status === 'placed' || o.status === 'accepted');
    
    if (pending.length === 0) {
        container.innerHTML = '<div style="font-size:11px; text-align:center; padding: 20px; color:var(--text-muted);">No active pending orders.</div>';
        return;
    }

    container.innerHTML = pending.map(o => {
        const itemsSummary = o.items.map(i => `${i.quantity}x ${i.name}`).join(', ');
        
        let actionBtn = '';
        if (o.status === 'placed') {
            actionBtn = `<button class="btn-action-small" onclick="farmerAcceptOrder('${o.id}')">Accept Order</button>`;
        } else if (o.status === 'accepted') {
            actionBtn = `<button class="btn-action-small" style="background:var(--primary-gradient); color:white;" onclick="farmerPrepareOrder('${o.id}')">Mark Prepared</button>`;
        }

        return `
            <div class="order-card-merchant">
                <div class="order-card-header">
                    <span style="font-weight:700;">#${o.id}</span>
                    <span style="color:var(--primary);text-transform:uppercase;font-size:9px;">${o.status}</span>
                </div>
                <div class="order-card-items-list">${itemsSummary}</div>
                <div class="order-card-footer">
                    <span class="order-card-price">$${o.total.toFixed(2)}</span>
                    ${actionBtn}
                </div>
            </div>
        `;
    }).join('');
}

function renderFarmerInventory() {
    const container = document.getElementById('farmer-inventory-list');
    if (!container) return;
    container.innerHTML = STATE.products.map(p => {
        let priceStr = typeof p.price === 'number' ? `$${p.price.toFixed(2)}` : p.price;
        return `
            <div class="order-card-merchant" style="margin-bottom:8px; display:flex; justify-content:space-between; align-items:center;">
                <div>
                    <div style="font-weight:700; font-size:12px;">${p.name}</div>
                    <div style="font-size:10px; color:var(--text-muted);">${p.weight} | ${priceStr}</div>
                </div>
                <button class="btn-action-small" style="background:#fee2e2; color:#ef4444; border:none; padding:4px 8px;" onclick="farmerDeleteProduct('${p.id}')">Delete</button>
            </div>
        `;
    }).join('');
}

window.farmerDeleteProduct = function(pId) {
    STATE.products = STATE.products.filter(p => p.id !== pId);
    renderFarmerInventory();
    renderProducts();
    Logger.log(`Farmer deleted product ID: ${pId} from online market.`, 'farmer');
};


window.farmerAcceptOrder = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'accepted';
    Logger.log(`Farmer accepted order #${orderId}. Preparing products for packaging...`, 'farmer');
    renderFarmerOrders();
    
    // Simulate push alert to customer
    Notification.show('Order Preparing', `Farmer accepted your order #${orderId}. Fresh produce is being gathered!`);
};

window.farmerPrepareOrder = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'prepared';
    Logger.log(`Farmer finished packaging order #${orderId}. Dispatched to delivery rider pool!`, 'farmer');
    
    const farmer = STATE.merchants[0];
    if (farmer.activeOrders > 0) farmer.activeOrders -= 1;
    updateFarmerStats();
    renderFarmerOrders();
    
    // Trigger notification to Rider & Customer
    Notification.show('Harvest Ready!', `Order #${orderId} is prepared and waiting for pickup.`);
};

// RIDER CONSOLE LOGIC
function renderRiderDashboard() {
    // Stats
    document.getElementById('delivery-earnings').innerText = `$${STATE.rider.earnings.toFixed(2)}`;
    document.getElementById('delivery-trips').innerText = STATE.rider.trips;
    
    const jobBoardSection = document.getElementById('delivery-job-board-section');
    const activeJobSection = document.getElementById('delivery-active-job-section');
    
    if (STATE.rider.activeOrderId) {
        jobBoardSection.style.display = 'none';
        activeJobSection.style.display = 'block';
        
        // Setup driving navigation simulation
        const order = STATE.orders.find(o => o.id === STATE.rider.activeOrderId);
        document.getElementById('delivery-info-text').innerText = `Transit to Client (OTP: ${order.otp})`;
        
        // Start animation driving
        const map = document.getElementById('rider-map');
        map.classList.add('driving');
    } else {
        jobBoardSection.style.display = 'block';
        activeJobSection.style.display = 'none';
        
        // Reset Map driving animation
        const map = document.getElementById('rider-map');
        map.classList.remove('driving');
        
        renderRiderJobs();
    }
}

function renderRiderJobs() {
    const container = document.getElementById('delivery-jobs-list');
    const jobs = STATE.orders.filter(o => o.status === 'prepared');
    
    if (jobs.length === 0) {
        container.innerHTML = '<div style="font-size:11px; text-align:center; padding: 20px; color:var(--text-muted);">No packages currently waiting for dispatch.</div>';
        return;
    }

    container.innerHTML = jobs.map(o => {
        const itemsSummary = o.items.map(i => `${i.quantity}x ${i.name}`).join(', ');
        return `
            <div class="order-card-merchant">
                <div class="order-card-header">
                    <span style="font-weight:700;">#${o.id}</span>
                    <span style="color:#2E7D32;">Prepared</span>
                </div>
                <div class="order-card-items-list">${itemsSummary}</div>
                <div class="order-card-footer">
                    <span class="order-card-price">$${o.total.toFixed(2)}</span>
                    <button class="btn-action-small" style="background:#E28C43; color:white;" onclick="riderAcceptJob('${o.id}')">Accept Delivery</button>
                </div>
            </div>
        `;
    }).join('');
}

window.riderAcceptJob = function(orderId) {
    const order = STATE.orders.find(o => o.id === orderId);
    if (!order) return;
    
    order.status = 'transit';
    STATE.rider.activeOrderId = orderId;
    
    Logger.log(`Rider Alex Rider accepted delivery trip for order #${orderId}. Navigating to client address...`, 'delivery');
    renderRiderDashboard();
    
    // Simulate push alert to customer
    Notification.show('Rider Out for Delivery!', `Rider Alex is on his way with your FarmFresh vegetables.`);
};

// CONFIRM DELIVERY WITH OTP
document.getElementById('btn-delivery-submit-otp').addEventListener('click', () => {
    const inputOtp = document.getElementById('delivery-otp-confirm-input').value.trim();
    const orderId = STATE.rider.activeOrderId;
    
    if (!orderId) return;
    
    const order = STATE.orders.find(o => o.id === orderId);
    
    if (inputOtp === order.otp) {
        // Complete Order
        order.status = 'completed';
        STATE.rider.activeOrderId = null;
        
        // Payout allocations
        const deliveryFee = 3.99;
        const farmerEarnings = order.total - deliveryFee;
        const riderPayout = 5.00; // Flat delivery agent payout
        
        // Credit Farmer
        const farmer = STATE.merchants[0];
        farmer.earnings += farmerEarnings;
        
        // Credit Rider
        STATE.rider.earnings += riderPayout;
        STATE.rider.trips += 1;
        
        // Credit Admin Log
        STATE.admin.totalSales += order.total;
        STATE.admin.totalOrders += 1;
        
        document.getElementById('delivery-otp-confirm-input').value = '';
        
        Logger.log(`Rider verified OTP correctly. Delivery completed! Payout of $${riderPayout.toFixed(2)} credited to Rider. Farmer credited $${farmerEarnings.toFixed(2)}`, 'delivery');
        
        renderRiderDashboard();
        
        // Alert Customer
        Notification.show('Order Delivered!', `Your delivery for order #${orderId} is complete. Bon Appétit!`);
    } else {
        alert('Invalid OTP Code! Check customer tracking screen for correct pin.');
        Logger.log(`Rider entered wrong OTP: "${inputOtp}" for order #${orderId}`, 'delivery');
    }
});

// FARMER ADD NEW HARVEST ITEM
document.getElementById('btn-farmer-add-product').addEventListener('click', () => {
    const name = document.getElementById('form-new-pname').value.trim();
    const price = parseFloat(document.getElementById('form-new-price').value);
    const weight = document.getElementById('form-new-unit').value.trim();
    const category = document.getElementById('form-new-category').value;
    
    if (!name || isNaN(price) || !weight) {
        alert('Please fill out all product details correctly!');
        return;
    }
    
    // Pick dynamic food emojis based on categories
    let emoji = '🍏';
    if (category === 'vegetables') emoji = '🥦';
    else if (category === 'meat') emoji = '🥩';
    else if (category === 'dairy') emoji = '🧀';
    
    const newProd = {
        id: `prod-${STATE.products.length + 1}`,
        name: name,
        price: price,
        originalPrice: price,
        discount: null,
        origin: 'Organico Farm, US',
        category: category,
        image: emoji,
        description: `Freshly harvested organic ${name} grown by local farmers at Organico Farm. Packed carefully for delivery.`,
        calories: '120 kcal',
        protein: '3 gram',
        fat: '0 gram',
        weight: weight
    };
    
    STATE.products.unshift(newProd);
    
    // Clear forms
    document.getElementById('form-new-pname').value = '';
    document.getElementById('form-new-price').value = '';
    document.getElementById('form-new-unit').value = '';
    
    Logger.log(`Farmer published new product harvest: "${name}" ($${price.toFixed(2)} per ${weight}) to storefront.`, 'farmer');
    
    // Rerender grids
    renderProducts();
    renderFarmerInventory();
    Notification.show('New Harvest Item!', `Merchant published ${name} to the online market.`);
});

// ADMIN PANEL DASHBOARD
function renderAdminDashboard() {
    document.getElementById('admin-total-sales').innerText = `$${STATE.admin.totalSales.toFixed(2)}`;
    document.getElementById('admin-total-orders').innerText = STATE.admin.totalOrders;
    
    const container = document.getElementById('admin-merchant-verification-list');
    const pendingMerchants = STATE.merchants.filter(m => !m.verified);
    
    if (pendingMerchants.length === 0) {
        container.innerHTML = '<div style="font-size:11px; text-align:center; padding: 15px; color:var(--text-muted);">No merchants currently in verification queue.</div>';
        return;
    }
    
    container.innerHTML = pendingMerchants.map(m => `
        <div class="order-card-merchant" style="margin-bottom:8px;">
            <div style="font-size:12px; font-weight:700; color:var(--text-main);">${m.name}</div>
            <div style="font-size:10px; color:var(--text-muted); margin-bottom:6px;">Applicant Role: Farmer Store</div>
            <button class="btn-action-small" onclick="adminVerifyMerchant('${m.id}')">Approve & Verify Account</button>
        </div>
    `).join('');
}

window.adminVerifyMerchant = function(mId) {
    const merchant = STATE.merchants.find(m => m.id === mId);
    if (!merchant) return;
    
    merchant.verified = true;
    Logger.log(`Administrator verified and approved merchant account: "${merchant.name}"`, 'admin');
    renderAdminDashboard();
    
    Notification.show('Farmer Account Verified!', `${merchant.name} has been approved to sell products.`);
};

// SEARCH STOREFRONT
document.getElementById('product-search-input').addEventListener('input', (e) => {
    STATE.searchQuery = e.target.value;
    renderProducts();
});

// ONBOARDING WORKFLOW TRIGGER
document.getElementById('btn-onboard-start').addEventListener('click', () => {
    Logger.log('Customer began store session.', 'customer');
    switchScreen('screen-customer-home');
});

// BACK NAVIGATION TRIGGERS
document.getElementById('btn-onboard-back').addEventListener('click', () => {
    Logger.log('Onboarding exit attempted. Sandbox loop resumed.', 'system');
});
document.getElementById('btn-details-back').addEventListener('click', () => {
    switchScreen('screen-customer-home');
});
document.getElementById('btn-tracking-cancel').addEventListener('click', () => {
    switchScreen('screen-customer-home');
});

// ROLE SELECT WORKSPACE SYNC
document.getElementById('btn-role-customer').addEventListener('click', () => switchRole('customer'));
document.getElementById('btn-role-farmer').addEventListener('click', () => switchRole('farmer'));
document.getElementById('btn-role-delivery').addEventListener('click', () => switchRole('delivery'));
document.getElementById('btn-role-admin').addEventListener('click', () => switchRole('admin'));

// TAB NAV BAR LISTENERS
document.getElementById('tab-home').addEventListener('click', () => switchScreen('screen-customer-home'));
document.getElementById('tab-categories').addEventListener('click', () => {
    switchScreen('screen-customer-home');
    document.getElementById('product-search-input').focus();
});
document.getElementById('tab-cart').addEventListener('click', () => {
    switchScreen('screen-customer-cart');
    renderCart();
});
document.getElementById('tab-tracking').addEventListener('click', () => {
    // Show tracking for latest order, or default placeholder
    if (STATE.orders.length > 0) {
        const latest = STATE.orders[STATE.orders.length - 1];
        document.getElementById('tracking-order-id').innerText = `#${latest.id}`;
        document.getElementById('tracking-delivery-otp').innerText = latest.otp;
        updateTrackingTimeline(latest);
    }
    switchScreen('screen-customer-tracking');
});

// FARMER TAB LISTENERS
document.getElementById('tab-farmer-dashboard').addEventListener('click', () => {
    switchScreen('screen-farmer-dashboard');
    renderFarmerOrders();
    updateFarmerStats();
});
document.getElementById('tab-farmer-products').addEventListener('click', () => {
    switchScreen('screen-farmer-products');
    renderFarmerInventory();
});
document.getElementById('tab-farmer-profile').addEventListener('click', () => {
    switchScreen('screen-farmer-profile');
});

// DELIVERY TAB LISTENERS
document.getElementById('tab-delivery-dashboard').addEventListener('click', () => {
    switchScreen('screen-delivery-dashboard');
    renderRiderDashboard();
});
document.getElementById('tab-delivery-profile').addEventListener('click', () => {
    switchScreen('screen-delivery-profile');
});


// CLEAR LEDGER LOGS
document.getElementById('btn-clear-logs').addEventListener('click', () => Logger.clear());

// INITIAL SETUP RUNS
renderCategories();
renderProducts();
Logger.log('Interactive Multi-Vendor FarmFresh Simulator re-initialized.', 'system');
Logger.log('Ready to test. Switch roles above to inspect screens.', 'system');
