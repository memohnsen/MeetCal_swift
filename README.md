# MeetCal

MeetCal is an iOS app for tracking weightlifting competitions, schedules, and athlete data. Built with SwiftUI, it helps weightlifters stay organized with competition calendars, start lists, rankings, records, and qualifying standards.

## Features

- **Competition Schedule**: Browse and track upcoming weightlifting meets
- **Start Lists**: Search for athletes and view competition start lists
- **Records & Rankings**: Access American records, WSO records, and international rankings
- **Qualifying Totals**: Check qualifying standards for various competitions
- **Saved Meets**: Bookmark and save meets to your personal calendar
- **Push Notifications**: Get reminders for weigh-ins and competition times
- **Sponsors**: Support the app and view sponsor information

## Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Data persistence
- **Clerk** - Authentication and user management
- **Supabase** - Backend database and API
- **RevenueCat** - In-app subscriptions and paywall
- **Firebase** - Cloud messaging
- **PostHog** - Product analytics

## Requirements

- iOS 26.0+
- Xcode 26.0+
- Swift 5.0+

## Configuration

The project uses `Config.xcconfig` for environment-specific configuration. Ensure you have the necessary API keys and credentials configured:

- Clerk publishable key
- Supabase credentials
- Firebase configuration (`GoogleService-Info.plist`)
- RevenueCat API key

## Project Structure

```
meetcal/
├── Views/
│   ├── Screens/        # Main app screens
│   │   ├── ScheduleScreens/
│   │   ├── CompDataScreens/
│   │   └── ProfileScreens/
│   ├── Tabs/           # Tab bar views
│   └── ContentView.swift
├── DataModels/
│   ├── Supabase/       # Supabase data fetching
│   └── RevenueCat/     # Subscription management
├── Components/         # Reusable UI components
└── Assets/            # Colors and styling
```

## Installation

1. Clone the repository
2. Open `meetcal.xcodeproj` in Xcode
3. Add your `Config.xcconfig` with required API keys
4. Add your `GoogleService-Info.plist` for Firebase
5. Build and run on simulator or device

## License

Copyright © 2025 Meetcal LLC

## Contact

maddisen@meetcal.app
