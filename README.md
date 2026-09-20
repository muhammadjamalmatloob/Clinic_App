# 🏥 Rukhsana Gynae Clinic - Smart Token & Queue Management System

A custom-built, modern clinic management application designed by AI Engineering and Software Development students at UET Lahore to optimize patient flow, reduce waiting times, and modernize clinical operations.

---

## 🛑 The Problem
Through our research on local healthcare facilities, we identified a critical bottleneck: **many clinics still rely on manual, physical token systems.** 

This archaic approach leads to:
- **Overcrowded Waiting Areas:** Patients are forced to sit in the clinic for hours, risking cross-infection.
- **Wasted Patient Time:** Uncertainty regarding when their token will be called leads to anxiety and frustration.
- **Lost Revenue & Poor Retention:** The friction of long, unmanaged wait times sometimes causes frustrated patients to leave before their turn, directly impacting the clinic's reputation.
- **Staff Burnout:** Receptionists and doctors are overwhelmed by managing angry crowds rather than focusing on healthcare.

## 💡 The Solution
To solve this, we engineered a **Smart Token & Queue Management System**. The solution provides a seamless, digital-first experience tailored for both the patients and the clinic staff.

By digitizing the queue, the system automatically allots tokens and provides **live updates with dynamic ETA calculations**. Patients can now wait comfortably at home or in their cars, arriving exactly when the doctor is ready to see them.

---

## ✨ Key Features

### 👩‍⚕️ For Patients (Patient App)
- **Live Queue Tracking:** View the currently serving token in real-time.
- **Smart ETA & Check-In:** Algorithmically estimated wait times to help patients time their arrival perfectly.
- **Digital Medical Vault:** View, download, and generate PDF reports for prescriptions, ultrasounds, and lab results.
- **Medication Pill Tracker:** Push notifications to remind patients to take their medicine.
- **Advance Appointment Booking:** Schedule time slots days in advance alongside walk-in tokens.
- **Emergency SOS:** A prominent button for instant dialing of clinic emergency services.
- **Multilingual Support:** Toggle the interface between English and Urdu.
- **Family Profiles:** Manage tokens and vaccination trackers for children/dependents under a single login.

### 👨‍💻 For Clinic Staff (Admin App)
- **Queue Control Panel:** Easy 1-tap buttons to "Call Next Patient", "Pause Queue", and "Mark Complete".
- **Doctor's Desk (Unified Calendar):** A single view interleaving advance appointment bookings with live walk-in tokens.
- **In-App Digital Prescriptions:** Doctors can generate prescriptions digitally, which instantly sync to the patient's vault.
- **Pharmacy Integration:** Send digital prescriptions straight to the in-house pharmacy for rapid preparation.
- **Broadcast Announcements:** Push instant banners to all registered patients (e.g., clinic closures, free camps).
- **Daily Analytics:** A robust dashboard tracking total patients served, average wait times, and PDF export for daily summary reports.

---

## 🛠 Tech Stack
- **Frontend Framework:** Flutter & Dart (Cross-platform for Android/iOS)
- **Routing:** GoRouter (Advanced declarative routing with bottom navigation ShellRoutes)
- **State Management:** Riverpod 2.0+
- **Styling:** Custom theme matching the clinic's brand identity (Deep Plum & Peach-Pink Gradient) utilizing `GoogleFonts` and `flutter_svg`.
- **Architecture:** Layer-First approach (Domain, Data, Presentation)

---

## 🚀 How to Run Locally

### Prerequisites
- Flutter SDK (latest version)
- Dart SDK

### Setup Instructions
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application (Desktop or Emulator):
   ```bash
   flutter run
   ```

### 🔐 Test Credentials (Mock Data Mode)
Currently, the app is running with a Mock Data Repository. Use these credentials to test the two distinct app experiences:
- **Patient Login:** Email: `user@gmail.com` | Password: `user`
- **Staff/Admin Login:** Email: `admin@gmail.com` | Password: `admin`
