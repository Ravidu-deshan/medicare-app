# MediCare — Medicine Reminder & Delivery System

> PUSL3190 Computing Project — BSc (Honours) Software Engineering  
> University of Plymouth | Student: Widana Gunasekara | Index: 10953062  
> Supervisor: Ms. Pavithra Subhashini

---

## What is MediCare?

MediCare is a cross-platform mobile application (Android & iOS) that connects **patients**, **pharmacies**, and **delivery agents** to solve two linked healthcare problems in Sri Lanka:

1. **Medication non-adherence** — patients forgetting to take medicines, especially the elderly
2. **Limited pharmaceutical access** — rural patients unable to order or track medicine deliveries

---

## Features

| Feature | Status |
|---|---|
| Role-based login (Patient / Pharmacy / Delivery Agent) | ✅ Done |
| Firebase Authentication (email/password) | ✅ Done |
| Firestore database schema (8 collections) | ✅ Done |
| Today's medication dashboard | ✅ Done |
| Mark medication as taken | ✅ Done |
| Gamification (streaks, points, badges) | ✅ Done |
| Monthly adherence calendar | ✅ Done |
| Add medication with reminder time | ✅ Done |
| Prescription photo upload | 🔄 Sprint 5 |
| Pharmacy map (Google Maps) | 🔄 Sprint 5 |
| Live GPS delivery tracking | 🔄 Sprint 8 |
| Sinhala / Tamil language | 🔄 Sprint 10 |
| Python AI service (gamification engine, OCR) | 🔄 In progress |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| State Management | Riverpod |
| Backend | Firebase (Auth, Firestore, FCM, Storage) |
| Maps | Google Maps API |
| AI Service | Python (FastAPI) |
| Version Control | Git + GitHub |

---

## Project Structure

```
medicare-app/
├── flutter_app/        # Flutter mobile application
├── python_ai/          # Python FastAPI AI microservice
├── firestore_rules/    # Firestore security rules
├── docs/               # Project documentation
└── scripts/            # Setup and utility scripts
```

---

## Getting Started

See the full setup guide: [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md)

### Quick start

```bash
# 1. Clone
git clone https://github.com/yourusername/medicare-app.git
cd medicare-app
git checkout develop

# 2. Flutter
cd flutter_app
flutter pub get
flutter run

# 3. Python AI
cd ../python_ai
python -m venv venv && venv\Scripts\activate
pip install -r requirements.txt
python app.py
```

---

## Branch Strategy

| Branch | Purpose |
|---|---|
| `main` | Production only — protected |
| `develop` | Integration — all PRs merge here |
| `feature/*` | One branch per feature |
| `sprint/*` | Sprint-scoped branches |
| `bugfix/*` | Bug fixes |
| `release/*` | Pre-release staging |

---

## Academic References

- WHO (2023) — NCDs account for 75% of Sri Lanka deaths
- Abeywickrama et al. (2024) — Sri Lanka economic crisis & medication practices
- Dias et al. (2023) — Adherence among hypertensive patients, Eastern Sri Lanka
- Zhang & Kumar (2023) — UX design for elderly mHealth users

---

*PUSL3190 Final Year Project — 2025/2026*
