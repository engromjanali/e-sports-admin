# Clean Architecture Boilerplate - Setup Commands

## Quick Start in 5 Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code (DI, Freezed, JSON, Retrofit)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Generate localizations
flutter gen-l10n

# 4. Create .env file
echo "BASE_URL=https://api.example.com" > .env
echo "API_KEY=your_api_key" >> .env

# 5. Run the app
flutter run
```

## Development Workflow

### When You Create New Models/APIs

```bash
# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Clean Build (if issues occur)

```bash
# Clean generated files
flutter pub run build_runner clean

# Clean Flutter build
flutter clean

# Reinstall dependencies
flutter pub get

# Regenerate everything
flutter pub run build_runner build --delete-conflicting-outputs
```

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Platform-Specific Commands

### iOS
```bash
cd ios
pod install
cd ..
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

### Web
```bash
flutter run -d chrome
```

## Code Generation Explained

### What Gets Generated?

1. **Freezed** (`*.freezed.dart`)
   - Immutable models
   - copyWith methods
   - Equality operators
   - toString methods

2. **JSON Serializable** (`*.g.dart`)
   - fromJson methods
   - toJson methods

3. **Injectable** (`injection.config.dart`)
   - Dependency injection setup
   - GetIt registration

4. **Retrofit** (`*_service.g.dart`)
   - API service implementations

5. **Flutter Gen** (`gen/assets.gen.dart`)
   - Type-safe asset access

### Useful Flags

```bash
# Delete conflicting outputs (recommended)
--delete-conflicting-outputs

# Watch for changes
watch

# Clean before building
clean
```

## Asset Management

Add assets to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

Then run:
```bash
flutter pub run flutter_gen_runner
```

Access assets type-safely:
```dart
Image.asset(Assets.images.logo.path)
```

## Localization

1. Add translations in `lib/l10n/arb/app_*.arb`
2. Run: `flutter gen-l10n`
3. Use in code:
```dart
AppLocalizations.of(context)!.yourKey
```

## Troubleshooting

### "No implementation found for X"
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### "Part file doesn't exist"
Run code generation

### "BuildRunner stuck"
Kill the process and run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Production Build

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```
