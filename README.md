# StudyTrack

**Name:** Sumitrra Narayanan  
**Matric Number:** 309867  
**Course:** STTPK2143 – Application Programming  
**Assignment:** Assignment 1 – Student Life Mobile App  
**Application Name:** StudyTrack

A Flutter-based Study Session Log application that helps students record and manage their study activities using a local SQLite database.

## 1. Application Purpose

StudyTrack is designed to help students keep track of their study sessions. Students can record the subject they studied, the duration, the date, and additional notes.

The application provides an organised way to manage study records and review previous study activities.

## 2. Main Features

- Add new study session records.
- View saved study session details.
- Edit existing study session records.
- Delete study session records.
- Validate required form fields.
- Store records locally using SQLite.
- Display up to 10 study records per page.
- Navigate between pages using Previous and Next buttons.
- Retain saved records after closing and reopening the application.

## 3. Study Session Record Fields

Each study session contains the following fields:

| Field | Description |
|---|---|
| ID | Unique identifier for each record |
| Title | Name or title of the study session |
| Subject | Subject or category studied |
| Duration | Time spent studying, in minutes |
| Date | Date of the study session |
| Notes | Optional additional information |
| Created At | Date and time when the record was created |

## 4. Database Structure

**Database name:** `studytrack.db`

**Table name:** `study_sessions`

The application uses SQLite through the Flutter `sqflite` package.

| Column | Data Type | Description |
|---|---|---|
| id | INTEGER | Primary key with auto-increment |
| title | TEXT | Study session title (required) |
| subject | TEXT | Subject (required) |
| duration | INTEGER | Study duration in minutes (required) |
| date | TEXT | Study session date (required) |
| notes | TEXT | Optional notes |
| created_at | TEXT | Record creation timestamp (required) |

The database supports inserting, retrieving, updating, and deleting study session records. Records are displayed from newest to oldest.

## 5. Technologies Used

- Flutter
- Dart
- SQLite
- sqflite
- Visual Studio Code

## 6. Main Application Flow

1. The application displays the splash screen.
2. After approximately three seconds, the home screen appears.
3. The home screen displays saved study session records.
4. The user can add a new study session using the Add Study Session button.
5. The user fills in the required information and confirms the save action.
6. The record is stored in the local SQLite database.
7. The user can view, edit, or delete saved records.
8. The home screen can be refreshed to retrieve the latest records.
9. Pagination allows the user to navigate through records, with a maximum of 10 records displayed per page.

## 7. How to Run the Application

1. Clone or download this GitHub repository.
2. Open the project folder in Visual Studio Code.
3. Open the terminal in the project directory.
4. Run the following command to install the required dependencies:

   `flutter pub get`

5. Connect an Android device or start an Android emulator.
6. Run the application using:

   `flutter run`

**Requirements:** Flutter SDK, Dart SDK, and an Android device or emulator.

## 8. Credits

**Packages and Resources Used:**
- Flutter SDK – Application development framework.
- Dart – Programming language.
- sqflite – SQLite database integration ([pub.dev](https://pub.dev/packages/sqflite)).
- Flutter Material Design – Built-in icons and UI components.

No external image assets were used in the application.