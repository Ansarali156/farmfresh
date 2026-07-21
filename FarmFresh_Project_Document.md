# 🌿 FarmFresh — Project Documentation

---

## 1. What is FarmFresh?

**FarmFresh** is a **multi-vendor farm-to-customer e-commerce platform** that connects farmers directly with consumers, eliminating middlemen to ensure fresh produce at fair prices.

The platform supports **four distinct user roles**:

| Role | Description |
|------|-------------|
| **Customer** | Browses products, adds to cart, places orders, tracks deliveries in real-time |
| **Farmer** | Lists farm produce, manages inventory, tracks earnings and order fulfilment |
| **Delivery Partner** | Accepts delivery assignments, navigates routes, confirms delivery via OTP |
| **Admin** | Manages the entire platform — users, farmers, orders, products, coupons, settings |

The app is designed as a **cross-platform mobile application** (Flutter) with a production-grade **REST + WebSocket backend** (NestJS), backed by a fully relational **PostgreSQL** database.

---

## 2. Tech Stack, Architecture & Key Decisions

### Complete Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| **Frontend** | Flutter (Dart) | SDK ≥ 3.0.0 |
| **Backend** | NestJS (Node.js) | v10+ |
| **Language** | TypeScript | v5+ |
| **Database** | PostgreSQL | v15 |
| **ORM** | Prisma | v5.22 |
| **Auth** | JWT (Access + Refresh tokens) | — |
| **Real-time** | Socket.IO | v4+ |
| **File Storage** | S3-compatible (T3 Storage) | — |
| **API Docs** | Swagger / OpenAPI | — |
| **Containerisation** | Docker + Docker Compose | — |
| **Hosting** | Railway (Backend + DB) | — |
| **State Management** | Flutter Riverpod | v2.4.9 |
| **Routing** | GoRouter | v13.1.0 |
| **HTTP Client** | Dio | v5.4.0 |
| **Maps** | flutter_map + OpenStreetMap | v6.1.0 |
| **Charts** | fl_chart | v0.68 |

---

### Architecture Choices & Why

#### Why TypeScript (not plain JavaScript)?
TypeScript brings **static type checking** to Node.js, which is essential for a platform this complex. With 17+ modules (auth, orders, delivery, inventory, payments, notifications, etc.), plain JS would cause runtime bugs that are hard to trace. TypeScript catches type mismatches at compile time, makes refactoring safe, and works perfectly with NestJS decorators for defining routes, guards, and interceptors.

#### Why NestJS (not Express)?
NestJS provides a **structured, opinionated framework** built on top of Express. It enforces separation of concerns through modules, controllers, services, and guards — making it easy for multiple developers to work on different parts without stepping on each other. It also has first-class support for Swagger, WebSockets, JWT guards, and global exception filters — all of which FarmFresh uses.

#### Why Flutter (not React Native or web only)?
Flutter was chosen for **true cross-platform support** (Android, iOS, Web) from a single codebase. It renders its own UI pixels rather than using native widgets, giving pixel-perfect consistency across devices. Flutter is also fast to develop in, and the team had existing Dart/Flutter knowledge.

#### Why PostgreSQL (not MongoDB)?
FarmFresh is a **highly relational** system — orders link to order items, which link to products, which link to farmers, which link to inventories. A relational database with proper foreign keys, cascades, and transactions is the natural fit. PostgreSQL also supports advanced features like decimal precision for pricing, UUID primary keys, and partial indexes.

#### Why Prisma (not TypeORM or raw SQL)?
Prisma gives a **type-safe database client** that is auto-generated from the schema. Any change to the database schema immediately breaks TypeScript compilation if the code doesn't match — preventing a whole category of runtime bugs. The `schema.prisma` file also serves as a single source of truth for the database structure.

#### Why Docker?
Docker was added to:
1. **Standardise the development environment** — anyone can run `docker-compose up` to get PostgreSQL + Redis running locally without installing them manually.
2. **Enable production containerisation** — the backend `Dockerfile` packages the compiled NestJS app into a production image that can be deployed anywhere.

Docker Compose (`docker-compose.yml`) spins up:
- **PostgreSQL 15** (database)
- **Redis 7** (for caching and session management — planned)

