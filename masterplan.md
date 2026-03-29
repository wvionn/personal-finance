# Master Plan: Catat Uang (Frictionless Finance Tracker)

## Project Overview and Objectives
"Catat Uang" is a modern, privacy-first personal finance application designed to remove the friction from logging daily expenses and incomes. The primary objective is to make logging financial data as fast and intuitive as possible using natural language processing and quick-access widgets.

## Target Audience
Individuals who want to track their daily finances but find traditional form-based budgeting apps too slow or tedious. It appeals to users who value data privacy and prefer an instantaneous, modern user experience.

## Core Features and Functionality
- **Editable Quick Income (Pemasukan Cepat):** Easily modifiable templates for rapid manual entry.
- **AI Natural Language Processing Widget:** A home screen widget allowing users to type or speak sentences (e.g., "bensin 35 ribu, makan 18 ribu") which are automatically parsed into structured expense data.
- **In-App AI Helper:** A small, floating AI helper icon inside the application that can process text inputs directly and assist the user in logging.
- **AI Engine Fallback Strategy:** Built with a primary NLP processor (like OpenAI 3.5 or an equivalent fast open-source model) with an immediate, automatic fallback to the Gemini API to ensure the parser never goes down.
- **Local-First Architecture:** All financial data remains exclusively on the user's physical device.

## High-Level Technical Stack Recommendations
- **Frontend Framework:** Cross-platform framework (Flutter) for high-performance mobile compilation.
- **Local Database:** A fast, local NoSQL or SQL storage solution (e.g., Hive, Isar, or SQLite).
- **AI Integration (NLP):** Standard HTTP REST API calls to Google AI Studio (Gemini) and OpenAI-compatible endpoints.

## Conceptual Data Model
- **Transaction:** ID, Amount, Type (Income/Expense), Category, Date, Note.
- **Category:** ID, Name, Icon/Color.
- **Quick Entry Template:** ID, Default Amount, Type, Category.

## User Interface Design Principles
- **Aesthetic:** High-contrast Neon Dark Theme (dark browns, neon amber) for a premium, modern feel.
- **Frictionless UX:** Minimal taps to complete an action. The AI helper is always one tap away as a continuous visual assistant.

## Security Considerations
- Data is entirely localized to the device storage to guarantee privacy, meaning no data leaks or server hacks are possible.
- Future expansion: Optional biometric lock (FaceID/Fingerprint) if the user demands an extra layer of privacy on their unlocked phone.

## Development Phases and Milestones
1. **Phase 1: Core Foundation.** Setup local database, basic category and transaction models, UI skeleton.
2. **Phase 2: Manual Data Entry.** Implement standard forms and the *Editable Quick Income* feature.
3. **Phase 3: The AI Helper.** Integrate the Gemini/OpenAI API, build the prompt parsing logic, and implement the in-app floating AI helper.
4. **Phase 4: Widget Integration.** Build native home screen widgets that ping the AI logic in the background.

## Potential Challenges and Proposed Solutions
- **Challenge:** AI hallucinating or incorrectly parsing amounts or categories.
- **Solution:** Force the AI to respond in strict JSON format. Implement a visual confirmation toast/snackbar before saving the data permanently to the database.
- **Challenge:** API rate limits or costs.
- **Solution:** Rely heavily on free-tier APIs (Gemini) and implement a "Bring Your Own Key" configuration if users exhaust free limits.

## Future Expansion Possibilities
- Cloud syncing (optional opt-in for cross-device support).
- AI financial insights and spending summaries derived from local data points.

## Implementation Status (Updated March 29, 2026)
- ✅ Core local database with SQLite and sqflite (already in place).
- ✅ App title changed to "Anti Boncos" in UI and notifications.
- ✅ Export database from Settings with user-sized selectable file path.
- ✅ Import database from Settings with confirmation and data replace semantics.
- ✅ Auto-backup engine with settings for Off/Daily/Weekly (persists in SharedPreferences).
- ✅ Backup filename uses date format `backup_YYYY-MM-DD.db`.
- ✅ App version display in Settings via package_info_plus.
- ✅ Auto-run backup on app startup when schedule is due.

### Remaining to implement
- [ ] Cross-device cloud sync (opt-in, user account + encrypted server storage).
- [ ] AI NLP parser widget as originally spec’d (Gemini/OpenAI, fallback strategy, strict JSON output).
- [ ] Full widget ecosystem (home screen shortcut + background parse updates).
- [ ] Optional biometric lock per security roadmap.
