# Clean Architecture Flutter Boilerplate

A production-ready Flutter boilerplate implementing **Clean Architecture** with **Feature-First organization**, **BLoC state management**, and modern code generation tools.

## 🏗️ Architecture

This project follows **Clean Architecture** principles with a **Feature-First** folder structure:

```
lib/
├── core/                          # Core utilities (shared across features)
│   ├── di/                       # Dependency injection setup
│   │   ├── injection.dart        # GetIt configuration
│   │   ├── injection.config.dart # Generated DI config
│   │   ├── network_module.dart   # Network module (Dio)
│   │   └── data_source_module.dart
│   ├── errors/                   # Error handling
│   │   ├── failures.dart         # Failure classes
│   │   └── exceptions.dart       # Exception classes
│   ├── network/                  # Network configuration
│   ├── routes/                   # App routing (go_router)
│   ├── theme/                    # App theming
│   └── usecase/                  # Base UseCase class
│
├── features/                      # Feature modules (Feature-First)
│   └── auth/                     # Example: Auth feature
│       ├── domain/               # Business logic layer
│       │   ├── entities/         # Business objects (UserEntity)
│       │   ├── repositories/     # Repository interfaces
│       │   └── usecases/         # Use cases (LoginUseCase, etc.)
│       ├── data/                 # Data layer
│       │   ├── models/           # Data models (UserModel with Freezed)
│       │   ├── datasources/      # Data sources
│       │   │   └── remote/       # API services (Retrofit)
│       │   └── repositories/     # Repository implementations
│       └── presentation/         # UI layer
│           ├── bloc/             # BLoC state management
│           ├── screens/          # Screen widgets
│           └── widgets/          # Reusable widgets
│
└── l10n/                          # Localization
    ├── arb/                      # Translation files
    └── gen/                      # Generated localization
```

## ✨ Features

- ✅ **Clean Architecture** with proper layer separation
- ✅ **Feature-First** organization for scalability
- ✅ **BLoC** state management with `flutter_bloc`
- ✅ **Dependency Injection** with `get_it` + `injectable`
- ✅ **Code Generation**:
  - `freezed` for immutable data classes
  - `json_serializable` for JSON parsing
  - `retrofit` for type-safe API calls
  - `flutter_gen` for asset management
- ✅ **go_router** for declarative routing
- ✅ **Localization** with `intl`
- ✅ **Error Handling** with `dartz` (Either monad)
- ✅ **Testable** code structure

## 📦 Tech Stack

### State Management
- `flutter_bloc` ^8.1.6 - BLoC pattern
- `hydrated_bloc` ^9.1.5 - State persistence

### Dependency Injection
- `get_it` ^8.0.0 - Service locator
- `injectable` ^2.5.0 - Code generation for DI

### Networking
- `dio` ^5.7.0 - HTTP client
- `retrofit` ^4.5.0 - Type-safe API calls
- `pretty_dio_logger` ^1.4.0 - Request/response logging

### Code Generation
- `freezed` ^2.5.7 - Immutable classes & unions
- `json_serializable` ^6.8.0 - JSON serialization
- `flutter_gen` ^5.7.0 - Asset code generation
- `build_runner` ^2.4.13 - Code generation tool

### Utilities
- `dartz` ^0.10.1 - Functional programming (Either, Option)
- `equatable` ^2.0.7 - Value equality
- `intl` ^0.20.2 - Internationalization
- `flutter_dotenv` ^5.2.1 - Environment variables

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code
```bash
# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Or watch for changes
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 3. Generate Localizations
```bash
flutter gen-l10n
```

### 4. Setup Environment
Create a `.env` file in the root directory:
```
BASE_URL=https://your-api-url.com
API_KEY=your_api_key
```

### 5. Run the App
```bash
flutter run
```

## 🔨 Code Generation Commands

```bash
# Generate all code (DI, Freezed, JSON, Retrofit)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Generate assets
flutter pub run flutter_gen_runner
```

## 📝 Creating a New Feature

### 1. Create Feature Structure
```
lib/features/your_feature/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── data/
│   ├── models/
│   ├── datasources/
│   └── repositories/
└── presentation/
    ├── bloc/
    ├── screens/
    └── widgets/
