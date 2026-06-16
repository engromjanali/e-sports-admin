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

# Supabase Database Documentation

This project uses [Supabase](https://supabase.com) as its backend — PostgreSQL database, Auth, and Storage.
Both the **Admin** (Flutter web/desktop) and **User** (Flutter mobile) apps connect to the **same Supabase project**.

---

## Project Overview

An e-sports club management platform for tracking players, matches, seasons, stats, news, and hall of fame entries.

- **Admin app** — manages players, matches, entries, news, FAQs, settings
- **User app** — read-only view: standings, match results, news, hall of fame, player profiles

---

## Setup: Recreate the Database

### Step 1 — Create a Supabase Project

1. Go to [https://supabase.com](https://supabase.com) and create a new project
2. Note your **Project URL** and **anon public key** from `Project Settings → API`

### Step 2 — Run Schema SQL

Open **SQL Editor → New Query** in your Supabase dashboard and run the following in order:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. No foreign key dependencies
CREATE TABLE public.season (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text,
  start_date timestamp with time zone NOT NULL DEFAULT now(),
  end_date timestamp with time zone,
  status boolean NOT NULL DEFAULT true,
  CONSTRAINT season_pkey PRIMARY KEY (id)
);

CREATE TABLE public.players (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  sort_name text,
  profileimageurl text,
  jerseynumber integer,
  createdat timestamp with time zone DEFAULT now(),
  email text UNIQUE,
  password text DEFAULT '12345678',
  CONSTRAINT players_pkey PRIMARY KEY (id)
);

CREATE TABLE public.competitions (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  name text NOT NULL UNIQUE,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT competitions_pkey PRIMARY KEY (id)
);

CREATE TABLE public.player_role (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  name text,
  status boolean DEFAULT true,
  CONSTRAINT player_role_pkey PRIMARY KEY (id)
);

CREATE TABLE public.custom_tags (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  name text,
  status boolean DEFAULT true,
  CONSTRAINT custom_tags_pkey PRIMARY KEY (id)
);

-- Junction tables: connect players to their roles and tags
CREATE TABLE public.player_player_roles (
  player_id uuid NOT NULL,
  role_id bigint NOT NULL,
  CONSTRAINT player_player_roles_pkey PRIMARY KEY (player_id, role_id),
  CONSTRAINT player_player_roles_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE,
  CONSTRAINT player_player_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.player_role(id) ON DELETE CASCADE
);

CREATE TABLE public.player_custom_tags (
  player_id uuid NOT NULL,
  tag_id bigint NOT NULL,
  CONSTRAINT player_custom_tags_pkey PRIMARY KEY (player_id, tag_id),
  CONSTRAINT player_custom_tags_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id) ON DELETE CASCADE,
  CONSTRAINT player_custom_tags_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.custom_tags(id) ON DELETE CASCADE
);

CREATE TABLE public.news (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT timezone('utc'::text, now()),
  title text NOT NULL,
  content text NOT NULL,
  author text NOT NULL,
  category text NOT NULL,
  date text NOT NULL,
  hot boolean NOT NULL DEFAULT false,
  image text,
  emoji text,
  CONSTRAINT news_pkey PRIMARY KEY (id)
);

CREATE TABLE public.faqs (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  question text NOT NULL,
  answer text NOT NULL,
  category text NOT NULL DEFAULT 'General'::text,
  display_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT faqs_pkey PRIMARY KEY (id)
);

-- 2. Depends on season + competitions
CREATE TABLE public.matches (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  season_id bigint NOT NULL,
  hometeam text NOT NULL DEFAULT 'The Elits'::text,
  awayteam text NOT NULL DEFAULT ''::text,
  homescore integer,
  awayscore integer,
  date text NOT NULL DEFAULT ''::text,
  status text NOT NULL DEFAULT 'upcoming'::text
    CHECK (status = ANY (ARRAY['upcoming'::text, 'live'::text, 'finished'::text, 'cancelled'::text])),
  competition_id bigint,
  CONSTRAINT matches_pkey PRIMARY KEY (id),
  CONSTRAINT matches_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.season(id),
  CONSTRAINT matches_competition_id_fkey FOREIGN KEY (competition_id) REFERENCES public.competitions(id)
);

-- 3. Depends on season
CREATE TABLE public.app_settings (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  current_season_id bigint,
  version text,
  verify_email boolean NOT NULL DEFAULT false,
  maintenance_mode boolean NOT NULL DEFAULT false,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT app_settings_pkey PRIMARY KEY (id),
  CONSTRAINT app_settings_current_season_id_fkey FOREIGN KEY (current_season_id) REFERENCES public.season(id)
);

-- 4. Depends on players + season
CREATE TABLE public.match_entries (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  playerid uuid NOT NULL,
  matchid uuid NOT NULL,
  goals integer DEFAULT 0,
  goalsconceded integer DEFAULT 0,
  hattricks integer DEFAULT 0,
  cleansheet boolean DEFAULT false,
  motm boolean DEFAULT false,
  result text DEFAULT 'draw'::text
    CHECK (result = ANY (ARRAY['win'::text, 'loss'::text, 'draw'::text])),
  notes text DEFAULT ''::text,
  season_id bigint,
  CONSTRAINT match_entries_pkey PRIMARY KEY (id),
  CONSTRAINT match_entries_playerid_fkey FOREIGN KEY (playerid) REFERENCES public.players(id),
  CONSTRAINT match_entries_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.season(id)
);

CREATE TABLE public.player_season_stats (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  player_id uuid NOT NULL,
  season_id bigint NOT NULL,
  appearances integer DEFAULT 0,
  goals integer DEFAULT 0,
  cleansheets integer DEFAULT 0,
  hattricks integer DEFAULT 0,
  motmcount integer DEFAULT 0,
  wins integer DEFAULT 0,
  draws integer DEFAULT 0,
  losses integer DEFAULT 0,
  goalsconceded integer DEFAULT 0,
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT player_season_stats_pkey PRIMARY KEY (id),
  CONSTRAINT player_season_stats_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id),
  CONSTRAINT player_season_stats_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.season(id)
);

