# myHealth — 10-Minute Architecture Presentation
## Speaker Notes · Slide-by-Slide Guide

> **Format:** 10 slides · ~1 minute each  
> **Audience:** Technical evaluators / academic panel  
> **Goal:** Walk through architectural decisions, not just features

---

## Slide 1 — Title & Problem Statement (1 min)

**Slide content:**
- Title: *myHealth — A Clinical Personal Health Record*
- Subtitle: *Cross-platform Flutter + Supabase · CI/CD · Vercel*
- Your name, date, institution

**What to say:**
> "Most personal health apps are either too simplistic — step counters — or too heavyweight — requiring institutional access. myHealth sits in the middle: a clinically-aware record system that any patient can use from a browser, without installing anything. Today I'll explain the architectural decisions that make this possible."

**Key point to land:** The app is *opinionated* — it encodes clinical logic (WHO-5, Framingham, FINDRISC) rather than just storing data.

---

## Slide 2 — High-Level Architecture (1 min)

**Slide content (diagram):**
```
┌─────────────┐     HTTPS      ┌──────────────────────┐
│   Browser   │ ◄────────────► │  Vercel CDN (Flutter  │
│  (Flutter   │                │  Web · static assets) │
│   WASM)     │                └──────────────────────┘
└─────────────┘                          │
                                 Supabase SDK calls
                                         │
                              ┌──────────▼──────────┐
                              │  Supabase Cloud      │
                              │  ┌───────────────┐  │
                              │  │  Auth (JWT)   │  │
                              │  ├───────────────┤  │
                              │  │  PostgreSQL   │  │
                              │  │  + RLS        │  │
                              │  └───────────────┘  │
                              └─────────────────────┘
```

**What to say:**
> "There are exactly three tiers. The Flutter app compiles to WebAssembly and runs entirely in the browser — no server-side rendering. The Supabase cloud handles authentication and the PostgreSQL database with row-level security. Vercel serves the static assets from a global CDN. There is no custom backend server to maintain."

**Key point to land:** Simplicity through managed services — zero backend code written by the developer.

---

## Slide 3 — Flutter Web & The Single Codebase (1 min)

**Slide content:**
```
One Dart codebase
        │
   ┌────┴────┐
   ▼         ▼
Android     Web (WASM)     ← deployed
   ▼         ▼
  iOS     Windows/macOS/Linux
```
- `flutter build web --release --no-tree-shake-icons`
- Compiled to WASM via `dart2wasm`
- Assets content-hashed → immutable 1-year cache

**What to say:**
> "Flutter compiles a single Dart codebase to native ARM for mobile and to WebAssembly for the browser. The web build is entirely static: HTML, JavaScript bootstrap, and WASM binary. This means Vercel serves it like any static site — no runtime, no server process. The Flutter 3.35.7 WASM renderer gives near-native rendering performance in the browser."

**Key point to land:** WASM is why the app feels fast in a browser — it's not JavaScript.

---

## Slide 4 — Feature-First Architecture (1 min)

**Slide content:**
```
lib/
├── core/           ← shared: auth, router, theme, widgets
│   ├── auth/
│   ├── router/
│   └── widgets/
└── features/       ← each module is self-contained
    ├── allergies/
    │   ├── models/
    │   ├── providers/   ← business logic
    │   └── screens/     ← UI
    ├── medications/
    ├── problems/
    ├── questionnaires/
    └── ... (12 modules total)
```

**What to say:**
> "The project follows feature-first architecture — each clinical domain is a self-contained folder with its own model, provider, and screens. This mirrors how a medical record is structured. A doctor thinks in 'allergies' and 'medications', not in 'repositories' and 'view models'. The structure makes onboarding easier and keeps modules independently testable."

**Key point to land:** Architecture mirrors the clinical domain, not a generic MVC template.

---

## Slide 5 — State Management: Provider Pattern (1 min)

**Slide content:**
```dart
// Startup: _AuthGate checks session
Supabase.session != null
    → DashboardScreen
    → LoginScreen

// Provider wires data to UI
ChangeNotifierProvider(create: (_) => AllergiesProvider())

// On login:
context.read<AllergiesProvider>().load(userId);
```
- `MultiProvider` at root — 9 providers registered
- Each provider owns one table's CRUD + in-memory cache
- `notifyListeners()` after every mutation

