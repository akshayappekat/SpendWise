# 💳 SpendWise — Personal Expense Tracker

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Provider](https://img.shields.io/badge/State_Management-Provider-6C5CE7?style=for-the-badge)](https://pub.dev/packages/provider)
[![Vercel](https://img.shields.io/badge/Frontend-Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://vercel.com)
[![Render](https://img.shields.io/badge/Backend-Render-46E3B7?style=for-the-badge&logo=render&logoColor=white)](https://render.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=for-the-badge)](LICENSE)

**SpendWise** is a modern, cross-platform personal finance & expense tracking application built with **Flutter**, **Dart**, and **Provider**. It features a complete user authentication system, user-isolated expense tracking, dynamic budget analytics, and dual-engine storage for Mobile, Desktop, and Web.

---

## 🌟 Key Features

* 🔐 **Full Authentication System**:
  * **Login & Sign Up**: Screen validation, show/hide password toggle, confirm password checking, and loading indicators.
  * **Session Persistence**: Remembers logged-in users across app restarts using `SharedPreferences`.
  * **Authentication Gate (`AuthGate`)**: Prevents unauthorized access or screen flickering on app launch.
  * **Clean Logout**: Safely clears session state, transactions, and redirects back to the login screen.

* 👤 **User-Isolated Financial Records**:
  * Transactions, balance totals, monthly budgets, and analytics belong strictly to the authenticated user.
  * User A cannot see User B's transactions.

* 📊 **Dynamic Dashboard & Analytics**:
  * **Personalized Greeting**: Displays `Hello, <User> 👋` based on the currently logged-in account.
  * **Real-Time Balance Summary**: Total Balance, Total Income, Total Expenses, and Monthly Budget Progress bar.
  * **Interactive Charts**: Category-wise expense breakdown powered by `fl_chart`.

* 💸 **Transaction & Budget Management**:
  * Full CRUD (Create, Read, Update, Delete) for Income & Expenses.
  * Categorization (Food, Transport, Shopping, Bills, Salary, Freelance, etc.) with custom icons & colors.
  * Payment method tracking (UPI, Cash, Credit Card, Debit Card, Bank Transfer).
  * Search bar & filter controls by Category or Type.

* 💾 **Dual-Engine Storage**:
  * **Mobile & Desktop**: Native SQLite database (`sqflite`) for fast offline storage.
  * **Flutter Web**: Automatic fallback to `SharedPreferences` JSON storage for web environments.

* 🚀 **Full-Stack Deployment Ready**:
  * **Frontend**: Configured with [`vercel.json`](file:///c:/Users/SAMSUNG/OneDrive/Documents/Expense%20Tracker/vercel.json) for 1-click Vercel deployment.
  * **Backend**: Express REST API ([`server.js`](file:///c:/Users/SAMSUNG/OneDrive/Documents/Expense%20Tracker/server.js)) ready for Render hosting.

---

## 📁 Project Structure

```text
lib/
├── main.dart                      # App entry point, MultiProvider & AuthGate
├── models/
│   ├── user_model.dart            # User entity (id, name, email, password)
│   ├── transaction_model.dart     # Transaction entity (userId, type, amount, category, date)
│   ├── budget_model.dart          # Budget entity (userId, month, amount)
│   ├── goal_model.dart            # Savings goal entity
│   └── recurring_model.dart       # Recurring subscriptions entity
├── services/
│   ├── auth_service.dart          # Local authentication & session persistence
│   ├── database_service.dart      # Dual SQLite / Web DB storage layer
│   └── firebase_service.dart      # Optional Firebase Cloud Sync service
├── providers/
│   ├── auth_provider.dart         # Authentication state management
│   └── transaction_provider.dart  # Financial state management & user-filtered data
├── screens/
│   ├── login_screen.dart          # Login screen with validation & show/hide password
│   ├── signup_screen.dart         # Sign Up screen with match validation
│   ├── dashboard_screen.dart      # Dynamic greeting dashboard with recent transactions
│   ├── add_transaction_screen.dart# Add/Edit transaction form
│   ├── transactions_screen.dart   # Transaction history with search & filters
│   ├── analytics_screen.dart      # Category breakdown charts & monthly summary
│   ├── budget_screen.dart         # Monthly budget limit management
│   ├── goals_screen.dart          # Savings goals tracking
│   ├── recurring_screen.dart      # Subscriptions & recurring bill management
│   ├── receipt_scanner_screen.dart# Receipt photo scanner UI
│   ├── ai_insights_screen.dart    # Automated AI spending tips
│   ├── profile_screen.dart        # User profile, currency, theme & logout
│   └── more_screen.dart           # Tools & preferences menu
├── widgets/
│   ├── balance_card.dart          # Gradient glassmorphism balance card
│   ├── transaction_tile.dart      # Transaction item tile
│   ├── expense_chart.dart         # Interactive pie chart
│   └── budget_progress.dart       # Budget progress bar
├── theme/
│   └── app_theme.dart             # Material 3 light & dark theme system
└── utils/
    ├── constants.dart             # Categories, colors, icons mapping
    └── helpers.dart               # Currency & date formatters
```

---

## 🚀 Getting Started Locally

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
* [Dart SDK](https://dart.dev/get-started) (>= 3.0.0)
* Android Studio / VS Code / Google Chrome

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/YOUR_USERNAME/spendwise.git
cd spendwise
flutter pub get
```

### 2. Run Application

* **Run on Android / Desktop / Emulator**:
  ```bash
  flutter run
  ```

* **Run on Web Browser**:
  ```bash
  flutter run -d chrome
  ```
  *(Or serve on port 8080: `flutter run -d web-server --web-port 8080`)*

---

## 🌐 Deployment Instructions

### 1. Deploy Frontend to Vercel
This project includes a pre-configured [`vercel.json`](file:///c:/Users/SAMSUNG/OneDrive/Documents/Expense%20Tracker/vercel.json) file for single-page routing:

* **Using Vercel CLI**:
  ```bash
  flutter build web --release
  npx vercel --prod
  ```
* **Using Vercel Dashboard**:
  1. Import repository on [vercel.com](https://vercel.com).
  2. Set **Framework Preset** to `Other`.
  3. Set **Output Directory** to `build/web`.
  4. Click **Deploy**.

### 2. Deploy Backend to Render
An Express API server ([`server.js`](file:///c:/Users/SAMSUNG/OneDrive/Documents/Expense%20Tracker/server.js)) is provided in the repository:

1. Create a **Web Service** on [render.com](https://render.com).
2. Connect your GitHub repository.
3. Configure settings:
   * **Build Command**: `npm install`
   * **Start Command**: `node server.js`
4. Click **Deploy**.

---

## 🧪 Demo Credentials

To test the application out of the box:

| Account Type | Email | Password |
| :--- | :--- | :--- |
| **Demo User** | `akshay@example.com` | `password123` |
| **New Account** | Click **Sign Up** | Create custom account |

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.
