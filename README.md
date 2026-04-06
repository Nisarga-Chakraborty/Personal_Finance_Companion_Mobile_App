# 💸 Finance Companion — Local-First Flutter App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Android-green.svg)](https://developer.android.com)

**A lightweight mobile finance companion app** built with Flutter that helps users track transactions, understand spending patterns, monitor savings goals, and receive intelligent insights — all stored locally on device with **no internet required**.

> 📱 Demo: Run the app on Android using the instructions below. All data is stored locally via SQLite — no backend or API keys required.

---

## 📸 Screenshots

| Home Dashboard | Transactions | Insights | Profile |
|----------------|--------------|----------| --------|
 ## Dark Mode
## 📸 Screenshots

### Dark Mode Gallery

<div align="center">
  <table>
    <tr>
      <td align="center"><strong>Home Dashboard</strong></td>
      <td align="center"><strong>Transactions</strong></td>
      <td align="center"><strong>Insights</strong></td>
    </tr>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/78ddf600-4b81-4d4e-9374-0196a0485f61" width="250"/></td>
      <td><img src="https://github.com/user-attachments/assets/0985c9b4-5b0a-4d4c-ad1b-e1fb3bd19fc2" width="250"/></td>
      <td><img src="https://github.com/user-attachments/assets/2c4b716e-85b5-40b2-b918-ce2ac867717c" width="250"/></td>
    </tr>
    <tr>
      <td align="center"><strong>Profile</strong></td>
      <td align="center"><strong>Add Transaction</strong></td>
      <td align="center"><strong>Budget</strong></td>
    </tr>
    <tr>
      <td><img src="https://github.com/user-attachments/assets/9ff2891b-3b41-464a-aab4-fbcac371ad9d" width="250"/></td>
      <td><img src="https://github.com/user-attachments/assets/6aed05b1-de09-466d-819b-538f2ec46e24" width="250"/></td>
      <td><img src="https://github.com/user-attachments/assets/691f7689-69c0-4d3b-9f42-5f9d5d5e7d27" width="250"/></td>
    </tr>
    <tr>
      <td align="center" colspan="3"><strong>Transaction Details</strong></td>
    </tr>
    <tr>
      <td colspan="3" align="center"><img src="https://github.com/user-attachments/assets/6c72e8e8-da27-467f-bee3-93269123cb13" width="250"/></td>
    </tr>
  </table>
</div>








---

## ✨ Features

### 🏠 Home Dashboard
- Total account balance with monthly income/expense summary
- Savings summary + month-on-month trend indicator
- Donut chart breaking down spending by category (top 4 + Other)
- AI-style insight chip: *"Food is your top spend — up 12% from last month"*

### 📝 Transaction Tracking
- Add, view, edit, and delete transactions (amount, type, category, date, optional note)
- Grouped by date with headers: *Today*, *Yesterday*, formatted dates
- Filter chips: All / Income / Expense
- Search by category or note

### 🎯 Goal / Budget Feature
- Set a monthly budget limit
- Real-time spending progress indicator
- Visual alerts when approaching or exceeding budget

### 📊 Insights Screen
- Category-wise bar chart
- Month-on-month spending comparison
- Highest spending categories breakdown

### 👤 Profile Screen
- Set user name
- View financial activity summary
- App preferences (Dark/Light mode toggle)

### 🌓 Theme Support
- Dark mode and light mode toggle

---

## 🛠️ Tech Stack

| Layer             | Technology                                      |
|-------------------|-------------------------------------------------|
| **Framework**     | Flutter (Dart)                                  |
| **State Mgmt**    | Riverpod (`flutter_riverpod`)                   |
| **Local DB**      | SQLite via `sqflite`                            |
| **Charts**        | `fl_chart`                                      |
| **Date Formatting** | `intl`                                        |
| **ID Generation** | `uuid`                                          |

---

## 🏗️ Architecture

The app follows a simple three-layer architecture:

### 1. Data Layer
- `app_database.dart` — Opens SQLite database, creates `transactions` and `budget` tables on first launch
- `transaction_repository.dart` — Handles all database operations, contains core business logic (e.g., `loadHomeData()` aggregates raw transactions into `HomeState`)

### 2. Provider Layer
- Four `FutureProvider`s expose database, repository, home state, and transaction list to UI
- Automatic loading/error state handling
- `ref.invalidate()` triggers fresh data loads after mutations

### 3. Presentation Layer
- Screens are `ConsumerWidget` or `ConsumerStatefulWidget`
- Watch providers and rebuild automatically on data changes
- Private builder methods keep `build()` clean and readable

---

## 📁 Project Structure
lib/
├── screens/ # Home, Transactions, Insights, Profile
├── providers/ # Riverpod providers
├── database/ # app_database.dart, transaction_repository.dart

text

---

## 🚀 Setup Instructions

### Prerequisites

- Flutter SDK 3.x or above
- Android device with USB debugging enabled, **or** Android emulator
- Android Studio or VS Code with Flutter extension

### Steps

1. **Clone or download the project**
   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
Install dependencies

bash
flutter pub get
Run the app

bash
# Connect Android device or start emulator, then:
flutter run

# For release build:
flutter build apk --release
⚠️ Note: No .env or API keys required — everything runs locally.

🧪 Running Tests
bash
flutter test
💡 Key Design Decisions & Assumptions
Decisions
Decision	Rationale
Local storage only	SQLite via sqflite. In production, extend with RBI Account Aggregator for auto-sync.
No forced daily logging	Accepts transactions anytime. Dashboard reflects current state with date-range aggregation.
Riverpod over Provider/Bloc	Clean async handling via FutureProvider, automatic dependency tracking, simple cache invalidation.
Single file per screen	Private builder methods keep UI logic co-located for easier navigation.
Category breakdown: 4 + Other	Keeps donut chart readable, avoids visual clutter on small screens.
ISO 8601 date storage	Allows reliable month filtering with LIKE '2026-04%' without complex parsing.
Assumptions
✅ Targets Android (iOS possible but not tested)

✅ Amounts in Indian Rupees (₹)

✅ Predefined categories: Food, Transport, Shopping, Bills, Health, Other

✅ Insight text generated from local calculations (not external AI API)

✅ Budget resets automatically at start of each new month

🔮 What I Would Add Next
🔗 Account Aggregator integration — automatic bank transaction sync

🔔 Push notifications for budget alerts

📁 CSV export for transaction history

🔒 Biometric lock for app security

💱 Multi-currency support

🔁 Recurring transaction templates

📄 License
This project is licensed under the MIT License — see the LICENSE file for details.

🙏 Acknowledgments
Flutter

Riverpod

fl_chart

sqflite

Built with ❤️ for local-first personal finance management.