**What to say:**
> "State management uses Flutter's built-in Provider package — lightweight and auditable. Each feature module has a ChangeNotifier that owns its data. On startup, the `_AuthGate` widget checks whether a Supabase JWT session already exists and routes accordingly — so returning users land directly on the dashboard without re-entering credentials. After any create, update, or delete, the provider re-fetches from Supabase and notifies the UI."

**Key point to land:** No complex reactive streams — explicit fetch after mutation keeps data consistent with the server.

---

## Slide 6 — Supabase: Auth + RLS (1 min)

**Slide content:**
```sql
-- Every table has this policy
CREATE POLICY "users see own rows"
  ON allergies
  FOR ALL
  USING (auth.uid() = user_id);

-- Schema pattern
CREATE TABLE allergies (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID NOT NULL REFERENCES auth.users,
  name       TEXT NOT NULL,
  severity   TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

**What to say:**
> "Supabase uses PostgreSQL Row Level Security to enforce data isolation at the database layer — not in application code. Every table has a single policy: `auth.uid() = user_id`. This means even if a bug in the app formed a malicious query, the database would refuse to return another user's rows. The user_id is a UUID generated by Supabase Auth — passwords are never stored in the application database."

**Key point to land:** Security enforced at the database layer — the app can't leak data even if it has a bug.

---

## Slide 7 — Clinical Algorithms (offline) (1 min)

**Slide content:**
```
WHO-5 Well-Being Index
  → 5 questions × 0–5 scale → score /100
  → < 50: depressive episode screen positive

Framingham CVD Risk (10-year)
  → Age, sex, total/HDL cholesterol, SBP,
    BP treatment, smoking status
  → Cox regression → % 10-year risk

FINDRISC (Type 2 Diabetes)
  → 8 questions, weighted scoring
  → ≥15 pts: High / Very High risk

ICD-10 Search
  → 68,000 codes loaded from local JSON asset
  → Filtered in-memory, zero network calls
```

**What to say:**
> "The three clinical calculators are pure Dart functions — no network calls, no third-party APIs. WHO-5 detects potential depression screening positives. Framingham estimates 10-year cardiovascular risk using the validated Cox regression coefficients. FINDRISC screens for Type 2 diabetes. All three produce color-coded risk interpretations. The ICD-10 code search loads a 68,000-entry JSON asset into memory on first use and filters locally — sub-millisecond search after the initial load."

**Key point to land:** Clinical logic is offline-capable and validated against published reference tables.

---

## Slide 8 — External APIs & Environment Isolation (1 min)

**Slide content:**
```
Open-Meteo (weather)
  GET /v1/forecast?lat=35.34&lon=25.14&...
  → temperature, humidity, UV index
  → no API key required

Open-Meteo Air Quality
  GET /v1/air-quality?...
  → PM2.5, PM10, European AQI

ZenQuotes
  GET /api/random
  → motivational health quote (dashboard)

Supabase keys → lib/core/config/supabase_config.dart
  → gitignored in production (env vars via Vercel)
```

**What to say:**
> "External integrations are minimal and purposeful. Weather and air quality use Open-Meteo — a free, GDPR-compliant API requiring no key, targeting Heraklion, Crete specifically. ZenQuotes provides a daily motivational quote on the dashboard. Supabase credentials are kept in a config file that is excluded from public commits — in the Vercel deployment they are injected as environment variables."

**Key point to land:** No paid API keys required to run the app — it works out of the box.

---

## Slide 9 — CI/CD Pipeline & Deployment (1 min)

**Slide content:**
```
git push → GitHub Actions
              │
         ┌────▼────┐
         │ Analyze │  flutter analyze --no-fatal-infos
         └────┬────┘
              │ (passes)
         ┌────▼──────┐
         │ Build Web │  flutter build web --release
         └────┬──────┘
              │ artifact uploaded (3-day retention)
              │
         Vercel GitHub Integration
              │
         ┌────▼──────────────┐
         │ vercel-build.sh   │  installs Flutter 3.35.7
         │ flutter build web │  in Vercel's Ubuntu env
         └────┬──────────────┘
              │
         ┌────▼──────┐
         │  CDN live │  global edge deployment
         └───────────┘