-- 5. Depends on players
CREATE TABLE public.hall_of_frame (
  id bigint GENERATED ALWAYS AS IDENTITY NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  player_id uuid,
  category text,
  season_text text,
  sub_title text,
  descriptions text,
  CONSTRAINT hall_of_frame_pkey PRIMARY KEY (id),
  CONSTRAINT hall_of_frame_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id)
);
```

### Step 3 — Run Trigger SQL

`player_season_stats` is **auto-maintained** by a trigger — never write to it directly.
Every INSERT / UPDATE / DELETE on `match_entries` recalculates and upserts the stats automatically.

```sql
-- Required unique constraint for upsert
ALTER TABLE public.player_season_stats
ADD CONSTRAINT player_season_stats_player_season_unique
UNIQUE (player_id, season_id);

-- Trigger function
CREATE OR REPLACE FUNCTION sync_player_season_stats()
RETURNS TRIGGER AS $$
DECLARE
  v_player_id uuid;
  v_season_id bigint;
BEGIN
  IF TG_OP = 'DELETE' THEN
    v_player_id := OLD.playerid;
    v_season_id := OLD.season_id;
  ELSE
    v_player_id := NEW.playerid;
    v_season_id := NEW.season_id;
  END IF;

  IF v_season_id IS NULL THEN
    IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
    RETURN NEW;
  END IF;

  INSERT INTO public.player_season_stats (
    player_id, season_id, appearances, goals, cleansheets,
    hattricks, motmcount, wins, draws, losses, goalsconceded, updated_at
  )
  SELECT
    v_player_id,
    v_season_id,
    COUNT(*),
    COALESCE(SUM(goals), 0),
    COUNT(*) FILTER (WHERE cleansheet = true),
    COALESCE(SUM(hattricks), 0),
    COUNT(*) FILTER (WHERE motm = true),
    COUNT(*) FILTER (WHERE result = 'win'),
    COUNT(*) FILTER (WHERE result = 'draw'),
    COUNT(*) FILTER (WHERE result = 'loss'),
    COALESCE(SUM(goalsconceded), 0),
    now()
  FROM public.match_entries
  WHERE playerid = v_player_id AND season_id = v_season_id
  ON CONFLICT (player_id, season_id)
  DO UPDATE SET
    appearances   = EXCLUDED.appearances,
    goals         = EXCLUDED.goals,
    cleansheets   = EXCLUDED.cleansheets,
    hattricks     = EXCLUDED.hattricks,
    motmcount     = EXCLUDED.motmcount,
    wins          = EXCLUDED.wins,
    draws         = EXCLUDED.draws,
    losses        = EXCLUDED.losses,
    goalsconceded = EXCLUDED.goalsconceded,
    updated_at    = EXCLUDED.updated_at;

  IF TG_OP = 'DELETE' THEN RETURN OLD; END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger
