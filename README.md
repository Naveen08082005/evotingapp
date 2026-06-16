# College E-Voting System

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)](https://flutter.dev)
[![GetX State Management](https://img.shields.io/badge/GetX-State--Management-purple.svg)](https://pub.dev/packages/get)
[![Supabase Database](https://img.shields.io/badge/Supabase-Backend--As--A--Service-green.svg?logo=supabase)](https://supabase.com)
[![Material 3 Design](https://img.shields.io/badge/Material--3-UI-orange.svg)](https://m3.material.io)

A highly secure, mobile-first, real-time digital voting platform tailored for college elections. Built on Flutter 3.x and GetX, utilizing a Supabase serverless PostgreSQL backend with Row-Level Security (RLS) policies to guarantee a transparent, robust "One Student, One Vote" election system.

---

## Architecture Diagram

The application implements a clean layered repository architecture, separating user interface, reactive state management, data access layers, and server side constraints:

```mermaid
graph TD
    subgraph Client Application (Flutter)
        UI[Material 3 UI Screens]
        Widgets[Reusable Custom Widgets]
        Controller[GetX Controllers & Bindings]
        Repo[Repository Layer]
        Service[Service Layer (Supabase, Storage, Realtime)]
    end

    subgraph Backend Infrastructure (Supabase)
        Auth[Supabase Auth & Email Verification]
        DB[(PostgreSQL Database)]
        Storage[Storage Buckets: avatars, candidate-photos]
        RLS{Row-Level Security Policies}
        Realtime[WebSockets Realtime Replication]
    end

    UI --> Widgets
    UI --> Controller
    Controller --> Repo
    Repo --> Service
    Service --> Auth
    Service --> Storage
    Service --> DB
    Service --> Realtime
    DB --- RLS
```

---

## Features

### 🗳 Student Module
- **Dual-Authentication**: Safe registration and login with automatic confirmation email checks.
- **Voter Verification**: Student profiles must be reviewed and approved by college administrators before access to active ballots is granted.
- **Biometric/Verification Checks**: Configurable requirements (Registration Number, Full Name, Department) dynamically loaded from the server settings.
- **Tamper-Proof Ballot**: Simple select-and-confirm voting flow for authorized active elections.
- **Voting History**: Complete read-only audit log of student's past voting transactions (timestamps and election ids).
- **Real-Time Live Results**: Visual, interactive chart statistics (Bar and Pie charts) displaying voting percentages instantly as ballots are cast.

### 💼 Administrator Module
- **Admin Dashboard**: Comprehensive overview displaying voter statistics, candidate registrations, and live results.
- **Candidate Management**: Full CRUD controls to add, update, search, and delete candidates (including manifesto, department, year, and photo upload).
- **Voter Verification Control**: Review panel to query, verify, or revoke student voter access.
- **Election Orchestration**: Panel to create new elections, toggle status (`pending` -> `active` -> `completed`), and toggle live result visibility settings for students.
- **Notification Broadcasts**: Compose and send instantaneous global broadcast popups or student-specific alerts.

---

## Folder Structure

```
evoting_app/
├── .env.example                # Template for database configuration keys
├── README.md                   # Project landing page and guide
├── android/                    # Android native configuration
├── assets/                     # Graphic resources and animations
│   ├── images/                 # App logos and placeholders
│   └── animations/             # Lottie loading files
├── docs/                       # Comprehensive deployment guides
│   ├── android_release.md      # Keystore setup and Gradle config
│   ├── ios_release.md          # Xcode signing and App Store release
│   ├── security_checklist.md   # Security audit matrix
│   ├── supabase_setup.md       # SQL schema, RLS policies, and admin seed
│   └── testing_checklist.md    # QA test matrices
├── ios/                        # iOS native configuration
├── lib/                        # Flutter source code
│   ├── app.dart                # Application entry configuration
│   ├── main.dart               # Global services and initialization setup
│   ├── bindings/               # GetX dependency injection bindings
│   ├── controllers/            # GetX state management controllers
│   ├── core/                   # Shared theme, constants, and utilities
│   ├── models/                 # Database representation models (Dart)
│   ├── repositories/           # Abstracted query repository layer
│   ├── routes/                 # Named routes definitions and middlewares
│   ├── screens/                # UI Screens (Splash, Auth, User, Admin)
│   ├── services/               # Singleton clients (Supabase, Realtime, Storage)
│   └── widgets/                # Reusable common, candidate, and chart widgets
└── supabase/                   # Local database migration schemas
```

---

## Screenshots Section

| Welcome & Onboarding | Student Dashboard | Live Real-time Results |
|:---:|:---:|:---:|
| ![Splash & Onboarding](docs/screenshots/onboarding.png) | ![Student Dashboard](docs/screenshots/dashboard.png) | ![Live Results Chart](docs/screenshots/live_results.png) |

| Admin Dashboard | Candidate Management | Broadcast Notifications |
|:---:|:---:|:---:|
| ![Admin Dashboard](docs/screenshots/admin_dashboard.png) | ![Candidate List](docs/screenshots/candidates.png) | ![Realtime Alerts](docs/screenshots/notifications.png) |

*(Note: Create a directory `docs/screenshots/` and upload UI captures to represent visual assets).*

---

## Installation Steps

### 1. System Requirements
- [Flutter SDK 3.24.x or higher](https://docs.flutter.dev/get-started/install)
- [Dart SDK 3.x](https://dart.dev/get-started)
- Android Studio / VS Code (with Flutter extensions)
- CocoaPods (for iOS developers)

### 2. Clone the Repository
```bash
git clone https://github.com/yourcollege/evoting_app.git
cd evoting_app
```

### 3. Fetch Packages
```bash
flutter pub get
```

---

## Environment Setup

1. Copy the `.env.example` file to create your local `.env` file:
   ```bash
   cp .env.example .env
   ```
2. Open `.env` and fill in your Supabase connection parameters (URL and Anon Public Key):
   ```properties
   SUPABASE_URL=https://your-supabase-id.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. Initialize your Supabase database. Follow the complete step-by-step SQL migration and configuration instructions in the [Supabase Setup Guide](docs/supabase_setup.md).

---

## Running Locally

To run the application in debug mode on a simulator or physical device:

### VS Code
Press `F5` or click the "Run" button above `lib/main.dart`.

### Command Line
Run the following command in the project root:
```bash
flutter run
```

---

## Production Deployment

Before compiling production binaries, review the configuration and deployment checklists for each target platform:

1. **Database Config**: Ensure all tables, policies, and bucket triggers are set up correctly by following the [Supabase Setup Guide](docs/supabase_setup.md).
2. **Android Release**: Follow the [Android Release Guide](docs/android_release.md) to generate a release signing keystore, configure gradle settings, and compile the release AAB/APK.
3. **iOS Release**: Follow the [iOS Release Guide](docs/ios_release.md) to set up developer profiles, signing certificates, and upload packages to TestFlight.
4. **Security Verification**: Perform the audits listed in the [Security Checklist](docs/security_checklist.md) to verify RLS constraints.
5. **Quality Assurance**: Complete the test scripts in the [Testing Checklist](docs/testing_checklist.md) to ensure all features function smoothly.

---

## Troubleshooting

- **Error: "Authentication Failed / Invalid Credentials"**:
  - Verify that the `.env` keys match your Supabase project dashboard settings.
  - Check if the email address registered has been confirmed via the verification link.
- **Error: "RLS violation / Database error"**:
  - Ensure that the database script in the [Supabase Setup Guide](docs/supabase_setup.md) has been executed completely.
  - Verify if your user profile `is_verified` column is marked `TRUE` inside the `users` table.
- **Error: "Storage Bucket Not Found"**:
  - Verify that the buckets `avatars` and `candidate-photos` have been created and marked **Public** inside the Supabase Storage dashboard.
- **Error: "Real-time updates not updating UI"**:
  - Verify that Realtime is enabled for the `votes`, `candidates`, `elections`, and `notifications` tables under Supabase Database Replication settings.