#### Why Railway for Hosting?
Railway was chosen as the current hosting platform because:
- It supports **direct deployment from GitHub** with zero config
- It provides a **managed PostgreSQL** database with automatic backups
- It auto-detects Dockerfiles and builds/deploys the backend automatically
- It has a **free/hobby tier** suitable for the current development phase
- It gives a public HTTPS URL immediately without DNS configuration

#### Why Docker Is Not Currently Working on Railway?
The backend `Dockerfile` runs `prisma migrate deploy` before starting the server. In the current Railway configuration, the `DATABASE_URL` environment variable was pointing to the **old database proxy** (`tokaido.proxy.rlwy.net:27364`) which was rotated/expired. The correct URL uses port `59034`. This mismatch caused the Prisma connection to fail during the Docker startup phase on Railway, resulting in the backend service showing as "not found". Once the Railway environment variables are updated to match the new database URL, Docker deployment on Railway will work correctly.

#### System Requirements (to run locally)

| Requirement | Minimum Version |
|-------------|----------------|
| Node.js | v18+ |
| npm | v9+ |
| Flutter SDK | v3.0.0+ |
| Dart SDK | v3.0.0+ |
| Docker Desktop | v4.0+ (optional, for local DB) |
| Chrome browser | Any modern version |
| Git | v2.0+ |

---

## 3. Features

### Customer Features
- ✅ Register / Login (email + password, JWT)
- ✅ Browse products by category (Fruits, Vegetables, Grains, Dairy, Meat, Juices)
- ✅ View product detail with images, pricing, farmer info
- ✅ Add to cart, update quantities, view cart summary
- ✅ Place orders with delivery address
- ✅ Track order status in real-time (WebSocket)
- ✅ View order history
- ✅ Real-time delivery tracking on map (OpenStreetMap)
- ✅ OTP-based delivery confirmation
- ✅ Product reviews and ratings
- ✅ Coupon code application at checkout
- ✅ Push notifications (order updates)
- ✅ Manage saved addresses
- ✅ Profile management with avatar upload (S3)

### Farmer Features
- ✅ Register as a farmer (KYC verification flow)
- ✅ List and manage products (DRAFT → PENDING_APPROVAL → APPROVED)
- ✅ Upload product images (S3)
- ✅ Manage inventory (stock levels, reorder thresholds)
- ✅ View incoming orders and accept/reject
- ✅ Dashboard with earnings summary and statistics
- ✅ Track sales, top products, revenue
- ✅ Bank account details for withdrawals
- ✅ Farmer location update (for delivery routing)

### Delivery Partner Features
- ✅ Register as a delivery partner
- ✅ View assigned deliveries
- ✅ Accept or reject delivery assignments
- ✅ Navigate to pickup location (map + OSRM routing)
- ✅ Mark order as picked up
- ✅ Real-time location broadcast (WebSocket)
- ✅ Navigate to customer location
- ✅ Confirm delivery via customer OTP

### Admin Features
- ✅ Full dashboard with platform-wide statistics
- ✅ Manage all users (customers, farmers, delivery partners)
- ✅ Approve / reject / suspend farmer accounts
- ✅ Manage all products and categories
- ✅ View and manage all orders
- ✅ Coupon management (create, edit, delete, usage tracking)
- ✅ Banner management for homepage promotions
- ✅ Notifications broadcast (send to all users)
- ✅ Platform settings management
- ✅ CMS content management
- ✅ Review moderation (approve / reject reviews)
- ✅ Payout management for farmer withdrawals
- ✅ Audit logs
- ✅ Inventory overview

---

## 4. Project Status

### Backend API — Implementation Status

