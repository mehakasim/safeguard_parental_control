# SafeGuard Parental Control 🛡️

A comprehensive Flutter-based parental control application with real-time monitoring, screen time management, and content filtering capabilities.

## 📋 Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation Guide](#installation-guide)
- [Running the Application](#running-the-application)
- [Admin Credentials](#admin-credentials)

## ✨ Features

### For Parents
- ✅ Create and manage multiple child accounts
- ✅ Real-time screen time tracking and limits
- ✅ Content restriction controls
- ✅ Comprehensive dashboard with analytics
- ✅ Child activity monitoring

### For Children
- ✅ Personalized dashboard
- ✅ Screen time overview
- ✅ Safe app recommendations
- ✅ Educational content access

### For Administrators
- ✅ System-wide user management
- ✅ Parent account oversight
- ✅ Children account management
- ✅ Analytics and reporting
- ✅ Account activation/deactivation

## 🔧 Prerequisites

Before you begin, ensure you have the following installed on your system:

### 1. Operating System Requirements
- **Windows**: Windows 10 or later (64-bit)
- **macOS**: macOS 10.14 (Mojave) or later
- **Linux**: Ubuntu 18.04 or later

### 2. Required Software
- Git
- Flutter SDK
- Dart SDK (comes with Flutter)
- Android Studio or VS Code
- Firebase CLI (optional but recommended)

## 📦 Installation Guide

### Step 1: Install Git

#### Windows
1. Download Git from [https://git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer and follow the setup wizard
3. Verify installation:
- git --version

### Step 2: Install Flutter & Dart

#### Windows

1. Download Flutter SDK

- Visit https://docs.flutter.dev/get-started/install/windows
- Download the latest stable Flutter SDK (ZIP file)
- Extract to C:\src\flutter (or your preferred location)

2. Add Flutter to PATH

- Search for "Environment Variables" in Windows Search
- Click "Environment Variables"
- Under "User variables", find "Path" and click "Edit"
- Click "New" and add: C:\src\flutter\bin
- Click "OK" to save

3. Verify Installation(Terminal)

- flutter --version
- dart --version

### Step 3: Install Android Studio (for Android development)

1. Download Android Studio

- Visit https://developer.android.com/studio
- Download the latest version for your OS
- Install following the setup wizard

2. Install Android SDK

- Open Android Studio
- Go to Settings → Appearance & Behavior → System Settings → Android SDK
- Install Android SDK Platform-Tools and Android SDK Build-Tools
- Install at least one Android SDK Platform (API 33 recommended)

3. Configure Flutter

- bashflutter config --android-studio-dir="C:\Program Files\Android\Android Studio"  # Windows

### Step 4: Install VS Code (Alternative to Android Studio)

1. Download from https://code.visualstudio.com/

2. Install the following extensions:

- Flutter
- Dart
- Flutter Widget Snippets (optional)

### Step 5: Run Flutter Doctor

1. This command checks your environment and displays a report:
- flutter doctor

2. Fix any issues reported by Flutter Doctor before proceeding.

### Step 6: Install Node.js and Firebase CLI (Optional)

1. Install Node.js

#### (Windows & macOS):

- Download from https://nodejs.org/
- Install the LTS version
- Verify installation:
    - node --version
    - npm --version


## 🚀 Running the Application

### Step 1: Clone the Repository
 
#### Clone the repository
- git clone https://github.com/mehakasim/safeguard_parental_control.git

#### Navigate to project directory
- cd safeguard_parental_control

### Step 2: Install Dependencies

#### Get all Flutter packages
- flutter pub get

### Step 3: Configure Firebase

#### Step 4: Run the App 

- flutter run


## 🔐 Admin Credentials

Email: admin@safeguard.com
Password: Admin.1234

- Launch the app
- On the User Type Selection screen, tap "Administrator"
- Enter the admin credentials above
- You'll be logged into the Admin Dashboard
