# 🛠️ DIYHub

**DIYHub** is a comic-book styled mobile app that turns learning practical DIY skills into an adventure. Built with Flutter for a university semester mobile application project, it lets users of all ages — from curious kids to serious makers — pick up hands-on skills across electronics, home repair, woodcraft, cooking, robotics, and gardening.

Instead of plain lessons, DIYHub frames everything as **Missions** with **XP rewards**, **Rank progression** (Novice → Cadet → Master), and age-tailored **Hero Tiers**, wrapped in a bold, halftone-dotted, superhero-comic visual style.

---

## 📱 About the Project

- **Platform:** Flutter (Android + iOS)
- **University:** UMT (University of Management & Technology)
- **Department:** Artificial Intelligence
- **Semester:** Spring 2026
- **Project Type:** Personal Project

---

## ✨ Core Features

- **Hero Tier Onboarding** — pick your age group once (Rookie Builders 5–12, Maker Cadets 13–17, Master Artisans 18+) to unlock tailored missions
- **Mission Browsing** — explore DIY skills across 6 categories: Electronics & Gadget Lab, Home Repair, Woodcraft, Cooking Lab, Robotics, and Gardening & Eco
- **Step-by-Step Episodes** — each mission is broken into ordered lessons/episodes with clear instructions
- **XP & Rank System** — complete missions to earn XP and level up your rank, tracked entirely on-device
- **Hero Gear Checklist** — see exactly what materials/tools you need before starting a mission
- **Favorites & Progress Tracking** — bookmark missions and track what you've started, finished, or still need to complete
- **Light & Dark Comic Themes** — bold outlines, halftone textures, and punchy colors in both modes
- **Fully Offline** — all content and progress is stored locally; no backend or account required

---

## 🧱 Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State Management | `setState` only — no Provider/Riverpod/Bloc |
| Local Persistence | `shared_preferences` |
| Data Source | Static local dataset (`skills_data.dart`) |

---

## 📂 Project Structure

```
lib/
├── main.dart                        # App entry, theme + onboarding loading, routing
│
├── screens/
│   ├── onboarding_screen.dart       # Hero Tier selection (first launch only)
│   ├── home_screen.dart             # Mission discovery, category grid
│   ├── category_screen.dart         # Full mission list, search & filters
│   ├── skill_detail_screen.dart     # Mission overview, Hero Gear, episode list
│   ├── lesson_screen.dart           # Step-by-step episode content
│   ├── progress_screen.dart         # XP, rank, completed missions
│   ├── favorites_screen.dart        # Bookmarked missions
│   └── settings_screen.dart         # Theme toggle, Hero Tier change, about
│
├── models/
│   ├── skill_model.dart             # Mission data model + DifficultyRank/HeroTier enums
│   ├── lesson_model.dart            # Episode/step data model
│   ├── progress_model.dart          # Per-mission progress tracking
│   └── user_stats_model.dart        # XP total, Hero Tier, computed rank
│
├── services/
│   └── progress_service.dart        # shared_preferences persistence layer
│
├── widgets/
│   ├── mission_card.dart
│   ├── hero_tier_card.dart
│   ├── category_tile.dart
│   ├── xp_rank_badge.dart
│   ├── hero_gear_checklist.dart
│   ├── episode_list_item.dart
│   ├── comic_burst_badge.dart
│   ├── power_meter_bar.dart
│   └── halftone_background.dart
│
└── constants/
    ├── app_colors.dart               # Comic color palette (light + dark)
    ├── app_theme.dart                # Light/dark ThemeData
    └── skills_data.dart              # Seeded mission content
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.3.0 or higher)
- Android Studio / VS Code with the Flutter extension
- An emulator or physical device

### Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd diyhub

# Install dependencies
flutter pub get

# Generate the app launcher icon (Android + iOS)
flutter pub run flutter_launcher_icons

# Run the app
flutter run
```

> The app icon source lives at `assets/icon/icon.png` (1024×1024), generated from `assets/icon/icon_source.svg`. Replace either file and re-run the `flutter_launcher_icons` command above to update the launcher icon.

### Permissions

DIYHub needs **no special device permissions** — no camera, storage, or internet access — since all content is bundled locally and all progress is saved on-device with `shared_preferences`.

---

## 🎮 How Progression Works

- Every mission has an **XP reward**, granted once all of its episodes are completed.
- Total XP determines your **Rank**:

| Rank | XP Range |
|---|---|
| Novice | 0 – 499 |
| Cadet | 500 – 1,499 |
| Master | 1,500+ |

- Progress, favorites, XP, and theme preference are all saved locally via `shared_preferences` and persist between app launches.

---

## 🗺️ Development Roadmap

- [x] **Phase 1** — Project setup, theming, data models, local persistence, seeded content
- [x] **Phase 2** — Home & Category screens with full comic styling
- [x] **Phase 3** — Skill Detail & Lesson screens, XP/rank-up celebration
- [x] **Phase 4** — Progress & Favorites screens
- [x] **Phase 5** — Settings screen (theme toggle, Hero Tier change, data reset)
- [x] **Phase 6** — Polish: app icon, empty/loading states, permissions review


---

## 📄 License

This project was built for academic purposes as part of a university semester project.