# Task Buddy 📋

A Task Management Flutter application built with clean architecture principles, offline-first design, and smart priority management.

## 🚀 Features

### Core Functionality
- **Task Management**: Create, edit, delete, and mark tasks as complete
- **Smart Priority System**: Automatic priority calculation based on due dates and user behavior
- **Category Organization**: Organize tasks by categories (Work, Personal, Study, etc.)
- **Due Date Management**: Set and track task deadlines with visual indicators
- **Search & Filter**: Advanced filtering by category, priority and completion status
- **Progress Tracking**: Visual progress indicators and completion statistics

### Advanced Features
- **Offline-First**: Works seamlessly without internet connection
- **Data Synchronization**: Automatic sync when connection is restored
- **Conflict Resolution**: Intelligent merging of conflicting data
- **Theme Support**: Light and dark theme with automatic persistence
- **Responsive Design**: Optimized for various screen sizes
- **User Analytics**: Track task completion patterns and productivity metrics

### User Experience
- **Intuitive Interface**: Clean, modern UI with Material Design 3
- **Real-time Updates**: Instant feedback and state management
- **Accessibility**: Screen reader support and keyboard navigation
- **Performance**: Optimized for smooth scrolling and fast interactions

## 🏗️ Architecture

Task Buddy follows **Clean Architecture** principles with a layered approach:

```
lib/
├── features/
│   └── task_management/
│       ├── data/           # Data layer (repositories, data sources)
│       ├── domain/         # Business logic (models, services, use cases)
│       └── presentation/   # UI layer (screens, widgets, providers)
├── shared/                 # Shared utilities and common code
│   ├── data/              # Shared data services
│   ├── domain/            # Shared domain models and exceptions
│   ├── theme/             # App theming and styling
│   └── localization/      # Internationalization
└── main.dart              # App entry point
```

### Key Architectural Patterns

- **Repository Pattern**: Abstract data access layer
- **Provider Pattern**: State management with Riverpod
- **Dependency Injection**: Service locator pattern with providers
- **Observer Pattern**: Reactive UI updates
- **Factory Pattern**: Object creation and configuration

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: 3.6.0+ (Dart SDK)
- **Riverpod**: State management and dependency injection
- **Hive**: Local database for offline storage
- **Shared Preferences**: Settings and configuration storage

### UI & Styling
- **Material Design 3**: Modern UI components
- **Flutter ScreenUtil**: Responsive design utilities
- **Custom Theme System**: Light/dark theme with persistence

### Development Tools
- **Mockito**: Mocking framework for testing
- **Build Runner**: Code generation
- **Flutter Lints**: Code quality and style enforcement

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK 3.6.0 or higher
- Android Studio / VS Code with Flutter extensions
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AchizuePriscilla/task-buddy.git
   cd task_buddy
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for mocks and database models)
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 🧪 Testing

Task Buddy includes comprehensive testing at multiple levels:

### Unit Tests
```bash
# Run all unit tests
flutter test test/unit/

# Run specific test categories
flutter test test/unit/services/
flutter test test/unit/providers/
flutter test test/unit/repositories/
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run specific integration test
flutter test integration_test/home_screen_test.dart
```

```

### Test Structure
```
test/
├── unit/                    # Unit tests for business logic
│   ├── services/           # Service layer tests
│   ├── providers/          # State management tests
│   ├── repositories/       # Data layer tests
│   └── models/             # Model tests
├── widget/                 # Widget tests
└── helpers/                # Test utilities and factories

integration_test/           # End-to-end integration tests
├── home_screen_test.dart
```

## 🔧 Development

### Code Generation

The project uses code generation for:
- **Mock classes** (Mockito)
- **Database models** (Hive)
- **Equatable implementations**

Run code generation when you modify:
- Classes with `@GenerateMocks` annotation
- Hive models with `@HiveType` annotation

```bash
# Generate code
flutter packages pub run build_runner build

# Watch for changes and regenerate automatically
flutter packages pub run build_runner watch
```

### Project Structure

```
lib/
├── features/
│   └── task_management/
│       ├── data/
│       │   ├── datasources/        # Data sources (local/remote)
│       │   └── repositories/       # Repository implementations
│       ├── domain/
│       │   ├── enums/             # Enumerations
│       │   ├── extensions/        # Extension methods
│       │   ├── models/            # Domain models
│       │   ├── providers/         # Dependency injection providers
│       │   ├── repositories/      # Repository interfaces
│       │   └── services/          # Business logic services
│       └── presentation/
│           ├── providers/         # UI state providers
│           ├── screens/           # Screen widgets
│           └── widgets/           # Reusable UI components
├── shared/
│   ├── data/
│   │   ├── local/                # Local storage services
│   │   └── sync/                 # Synchronization logic
│   ├── domain/
│   │   ├── exceptions/           # Custom exceptions
│   │   └── providers/            # Shared providers
│   ├── theme/                    # App theming
│   └── localization/             # String resources
└── main.dart
```

### State Management

Task Buddy uses **Riverpod** for state management:

- **StateNotifierProvider**: For complex state logic
- **Provider**: For simple values and dependencies
- **FutureProvider**: For async operations
- **ComputedProvider**: For derived state

### Database Schema

The app uses **Hive** for local storage with the following collections:
- **Tasks**: Task data with relationships
- **User Analytics**: Usage statistics and patterns
- **Sync Queue**: Pending synchronization operations

## 🎨 Theming

The app supports both light and dark themes with:
- **Material Design 3** color system
- **Automatic theme persistence**
- **Dynamic theme switching**
- **Responsive typography**

## 📊 Analytics

Task Buddy includes built-in analytics for:
- Task creation and completion patterns
- Category usage statistics
- Productivity metrics
- User behavior insights

## 🔄 Synchronization

The app implements an offline-first architecture with:
- **Local-first data storage**
- **Queue-based synchronization**
- **Conflict resolution algorithms**
- **Automatic retry mechanisms**

### To run:
```bash
# Build APK
flutter build
```