| Module | Endpoints | Status |
|--------|-----------|--------|
| **Auth** | Register, Login, Refresh Token, Profile, Logout, Change Password, Reset Password | ✅ Complete |
| **Products** | CRUD, listing with filters, search, farmer products | ✅ Complete |
| **Categories** | CRUD, hierarchy (parent/child), admin management | ✅ Complete |
| **Cart** | Add/update/remove items, pricing calculation | ✅ Complete |
| **Orders** | Place order, status updates, order history, cancel | ✅ Complete |
| **Delivery** | Assignment, real-time tracking, OTP confirm, route | ✅ Complete |
| **Inventory** | Stock management, history, reorder alerts | ✅ Complete |
| **Farmer** | Dashboard, earnings, statistics, location update | ✅ Complete |
| **Admin** | Full platform management (15+ sub-features) | ✅ Complete |
| **Notifications** | CRUD, mark as read, broadcast | ✅ Complete |
| **Upload** | S3 profile picture upload/remove | ✅ Complete |
| **Addresses** | CRUD for saved user addresses | ✅ Complete |
| **Payments** | COD, UPI, Card, Net Banking (schema ready) | ⚠️ Schema Only — payment gateway integration pending |
| **Reviews** | Submit, moderate, approve/reject | ✅ Complete |
| **Coupons** | Create, apply, validate, usage tracking | ✅ Complete |
| **WebSocket (Delivery)** | Real-time location broadcast | ✅ Complete |

---

### Frontend App — Implementation Status

| Screen / Feature | Status |
|-----------------|--------|
| Splash + Auth (Login / Register) | ✅ Complete |
| Customer Home / Browse | ✅ Complete |
| Product Detail | ✅ Complete |
| Cart & Checkout | ✅ Complete |
| Order Tracking (map) | ✅ Complete |
| Order History | ✅ Complete |
| Profile Management | ✅ Complete |
| Farmer Dashboard | ✅ Complete |
| Farmer Product Management | ✅ Complete |
| Delivery Partner Dashboard | ✅ Complete |
| Delivery Map + OTP flow | ✅ Complete |
| Admin Dashboard | ✅ Complete |
| Admin User/Product/Order Management | ✅ Complete |
| Notifications | ✅ Complete |
| Payment Gateway UI | ⚠️ UI Only — real gateway pending |
| Real-time WebSocket connection | ✅ Complete |

---

### Infrastructure Status

| Component | Status |
|-----------|--------|
| Railway PostgreSQL Database | ✅ Running |
| Railway Backend Deployment | ⚠️ Broken — env var mismatch (old DB URL in Railway dashboard) |
| Local Backend (`node dist/main.js`) | ✅ Running on port 3000 |
| Flutter Web App | ✅ Running, connected to local backend |
| Docker Compose (local dev) | ✅ Available |
| S3 File Storage | ✅ Configured |
| Swagger API Docs (local) | ✅ Available at `http://localhost:3000/api/docs` |

---

## 5. Developers & Their Responsibilities

> *(Fill in actual developer names and GitHub handles below)*

| Developer | Role | Responsibilities |
|-----------|------|-----------------|
| **[Dev 1 — Backend Lead]** | Backend Engineer | NestJS architecture, Prisma schema design, Auth module, JWT strategy, CORS, deployment to Railway, Docker configuration |
| **[Dev 2 — Frontend Lead]** | Flutter Engineer | Flutter app structure, Riverpod state management, GoRouter navigation, all customer-facing screens |
| **[Dev 3 — Full Stack]** | Full Stack Engineer | Delivery module (backend + frontend), real-time WebSocket integration, map tracking, OTP flow |
| **[Dev 4 — Admin Panel]** | Frontend / Full Stack | Admin dashboard screens, farmer management, product approval flows, coupon and banner management |
| **[Dev 5 — DevOps / DB]** | DevOps & Database | PostgreSQL schema migrations, Prisma migrations, Docker Compose setup, Railway hosting, S3 storage configuration, environment management |

---

## 6. Quick Reference

| Item | Value |
|------|-------|
| **Local Backend URL** | `http://localhost:3000/api/v1` |
| **Local Swagger Docs** | `http://localhost:3000/api/docs` |
| **Production Backend URL** | `https://farmfresh-production-01f2.up.railway.app` *(currently down — Railway env fix needed)* |
| **Database (Railway)** | `tokaido.proxy.rlwy.net:59034` |
| **File Storage** | `https://t3.storageapi.dev` |
| **Flutter Target** | Web (Chrome), Android, iOS |
| **Repository** | `https://github.com/incuxaiwork/farmfresh.git` |

---

*Document generated: July 2026 | FarmFresh v1.0.0*
