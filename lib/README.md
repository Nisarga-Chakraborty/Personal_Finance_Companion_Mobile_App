A lightweight mobile finance companion app built with Flutter that helps users track transactions, understand spending patterns, monitor savings goals, and receive intelligent insights — all stored locally on device with no internet required.

Demo

Run the app on Android using the instructions below. All data is stored locally via SQLite — no backend or API keys required.


Features
Home Dashboard
The home screen gives an immediate snapshot of the user's financial health. It displays the total account balance, this month's income and expenses, a savings summary, and a month-on-month trend indicator showing whether the user is doing better or worse than last month. A donut chart breaks down spending by category (top 4 + Other), and an AI-style insight chip surfaces a one-line observation like "Food is your top spend — up 12% from last month."
Transaction Tracking
Users can add, view, edit, and delete transactions. Each transaction captures an amount, type (income or expense), category, date, and an optional note. The transactions screen shows the full history grouped by date with section headers like "Today", "Yesterday", and formatted dates for older entries. Filter chips allow quick filtering by All, Income, or Expense, and a search bar lets users find transactions by category or note.
Goal / Budget Feature
Users can set a monthly budget limit. The app tracks spending against this limit in real time and shows a progress indicator. A visual alert appears when spending approaches or exceeds the budget, encouraging mindful spending habits throughout the month.
Insights Screen
The insights screen presents spending patterns in a visual format including a category-wise bar chart, month-on-month comparison, and the highest spending categories. The purpose is to help users understand their habits at a glance rather than manually calculating from raw data.
Profile Screen
The profile screen allows users to set their name, view a summary of their financial activity, and manage app preferences.

This app also includes Dark and Light mode toggle which further helps the Users to handle this app.

Tech Stack
Layer Technology Framework-- Flutter (Dart),
State Management-- Riverpod (flutter_riverpod)
Local Database-- SQLite via sqflite
Charts-- fl_chart
Date Formatting-- intl
ID Generation-- uuid

Architecture
The app follows a simple three-layer architecture suited to a single-developer Flutter project:
Data Layer — app_database.dart opens a SQLite database using sqflite and creates the transactions and budget tables on first launch. transaction_repository.dart handles all database operations and contains the core business logic including loadHomeData(), which aggregates raw transactions into a structured HomeState object consumed by the home screen.
Provider Layer — Four Riverpod FutureProviders expose the database, repository, home state, and transaction list to the UI. Providers automatically handle loading and error states. When a new transaction is saved, ref.invalidate() is called on the relevant providers to trigger a fresh data load, keeping the UI always in sync.
Presentation Layer — Screens are ConsumerWidget or ConsumerStatefulWidget instances that watch providers and rebuild automatically when data changes. Each screen is broken into private builder methods for readability, keeping the build() method clean and declarative.

Setup Instructions
Prerequisites

Flutter SDK 3.x or above
Android device with USB debugging enabled, or Android emulator
Android Studio or VS Code with Flutter extension

Steps
Clone or download the project, then navigate to the project folder:

"cd assignment"
Install dependencies:
"flutter pub get"
Connect your Android device via USB (enable USB debugging in Developer Options) or start an emulator, then run:
"flutter run"
For a release build:
"flutter build apk --release"

Key Design Decisions and Assumptions
Local storage only — The app uses SQLite via sqflite for all data persistence. In a production context, this would be extended using the RBI Account Aggregator framework for automatic bank transaction sync. For this assignment, manual entry with a frictionless quick-log flow was prioritized instead.
No forced daily logging — Unlike many finance apps that require users to log expenses at a fixed time, this app accepts transactions at any time. The dashboard always reflects the current state of all stored data, with date-range based aggregation rather than day-by-day dependency.
Riverpod over Provider or Bloc — Riverpod was chosen for its clean async handling via FutureProvider, automatic dependency tracking, and straightforward cache invalidation with ref.invalidate(). This eliminates the boilerplate of ChangeNotifier and notifyListeners() that Provider requires.
Single file per screen — Rather than splitting each screen into separate widget files, private builder methods are used within each screen file. This keeps related UI logic co-located and makes the codebase easier to navigate for a project of this size.
Category breakdown capped at 4 + Other — The donut chart shows the top 4 spending categories by amount, with everything else combined into "Other". This keeps the chart readable and avoids visual clutter on small screens.
ISO 8601 date storage — Dates are stored as ISO 8601 strings in SQLite since SQLite has no native date type. This allows reliable month filtering using a simple LIKE '2026-04%' query pattern without complex date parsing.

Assumptions

The app targets Android. iOS support is possible with the same codebase but was not tested.
All amounts are in Indian Rupees (₹).
Categories are predefined: Food, Transport, Shopping, Bills, Health, Other. Custom categories can be added as a future enhancement.
The insight text is generated from local data calculations, not an external AI API.
Budget is set per month and resets automatically at the start of each new month.


What I Would Add Next

Account Aggregator integration for automatic bank transaction sync
Push notifications for budget alerts
Data export to CSV
Biometric lock for app security
Multi-currency support
Recurring transaction templates