# DayDesk - Personal Productivity & Finance Assistant

A comprehensive Flutter application that helps users manage daily tasks, track finances, set budgets, and receive timely reminders — all with a beautiful, adaptive UI and intelligent notification system.

## ✨ Features

- **Task Management**: Create, edit, complete, and delete tasks with due dates/times
- **Financial Tracking**: Log income and expenses, categorize transactions, view spending trends
- **Budget Planning**: Set daily budgets and savings goals with real-time progress tracking
- **Smart Reminders**: Time-based task notifications (even when app is closed) and missed task alerts
- **Recurring Tasks**: Mark tasks as "Consistent" for daily repetition
- **Urgent Tasks**: Prioritize important tasks with visual highlighting
- **Notes & Details**: Add notes to tasks and transactions
- **Dark/Light Theme**: Automatic theme switching based on system preference
- **Secure Storage**: All data encrypted locally using Hive and Flutter Secure Storage
- **Intuitive UI**: Clean, modern interface with smooth animations and responsive layout

## 📱 Screens Overview

| Splash | Onboarding | Dashboard |
|--------|------------|-----------|
| ![Splash](https://via.placeholder.com/150x300?text=Splash) | ![Onboarding](https://via.placeholder.com/150x300?text=Onboarding) | ![Dashboard](https://via.placeholder.com/150x300?text=Dashboard) |

| Task Entry | Finance Entry | Settings |
|------------|---------------|----------|
| ![Task Entry](https://via.placeholder.com/150x300?text=Task+Entry) | ![Finance Entry](https://via.placeholder.com/150x300?text=Finance+Entry) | ![Settings](https://via.placeholder.com/150x300?text=Settings) |

## 🏗️ Architecture & Folder Structure

```
lib/
├── main.dart                    # App entry point
├── app/
│   ├── core/
│   │   ├── constants/          # App constants, enums, constants
│   │   ├── theme/              # Theme definitions (light/dark)
│   │   ├── utils/              # Helper functions, formatters
│   │   └── services/           # Core services (navigation, etc.)
│   ├── data/
│   │   ├── models/             # Data classes (TaskModel, FinanceModel, etc.)
│   │   └── services/           # Business logic services:
│   │       ├── local_storage_service.dart   # Hive + SecureStorage wrapper
│   │       ├── notification_service.dart    # Local notifications with scheduling
│   │       └── onboarding_service.dart      # User onboarding flow
│   ├── modules/                # Feature modules (feature-first structure)
│   │   ├── dashboard/
│   │   │   ├── home/           # Dashboard screen
│   │   │   │   ├── controllers/ # GetX controllers (HomeController)
│   │   │   │   ├── views/      # UI pages (HomeView)
│   │   │   │   └── widgets/    # Reusable widgets (TaskCard, BudgetCard)
│   │   │   ├── tasks/          # Tasks list screen
│   │   │   ├── finance/        # Financial overview screen
│   │   │   └── charts/         # Data visualization
│   │   ├── auth/               # Authentication stub (login/signup)
│   │   ├── onboarding/         # Initial user setup
│   │   └── settings/           # User preferences
│   └── routes/                 # App routes and navigation
│       ├── app_pages.dart      # GetPage definitions
│       └── app_routes.dart     # Route constants
└── generated/                  # Generated files (if any)
```

## ⚙️ State Management

We use **[GetX](https://pub.dev/packages/get)** for lightweight, high-performance state management and dependency injection.

### Key Concepts:
- **Controllers** (`GetxController`): Manage UI state and business logic
  - Examples: `HomeController`, `QuickEntryController`, `OnboardingService`
- **Reactive Variables** (`.obs`): Auto-update UI when values change
  - Examples: `userName.obs`, `todayTaskCount.obs`, `selectedTime.obs`
- **Binding**: Associates controllers with routes via `GetPage` bindings
- **Dependency Injection**: `Get.put()` and `Get.find()` for service access
- **Reactive UI**: `Obx()`, `GetView<>`, and `GetBuilder` for automatic updates

### Data Flow Example (Adding a Timed Task):
1. User enters task details in `QuickEntrySheet`
2. `QuickEntryController.saveEntry()`:
   - Combines date & time into `DateTime? scheduledAt`
   - Calls `LocalStorageService.addTask()` with the scheduled time
3. `LocalStorageService`:
   - Stores task in Hive box with `scheduledAt` as ISO string
   - Notifies listeners via `tasks.refresh()`
4. `HomeController._loadDashboard()` (triggered by listener):
   - Reads tasks from storage
   - Converts `scheduledAt` string back to `DateTime?`
   - Updates `tasks` observable list
5. UI rebuilds via `Obx(() => ListView(...))` in `HomeView`
6. `NotificationService`:
   - Runs periodic timer (every minute)
   - Checks for tasks with `scheduledAt` within next minute
   - Shows local notification via `flutter_local_notifications`
   - Handles app lifecycle to catch missed notifications

## 🔐 Data Persistence & Security

- **Hive**: Lightweight NoSQL database for fast local storage
- **Flutter Secure Storage**: Encrypted storage for sensitive data (encryption keys)
- **Encryption**: All Hive boxes are encrypted with a randomly generated key stored securely
- **Data Models**: 
  - `TaskModel`: id, title, subtitle, badge, isDone, scheduledAt, notes, createdAt
  - Financial activities: Similar structure with amount, category, occurredAt

## 🛠️ Technical Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| **UI Framework** | Flutter 3.0+ | Cross-platform UI |
| **State Management** | GetX | Reactive state & dependency injection |
| **Local Database** | Hive | Fast, lightweight NoSQL storage |
| **Secure Storage** | Flutter Secure Storage | Encrypted key/value storage |
| **Notifications** | Flutter Local Notifications | Local push notifications (iOS/Android) |
| **Timezone Handling** | timezone + flutter_timezone | Correct scheduled times across zones |
| **Date/Time Picking** | Built-in showDatePicker/showTimePicker | Native platform pickers |
| **Dependency Injection** | GetX service locator | Decoupled architecture |
| **Animation** | Flutter's animation framework | Transitions & micro-interactions |
| **Architecture** | Feature-first / Clean-ish layers | Scalable, maintainable codebase |

## 📦 Dependencies

See `pubspec.yaml` for full list, key dependencies include:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.7.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^10.2.0
  flutter_local_notifications: ^12.0.0
  timezone: ^0.9.0
  flutter_timezone: ^2.0.0
  # ... plus UI and utility packages
```

## 🔧 Installation & Setup

1. **Flutter SDK**: Install Flutter 3.0+ ([install guide](https://docs.flutter.dev/get-started/install))
2. **Clone Repository**:
   ```bash
   git clone https://github.com/yourusername/daydesk.git
   cd daydesk
   ```
3. **Get Packages**:
   ```bash
   flutter pub get
   ```
4. **Run**:
   ```bash
   flutter run
   ```
   (Supports Android, iOS, web, Windows, macOS, Linux)

## 🧪 Testing

- **Unit Tests**: Located in `test/` directory
- **Widget Tests**: UI Tests can also `integration_test/`integration_test`) and end
```

## 🚀 Release Building

```bash
# Android APK
flutter build apk --release

# iOS App Store (requires macOS & Xcode)
flutter build ios --release

# Web
flutter build web --release

# Desktop (examples)
flutter build windows --release
flutter build macos --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Ensure you follow the existing code style (see `analysis_options.yaml`)
5. Write tests for new functionality
6. Run `flutter test` to verify nothing breaks
7. Commit and push your changes
8. Open a Pull Request with a clear description

Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🙏 Acknowledgments

- **Flutter Team**: For the excellent cross-platform UI toolkit
- **GetX Contributors**: For the powerful yet simple state management solution
- **Hive Team**: For the blazing-fast NoSQL database
- **Flutter Secure Storage & Local Notifications**: For essential security and notification capabilities
- **Open Source Community**: For countless packages that make Flutter development joyful

---

*Built with ❤️ using Flutter, GetX, and a passion for helping people stay organized and financially healthy.*

**Last Updated**: June 2027