CREATE TRIGGER trigger_sync_player_season_stats
AFTER INSERT OR UPDATE OR DELETE ON public.match_entries
FOR EACH ROW EXECUTE FUNCTION sync_player_season_stats();
```

### Step 4 — Environment Variables

Add your Supabase credentials to the project `.env` file:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key
```

---

## Migrations

For an **existing** database (where `players` was created before user-app login
existed), add the `password` column and backfill the default:

```sql
ALTER TABLE public.players
  ADD COLUMN IF NOT EXISTS password text DEFAULT '12345678';

-- Backfill existing players so every account can log in
UPDATE public.players
SET password = '12345678'
WHERE password IS NULL;
```

> Fresh installs don't need this — the column is already in the Step 2 schema.

---

## Table Reference

### `season`
Defines competition seasons (e.g. "Season 1", "2024/25").

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `name` | text | Season display name |
| `start_date` | timestamptz | Season start |
| `end_date` | timestamptz | Season end (nullable → ongoing) |
| `status` | boolean | Active/inactive. Inactive seasons are hidden from the user app. |

> **Current season** is NOT stored on this table — it's `app_settings.current_season_id` (set in Business Setup). The user app derives weeks/months from each season's `start_date`/`end_date`.

---

### `players`
All registered club members.

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Primary key |
| `name` | text | Full name |
| `sort_name` | text | Short/display name |
| `profileimageurl` | text | Avatar URL |
| `jerseynumber` | integer | Jersey number |
| `createdat` | timestamptz | Registration date |
| `email` | text | Unique login email (user app) |
| `password` | text | Login password for the user app (default `12345678`) |

> Roles and tags are stored in junction tables — see `player_player_roles` and `player_custom_tags` below.

> **User app login:** the user app authenticates by matching `email` + `password` against this table and uses the player's `id` (UUID) as the session token. Default password for all players is `12345678`.

---

### `competitions`
Competition types (e.g. "League", "Cup", "Friendly").

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `name` | text | Unique competition name |
| `is_active` | boolean | Whether it's selectable for new matches |

---

### `matches`
Each match record.

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Primary key |
| `season_id` | bigint → `season.id` | Which season |
| `hometeam` | text | Home team name (default: "The Elits") |
| `awayteam` | text | Opponent name |
| `homescore` | integer | Home goals (null until finished) |
| `awayscore` | integer | Away goals (null until finished) |
| `date` | text | Match date string |
| `status` | text | `upcoming` / `live` / `finished` / `cancelled` |
| `competition_id` | bigint → `competitions.id` | Competition type |

---

### `match_entries`
Individual player performance record per match. **Write here; stats auto-update.**

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Primary key |
| `playerid` | uuid → `players.id` | The player |
| `matchid` | uuid | The match (no FK — admin manages integrity) |
| `season_id` | bigint → `season.id` | Denormalized for trigger use |
| `goals` | integer | Goals scored |
| `goalsconceded` | integer | Goals conceded |
| `hattricks` | integer | Hat-tricks scored |
| `cleansheet` | boolean | Clean sheet earned |
| `motm` | boolean | Man of the Match |
| `result` | text | `win` / `loss` / `draw` |
| `notes` | text | Optional notes |

---

### `player_season_stats`
Aggregated stats per player per season. **Auto-maintained by trigger — do not write manually.**

