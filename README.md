# Task Manager App

A modern, offline-first Flutter application built using **Clean Architecture** and **BLoCs**, featuring **Firebase Integration** and **Hive Local Storage**.

---

##  Architecture Overview

This project strictly adheres to **Clean Architecture** principles to separate concerns, improve testability, and decouple core business logic from external frameworks.

```

core                  # Shared utilities, constants, errors, and network info
   constants        # App colors, constants
   errors           # Failure definitions (ServerFailure, AuthFailure)
   network          # Connectivity checking (NetworkInfo)
   widgets          # Reusable UI widgets & loaders

domain                # Business logic (Pure Dart - No Framework dependencies)
   entities          # Core domain models (TaskEntity, UserEntity)
   repositories      # Repository interfaces (contracts)
    usecases          # Independent business use cases (Auth & Task usecases)

data                  # Data management & persistence
   datasources       # Remote (Firebase) & Local (Hive) data sources
   models            # Data transfer models (TaskModel, UserModel)
   repositories     # Repository implementations combining Remote & Local sources

presentation          # User Interface & State Management
    bloc             # BLoCs & States (AuthBloc, TaskBloc)
    screens           # UI Screens (Login, SignUp, Task List, Detail, Add/Edit)
    widgets           # Component-specific widgets
```

---

##  Features & Functionality

### 1.  User Authentication
- **Firebase Auth**: Secure Email & Password Sign Up and Login.
- **Session Management**: Persistent auth state with automatic routing via `authgate`.
- **Sign Out**: Graceful session termination.

### 2. 📋 Task Management (CRUD)
- **Real-Time Sync**: Synchronizes tasks live with **Firebase Firestore**.
- **Create Tasks**: Add new tasks with title, description, priority, and due date.
- **Update Tasks**: Edit existing task details smoothly.
- **Delete Tasks**: Remove tasks with instant updates.
- **Status Toggle**: Transition tasks through statuses: `Pending`, `Started`, `Completed`, `Dropped`.

### 3. 🌐 Offline-First Support (Hive)

### 4. 🔍 Search, Filter & Sort
- **Search**: Search tasks dynamically by title or description.
- **Filter**: Filter by task completion status (`All`, `Pending`, `Started`, `Completed`, `Dropped`).
- **Sort**: Order tasks by Due Date or Created Date.

### 5. 📡 Connectivity Monitoring
- **Real-Time Status**: Detects network online/offline state changes live using `connectivity_plus`.
- **UI Banner/Indicator**: Informs the user visually when working in offline mode.

---

## 🚀 Getting Started

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/BADUSHKBABU/taskmanagerapp
   cd taskmanagerapp
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Application**:
   ```bash
   flutter run
   ```

---

