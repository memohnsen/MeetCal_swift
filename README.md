# MeetCal

MeetCal is an iOS app for tracking weightlifting competitions, schedules, and athlete data. Built with SwiftUI, it helps weightlifters stay organized with competition calendars, start lists, rankings, records, and qualifying standards.

## Features

- **Competition Schedule**: Browse schedules and start lists for all USAW National meets, WSO meets, and USAMW competitions with day-by-day navigation and custom page indicators
- **Session Details**: View detailed athlete information including age, club, weight class, entry total, and complete USAW meet history for each session
- **Start List Search**: Search and filter through complete start lists with advanced filtering options
- **Competition Data**: Access qualifying totals, A/B standards, American records, WSO records, and international rankings
- **Saved Sessions**: Bookmark important sessions in-app and sync to your calendar with push notifications 90 minutes before session start
- **WL Wrapped**: Annual year-in-review statistics and competition insights
- **Authentication**: Secure sign-in with Clerk authentication
- **Onboarding**: Interactive feature walkthrough for new users

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
