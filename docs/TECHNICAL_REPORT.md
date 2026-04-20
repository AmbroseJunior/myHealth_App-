# myHealth Application
## Technical Report

**Project Title:** myHealth — Multilingual Personal Health Management Application
**Platform:** Flutter (Android · iOS · Windows · macOS · Linux · Web)
**Backend:** Supabase (Cloud PostgreSQL)
**Deployment:** Vercel (Web) · Docker (Self-hosted)
**Version:** 1.0.0
**Date:** April 2026
**Author:** Nnamdi Ambrose Junior Eze

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Introduction & Background](#2-introduction--background)
3. [System Architecture](#3-system-architecture)
4. [Technology Stack](#4-technology-stack)
5. [Feature Modules](#5-feature-modules)
6. [Database Design & Cloud Backend](#6-database-design--cloud-backend)
7. [Clinical Decision Support Tools](#7-clinical-decision-support-tools)
8. [Authentication & Security](#8-authentication--security)
9. [External API Integrations](#9-external-api-integrations)
10. [CI/CD Pipeline & Deployment](#10-cicd-pipeline--deployment)
11. [Containerization Strategy](#11-containerization-strategy)
12. [Localization & Internationalization](#12-localization--internationalization)
13. [Example Patient Workflow](#13-example-patient-workflow)
14. [Performance & Caching](#14-performance--caching)
15. [Limitations & Future Work](#15-limitations--future-work)
16. [Conclusion](#16-conclusion)
17. [Technical Specifications Reference](#17-technical-specifications-reference)

---

## 1. Executive Summary

myHealth is a production-grade, cross-platform personal health record (PHR) application built with Flutter and backed by Supabase cloud PostgreSQL. It enables patients to self-manage their health data — including allergies, medications, and medical problems — while running validated clinical risk calculators used in primary care settings.

The application operates on six platforms (Android, iOS, Windows, macOS, Linux, and Web/Chrome) from a single Dart codebase. All health data is stored permanently in the cloud, meaning patients never lose their records regardless of device changes, reinstalls, or platform switching.

**Key achievements:**
- Zero-loss cloud persistence via Supabase with Row Level Security protecting all patient data
- Clinically validated calculators: WHO-5 Well-Being Index, Framingham CVD Risk Score, and FINDRISC Diabetes Risk Score — all offline, pure Dart implementations
- Full multilingual support (English and Greek) switchable at runtime
- Automated CI/CD pipeline via GitHub Actions with continuous deployment to Vercel's global CDN
- Production Docker image (~30 MB) for self-hosted deployment with nginx

---

## 2. Introduction & Background

### 2.1 Problem Statement

Patients increasingly manage chronic conditions across multiple healthcare providers and settings. Personal health records are fragmented, stored on paper, locked in provider systems, or held in device-local apps that are lost when hardware changes. There is a need for a patient-owned, persistent health management tool that:

- Works across all devices and operating systems the patient uses
- Preserves data permanently regardless of reinstalls or device changes
- Surfaces clinically relevant risk information to support informed health decisions
- Remains accessible without technical expertise

### 2.2 Objectives

1. Build a cross-platform Flutter application deployable on all six major platforms from a single codebase
2. Implement cloud-backed persistence using Supabase so patient data is never lost
3. Integrate validated clinical screening tools (WHO-5, Framingham, FINDRISC) with offline computation
4. Support English and Greek languages with runtime switching
5. Deploy a production web version accessible via a public URL with automated CI/CD

### 2.3 Scope

The application covers the following clinical domains:
- Mental health screening (WHO-5)
- Cardiovascular risk assessment (Framingham)
- Diabetes risk screening (FINDRISC)
- Allergy management
- Medication tracking with change history
- ICD-10 coded problem list
- Patient demographics
- Health event calendar aggregation

---

## 3. System Architecture

### 3.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       PRESENTATION LAYER                        │
│  Flutter Widgets — Screens, Forms, Cards, Navigation Drawer     │
└─────────────────────────┬───────────────────────────────────────┘
                          │ Provider.of / context.watch
┌─────────────────────────▼───────────────────────────────────────┐
│                         STATE LAYER                             │
│  ChangeNotifier Providers — one per feature module              │
│  AuthProvider · DemographicsProvider · AllergiesProvider        │
│  MedicationsProvider · ProblemsProvider · Who5Provider          │
│  FraminghamProvider · FindriscProvider · CalendarProvider       │
└─────────────────────────┬───────────────────────────────────────┘
                          │ Supabase.instance.client
┌─────────────────────────▼───────────────────────────────────────┐
│                        SERVICE LAYER                            │
│  AuthService (Supabase Auth) · WeatherService (Open-Meteo)      │
│  AirQualityService (Open-Meteo) · QuoteService (ZenQuotes)      │
└─────────────────────────┬───────────────────────────────────────┘
                          │ HTTPS / WebSocket
┌─────────────────────────▼───────────────────────────────────────┐
│                         DATA LAYER                              │
│  Supabase Cloud PostgreSQL — 8 tables, RLS on all              │
│  auth.users · patients · who5_results · framingham_results      │
│  findrisc_results · allergies · medications · problems          │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Feature-First Folder Architecture

The codebase uses a feature-first organisation where each clinical domain is fully encapsulated:

```
lib/
├── core/           ← Shared: constants, services, utils, widgets
└── features/
    ├── auth/       ← Registration, login, session management
    ├── dashboard/  ← Quote, weather, air quality cards
    ├── demographics/    ← Patient profile
    ├── questionnaires/  ← WHO-5, Framingham, FINDRISC
    ├── allergies/       ← CRUD allergy records
    ├── medications/     ← CRUD medications + history
    ├── problems/        ← ICD-10 problem list
    ├── calendar/        ← Unified event view
    └── settings/        ← Language, logout
```

Each feature contains:
- `models/` — pure Dart data classes with `fromMap()` / `toMap()`
- `providers/` — ChangeNotifier classes handling Supabase queries
- `screens/` — Flutter UI widgets

### 3.3 State Management

The application uses the **Provider** pattern (`package:provider ^6.1.2`). All providers are registered at the root via `MultiProvider` in `app.dart` and are available throughout the widget tree.

```
MultiProvider (root)
  ├── LocaleProvider       — locale persistence (SharedPreferences)
  ├── AuthProvider         — Supabase Auth state, userId getter
  ├── DashboardProvider    — parallel API fetching
  ├── DemographicsProvider — patient profile CRUD
  ├── Who5Provider         — WHO-5 results
  ├── FraminghamProvider   — Framingham results
  ├── FindriscProvider     — FINDRISC results
  ├── AllergiesProvider    — allergy CRUD
  ├── MedicationsProvider  — medication CRUD + history
  ├── ProblemsProvider     — problem list CRUD
  └── CalendarProvider     — aggregated event loading
```

State flows: user action → provider method → Supabase query → `notifyListeners()` → widget rebuild.

### 3.4 Navigation Architecture

All routing uses Flutter's **named route** system managed by `onGenerateRoute` in `app.dart`. This decouples screens from navigation logic and allows type-safe argument passing via `RouteSettings.arguments`.

The startup sequence is handled by `_AuthGate`, a stateful widget that shows a loading spinner while checking whether Supabase has a valid stored session, then routes to either `/dashboard` or `/login` without any flickering.

```
App Start
   │
   ▼
_AuthGate (shows CircularProgressIndicator)
   │
   ├── tryAutoLogin() → Supabase.currentUser != null
   │         │
   │         ├─ YES → pushReplacementNamed('/dashboard')
   │         └─ NO  → pushReplacementNamed('/login')
   │
   └── Session managed by Supabase JWT (auto-refresh)
```

---

## 4. Technology Stack

### 4.1 Frontend

| Technology | Version | Role |
|---|---|---|
| Flutter | 3.35.7 | Cross-platform UI framework |
| Dart | 3.9.2 | Programming language |
| Material 3 | — | Design system (`useMaterial3: true`) |
| Provider | ^6.1.2 | State management (ChangeNotifier) |
| flutter_localizations | SDK | i18n delegates |
| table_calendar | ^3.1.2 | Interactive calendar widget |
| flutter_slidable | ^3.1.1 | Swipe-to-action list rows |
| intl | 0.20.2 | Date/number formatting |
| shared_preferences | ^2.2.3 | Locale persistence |

### 4.2 Backend

| Technology | Version | Role |
|---|---|---|
| Supabase | ^2.8.0 | Cloud PostgreSQL + Auth |
| PostgreSQL | 15 | Relational database |
| Row Level Security | — | Per-user data isolation |
| Supabase Auth | — | JWT-based email/password auth |

### 4.3 External APIs

| API | Protocol | Purpose |
|---|---|---|
| ZenQuotes | REST/HTTPS | Motivational quotes (dashboard) |
| Open-Meteo Weather | REST/HTTPS | Live weather for Heraklion |
| Open-Meteo Air Quality | REST/HTTPS | AQI, PM10, PM2.5 data |

### 4.4 DevOps & Infrastructure

| Tool | Role |
|---|---|
| GitHub Actions | CI — analyze + build verification |
| Vercel | CD — production deployment, global CDN |
| Docker + nginx | Self-hosted containerised deployment |
| vercel-build.sh | Installs Flutter in Vercel's build environment |

---

## 5. Feature Modules

### 5.1 Authentication Module

The authentication module uses Supabase Auth, replacing any local credential storage. Passwords are never stored on-device — Supabase manages hashing, salting, and JWT issuance server-side.

- **Registration:** `signUp(email, password)` → Supabase creates `auth.users` entry → returns `User` with UUID
- **Login:** `signInWithPassword(email, password)` → Supabase returns session + JWT → stored securely by Supabase SDK
- **Auto-login:** `auth.currentUser` checked at startup — non-null means valid session exists
- **Logout:** `auth.signOut()` → JWT invalidated → local state cleared

### 5.2 Dashboard Module

The dashboard (`DashboardProvider`) fetches three independent data sources in parallel on mount:

```dart
Future<void> loadAll() async {
  await Future.wait([
    _loadQuote(),
    _loadWeather(),
    _loadAirQuality(),
  ]);
}
```

Each fetch has a 10-second timeout and independent error handling. If any API is unreachable, that card shows "data unavailable" while others remain functional.

### 5.3 Clinical Assessment Modules

Three validated screening tools are implemented:

**WHO-5 Well-Being Index**
Five slider questions (0–5 each). Score 0–25 multiplied by 4 gives a 0–100% well-being percentage. Score ≤28% triggers a note about possible depression screening.

**Framingham CVD Risk Score**
The 2008 gender-stratified point system. Accepts age, total cholesterol, HDL, systolic BP (treated/untreated), and smoking status. Points are totalled and looked up in gender-specific risk tables to produce a 10-year CVD percentage.

**FINDRISC Diabetes Risk Score**
Eight weighted questions covering age, BMI, waist circumference, physical activity, diet, hypertension medication, prior hyperglycaemia, and family history. Total score 0–26 maps to five risk categories.

All three calculators produce results instantly (pure Dart, no network), which are then saved to Supabase on user confirmation.

### 5.4 Health Records Modules

**Allergies** — Full CRUD with severity classification (mild/moderate/severe) colour-coded green/orange/red. Swipe to edit or delete (with confirmation dialog).

**Medications** — Full CRUD with current/past tabs split on `is_ongoing` boolean. Every create or update action writes a JSON snapshot to `medication_history`, creating a full audit trail of changes.

**Problems** — ICD-10 coded problem list. A live search field queries a bundled JSON asset (~70,000 codes) as the user types. Selected code + title are stored alongside status (active/chronic/resolved) and optional onset date and notes.

### 5.5 Health Calendar Module

The calendar aggregates data from all six clinical tables into a single chronological view. Events are placed on dates using either the clinically meaningful date (onset date, start date, assessment date) or the record creation date as fallback.

```
Load calendar:
  ├── who5_results    → each row → WHO-5 event on recorded_at
  ├── framingham_results → each row → CVD event on recorded_at
  ├── findrisc_results   → each row → Diabetes event on recorded_at
  ├── allergies       → each row → Allergy event on onset_date ?? created_at
  ├── medications     → each row → Medication event on start_date ?? created_at
  └── problems        → each row → Problem event on onset_date ?? created_at
```

Up to four coloured dots are rendered per day cell on the calendar grid. Tapping a day lists all events for that date below the calendar.

---

## 6. Database Design & Cloud Backend

### 6.1 Entity Relationship Overview

```
auth.users (Supabase managed)
    │ id (UUID) — referenced as user_id in all tables below
    │
    ├── patients          (1:1)   — demographics
    ├── who5_results      (1:N)   — mental health assessments
    ├── framingham_results (1:N)  — CVD risk assessments
    ├── findrisc_results  (1:N)   — diabetes risk assessments
    ├── allergies         (1:N)   — allergy records
    ├── medications       (1:N)   — medication records
    │       └── medication_history (1:N) — change audit trail
    └── problems          (1:N)   — ICD-10 problem list
```

### 6.2 Row Level Security Model

Every table has RLS enabled with a single all-operations policy:

```sql
create policy "Users manage own data" on <table>
  for all using (auth.uid() = user_id);
```

`auth.uid()` is the UUID of the currently authenticated Supabase user. This guarantees that even if the anonymous public key is exposed, no user can read or write another user's data. The Supabase anon key only provides access to rows where `auth.uid()` matches.

### 6.3 Data Type Decisions

PostgreSQL-native types are used throughout:
- `uuid` for `user_id` — matches Supabase Auth user IDs exactly
- `boolean` for flags (`is_ongoing`, `is_bp_treated`, `is_smoker`) — avoids SQLite-era integer encoding
- `bigint generated always as identity` for primary keys — auto-incrementing, no application-side ID generation
- `text` for dates — stored as ISO-8601 strings for cross-platform consistency and timezone safety

### 6.4 Provider Query Pattern

All eight providers follow the same Supabase query pattern:

```dart
// Load
final rows = await _client
    .from('allergies')
    .select()
    .eq('user_id', userId)
    .order('created_at', ascending: false);
allergies = rows.map((m) => AllergyModel.fromMap(m)).toList();

// Insert
await _client.from('allergies').insert(a.toMap());

// Update
await _client.from('allergies').update(a.toMap()).eq('id', a.id!);

// Delete
await _client.from('allergies').delete().eq('id', id);
```

---

## 7. Clinical Decision Support Tools

### 7.1 WHO-5 Well-Being Index

**Source:** World Health Organization (1998/revised)
**Implementation:** `lib/core/utils/score_calculators.dart`

```
Raw score = sum(q1..q5)        range: 0–25
Percentage = raw_score × 4     range: 0–100%

Interpretation:
  0–28%  → Poor well-being (possible depression — recommend clinical assessment)
  29–50% → Below average well-being
  51–72% → Average well-being
  73–100% → Good well-being
```

Scores ≤50% are flagged. The WHO recommends a full depression assessment for patients scoring ≤50% on the WHO-5.

### 7.2 Framingham 10-Year CVD Risk Score

**Source:** D'Agostino et al. (2008), Circulation
**Implementation:** Gender-stratified point table lookup

Points are assigned across six risk factors independently, then totalled and mapped to a risk percentage via gender-specific lookup tables:

| Risk Factor | Male Points Range | Female Points Range |
|---|---|---|
| Age | −9 to +13 | −7 to +16 |
| Total Cholesterol | 0 to +11 | 0 to +13 |
| HDL Cholesterol | −1 to +2 | −1 to +2 |
| Systolic BP (untreated) | 0 to +2 | 0 to +4 |
| Systolic BP (treated) | 0 to +3 | 0 to +6 |
| Smoking | +4 | +3 |

The lookup tables cover −3 to 17 points (male) and −2 to 17 points (female), with point totals outside this range clamped to the table extremes.

**Risk categories:** <10% Low · 10–19% Intermediate · ≥20% High

### 7.3 FINDRISC — Finnish Diabetes Risk Score

**Source:** Lindström & Tuomilehto (2003), Diabetes Care
**Implementation:** Additive scoring, 8 weighted inputs

```
Total score = Σ(age_score + bmi_score + waist_score +
               physical_activity_score + vegetable_score +
               hypertension_score + hyperglycemia_score + family_score)
Maximum = 26 points

Risk interpretation:
  0–6   → Low             (~1% 10-year T2DM risk)
  7–11  → Slightly elevated (~4%)
  12–14 → Moderate         (~17%)
  15–20 → High             (~33%)
  21–26 → Very high        (~50%)
```

The FINDRISC has 76–77% sensitivity and 73% specificity for detecting undiagnosed T2DM when validated against glucose tolerance tests.

### 7.4 ICD-10 Code Search

A bundled JSON asset (~70,000 WHO ICD-10-CM codes) is loaded lazily on first search and cached in memory. Search matches on code prefix (exact left-anchored) or title substring, returning up to 20 results. This is entirely offline — no network call is made.

---

## 8. Authentication & Security

### 8.1 Supabase Auth

Supabase Auth is a full-featured authentication service built on GoTrue. It provides:
- Bcrypt password hashing (server-side, never exposed)
- JWT access tokens (short-lived, 1-hour expiry by default)
- Refresh tokens (long-lived, stored securely by the Supabase Flutter SDK)
- Automatic token refresh before expiry

The app's `AuthProvider` listens to the Supabase auth state stream:
```dart
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  _currentUser = data.session?.user;
  notifyListeners();
});
```

This means the provider updates automatically when a session expires, is refreshed, or is signed out from another device.

### 8.2 Row Level Security

All eight Supabase tables have RLS enabled. The security model:
1. Client sends request with JWT in `Authorization` header
2. Supabase evaluates `auth.uid()` — the UUID from the JWT
3. RLS policy `auth.uid() = user_id` is applied to every query automatically
4. Rows not matching the policy are invisible to the client

This means even a malicious client with a valid JWT cannot read another user's data.

### 8.3 Security Headers

Production deployments (both Vercel and Docker/nginx) set the following security headers on all responses:

| Header | Value | Purpose |
|---|---|---|
| `X-Content-Type-Options` | `nosniff` | Prevents MIME sniffing |
| `X-Frame-Options` | `SAMEORIGIN` | Prevents clickjacking |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Limits referrer leakage |
| `Cross-Origin-Opener-Policy` | `same-origin` | Enables SharedArrayBuffer (WASM) |
| `Cross-Origin-Embedder-Policy` | `require-corp` | Required for WASM threading |

The COEP/COOP headers are specifically required for Flutter Web's WebAssembly runtime.

---

## 9. External API Integrations

All three external APIs are accessed via the `http` package with a 10-second timeout. All failures are caught silently and result in graceful degradation — the app continues to function normally.

### 9.1 ZenQuotes API

```
Endpoint: GET https://zenquotes.io/api/random
Auth:     None
Fields:   q (quote text), a (author name)
Fallback: "Take care of your body..." — Jim Rohn
```

### 9.2 Open-Meteo Weather API (Free, Open Data)

```
Endpoint: GET https://api.open-meteo.com/v1/forecast
Location: Heraklion, Crete (lat: 35.3387, lon: 25.1442)
Fields:   temperature_2m (°C), weathercode, windspeed_10m (km/h)
Timezone: Europe/Athens
```

Weather codes (WMO standard) are mapped to human-readable descriptions and emoji icons. Code 0 = clear sky, codes 80–99 = thunderstorm, etc.

### 9.3 Open-Meteo Air Quality API (Free, Open Data)

```
Endpoint: GET https://air-quality-api.open-meteo.com/v1/air-quality
Location: Heraklion, Crete (same coordinates)
Fields:   pm10 (µg/m³), pm2_5 (µg/m³), european_aqi (0–500)
```

European AQI scale: 0–20 Good · 21–40 Fair · 41–60 Moderate · 61–80 Poor · 81–100 Very Poor · >100 Extremely Poor

---

## 10. CI/CD Pipeline & Deployment

### 10.1 Pipeline Architecture

```
Developer pushes to GitHub (master branch)
              │
    ┌─────────┴──────────────────────────────────────────┐
    │  GitHub Actions (.github/workflows/ci-cd.yml)       │
    │                                                      │
    │  Job 1 — analyze                                     │
    │    • subosito/flutter-action (cached SDK)            │
    │    • actions/cache (pub packages, keyed on lockfile) │
    │    • flutter pub get                                 │
    │    • flutter analyze --no-fatal-infos                │
    │                 │ success                            │
    │  Job 2 — build  ▼                                   │
    │    • flutter build web --release --base-href /       │
    │    • upload build/web/ as artifact (3-day retention) │
    │                                                      │
    └─────────┬──────────────────────────────────────────┘
              │ (simultaneous, separate trigger)
    ┌─────────▼──────────────────────────────────────────┐
    │  Vercel GitHub Integration                           │
    │    • detects push to master                         │
    │    • runs vercel-build.sh on Ubuntu build server    │
    │        ├─ git clone flutter@3.35.7 (shallow)        │
    │        ├─ flutter config --no-analytics             │
    │        ├─ flutter precache --web                    │
    │        ├─ flutter pub get                           │
    │        └─ flutter build web --release               │
    │    • serves build/web/ via global CDN              │
    │    • assigns *.vercel.app URL                       │
    └─────────────────────────────────────────────────────┘
```

### 10.2 Caching Strategy

| Cache | Key | What is cached |
|---|---|---|
| Flutter SDK | `flutter-3.35.7-Linux` | Entire Flutter installation |
| Pub packages | `pub-Linux-<lockfile hash>` | `~/.pub-cache` + `.dart_tool` |
| Vercel CDN | Per-asset fingerprint | JS/WASM/assets with `immutable` headers |
| index.html | No-cache | Always fetched fresh so new versions load |

JavaScript and WebAssembly files produced by Flutter contain content hashes in their filenames (e.g., `main.dart.js`). These are served with `Cache-Control: public, max-age=31536000, immutable` — browsers cache them for one year, reducing load time to zero for repeat visits. Only `index.html` (which references those hashed filenames) is always fetched fresh.

### 10.3 Vercel Routing Configuration

`vercel.json` configures two essential behaviours:

**SPA rewriting** — Any path that does not look like a file (no extension) is rewritten to `/index.html`, allowing Flutter's client-side router to take over:
```json
{ "source": "/((?!.*\\.).*)", "destination": "/index.html" }
```

**WASM MIME type** — Browsers require WebAssembly files to be served with `Content-Type: application/wasm`, otherwise they refuse to load them:
```json
{ "source": "/(.*)\\.wasm",
  "headers": [{ "key": "Content-Type", "value": "application/wasm" }] }
```

---

## 11. Containerization Strategy

### 11.1 Multi-Stage Docker Build

The Dockerfile uses two stages to produce a minimal production image:

**Stage 1 — Builder** (`ghcr.io/cirruslabs/flutter:3.35.7`)
- Copies `pubspec.yaml` and `pubspec.lock` first (Docker layer cache: `pub get` only re-runs when dependencies change)
- Copies remaining source and runs `flutter build web --release`
- Output: `build/web/` directory with HTML, JS, WASM, and assets

**Stage 2 — Runner** (`nginx:1.27-alpine`)
- Copies only `build/web/` from Stage 1 (builder layer is discarded)
- Copies custom `nginx.conf`
- Final image size: ~30 MB

```dockerfile
FROM ghcr.io/cirruslabs/flutter:3.35.7 AS builder
WORKDIR /app
COPY pubspec.yaml pubspec.lock ./   # cached layer
RUN flutter pub get --no-example
COPY . .
RUN flutter build web --release
                                    # ↑ builder (~2 GB) discarded
FROM nginx:1.27-alpine AS runner
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
```

### 11.2 nginx Configuration

The custom `nginx.conf` provides:
- **SPA routing:** `try_files $uri $uri/ /index.html` — handles all Flutter named routes
- **Gzip compression:** reduces transfer size for JS/CSS/JSON by 60–80%
- **WASM MIME type:** correctly declared in `types {}` block
- **Immutable caching:** 1-year `Cache-Control` for hashed static assets
- **No-cache for index.html:** ensures updates are always picked up
- **Security headers:** X-Frame-Options, X-Content-Type-Options, Referrer-Policy

### 11.3 Docker Compose

```yaml
services:
  myhealth-web:
    build: .
    image: myhealth-web:latest
    ports: ["8080:80"]
    healthcheck:
      test: wget --quiet --tries=1 --spider http://localhost/
```

`docker compose up --build` builds the image and starts the container. The app is accessible at `http://localhost:8080`.

---

## 12. Localization & Internationalization

### 12.1 Supported Languages

| Language | Code | Status |
|---|---|---|
| English | `en` | Primary |
| Greek | `el` | Full translation |

### 12.2 Implementation

Localizations are generated from ARB (Application Resource Bundle) files using Flutter's built-in `gen_l10n` tool (configured in `l10n.yaml`). The generated `AppLocalizations` class provides type-safe access to all strings.

All UI text is accessed via `AppLocalizations.of(context)!.<key>` — no hardcoded strings in any widget.

### 12.3 Runtime Language Switching

Language selection in the Settings screen immediately rebuilds the entire widget tree:

```
User selects Greek in Settings
    │
    ▼
LocaleProvider.setLocale(Locale('el'))
    │
    ├─ saves 'el' to SharedPreferences (locale_code)
    │
    └─ notifyListeners()
           │
           ▼
    Consumer<LocaleProvider> wrapping MaterialApp rebuilds
           │
           ▼
    All widgets receive Locale('el') → Greek strings displayed
```

The locale persists across app restarts — `LocaleProvider` reads from SharedPreferences on init.

---

## 13. Example Patient Workflow

The following workflow traces a realistic usage scenario for a 58-year-old male patient with type 2 diabetes and hypertension.

### Step 1: Registration (first use)

The patient opens the app on their Android phone for the first time. They tap **Register**, enter their email address and a password, and tap **Sign Up**. Supabase creates their account and immediately starts a session. The `_AuthGate` detects the session and routes them to the dashboard.

### Step 2: Dashboard overview

The dashboard loads automatically, showing:
- Today's motivational health quote
- Current weather in Heraklion (temperature, wind, conditions)
- Current air quality index (AQI, PM10, PM2.5)

The patient pulls down to refresh the data.

### Step 3: Setting up demographics

From the navigation drawer, the patient taps **Demographics**. Seeing no profile yet, they tap the edit button and fill in:
- First name, Last name
- Date of birth: 15 March 1967
- Gender: Male
- Location: Heraklion, Crete

They tap **Save**. The record is instantly written to the Supabase `patients` table.

### Step 4: Adding a medical problem

The patient taps **Problems** in the drawer, then the **+** button. In the ICD-10 search field, they type "type 2 diabetes". The app instantly searches the local JSON asset and shows matching codes. They select **E11.9 — Type 2 diabetes mellitus without complications**, set status to **Chronic**, set onset date to **January 2019**, and tap **Save**.

They add a second problem: searching "hypertension", selecting **I10 — Essential (primary) hypertension**, status **Chronic**, onset **2021**.

### Step 5: Adding medications

The patient taps **Medications**, then **+**. They add:
1. **Metformin** · 500mg · twice daily · start date January 2019 · ongoing: Yes
2. **Amlodipine** · 5mg · once daily · start date March 2021 · ongoing: Yes

Each save writes to `medications` and logs a `create` snapshot in `medication_history`.

### Step 6: Running FINDRISC

From the drawer, the patient taps **FINDRISC**. They answer the eight questions:
- Age 55–64 → 3 points
- BMI 28 kg/m² → 1 point (25–30)
- Waist 96 cm (male) → 3 points
- Physical activity < 30 min/day → 2 points
- Vegetables not daily → 1 point
- Hypertension medication: Yes → 2 points
- High blood glucose history: No → 0 points
- Family history — parent with diabetes → 5 points
- **Total: 17 points → High risk (~33%)**

The result is displayed with colour-coded risk. They tap **Save Result**. This is stored in `findrisc_results` and will appear in the calendar.

### Step 7: Running Framingham CVD Risk

The patient taps **Framingham** from the drawer. They enter:
- Age: 58 · Gender: Male
- Total cholesterol: 220 mg/dL
- HDL: 38 mg/dL
- Systolic BP: 145 mmHg · On treatment: Yes
- Smoker: No
- **Calculated risk: 18.4% → Intermediate CVD risk**

They review the colour-coded result (orange for intermediate) and tap **Save**.

### Step 8: Running WHO-5 Well-Being Assessment

The patient completes the five WHO-5 questions, rating each 0–5. They score:
- Q1 (cheerful): 3 · Q2 (calm): 3 · Q3 (active): 2 · Q4 (fresh): 2 · Q5 (interested): 3
- **Total: 13 → 52% → Average well-being**

Result saved to `who5_results`.

### Step 9: Adding an allergy

The patient remembers they are allergic to penicillin. They tap **Allergies → +**:
- Allergen: Penicillin
- Reaction: Skin rash, urticaria
- Severity: **Moderate** (shown in orange)
- Onset date: Unknown (left blank)

Saved to Supabase.

### Step 10: Viewing the health calendar

The patient taps **Calendar**. The calendar shows coloured dots on today's date:
- 🩸 FINDRISC assessment
- ❤️ Framingham CVD assessment
- 🧠 WHO-5 assessment
- ⚠️ Penicillin allergy (creation date)
- 💊 Two medication start entries
- 📋 Two problem entries (chronic disease dates)

Tapping today's date shows a full list of all these events below the calendar.

### Step 11: Switching device

The patient opens the app on their Windows laptop two weeks later. They enter the same email and password. Supabase authenticates them and all their data — problems, medications, assessments, allergies — is immediately available. Nothing is stored locally; everything came from the cloud.

### Step 12: Switching language to Greek

In Settings, the patient selects **Greek**. The entire app interface immediately switches to Greek — no restart required, all clinical content and labels displayed in Greek.

---

## 14. Performance & Caching

### 14.1 Client-Side Performance

| Mechanism | Impact |
|---|---|
| Supabase connection pooling | Low-latency queries via PgBouncer |
| Provider lazy loading | Providers only query Supabase when their screen is first opened |
| ICD-10 lazy loading | JSON asset loaded once, cached in memory for subsequent searches |
| Dashboard parallel fetching | `Future.wait([...])` — all three APIs called simultaneously |
| Flutter const constructors | Widgets marked `const` skip rebuild when parent rebuilds |

### 14.2 Network Performance

| Asset type | Cache strategy | TTL |
|---|---|---|
| `index.html` | No-cache | Always fresh |
| `main.dart.js` (hashed) | Immutable | 1 year |
| `*.wasm` (hashed) | Immutable | 1 year |
| `/assets/**` (hashed) | Immutable | 1 year |

Because Flutter web produces content-hashed filenames for all compiled assets, cache-busting is automatic — new deployments get new filenames, so users always receive the latest version within one page refresh.

### 14.3 Build Optimisation

- `--release` — disables debug symbols, enables tree shaking and minification
- `--no-tree-shake-icons` — prevents aggressive icon pruning (required for custom icon usage)
- `--base-href /` — correct relative path for assets when served at domain root

---

## 15. Limitations & Future Work

### 15.1 Current Limitations

| Limitation | Detail |
|---|---|
| No offline write support | Supabase queries require internet connectivity. Offline edits are not queued. |
| Fixed location (weather/AQI) | Weather and air quality are hardcoded to Heraklion, Crete. |
| No push notifications | Medication reminders or assessment due dates cannot notify the patient. |
| No image attachments | Allergy and problem records cannot include photos or documents. |
| No data export | Patients cannot export their records to PDF or FHIR format. |
| Single user per account | The app does not support family/carer-managed profiles under one account. |

### 15.2 Proposed Enhancements

| Enhancement | Priority | Complexity |
|---|---|---|
| Offline-first with Supabase Realtime sync | High | High |
| Push notifications (Flutter Local Notifications) | High | Medium |
| Location-based weather (device GPS) | Medium | Low |
| PDF export of health records | Medium | Medium |
| FHIR R4 data export | Low | High |
| Biometric authentication (Face ID / fingerprint) | Medium | Low |
| Caregiver/family profile access | Low | High |
| Dark mode | Low | Low |
| Additional languages | Medium | Medium |
| Integration with wearable health data (Apple Health, Google Fit) | Low | High |

---

## 16. Conclusion

myHealth demonstrates that a clinically useful, production-grade personal health record application can be built and deployed across six platforms from a single Flutter codebase, with a zero-cost cloud backend. The integration of three validated clinical screening tools (WHO-5, Framingham, FINDRISC) with offline computation, combined with real-time cloud persistence via Supabase and automated CI/CD deployment to Vercel's global CDN, results in an application that is both clinically relevant and technically robust.

The architecture decisions — feature-first folder structure, Provider state management, Supabase RLS for data isolation, multi-stage Docker builds, and Vercel-native Flutter builds — collectively produce a system that is maintainable, scalable, and secure. No patient data is ever stored on-device, eliminating the risk of data loss through device failure or reinstallation.

The application is available live on the web and installable as a native app on all major platforms, with all changes continuously deployed through an automated pipeline that validates code quality before every release.

---

## 17. Technical Specifications Reference

| Specification | Value |
|---|---|
| Flutter version | 3.35.7 (stable) |
| Dart SDK | ^3.9.2 |
| Supabase project URL | https://lexmgsylpikqghxziswq.supabase.co |
| Supabase database | PostgreSQL 15 |
| Authentication | Supabase Auth (email/password, JWT) |
| Number of database tables | 8 |
| Number of feature modules | 11 |
| Number of named routes | 21 |
| Supported languages | 2 (English, Greek) |
| Clinical calculators | 3 (WHO-5, Framingham, FINDRISC) |
| External APIs | 3 (ZenQuotes, Open-Meteo ×2) |
| Production web URL | Vercel (*.vercel.app) |
| Docker image size | ~30 MB |
| CI runner | GitHub Actions (ubuntu-latest) |
| Flutter SDK CI cache | subosito/flutter-action v2 |
| Pub cache key | pubspec.lock SHA hash |
| Vercel build command | `bash vercel-build.sh` |
| Vercel output directory | `build/web` |
| nginx base image | nginx:1.27-alpine |

---

*Report generated: April 2026*
*Repository: https://github.com/AmbroseJunior/myHealth_App-*
