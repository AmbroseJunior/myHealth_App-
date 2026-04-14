# myHealth

A multilingual personal health management application built with Flutter and powered by Supabase (cloud PostgreSQL). Runs natively on Android, iOS, Windows, macOS, Linux, and Chrome from a single codebase.

---

## Table of Contents

1. [Overview](#overview)
2. [Platform Support](#platform-support)
3. [Features](#features)
4. [Architecture](#architecture)
5. [Project Structure](#project-structure)
6. [Backend — Supabase](#backend--supabase)
7. [Database Schema](#database-schema)
8. [External APIs](#external-apis)
9. [Authentication](#authentication)
10. [Clinical Calculators](#clinical-calculators)
11. [ICD-10 Search](#icd-10-search)
12. [Localization](#localization)
13. [Navigation & Routes](#navigation--routes)
14. [Dependencies](#dependencies)
15. [Getting Started](#getting-started)
16. [Running the App](#running-the-app)
17. [Design System](#design-system)

---

## Overview

myHealth is a comprehensive patient-facing health record application. It allows users to register and maintain a personal health profile, track allergies, medications, and medical problems, run validated clinical risk calculators, and view all health events on a unified calendar. The dashboard fetches live weather and air quality data alongside a daily motivational health quote.

All health data is stored in **Supabase** (cloud PostgreSQL), protected by Row Level Security. Data persists permanently across sessions, devices, reinstalls, and platforms — nothing is ever stored locally.

---

## Platform Support

| Platform | Status | Notes |
|---|---|---|
| Android | Supported | Native Flutter |
| iOS | Supported | Native Flutter |
| Windows | Supported | Native Flutter desktop |
| macOS | Supported | Native Flutter desktop |
| Linux | Supported | Native Flutter desktop |
| Web (Chrome) | Supported | Flutter Web / WASM |

All platforms share the same Supabase backend. A user's data is available on every device they log into.

---

## Features

### 1. Authentication
- Email + password registration and login via **Supabase Auth**
- Passwords are never stored locally — Supabase manages secure credential storage and JWT session tokens
- **Auto-login** on app launch — Supabase restores the previous session from its secure token store
- The `_AuthGate` widget checks session state on startup and routes to dashboard or login automatically
- Logout invalidates the Supabase session and clears the in-memory user state

### 2. Dashboard
The home screen loads three live data cards in parallel:

| Card | Source | Data Shown |
|---|---|---|
| Motivational Quote | ZenQuotes API | Random health/wellness quote + author |
| Weather | Open-Meteo API | Temperature (°C), wind speed, weather icon |
| Air Quality | Open-Meteo Air Quality API | European AQI, PM10, PM2.5 (µg/m³) |

All cards degrade gracefully — a "data unavailable" message is shown if any API call fails or times out (10-second timeout on each). The dashboard supports pull-to-refresh.

Weather and air quality data are fixed to **Heraklion, Crete** (lat: 35.3387, lon: 25.1442).

### 3. Demographics (Patient Profile)
Stores the user's personal health profile:
- First name, last name
- Date of birth
- Gender
- Race
- Ethnicity
- Location

One profile record per user. Editable via a form screen. Data is upserted into the `patients` table in Supabase.

### 4. WHO-5 Well-Being Index
A validated five-question mental health screening tool from the World Health Organization.

**Questions** (last 2 weeks timeframe):
1. I have felt cheerful and in good spirits
2. I have felt calm and relaxed
3. I have felt active and vigorous
4. I woke up feeling fresh and rested
5. My daily life has been filled with things that interest me

Each answered on a 0–5 slider (All of the time → At no time).

**Scoring:**
| Raw Score | % (×4) | Category |
|---|---|---|
| 0–7 | 0–28% | Poor well-being (possible depression) |
| 8–12 | 32–50% | Below average well-being |
| 13–18 | 52–72% | Average well-being |
| 19–25 | 76–100% | Good well-being |

Results are saved with a timestamp to Supabase. Full history view available.

### 5. Framingham 10-Year CVD Risk Score
The 2008 Framingham point system for estimating 10-year cardiovascular disease risk.

**Inputs:**
- Gender (male / female)
- Age
- Total cholesterol (mg/dL)
- HDL cholesterol (mg/dL)
- Systolic blood pressure (mmHg)
- Blood pressure treatment status (yes / no)
- Smoking status (yes / no)

**Risk Categories:**
| Risk % | Category |
|---|---|
| < 10% | Low |
| 10–19% | Intermediate |
| ≥ 20% | High |

Results display color-coded (green / orange / red). Calculated in real time — save separately to persist. Full history view available.

### 6. FINDRISC — Finnish Diabetes Risk Score
An eight-question validated screening tool for estimating 10-year type 2 diabetes risk.

**Questions and Point Values:**

| Question | Options | Points |
|---|---|---|
| Age | Under 45 / 45–54 / 55–64 / 65+ | 0 / 2 / 3 / 4 |
| BMI (kg/m²) | <25 / 25–30 / >30 | 0 / 1 / 3 |
| Waist circumference | Low / Medium / High (gender-specific) | 0 / 3 / 4 |
| Physical activity ≥30 min/day | Yes / No | 0 / 2 |
| Vegetables daily | Yes / No | 0 / 1 |
| Hypertension medication | No / Yes | 0 / 2 |
| High blood glucose history | No / Yes | 0 / 5 |
| Family history of diabetes | None / Distant relative / Close relative | 0 / 3 / 5 |

**Score Interpretation:**
| Score | Category | 10-Year Risk |
|---|---|---|
| 0–6 | Low | ~1% |
| 7–11 | Slightly elevated | ~4% |
| 12–14 | Moderate | ~17% |
| 15–20 | High | ~33% |
| 21–26 | Very high | ~50% |

Full history view available.

### 7. Allergies
Full CRUD management of allergy records.

**Fields:**
- Allergen (required)
- Reaction description
- Severity: mild / moderate / severe (color-coded green / orange / red)
- Onset date
- Notes

Swipe-to-edit and swipe-to-delete via `flutter_slidable`. Delete requires a confirmation dialog.

### 8. Medications
Full CRUD management of medication records with **change history tracking**.

**Fields:**
- Name (required)
- Dosage
- Frequency
- Start date
- End date
- Ongoing flag (boolean)
- Notes

**Tabs:** Current medications / Past medications (split by `is_ongoing` flag).

Every create and update action appends a snapshot record to `medication_history` with a `change_type` (`create` / `update`) and a full JSON snapshot of the medication state at that moment. History is viewable per medication.

Swipe-to-edit and swipe-to-delete. Delete requires confirmation.

### 9. Medical Problems
ICD-10 coded problem list.

**Fields:**
- ICD-10 code (required, via live search)
- ICD-10 title (auto-populated from code search)
- Status: active / chronic / resolved (color and icon coded)
- Onset date
- Notes

**Status Indicators:**
| Status | Color | Icon |
|---|---|---|
| active | Red | Emergency |
| chronic | Orange | Repeat |
| resolved | Green | Check circle |

ICD-10 search is powered by a bundled local JSON asset — no network required.

### 10. Health Calendar
A unified calendar view (via `table_calendar`) aggregating events from all clinical modules. Colored dot markers appear on dates that have recorded data.

**Event Types and Colors:**

| Type | Color | Icon |
|---|---|---|
| WHO-5 | Purple | 🧠 |
| Framingham | Red | ❤️ |
| FINDRISC | Orange | 🩸 |
| Allergy | Amber | ⚠️ |
| Medication | Blue | 💊 |
| Problem | Teal | 📋 |

Selecting a day shows a list of all events for that date below the calendar. Up to 4 colored dots per day on the grid.

### 11. Settings
- **Language selection:** English or Greek, persisted via `SharedPreferences`, changes the entire app UI immediately without restart
- **Account info:** displays the logged-in user's email (from Supabase Auth)
- **Logout:** signs out of Supabase, clears in-memory state, and returns to the login screen

---

## Architecture

The app uses a **feature-first** folder structure with the **Provider** pattern (`ChangeNotifier`) for state management.

```
Presentation Layer  →  Screens (Flutter Widgets)
State Layer         →  Providers (ChangeNotifier)
Service Layer       →  Services (API calls, AuthService)
Data Layer          →  Supabase (cloud PostgreSQL via supabase_flutter)
```

### Key Architectural Decisions

| Decision | Choice | Reason |
|---|---|---|
| State management | Provider | Lightweight, built-in Flutter support |
| Backend | Supabase | Cloud PostgreSQL, persistent across all platforms and reinstalls |
| Auth | Supabase Auth | JWT sessions, secure credential storage, auto-refresh |
| Routing | Named routes + `onGenerateRoute` | Decoupled navigation, argument passing |
| Localization | ARB files + generated delegates | Standard Flutter i18n, runtime locale switching |
| Clinical logic | Pure Dart (offline) | No network dependency for calculations |

---

## Project Structure

```
lib/
├── main.dart                          # Entry point — Supabase.initialize(), runApp()
├── app.dart                           # MaterialApp, MultiProvider, _AuthGate, routes
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Color palette & Material 3 color scheme
│   │   ├── db_constants.dart          # Table name constants, Heraklion coordinates
│   │   └── route_names.dart           # All named route string constants
│   ├── database/
│   │   ├── database_helper.dart       # No-op stub (SQLite removed, kept for import compat)
│   │   ├── db_init_web.dart           # No-op stub
│   │   └── db_init_io.dart            # No-op stub
│   ├── services/
│   │   ├── auth_service.dart          # Supabase Auth — signIn, signUp, signOut
│   │   ├── weather_service.dart       # Open-Meteo weather API
│   │   ├── air_quality_service.dart   # Open-Meteo air quality API
│   │   └── quote_service.dart         # ZenQuotes API
│   ├── utils/
│   │   ├── score_calculators.dart     # WHO-5, Framingham, FINDRISC pure Dart algorithms
│   │   ├── icd10_search.dart          # Local JSON ICD-10 asset search
│   │   ├── validators.dart            # Form field validators
│   │   └── app_date_utils.dart        # Date formatting helpers
│   └── widgets/
│       ├── app_drawer.dart            # Side navigation drawer (email from Supabase User)
│       ├── confirm_dialog.dart        # Reusable confirmation dialog
│       └── loading_indicator.dart     # Centered CircularProgressIndicator
│
├── features/
│   ├── auth/
│   │   ├── models/user_model.dart
│   │   ├── providers/auth_provider.dart   # Wraps Supabase User, exposes userId (UUID String)
│   │   └── screens/login_screen.dart, register_screen.dart
│   ├── dashboard/
│   │   ├── providers/dashboard_provider.dart
│   │   └── screens/dashboard_screen.dart
│   ├── demographics/
│   │   ├── models/patient_model.dart       # userId: String (UUID)
│   │   ├── providers/demographics_provider.dart
│   │   └── screens/demographics_screen.dart, demographics_form_screen.dart
│   ├── questionnaires/
│   │   ├── models/
│   │   │   ├── who5_result_model.dart      # userId: String
│   │   │   ├── framingham_result_model.dart # userId: String, booleans native
│   │   │   └── findrisc_result_model.dart  # userId: String
│   │   ├── providers/
│   │   │   ├── who5_provider.dart
│   │   │   ├── framingham_provider.dart
│   │   │   └── findrisc_provider.dart
│   │   └── screens/
│   │       ├── who5/who5_questionnaire_screen.dart, who5_history_screen.dart
│   │       ├── framingham/framingham_form_screen.dart, framingham_history_screen.dart
│   │       └── findrisc/findrisc_form_screen.dart, findrisc_history_screen.dart
│   ├── allergies/
│   │   ├── models/allergy_model.dart       # userId: String
│   │   ├── providers/allergies_provider.dart
│   │   └── screens/allergies_screen.dart, allergy_form_screen.dart
│   ├── medications/
│   │   ├── models/medication_model.dart    # userId: String, is_ongoing: bool
│   │   ├── providers/medications_provider.dart
│   │   └── screens/
│   │       ├── medications_screen.dart
│   │       ├── medication_form_screen.dart
│   │       └── medication_history_screen.dart
│   ├── problems/
│   │   ├── models/problem_model.dart       # userId: String
│   │   ├── providers/problems_provider.dart
│   │   └── screens/problems_screen.dart, problem_form_screen.dart
│   ├── calendar/
│   │   ├── models/calendar_event_model.dart
│   │   ├── providers/calendar_provider.dart
│   │   └── screens/calendar_screen.dart
│   └── settings/
│       ├── providers/locale_provider.dart
│       └── screens/settings_screen.dart
│
└── l10n/
    ├── app_localizations.dart
    ├── app_localizations_en.dart      # English strings
    └── app_localizations_el.dart      # Greek strings

assets/
└── data/
    └── icd10_codes.json              # Bundled ICD-10 code database (offline)
```

---

## Backend — Supabase

### Project Details

| Field | Value |
|---|---|
| Provider | Supabase (cloud-hosted PostgreSQL) |
| Project URL | `https://lexmgsylpikqghxziswq.supabase.co` |
| Auth | Supabase Auth (email/password, JWT) |
| Security | Row Level Security (RLS) on all tables |

### Initialization

Supabase is initialized once at app startup in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://lexmgsylpikqghxziswq.supabase.co',
  anonKey: 'sb_publishable_ggTfJ0JYbbVICkm9YzDsuw_LFVSXpEc',
);
```

The anonymous key is safe to embed — all data access is restricted by RLS policies that enforce `auth.uid() = user_id`. No user can read or write another user's data.

### Row Level Security

Every table has an RLS policy of the form:

```sql
create policy "Users manage own data" on <table>
  for all using (auth.uid() = user_id);
```

This means even if someone obtains the anon key, they can only access rows where `user_id` matches their own authenticated UUID.

### Required SQL Setup

Run the following in the **Supabase SQL Editor** to create all required tables:

```sql
-- Patients
create table if not exists patients (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  first_name text, last_name text, date_of_birth text,
  gender text, race text, ethnicity text, location text
);
alter table patients enable row level security;
create policy "Users manage own patients" on patients for all using (auth.uid() = user_id);

-- WHO-5
create table if not exists who5_results (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  recorded_at text not null,
  q1 int, q2 int, q3 int, q4 int, q5 int, total_score int
);
alter table who5_results enable row level security;
create policy "Users manage own who5" on who5_results for all using (auth.uid() = user_id);

-- Framingham
create table if not exists framingham_results (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  recorded_at text not null, age int, gender text,
  total_chol float, hdl_chol float, systolic_bp int,
  is_bp_treated boolean, is_smoker boolean, risk_percent float
);
alter table framingham_results enable row level security;
create policy "Users manage own framingham" on framingham_results for all using (auth.uid() = user_id);

-- FINDRISC
create table if not exists findrisc_results (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  recorded_at text not null,
  age_score int, bmi_score int, waist_score int,
  physical_activity_score int, vegetable_score int,
  hypertension_score int, hyperglycemia_score int,
  family_score int, total_score int, risk_category text
);
alter table findrisc_results enable row level security;
create policy "Users manage own findrisc" on findrisc_results for all using (auth.uid() = user_id);

-- Allergies
create table if not exists allergies (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  allergen text not null, reaction text, severity text,
  onset_date text, notes text, created_at text not null
);
alter table allergies enable row level security;
create policy "Users manage own allergies" on allergies for all using (auth.uid() = user_id);

-- Medications
create table if not exists medications (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null, dosage text, frequency text,
  start_date text, end_date text, is_ongoing boolean default true,
  notes text, created_at text not null, updated_at text not null
);
alter table medications enable row level security;
create policy "Users manage own medications" on medications for all using (auth.uid() = user_id);

-- Medication history
create table if not exists medication_history (
  id bigint generated always as identity primary key,
  medication_id bigint references medications(id) on delete cascade not null,
  changed_at text not null, change_type text not null, snapshot text not null
);
alter table medication_history enable row level security;
create policy "Users manage own med history" on medication_history for all
  using (exists (select 1 from medications m where m.id = medication_id and m.user_id = auth.uid()));

-- Problems
create table if not exists problems (
  id bigint generated always as identity primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  icd10_code text not null, icd10_title text not null,
  status text default 'active', onset_date text, notes text,
  created_at text not null
);
alter table problems enable row level security;
create policy "Users manage own problems" on problems for all using (auth.uid() = user_id);
```

Also disable **"Confirm email"** in Supabase → Authentication → Settings → Email Auth, so users can log in immediately after registering without needing email verification.

---

## Database Schema

All tables live in a cloud Supabase (PostgreSQL) database. `user_id` is a UUID (`uuid`) referencing `auth.users(id)` — it is the Supabase Auth user's unique identifier.

### `patients`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | FK → auth.users(id), RLS key |
| `first_name` | TEXT | |
| `last_name` | TEXT | |
| `date_of_birth` | TEXT | ISO-8601 date string |
| `gender` | TEXT | |
| `race` | TEXT | |
| `ethnicity` | TEXT | |
| `location` | TEXT | |

### `who5_results`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | RLS key |
| `recorded_at` | TEXT NOT NULL | ISO-8601 datetime |
| `q1`–`q5` | INTEGER | 0–5 each |
| `total_score` | INTEGER | 0–25 |

### `framingham_results`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | RLS key |
| `recorded_at` | TEXT NOT NULL | ISO-8601 datetime |
| `age` | INTEGER | |
| `gender` | TEXT | `'male'` or `'female'` |
| `total_chol` | FLOAT | mg/dL |
| `hdl_chol` | FLOAT | mg/dL |
| `systolic_bp` | INTEGER | mmHg |
| `is_bp_treated` | BOOLEAN | PostgreSQL native bool |
| `is_smoker` | BOOLEAN | PostgreSQL native bool |
| `risk_percent` | FLOAT | Estimated 10-year CVD % |

### `findrisc_results`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | RLS key |
| `recorded_at` | TEXT NOT NULL | ISO-8601 datetime |
| `age_score` | INTEGER | 0 / 2 / 3 / 4 |
| `bmi_score` | INTEGER | 0 / 1 / 3 |
| `waist_score` | INTEGER | 0 / 3 / 4 |
| `physical_activity_score` | INTEGER | 0 / 2 |
| `vegetable_score` | INTEGER | 0 / 1 |
| `hypertension_score` | INTEGER | 0 / 2 |
| `hyperglycemia_score` | INTEGER | 0 / 5 |
| `family_score` | INTEGER | 0 / 3 / 5 |
| `total_score` | INTEGER | 0–26 |
| `risk_category` | TEXT | low / slightly elevated / moderate / high / very high |

### `allergies`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | RLS key |
| `allergen` | TEXT NOT NULL | |
| `reaction` | TEXT | |
| `severity` | TEXT | `'mild'` / `'moderate'` / `'severe'` |
| `onset_date` | TEXT | ISO-8601 date |
| `notes` | TEXT | |
| `created_at` | TEXT NOT NULL | ISO-8601 datetime |

### `medications`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | RLS key |
| `name` | TEXT NOT NULL | |
| `dosage` | TEXT | |
| `frequency` | TEXT | |
| `start_date` | TEXT | ISO-8601 date |
| `end_date` | TEXT | ISO-8601 date |
| `is_ongoing` | BOOLEAN | Default `true` |
| `notes` | TEXT | |
| `created_at` | TEXT NOT NULL | ISO-8601 datetime |
| `updated_at` | TEXT NOT NULL | ISO-8601 datetime |

### `medication_history`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `medication_id` | BIGINT NOT NULL | FK → medications(id) ON DELETE CASCADE |
| `changed_at` | TEXT NOT NULL | ISO-8601 datetime |
| `change_type` | TEXT NOT NULL | `'create'` / `'update'` |
| `snapshot` | TEXT NOT NULL | Full medication JSON at time of change |

### `problems`
| Column | Type | Notes |
|---|---|---|
| `id` | BIGINT PK | Auto-generated |
| `user_id` | UUID NOT NULL | RLS key |
| `icd10_code` | TEXT NOT NULL | e.g. `'E11.9'` |
| `icd10_title` | TEXT NOT NULL | e.g. `'Type 2 diabetes mellitus without complications'` |
| `status` | TEXT | `'active'` / `'chronic'` / `'resolved'` (default `'active'`) |
| `onset_date` | TEXT | ISO-8601 date |
| `notes` | TEXT | |
| `created_at` | TEXT NOT NULL | ISO-8601 datetime |

---

## External APIs

All API calls use the `http` package with a **10-second timeout**. All calls fail gracefully — the app shows fallback content rather than crashing.

### ZenQuotes API
- **Purpose:** Daily motivational health quote for the dashboard
- **Endpoint:** `GET https://zenquotes.io/api/random`
- **Auth:** None required
- **Response fields used:** `q` (quote text), `a` (author name)
- **Fallback:** `"Take care of your body. It's the only place you have to live." — Jim Rohn`

### Open-Meteo Weather API
- **Purpose:** Current weather conditions for Heraklion, Crete
- **Endpoint:** `GET https://api.open-meteo.com/v1/forecast`
- **Parameters:** `latitude=35.3387`, `longitude=25.1442`, `current=temperature_2m,weathercode,windspeed_10m`, `timezone=Europe/Athens`
- **Auth:** None required (free, open data)
- **Response fields used:** `current.temperature_2m` (°C), `current.weathercode`, `current.windspeed_10m` (km/h)
- **Weather code mapping:**

| Code | Condition | Icon |
|---|---|---|
| 0 | Clear sky | ☀️ |
| 1–3 | Partly cloudy | ⛅ |
| 4–49 | Foggy | 🌫️ |
| 50–69 | Rainy | 🌧️ |
| 70–79 | Snowy | ❄️ |
| 80–99 | Thunderstorm | ⛈️ |

### Open-Meteo Air Quality API
- **Purpose:** Current air quality metrics for Heraklion, Crete
- **Endpoint:** `GET https://air-quality-api.open-meteo.com/v1/air-quality`
- **Parameters:** `latitude=35.3387`, `longitude=25.1442`, `current=pm10,pm2_5,european_aqi`
- **Auth:** None required
- **Response fields used:** `current.pm10` (µg/m³), `current.pm2_5` (µg/m³), `current.european_aqi`
- **European AQI scale:**

| AQI | Label |
|---|---|
| 0–20 | Good |
| 21–40 | Fair |
| 41–60 | Moderate |
| 61–80 | Poor |
| 81–100 | Very Poor |
| >100 | Extremely Poor |

---

## Authentication

Authentication is handled entirely by **Supabase Auth**. No passwords or credential hashes are stored locally.

### Registration Flow
1. User enters email, password, and confirm password
2. Form validated client-side (email format, password strength, passwords match)
3. `_client.auth.signUp(email: ..., password: ...)` called via `AuthService`
4. Supabase creates the user in `auth.users` and returns a `User` object with a UUID `id`
5. `AuthProvider` sets `_currentUser` and calls `notifyListeners()`
6. App navigates to dashboard

### Login Flow
1. User enters email and password
2. `_client.auth.signInWithPassword(email: ..., password: ...)` called
3. Supabase validates credentials server-side and returns a `Session` + `User`
4. Supabase stores the JWT refresh token securely on-device
5. App navigates to dashboard

### Auto-Login Flow
1. On app start, `_AuthGate` widget calls `AuthProvider.tryAutoLogin()`
2. `tryAutoLogin()` calls `Supabase.instance.client.auth.currentUser`
3. If Supabase has a valid stored session, `currentUser` is non-null → navigate to dashboard
4. If no session → navigate to login screen

### Logout Flow
1. `AuthProvider.logout()` calls `_client.auth.signOut()`
2. Supabase invalidates the JWT and clears the stored token
3. `_currentUser` set to `null`, listeners notified
4. Navigation stack cleared, user lands on login screen

### User Identity
The Supabase Auth `User` object exposes:
- `id` — UUID string, used as `user_id` in all database tables
- `email` — shown in the drawer header and Settings screen
- `AuthProvider.userId` — `String get userId => _currentUser?.id ?? ''`

### SharedPreferences
| Key | Type | Value |
|---|---|---|
| `locale_code` | String | `'en'` or `'el'` — persisted language preference |

No auth session data is stored in SharedPreferences; Supabase manages that internally.

---

## Clinical Calculators

All scoring logic is pure Dart, implemented in [lib/core/utils/score_calculators.dart](lib/core/utils/score_calculators.dart). No network calls are made. Calculations run fully offline.

### WHO-5 (`who5TotalScore`, `who5Category`)
- Sums five 0–5 responses → raw score 0–25
- Multiply by 4 → percentage 0–100%
- Thresholds: ≤28% Poor, ≤50% Below average, ≤72% Average, >72% Good

### Framingham (`framinghamRiskScore`, `framinghamRiskCategory`)
- Implements the **2008 gender-stratified point table** system
- Six input categories: age band, total cholesterol band, HDL band, systolic BP (treated vs. untreated), smoking
- Points summed and mapped to % risk via lookup tables:
  - Male table: −3 to 17 points → 1.0% to 29.4%
  - Female table: −2 to 17 points → 1.0% to 26.9%
- Points outside table range are clamped to min/max
- Risk categories: < 10% Low, 10–19% Intermediate, ≥ 20% High

### FINDRISC (`findRiscScore`, `findRiscCategory`, `findRiscDescription`)
- Simple additive sum of 8 pre-weighted input scores (max 26 points)
- Thresholds: 0–6 Low, 7–11 Slightly elevated, 12–14 Moderate, 15–20 High, 21+ Very high
- Estimated 10-year T2DM probabilities: ~1% / ~4% / ~17% / ~33% / ~50%

---

## ICD-10 Search

Located in [lib/core/utils/icd10_search.dart](lib/core/utils/icd10_search.dart).

- Reads `assets/data/icd10_codes.json` on first use (lazy-loaded, then cached in memory)
- Each entry has `code` and `title` fields
- Search matches if:
  - `code` **starts with** the query (case-insensitive), OR
  - `title` **contains** the query (case-insensitive)
- Returns up to **20** results
- Fully offline — no network required
- Used in the Problem form screen's live search field

---

## Localization

The app supports two languages switchable at runtime without restarting.

| Language | Code | File |
|---|---|---|
| English | `en` | [lib/l10n/app_localizations_en.dart](lib/l10n/app_localizations_en.dart) |
| Greek | `el` | [lib/l10n/app_localizations_el.dart](lib/l10n/app_localizations_el.dart) |

Localization delegates configured in `app.dart`:
- `AppLocalizations.delegate`
- `GlobalMaterialLocalizations.delegate`
- `GlobalWidgetsLocalizations.delegate`
- `GlobalCupertinoLocalizations.delegate`

The selected locale is persisted in `SharedPreferences` under `locale_code`. `LocaleProvider` wraps `MaterialApp` via `Consumer<LocaleProvider>` — changing the locale triggers a full widget tree rebuild.

---

## Navigation & Routes

All navigation uses **named routes** with arguments passed via `RouteSettings.arguments`. Route constants are defined in [lib/core/constants/route_names.dart](lib/core/constants/route_names.dart).

| Route | Screen | Arguments |
|---|---|---|
| `/login` | `LoginScreen` | — |
| `/register` | `RegisterScreen` | — |
| `/dashboard` | `DashboardScreen` | — |
| `/demographics` | `DemographicsScreen` | — |
| `/demographics/edit` | `DemographicsFormScreen` | — |
| `/who5` | `Who5QuestionnaireScreen` | — |
| `/who5/history` | `Who5HistoryScreen` | — |
| `/framingham` | `FraminghamFormScreen` | — |
| `/framingham/history` | `FraminghamHistoryScreen` | — |
| `/findrisc` | `FindriscFormScreen` | — |
| `/findrisc/history` | `FindriscHistoryScreen` | — |
| `/allergies` | `AllergiesScreen` | — |
| `/allergies/form` | `AllergyFormScreen` | `AllergyModel?` (null = add, set = edit) |
| `/medications` | `MedicationsScreen` | — |
| `/medications/form` | `MedicationFormScreen` | `MedicationModel?` |
| `/medications/history` | `MedicationHistoryScreen` | `int` (medication ID) |
| `/problems` | `ProblemsScreen` | — |
| `/problems/form` | `ProblemFormScreen` | `ProblemModel?` |
| `/calendar` | `CalendarScreen` | — |
| `/settings` | `SettingsScreen` | — |

The startup route is handled by `_AuthGate` (home widget), which shows a loading spinner while checking session state and then redirects to dashboard or login.

The side navigation drawer (`AppDrawer`) is present on all post-login screens and provides access to all modules.

---

## Dependencies

### Runtime

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.2 | State management (ChangeNotifier / MultiProvider) |
| `supabase_flutter` | ^2.8.0 | Cloud PostgreSQL backend + Supabase Auth |
| `http` | ^1.2.1 | HTTP client for external API calls |
| `table_calendar` | ^3.1.2 | Interactive monthly calendar widget |
| `intl` | 0.20.2 | Internationalization, date/number formatting |
| `shared_preferences` | ^2.2.3 | Persistent key-value storage (locale) |
| `uuid` | ^4.4.0 | UUID generation utilities |
| `cupertino_icons` | ^1.0.8 | iOS-style icon set |
| `flutter_slidable` | ^3.1.1 | Swipe-to-reveal action panels on list items |
| `flutter_localizations` | SDK | Localization delegates (Material, Cupertino, Widgets) |

### Dev

| Package | Version | Purpose |
|---|---|---|
| `flutter_lints` | ^5.0.0 | Dart/Flutter lint rules |
| `flutter_test` | SDK | Unit and widget testing framework |

---

## Getting Started

### Prerequisites

- **Flutter SDK** with Dart `^3.9.2`
- A **Supabase project** with the SQL schema applied (see [Backend — Supabase](#backend--supabase))
- For Web: **Chrome** browser
- For Windows desktop: **Visual Studio** with the "Desktop development with C++" workload
- For macOS desktop: **Xcode**
- For iOS: **Xcode** + iOS Simulator or device

### 1. Clone and Install

```bash
git clone <repository-url>
cd myHealth_App
flutter pub get
```

### 2. Configure Supabase

The Supabase URL and anon key are already set in `lib/main.dart`:

```dart
await Supabase.initialize(
  url: 'https://lexmgsylpikqghxziswq.supabase.co',
  anonKey: 'sb_publishable_ggTfJ0JYbbVICkm9YzDsuw_LFVSXpEc',
);
```

No additional configuration file is needed.

### 3. Create Database Tables

In the Supabase Dashboard, go to **SQL Editor → New Query**, paste the SQL from the [Backend — Supabase](#backend--supabase) section, and click **Run**.

### 4. Disable Email Confirmation (for development)

In the Supabase Dashboard: **Authentication → Settings → Email Auth → uncheck "Confirm email" → Save**.

This allows users to log in immediately after registering without needing to verify their email address.

---

## Running the App

```bash
# List available devices
flutter devices

# Android emulator or connected device
flutter run -d android

# iOS simulator or connected device
flutter run -d ios

# Chrome (Web)
flutter run -d chrome

# Windows desktop
flutter run -d windows

# macOS desktop
flutter run -d macos

# Linux desktop
flutter run -d linux
```

### Production Builds

```bash
# Web (output: build/web/)
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# Windows executable
flutter build windows --release

# macOS application
flutter build macos --release
```

### Verify No Errors

```bash
flutter analyze
```

Expected: 0 errors (informational style warnings only).

---

## Design System

### Color Palette

Defined in [lib/core/constants/app_colors.dart](lib/core/constants/app_colors.dart):

| Name | Hex | Usage |
|---|---|---|
| `primary` | `#1565C0` | App bar, primary buttons, active states — deep blue |
| `secondary` | `#26C6DA` | Secondary elements — cyan |
| `accent` | `#43A047` | Success, low risk — green |
| `background` | `#F5F7FA` | Screen backgrounds — light grey |
| `surface` | `#FFFFFF` | Card surfaces — white |
| `error` | `#D32F2F` | Error states — deep red |
| `textPrimary` | `#212121` | Primary text — near black |
| `textSecondary` | `#757575` | Secondary / hint text — grey |
| `riskLow` | `#43A047` | Low clinical risk indicator — green |
| `riskModerate` | `#FFA726` | Moderate clinical risk indicator — orange |
| `riskHigh` | `#EF5350` | High clinical risk indicator — red |

### Material Theme

- **Material 3** (`useMaterial3: true`)
- `AppBarTheme`: primary blue background, white foreground, elevation 2
- `ElevatedButtonTheme`: primary blue background, white text, 8dp corner radius
- `CardTheme`: elevation 2, 12dp corner radius
- `InputDecorationTheme`: filled inputs with `Colors.grey.shade50` background, 16/12dp padding

### Typography

Uses the default Material 3 typography scale. No custom fonts are loaded — the system default font is used on each platform (Roboto on Android/Web, San Francisco on iOS/macOS, Segoe UI on Windows).