```

### 2. Domain Layer

**Entity** (`entities/item_entity.dart`):
```dart
class ItemEntity extends Equatable {
  final String id;
  final String name;
  
  const ItemEntity({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}
```

**Repository Interface** (`repositories/item_repository.dart`):
```dart
abstract class ItemRepository {
  ResultFuture<List<ItemEntity>> getItems();
}
```

**Use Case** (`usecases/get_items_usecase.dart`):
```dart
@lazySingleton
class GetItemsUseCase implements UseCase<List<ItemEntity>, NoParams> {
  final ItemRepository _repository;
  GetItemsUseCase(this._repository);
  
  @override
  ResultFuture<List<ItemEntity>> call(NoParams params) {
    return _repository.getItems();
  }
}
```

### 3. Data Layer

**Model** (`models/item_model.dart`):
```dart
@freezed
class ItemModel with _$ItemModel {
  const ItemModel._();
  
  const factory ItemModel({
    required String id,
    required String name,
  }) = _ItemModel;
  
  factory ItemModel.fromJson(Map<String, dynamic> json) => 
      _$ItemModelFromJson(json);
  
  ItemEntity toEntity() => ItemEntity(id: id, name: name);
}
```

**API Service** (`datasources/remote/item_api_service.dart`):
```dart
@RestApi()
abstract class ItemApiService {
  factory ItemApiService(Dio dio) = _ItemApiService;
  
  @GET('/items')
  Future<List<ItemModel>> getItems();
}
```

**Repository Implementation** (`repositories/item_repository_impl.dart`):
```dart
@LazySingleton(as: ItemRepository)
class ItemRepositoryImpl implements ItemRepository {
  final ItemRemoteDataSource _remoteDataSource;
  
  ItemRepositoryImpl(this._remoteDataSource);
  
  @override
  ResultFuture<List<ItemEntity>> getItems() async {
    try {
      final items = await _remoteDataSource.getItems();
      return Right(items.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
```

### 4. Presentation Layer

**BLoC** (`presentation/bloc/`):
```dart
@injectable
class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemsUseCase _getItemsUseCase;
  
  ItemBloc(this._getItemsUseCase) : super(const ItemInitial()) {
    on<LoadItems>(_onLoadItems);
  }
  
  Future<void> _onLoadItems(LoadItems event, Emitter<ItemState> emit) async {
    emit(const ItemLoading());
    final result = await _getItemsUseCase(const NoParams());
    result.fold(
      (failure) => emit(ItemError(failure.message)),
      (items) => emit(ItemLoaded(items)),
    );
  }
}
```

### 5. Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/domain/usecases/login_usecase_test.dart
```

## 📚 Clean Architecture Principles

### Dependency Rule
```
Presentation → Domain ← Data
     ↓           ↑
  Depends    Independent
```

- **Domain Layer**: Independent, contains business logic
- **Data Layer**: Depends on Domain (implements interfaces)
- **Presentation Layer**: Depends on Domain (uses use cases)

### Key Concepts

1. **Entities**: Pure business objects (no external dependencies)
2. **Use Cases**: Single business operation per class
3. **Repository Pattern**: Interface in domain, implementation in data
4. **Dependency Inversion**: Domain defines contracts, outer layers implement
5. **Error Handling**: Either monad for explicit error handling

## 🎯 Best Practices

1. **One Use Case = One Business Operation**
2. **Entities != Models** (separate domain from data)
3. **Repository returns Entities** (not models or responses)
4. **BLoC uses Use Cases** (not repositories directly)
5. **Feature isolation** (but share core utilities)
6. **Immutable data** (using Freezed)
7. **Type-safe APIs** (using Retrofit)
8. **Explicit error handling** (using Either)

## 📖 Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Documentation](https://bloclibrary.dev/)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Injectable Package](https://pub.dev/packages/injectable)
- [Go Router](https://pub.dev/packages/go_router)

## 📄 License

This project is open-source and available for use as a boilerplate for your Flutter applications.

---

**Happy Coding! 🚀**