| Column | Type | Description |
|---|---|---|
| `player_id` | uuid → `players.id` | The player |
| `season_id` | bigint → `season.id` | The season |
| `appearances` | integer | Total matches played |
| `goals` | integer | Total goals |
| `cleansheets` | integer | Total clean sheets |
| `hattricks` | integer | Total hat-tricks |
| `motmcount` | integer | Total MOTM awards |
| `wins` | integer | Total wins |
| `draws` | integer | Total draws |
| `losses` | integer | Total losses |
| `goalsconceded` | integer | Total goals conceded |
| `updated_at` | timestamptz | Last recalculated |

> **Unique constraint:** `(player_id, season_id)` — one row per player per season.

---

### `news`
Club news articles.

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Primary key |
| `title` | text | Article headline |
| `content` | text | Full article body |
| `author` | text | Author name |
| `category` | text | News category |
| `date` | text | Display date string |
| `hot` | boolean | Featured/pinned article |
| `image` | text | Cover image URL |
| `emoji` | text | Optional emoji icon |

---

### `faqs`
Frequently asked questions shown in the user app.

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `question` | text | FAQ question |
| `answer` | text | FAQ answer |
| `category` | text | Category (default: "General") |
| `display_order` | integer | Sort order |
| `is_active` | boolean | Visibility toggle |

---

### `app_settings`
Global app configuration (single row).

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `current_season_id` | bigint → `season.id` | Active season used app-wide |
| `version` | text | App version string |
| `verify_email` | boolean | Enforce email verification on signup |
| `maintenance_mode` | boolean | Show maintenance screen in user app |

---

### `player_role`
Lookup table of available role options (e.g. Goalkeeper, Defender).

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `name` | text | Role label |
| `status` | boolean | Active/inactive |

---

### `custom_tags`
Lookup table of available tag options assignable to players.

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `name` | text | Tag label |
| `status` | boolean | Active/inactive |

---

### `player_player_roles`
Junction table linking players to their roles. Replaces the old `playerroles text[]` column.

| Column | Type | Description |
|---|---|---|
| `player_id` | uuid → `players.id` | The player (CASCADE on delete) |
| `role_id` | bigint → `player_role.id` | The assigned role (CASCADE on delete) |

> Primary key is `(player_id, role_id)` — a player cannot have the same role twice.

---

### `player_custom_tags`
Junction table linking players to their custom tags. Replaces the old `customtags text[]` column.

| Column | Type | Description |
|---|---|---|
| `player_id` | uuid → `players.id` | The player (CASCADE on delete) |
| `tag_id` | bigint → `custom_tags.id` | The assigned tag (CASCADE on delete) |

> Primary key is `(player_id, tag_id)` — a player cannot have the same tag twice.

---

### `hall_of_frame`
Hall of Fame entries linking players to award categories.

| Column | Type | Description |
|---|---|---|
| `id` | bigint (auto) | Primary key |
| `player_id` | uuid → `players.id` | The awarded player |
| `category` | text | Award category (e.g. "Top Scorer") |
| `season_text` | text | Season label string |
| `sub_title` | text | Award subtitle |
| `descriptions` | text | Description text |

---

## Entity Relationships

```
season ──────────────────────────────────┐
  │                                      │
  ├── matches (season_id)                │
  │     └── competitions (competition_id)│
  │                                      │
  ├── match_entries (season_id) ─────────┤
  │     └── players (playerid)           │
  │                ↓  [trigger]          │
  └── player_season_stats ───────────────┘
        player_id → players.id
        season_id → season.id

players ──┬── player_player_roles ── player_role
          ├── player_custom_tags  ── custom_tags
          └── hall_of_frame (player_id)

season  ── app_settings (current_season_id)

Standalone: news, faqs, competitions
```

---

## Important Notes

1. **`player_season_stats` is read-only from app code** — only written by the database trigger
2. **`match_entries.matchid` has no FK** — the admin is responsible for passing a valid `matches.id`
3. **`app_settings` should always have exactly one row** — create it manually after setup
4. **Player roles and tags use junction tables** — `player_player_roles` and `player_custom_tags` link players to `player_role` and `custom_tags` via real FK constraints (cascade on delete)
5. **Match status values:** `upcoming` | `live` | `finished` | `cancelled`
6. **Match entry result values:** `win` | `loss` | `draw`