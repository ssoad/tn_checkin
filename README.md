# TN Check-In 📍

## 🔗 GitHub Repository

**Repository**: [https://github.com/ssoad/tn_checkin](https://github.com/ssoad/tn_checkin)

## 📱 Download APK

The latest Android APK is available in the [`dist/`](./dist/) folder:

- **[tn-checkin-v1.0.0.apk](./dist/tn-checkin-v1.0.0.apk)** (51.4MB)

## The Challenge

It's often tough to know who is physically present at a certain place, whether it's for a team meeting, a social event, or a class. Relying on people to manually check in can be slow and unreliable.

## Proposed Solution

This app lets a user create a check-in point at a specific spot. Then, other users can check in to that post, but only if they are within the specified meters of that location specified in the post. This makes it easy to confirm who is truly there, in real time.

## Key Features and Requirements

- **Create Check In Point**: A user can drop a pin on a map to create a check-in point as well as specify the meter radius of which a person can check in. There can only be one check-in point active at a time.
- **Check In Nearby**: Other users can check in, but the app will automatically verify that they are within meters specified of the check in point location.
- **Check Out**: The user will automatically checkout if they are out of the check-in point range.
- **Live Updates**: Everyone involved will see the number of live check-in counts.
- **Reliability**: The system will be built to handle many users checking in at once without slowing down.

## Bonus Points

- **Production Level Coding Standard**: Adhere to high-quality coding standards, including clean code, comprehensive documentation, and thorough testing.

## Tech Stack 🛠️

- **Flutter**: Cross-platform mobile development
- **Firebase**: Authentication and real-time database
- **Riverpod**: State management
- **Material 3**: Design system
- **Geolocator**: Location services
- **Clean Architecture**: Code organization

## Getting Started 🚀

### Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio or Xcode
- Firebase project setup

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/ssoad/tn_checkin.git
   cd tn_checkin
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Add your platform configuration files

4. **Run the app**

   ```bash
   flutter run
   ```

## Project Structure 📁

```text
lib/
├── core/                    # Shared utilities and services
│   ├── common/             # Reusable widgets and components
│   ├── services/           # Location and other core services
│   └── errors/             # Error handling
├── features/               # Feature-based organization
│   ├── auth/              # User authentication
│   └── check_in/          # Check-in functionality
└── main.dart              # App entry point
```

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
