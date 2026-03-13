# Product Requirements Document (PRD): Smart Class Check-in App

## 1. Objective
To develop a web-based class check-in and post-class reflection application for university students. The app uses GPS location and mock QR code scanning for authentication, while collecting students' expectations and feedback.

## 2. Target Users
- University students who need to check in to classes and provide learning reflections.

## 3. Key Features
1. **Home Screen:** The main landing page allowing users to select "Check-in (Before Class)" or "Finish Class (After Class)".
2. **Check-in (Before Class):**
   - Auto-fetches GPS location immediately upon opening the screen.
   - Mock QR Code scanner for location/class verification.
   - Form inputs for previous topics, today's expectations, and a mood score (1-5).
3. **Finish Class (After Class):**
   - **Strict Flow:** Requires scanning the mock QR Code *before* fetching the GPS location.
   - Auto-fetches GPS location only after a successful QR scan.
   - Form inputs for what was learned today and class/instructor feedback.

## 4. Tech Stack
- **Frontend:** Flutter (compiled for Web)
- **Backend/Database:** Firebase Cloud Firestore
- **Key Packages:** `firebase_core`, `cloud_firestore`, `geolocator`