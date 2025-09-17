# ⏰ True Time Provider for Flutter

> A secure and reliable time provider for Flutter apps.
> Fetches accurate time from NTP servers, with Firebase and device time as fallbacks.

<img width="1179" height="2556" alt="result2" src="https://github.com/user-attachments/assets/a1490c0d-51a3-429f-a946-cc90bb0c7ac0" />
<img width="1179" height="2556" alt="result1" src="https://github.com/user-attachments/assets/bebfbe3d-91d0-4180-ae6a-49028b2df72e" />

---

## Table of Contents

* [Features](#-features)
* [Installation](#-installation)
* [Usage](#-usage)
* [How It Works](#-how-it-works)
* [Example Use Cases](#-example-use-cases)
* [Configuration](#-configuration)
* [Limitations](#️-limitations)
* [Roadmap](#-roadmap)
* [License](#-license)

---

## ✨ Features

* ✅ Provides accurate, tamper-resistant current time
* ✅ Built-in **Singleton pattern** (global instance)
* ✅ Multi-source fallback (NTP → Firebase → Device)
* ✅ Handles network failures gracefully
* ✅ Supports **IPv4 & IPv6**
* ✅ Configurable NTP host, port, and timeout

---

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  true_time_provider: latest_version
```

Install it with:

```bash
flutter pub get
```

---

## Usage

### 1. Initialize at app startup

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase fallback
  TrueTimeProvider.instance.init(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}
```

### 2. Fetch secure time

```dart
final DateTime safeNow = await TrueTimeProvider.instance.now();
print("Secure current time: $safeNow");
```

---

## 🛠 How It Works

### Fallback Flow

```
try NTP server
   │
   ├── success → return ntpTime
   │
   └── fail → try Firebase
               │
               ├── success → return fireSTime
               │
               └── fail → return DateTime.now() (device)
```

### Class Overview

* **TrueTimeProvider** → Singleton entry point
* **NtpServerProvider** → Fetches time via UDP NTP
* **FirebaseCloudProvider** → Fetches server time from Firestore
* **Device Time** → Final fallback

---

## ⚡ Example Use Cases

* Banking / Payment apps
* Event logging / Audit trails
* Subscription & licensing apps
* Distributed systems

---

## 🔧 Configuration

Override NTP lookup options:

```dart
final time = await TrueTimeProvider.instance.now(
  ntpFetchDuration: Duration(seconds: 20),
  ntoLookUpAddress: "pool.ntp.org",
  ntpLookupPort: 123,
);
```

---

## Limitations

* NTP requires **UDP port 123** (may be blocked in some networks)
* Firebase fallback requires internet access
* Falls back to device time if both fail
* Currently **only one NTP request per call** (no retries)

---

## Roadmap

* [ ] Retry mechanism with exponential backoff
* [ ] Cache last known good offset
* [ ] Expose NTP sync statistics (delay, jitter)
* [ ] Add tests with mock NTP responses

---

## License

This project is licensed under the **MIT License**.

---