```

**What to say:**
> "Every push to master triggers two GitHub Actions jobs: analyze — which runs the Dart static analyzer — and build web, which confirms the release build succeeds. Only then does Vercel pick up the commit and run its own build via `vercel-build.sh`, which installs Flutter inside Vercel's Ubuntu container and produces the final artifact. The two-stage gate means Vercel never attempts to deploy broken code. Flutter SDK and pub packages are cached by content hash, so a typical CI run takes under three minutes."

**Key point to land:** Two independent gates — GitHub Actions + Vercel — before code reaches users.

---

## Slide 10 — Summary & Demo (1 min)

**Slide content:**
```
Architecture decisions recap:
  ✓ Flutter WASM  → fast browser UX, single codebase
  ✓ Feature-first → mirrors clinical domain
  ✓ Provider      → simple, auditable state management
  ✓ Supabase RLS  → security at DB layer
  ✓ Offline logic → clinical calculators, ICD-10 search
  ✓ CI/CD gates   → broken builds never reach production
  ✓ Zero secrets  → no paid API keys required

Live URL: https://my-health-app-xi.vercel.app
Repo:     github.com/AmbroseJunior/myHealth_App-
```

**What to say:**
> "To summarise: myHealth is a clinically-aware PHR built on a three-tier architecture — Flutter WASM on the client, Supabase for auth and data, Vercel for delivery. Every architectural decision was motivated by a real constraint: feature-first folders because the domain is clinical, Provider because state is simple, RLS because patients' data must be isolated, offline calculators because clinical tools should never fail due to network issues, and a CI/CD pipeline because health software should not ship broken. The live app is accessible now at the URL shown. I'm happy to take questions."

**Closing line:** *"Any questions on a specific layer — the clinical algorithms, the security model, or the deployment pipeline?"*

---

## Timing Cheat Sheet

| Slide | Topic | Time |
|-------|-------|------|
| 1 | Problem Statement | 1:00 |
| 2 | High-Level Architecture | 1:00 |
| 3 | Flutter Web & WASM | 1:00 |
| 4 | Feature-First Structure | 1:00 |
| 5 | Provider State Management | 1:00 |
| 6 | Supabase Auth + RLS | 1:00 |
| 7 | Clinical Algorithms | 1:00 |
| 8 | External APIs | 1:00 |
| 9 | CI/CD Pipeline | 1:00 |
| 10 | Summary & Demo | 1:00 |
| **Total** | | **10:00** |

---

## Likely Q&A — Prepared Answers

**Q: Why not use a REST API backend instead of Supabase directly?**
> A custom REST backend adds a server to maintain, deploy, scale, and secure. Supabase's PostgREST gives us a typed HTTP API generated from the PostgreSQL schema, with JWT authentication built in. We get the same security guarantees with zero server code.

**Q: What happens if Supabase goes down?**
> The three clinical calculators (WHO-5, Framingham, FINDRISC) and ICD-10 search work fully offline. Read-write operations that require the database will fail gracefully with an error message — we show a snackbar rather than a crash. A local cache layer (SharedPreferences for last-loaded data) is listed as a future enhancement.

**Q: Why Provider and not Riverpod or Bloc?**
> Provider is Flutter's own recommended solution for this scale of app. Riverpod adds compile-safe providers but introduces more boilerplate for marginal benefit in a single-developer project. Bloc is appropriate for complex event-driven flows — our CRUD operations don't need that formalism.

**Q: How is the Supabase URL/anon key protected?**
> The anon key is intentionally public-safe — it identifies the project but grants no elevated permissions. All data access is gated by RLS policies enforced at the database. The service-role key (which bypasses RLS) is never in the client code.

**Q: Can this scale to many users?**
> Supabase's free tier handles up to 500 MB database and 2 GB bandwidth — sufficient for hundreds of active users. PostgreSQL with proper indexing scales to millions of rows. The Flutter WASM client is statically served from Vercel's CDN — there is no application server that could become a bottleneck.

**Q: Why Vercel and not Firebase Hosting?**
> Vercel's GitHub integration triggers on push automatically, handles HTTPS, CDN, and custom rewrites for SPA routing with a single JSON config file. Firebase Hosting requires a separate CLI deploy step in CI. Both are valid choices; Vercel was faster to configure for this project.
