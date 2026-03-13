# 🚗 CarRento — Premium Car Rental App

A production-ready car rental platform built with **Flutter + Node.js/Express + MongoDB**.

---

## 📁 Project Structure

```
carrento/
├── backend/          # Node.js + Express REST API
└── frontend/
    └── carrento/     # Flutter mobile app
```

---

## 🛠 Tech Stack

| Layer      | Technology                          |
|------------|-------------------------------------|
| Mobile     | Flutter 3.x (Dart)                  |
| Backend    | Node.js + Express.js                |
| Database   | MongoDB + Mongoose ODM              |
| Auth       | JWT (JSON Web Tokens)               |
| State Mgmt | Provider                            |
| Navigation | GoRouter                            |
| HTTP       | Dio                                 |
| Storage    | Flutter Secure Storage              |

---

## ⚙️ Backend Setup

### Prerequisites
- Node.js v18+
- MongoDB (local or Atlas)

### Steps

```bash
cd backend

# Install dependencies
npm install

# Configure environment
cp .env.example .env
# Edit .env with your MongoDB URI and JWT secret

# Seed the database (creates admin + sample cars)
npm run seed

# Start development server
npm run dev

# Start production server
npm start
```

### API Endpoints

| Method | Endpoint                         | Auth     | Description              |
|--------|----------------------------------|----------|--------------------------|
| POST   | /api/auth/register               | Public   | Register user            |
| POST   | /api/auth/login                  | Public   | Login                    |
| GET    | /api/auth/me                     | User     | Get current user         |
| PUT    | /api/auth/profile                | User     | Update profile           |
| GET    | /api/cars                        | Public   | List/filter cars         |
| GET    | /api/cars/:id                    | Public   | Get car detail           |
| POST   | /api/cars                        | Admin    | Create car               |
| PUT    | /api/cars/:id                    | Admin    | Update car               |
| DELETE | /api/cars/:id                    | Admin    | Delete car               |
| POST   | /api/bookings                    | User     | Create booking           |
| GET    | /api/bookings/my                 | User     | Get my bookings          |
| PUT    | /api/bookings/:id/cancel         | User     | Cancel booking           |
| GET    | /api/admin/dashboard             | Admin    | Dashboard stats          |
| GET    | /api/admin/users                 | Admin    | List users               |
| PUT    | /api/admin/users/:id/role        | Admin    | Change user role         |
| PUT    | /api/admin/users/:id/toggle-status | Admin  | Activate/deactivate user |
| GET    | /api/admin/bookings              | Admin    | All bookings             |
| PUT    | /api/admin/bookings/:id/status   | Admin    | Update booking status    |

---

## 📱 Flutter App Setup

### Prerequisites
- Flutter 3.x SDK
- Android Studio / Xcode
- An emulator or physical device

### Steps

```bash
cd frontend/carrento

# Install dependencies
flutter pub get

# Configure API URL
# Edit lib/utils/app_theme.dart → AppConstants.baseUrl
# For Android emulator: http://10.0.2.2:5000/api
# For iOS simulator:    http://localhost:5000/api
# For physical device:  http://<your-local-ip>:5000/api

# Run the app
flutter run
```

---

## 🔐 Admin Access

### How to Become an Admin

There are **two ways** to get admin access:

#### Method 1 — Seed Script (Recommended for initial setup)
```bash
cd backend
npm run seed
```
This creates a default admin account:
- **Email:** `admin@carrento.com`
- **Password:** `Admin@123456`

You can customize these in your `.env` file:
```env
ADMIN_EMAIL=youremail@example.com
ADMIN_PASSWORD=YourSecurePassword
ADMIN_NAME=Your Name
```

#### Method 2 — Promote an Existing User
1. Log in as an existing admin
2. Go to **Admin Panel → Users**
3. Find the user and tap **"Make Admin"**

That user can now access the full admin dashboard.

### Admin Capabilities
- 📊 Dashboard with revenue, bookings, user stats
- 🚗 Add / Edit / Delete cars
- 📋 Manage all bookings (confirm, activate, complete, cancel)
- 👥 Manage users (promote to admin, activate/deactivate)

---

## 🎨 App Features

### User Features
- 🔐 Register / Login with JWT auth
- 🏠 Home feed with featured banner and categories
- 🔍 Explore with advanced filters (type, fuel, price, transmission)
- 🚗 Car detail with specs, features, and rating
- 📅 Booking with calendar date picker
- 📋 My bookings with status tracking
- ❌ Cancel bookings
- 👤 Profile management

### Admin Features
- 📊 Analytics dashboard (revenue, cars, bookings, users)
- ➕ Add / edit / delete cars with full form
- 🔄 Toggle car availability
- 📋 View and update all booking statuses
- 👥 Promote users to admin / deactivate accounts

---

## 🚀 Production Deployment

### Backend (e.g. Railway, Render, Heroku)
1. Set environment variables in your hosting platform
2. Set `NODE_ENV=production`
3. Update `MONGODB_URI` to your MongoDB Atlas URI
4. Deploy the `backend/` folder

### Flutter App
1. Update `AppConstants.baseUrl` to your deployed API URL
2. Build for Android: `flutter build apk --release`
3. Build for iOS: `flutter build ios --release`

---

## 📝 License

MIT License — Free to use and modify.
# Carrento
