# Flutter Boilerplate – Feature Document

## Overview

This Flutter boilerplate provides a universal, production-ready foundation for building scalable mobile applications. It includes all essential functionality commonly required across apps such as splash screen, authentication, backend integration, AI model support, push notifications, and customizable settings. The goal is to minimize repetitive setup work and ensure consistency, scalability, and maintainability across future projects.

---

## Core Features

### 1. Splash Screen

* Native splash screen setup using **flutter_native_splash**.
* Configurable theme support (light/dark mode).
* Option to display branding animation or app logo.

### 2. Authentication System (Firebase)

* **Firebase Authentication** with Email/Password, Google Sign-In, and Apple Sign-In.
* Secure token storage with **flutter_secure_storage**.
* Reusable authentication service for login, signup, logout, and session management.
* Extendable structure for future providers (Facebook, Twitter, etc.).

### 3. Backend Integration (Neon.tech)

* **Neon.tech** (serverless PostgreSQL) connected via **Supabase** or Postgres client.
* Pre-configured repository pattern for CRUD operations.
* Offline-first design with local caching (Hive/Drift).
* Role-based access control integrated with auth.

### 4. OpenRouter AI Integration

* Service wrapper for **OpenRouter API**.
* Support for text completion, chat models, and embeddings.
* Environment-based API key management (`.env` files).
* Prebuilt AI chat screen for quick prototyping.

### 5. Application Settings

* Centralized settings screen.
* Dark/Light mode toggle.
* Multi-language support with **flutter_localizations**.
* Push notification preferences.
* Account management (update profile, change password).

### 6. Push Notifications

* **Firebase Cloud Messaging (FCM)** integration.
* Local notifications with **flutter_local_notifications**.
* Background/foreground notification handling.
* Deep link support for navigating to specific screens.

---

## Additional Features

* **State Management**: Riverpod for modularity and scalability.
* **Navigation**: go_router with guarded routes and deep linking.
* **Error Handling**: Global error handler and custom error UI.
* **Theming**: Centralized **Material 3** theme configuration.
* **Logging & Monitoring**: Firebase Crashlytics with custom logging service.
* **Environment Configurations**: `.env` files for dev, staging, production.
* **Testing Setup**: Unit, widget, and integration test templates.
* **Analytics**: Firebase Analytics (extendable to Mixpanel/Amplitude).
* **Offline Support**: Local persistence with Hive/Drift.
* **CI/CD Ready**: GitHub Actions and Codemagic template.

---

## Optional Enhancements

* In-app updates using **in_app_update**.
* App version and changelog screen.
* Firebase Dynamic Links for sharing and invites.
* Payments integration (Stripe, Google Pay, Apple Pay).
* Prebuilt AI chatbot UI component.

---

## Folder Structure

```
lib/
 ├── core/
 │    ├── constants/
 │    ├── utils/
 │    ├── services/ (auth, backend, notifications, ai)
 │    ├── themes/
 │    └── error_handler.dart
 ├── features/
 │    ├── auth/
 │    ├── settings/
 │    ├── notifications/
 │    ├── ai/
 │    └── home/
 ├── data/
 │    ├── repositories/
 │    ├── models/
 │    └── api_clients/
 ├── presentation/
 │    ├── widgets/
 │    ├── screens/
 │    └── navigation/
 └── main.dart
```

---

## Benefits

* **Time-saving**: Eliminates repetitive setup for each new app.
* **Scalable**: Modular structure for easy feature expansion.
* **Production-ready**: Security, error handling, monitoring built-in.
* **Future-proof**: AI integration (OpenRouter), backend (Neon.tech), Firebase ecosystem.
* **Customizable**: Easily extendable for app-specific requirements.
