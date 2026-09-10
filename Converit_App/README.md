# Mobile App Development Semester Project

---

## Student Information

| Field | Details |
|---------|---------|
| Student Name | Muhammad Tayyab |
| Registration Number | F2024376199 |
| Section | A4 |
| Semester | 4 |
| GitHub Username | tayyabtt1 |

---

## Project Information

| Field | Details |
|---------|---------|
| Project Title | ConvertIt — Mobile File Converter App |
| Project Category | Productivity / Utility |
| Project Type | Mobile Application |
| Start Date | Spring 2026 |
| Expected Completion Date | End of Spring 2026 Semester |

---

## Problem Statement

Students and professionals frequently need to convert files between formats (PDF ↔ Word, PDF ↔ Image, etc.) but existing tools are either desktop-only, cluttered with ads, or require a browser. There is no clean, fast, mobile-first file converter that works entirely from a smartphone. **ConvertIt** solves this by bringing 12 common file conversion tools into a single, easy-to-use Flutter mobile app — no browser, no ads, no friction.

---

## Target Users

- **Students** who need to convert assignment files between PDF and Word formats.
- **Office workers** who frequently deal with PDF, Excel, and PowerPoint files on the go.
- **General smartphone users** who want a simple, one-tap solution for file conversion without visiting websites.

---

## Project Objectives

- Build a fully functional Flutter mobile app that supports 12 different file conversion operations.
- Integrate the CloudConvert REST API to handle server-side conversions (PDF, Word, Excel, PowerPoint).
- Implement local on-device conversions for image-to-image tasks (JPG ↔ PNG) using the Dart `image` package.
- Persist conversion history locally using `shared_preferences` so users can re-download past files.
- Deliver a polished UI with full dark/light mode support, inspired by iLovePDF (https://www.ilovepdf.com/).

---

## Planned Features

- [x] Tool Grid — Browse and search all 12 conversion tools
- [x] File Picker — Select files from device storage
- [x] CloudConvert API Integration — Upload, convert, and download files
- [x] Local Image Conversion — JPG ↔ PNG without API
- [x] Conversion Progress Screen — Animated progress with live percentage
- [x] Result Screen — Download and share converted files
- [x] Conversion History — View, re-download, and delete past conversions
- [x] Dark / Light Mode Toggle
- [x] Settings Screen — Theme, storage, and app preferences
- [x] Form Validation — File type and size checks before conversion

---

## Technology Stack

### Frontend
- Flutter (Dart) — UI and app logic
- `setState` only (no Provider / Riverpod / Bloc)

### Backend / API
- **CloudConvert REST API** (`https://api.cloudconvert.com/v2`) — handles PDF, Word, Excel, PPT conversions
- Free tier: 25 conversions/day

### Database / Storage
- `shared_preferences` — stores conversion history locally on device

### Additional Packages

| Package | Purpose |
|---------|---------|
| `file_picker: ^6.1.1` | Pick files from device storage |
| `http: ^1.2.0` | CloudConvert API REST calls |
| `dio: ^5.4.0` | Download converted files to device |
| `path_provider: ^2.1.2` | Get device Downloads folder path |
| `open_filex: ^4.3.4` | Open/preview downloaded files |
| `share_plus: ^7.2.1` | Share files via system share sheet |
| `shared_preferences: ^2.2.2` | Persist conversion history |
| `image: ^4.1.3` | Local JPG ↔ PNG conversion |
| `permission_handler: ^11.3.0` | Storage and internet permissions |
| `flutter_svg: ^2.0.10+1` | SVG icon support |

---

## Application Screens

| Screen | File | Status |
|--------|------|--------|
| Home Screen | `home_screen.dart` | ⬜ |
| All Tools Screen | `all_tools_screen.dart` | ⬜ |
| Tool Detail Screen | `tool_detail_screen.dart` | ⬜ |
| Converting Screen | `converting_screen.dart` | ⬜ |
| Result Screen | `result_screen.dart` | ⬜ |
| History Screen | `history_screen.dart` | ⬜ |
| Settings Screen | `settings_screen.dart` | ⬜ |

---

## Conversion Tools (12 Total)

| # | Tool | Input | Output | Method |
|---|------|-------|--------|--------|
| 1 | PDF to Word | .pdf | .docx | CloudConvert |
| 2 | Word to PDF | .docx / .doc | .pdf | CloudConvert |
| 3 | Image to PDF | .jpg / .png | .pdf | CloudConvert |
| 4 | PDF to Image | .pdf | .jpg / .png | CloudConvert |
| 5 | Compress PDF | .pdf | .pdf | CloudConvert |
| 6 | Merge PDFs | .pdf (multi) | .pdf | CloudConvert |
| 7 | Split PDF | .pdf | .pdf (zip) | CloudConvert |
| 8 | JPG to PNG | .jpg | .png | Local (image pkg) |
| 9 | PNG to JPG | .png | .jpg | Local (image pkg) |
| 10 | PDF to PPT | .pdf | .pptx | CloudConvert |
| 11 | PPT to PDF | .pptx | .pdf | CloudConvert |
| 12 | Excel to PDF | .xlsx | .pdf | CloudConvert |

---

## Folder Structure

```
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── all_tools_screen.dart
│   ├── tool_detail_screen.dart
│   ├── converting_screen.dart
│   ├── result_screen.dart
│   ├── history_screen.dart
│   └── settings_screen.dart
├── models/
│   ├── tool_model.dart
│   └── conversion_model.dart
├── services/
│   ├── cloudconvert_service.dart
│   └── storage_service.dart
├── widgets/
│   ├── tool_card.dart
│   ├── file_upload_area.dart
│   └── conversion_options.dart
└── constants/
    ├── app_colors.dart
    ├── app_theme.dart
    └── tools_data.dart
```

---

## Project Milestones

| # | Milestone | Status |
|---|-----------|--------|
| 1 | Proposal Approved | ⬜ |
| 2 | Phase 1 — Project Setup & Theme | ⬜ |
| 3 | Phase 2 — Home Screen & All Tools Screen | ⬜ |
| 4 | Phase 3 — Tool Detail Screen & File Picker | ⬜ |
| 5 | Phase 4 — CloudConvert API Service | ⬜ |
| 6 | Phase 5 — Converting & Result Screens | ⬜ |
| 7 | Phase 6 — History & Settings Screens | ⬜ |
| 8 | Phase 7 — Polish, Permissions & Testing | ⬜ |
| 9 | Final Submission Ready | ⬜ |

---

## Repository Activity Rules

- Minimum 2 commits per week.
- Commit messages must be meaningful.
- Progress must be pushed regularly.
- Documentation must be updated throughout the semester.

### Good Commit Messages

```bash
feat: Added Home Screen UI with tool grid
feat: Integrated CloudConvert API for PDF to Word
fix: Resolved file picker null crash on cancel
feat: Implemented dark/light mode toggle
feat: Added conversion history with shared_preferences
```

### Poor Commit Messages

```bash
Update
Work
Changes
Final
Latest
```

---

## Screenshots

Screenshots will be uploaded inside the `screenshots/` folder.

---

## Declaration

I certify that this project is my own original work and that all external resources have been properly acknowledged.

Student Signature: _____Tayyab_________________

Date: ___________10/6/2026___________
