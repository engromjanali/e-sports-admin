# Project Structure

```
clean_boilerplate/
│
├── lib/
│   ├── core/                          # Shared core functionality
│   │   ├── di/                        # Dependency Injection
│   │   │   ├── injection.dart         # DI configuration
│   │   │   ├── injection.config.dart  # Generated DI (don't edit)
│   │   │   ├── network_module.dart    # Network DI module
│   │   │   └── data_source_module.dart # DataSource DI module
│   │   │
│   │   ├── errors/                    # Error handling
│   │   │   ├── failures.dart          # Failure classes
│   │   │   └── exceptions.dart        # Exception classes
│   │   │
│   │   ├── network/                   # Network configuration
│   │   │   └── network_module.dart    # Dio setup
│   │   │
│   │   ├── routes/                    # Routing
│   │   │   └── app_router.dart        # Go Router configuration
│   │   │
│   │   ├── theme/                     # Theming
│   │   │   └── app_theme.dart         # App theme config
│   │   │
│   │   └── usecase/                   # Base classes
│   │       └── usecase.dart           # UseCase abstract class
│   │
│   ├── features/                       # Feature modules
│   │   │
│   │   └── auth/                       # Authentication feature
│   │       │
│   │       ├── domain/                 # 🔵 DOMAIN LAYER (Business Logic)
│   │       │   │
│   │       │   ├── entities/           # Pure business objects
│   │       │   │   └── user_entity.dart
│   │       │   │
│   │       │   ├── repositories/       # Repository contracts (interfaces)
│   │       │   │   └── auth_repository.dart
│   │       │   │
│   │       │   └── usecases/           # Business use cases
│   │       │       ├── login_usecase.dart
│   │       │       ├── logout_usecase.dart
│   │       │       └── get_current_user_usecase.dart
│   │       │
│   │       ├── data/                   # 🟢 DATA LAYER (Data Access)
│   │       │   │
│   │       │   ├── models/             # Data models (DTOs)
│   │       │   │   ├── user_model.dart
│   │       │   │   ├── user_model.freezed.dart  # Generated
│   │       │   │   └── user_model.g.dart        # Generated
│   │       │   │
│   │       │   ├── datasources/        # Data sources
│   │       │   │   └── remote/
│   │       │   │       ├── auth_api_service.dart
│   │       │   │       ├── auth_api_service.g.dart  # Generated
│   │       │   │       ├── auth_remote_data_source.dart
│   │       │   │       └── auth_remote_data_source_impl.dart
│   │       │   │
│   │       │   └── repositories/       # Repository implementations
│   │       │       └── auth_repository_impl.dart
│   │       │
│   │       └── presentation/           # 🟡 PRESENTATION LAYER (UI)
│   │           │
│   │           ├── bloc/               # BLoC state management
│   │           │   ├── auth_bloc.dart
│   │           │   ├── auth_event.dart
│   │           │   └── auth_state.dart
│   │           │
│   │           ├── screens/            # Screen widgets
│   │           │   └── login_screen.dart
│   │           │
│   │           └── widgets/            # Reusable widgets
│   │
│   ├── l10n/                           # Localization
│   │   ├── arb/                        # Translation files
│   │   │   ├── app_en.arb             # English
│   │   │   └── app_*.arb              # Other languages
│   │   │
│   │   └── gen/                        # Generated localizations
│   │       └── app_localizations.dart
│   │
│   └── main.dart                       # App entry point
│
├── assets/                             # Static assets
│   ├── images/
│   └── icons/
│
├── test/                               # Tests mirror lib/ structure
│   └── features/
│       └── auth/
│           ├── domain/
│           ├── data/
│           └── presentation/
│
├── .env                                # Environment variables (gitignored)
├── .gitignore
├── analysis_options.yaml               # Linting rules
├── build.yaml                          # Build configuration
├── l10n.yaml                           # Localization config
├── pubspec.yaml                        # Dependencies
├── README.md                           # Main documentation
└── SETUP.md                            # Setup commands
```

## Layer Communication Flow

```
┌─────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                   │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────────┐   │
│  │ Screens │→ │   BLoC   │→ │ Use Cases (Domain)  │   │
│  └─────────┘  └──────────┘  └─────────────────────┘   │
└────────────────────────────────┬────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                        │
│  ┌──────────┐  ┌───────────────┐  ┌─────────────────┐ │
│  │ Entities │  │ Use Cases     │  │  Repository     │ │
│  │          │  │ (Business     │  │  Interfaces     │ │
│  │          │  │  Logic)       │  │  (Contracts)    │ │
│  └──────────┘  └───────────────┘  └─────────────────┘ │
└────────────────────────────────┬────────────────────────┘
                                 ↓
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                         │
│  ┌─────────┐  ┌────────────────┐  ┌─────────────────┐ │
│  │ Models  │  │ Data Sources   │  │  Repository     │ │
│  │ (DTOs)  │  │ (API, Local)   │  │ Implementation  │ │
│  └─────────┘  └────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────┘
                         ↓
                   External APIs
```

## Dependency Flow

```
Presentation ──depends on──→ Domain ←──implements── Data
                              ↑
                          Independent
                      (No dependencies)
```

## File Naming Conventions

- **Entities**: `*_entity.dart` (e.g., `user_entity.dart`)
- **Models**: `*_model.dart` (e.g., `user_model.dart`)
- **Repositories (Interface)**: `*_repository.dart`
- **Repositories (Implementation)**: `*_repository_impl.dart`
- **Use Cases**: `*_usecase.dart` (e.g., `login_usecase.dart`)
- **BLoC**: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- **Screens**: `*_screen.dart`
- **Widgets**: `*_widget.dart`
- **Data Sources**: `*_data_source.dart`, `*_data_source_impl.dart`
- **API Services**: `*_api_service.dart`

## Generated Files (Don't Edit)

- `*.g.dart` - JSON serialization
- `*.freezed.dart` - Freezed models
- `*.config.dart` - Injectable DI
- `gen/**` - Generated code (assets, localization)

## Adding a New Feature

1. Create feature folder: `lib/features/your_feature/`
2. Add three layers: `domain/`, `data/`, `presentation/`
3. Start with domain (entities, repository interface, use cases)
4. Implement data layer (models, data sources, repository)
5. Build presentation (BLoC, screens, widgets)
6. Run code generation
7. Register in DI (automatically handled by injectable)
