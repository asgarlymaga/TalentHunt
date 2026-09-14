You are a senior Flutter engineer building a mobile job-discovery app (seeker experience). Your task is to implement the complete mobile specification for **Stackt** — a swipe-based job marketplace with profile setup, CV management, and match tracking.

## Core Objective

Build a production-ready Flutter codebase that matches the provided HTML mockup (`swipe-jobs-ui.html`) in visual design, interaction patterns, and user flow. The app must handle role selection (seeker-only on mobile), guided profile setup, CV management (generated + uploaded), swipe discovery with optimistic UI, and application tracking — all with robust error handling and comprehensive tests.

---

## Tech Stack (Non-Negotiable)

- **Flutter** (stable channel)
- **State management**: Riverpod (chosen for simplicity and testability; Bloc is acceptable if the team prefers)
- **Network**: Dio with JWT interceptor for token injection
- **Gesture handling**: Custom `GestureDetector` + `Transform` (no third-party swipe packages — the mockup's rotation + stamp overlay + threshold-based fling behavior requires precise control)
- **File selection**: `file_picker` package with PDF/DOCX restrictions
- **Fonts**: Google Fonts package (match mockup typography: Fraunces + IBM Plex Sans equivalents)

---

## Screen Specifications

Implement these 8 screens following the mockup's visual language (color palette, "ticket/index-card" metaphor, typography):

| Screen | Widget Class | Key Behavior |
|---|---|---|
| Role Select | `RoleSelectScreen` | Seeker/Employer choice. If Employer selected, redirect to web via deep-link. |
| Profile Setup | `ProfileSetupWizard` | 3-step wizard in `PageView`: (1) skills chip-selector, (2) salary slider, (3) work-style selection. Validate at each step. |
| **CV Manager** | `CvManagerScreen` | Two sections: Generated CV (from `POST /api/cv/generate`, refreshable) and Uploaded CVs (via `file_picker`, uploaded to `POST /api/cv/upload`). Each CV card has: Preview (open PDF), Set as Default (radio-button logic—only one default at a time), Delete (with confirmation dialog). See section below for detailed behavior. |
| Discover | `DiscoverScreen` + `SwipeCardStack` | Main swipe interface. See section below. |
| Match Celebration | `MatchScreen` | Full-screen modal overlay (open via `Navigator.push`). |
| Matches List | `MatchesListScreen` | List of matched jobs with status badges (Matched/Pending). |
| Applied | `AppliedListScreen` | Jobs swiped right (emails sent). Show status: Sending / Sent / Failed. Display which CV (generated or uploaded filename) was used for each application. |
| Match Breakdown | `MatchBreakdownScreen` | Show which skills matched, which filters were close but didn't pass. |

---

## CV Manager Screen — Critical Design Decision

The CV selection happens **before swipe discovery**, not during it. This preserves the "one card = one decision" principle of the swipe UX.

**Behavior:**

- Two sections: **Generated CV** (created from profile data, refreshable with one tap) and **Uploaded CVs** (user-selected files).
- Each CV card has three actions: **Preview** (open PDF inline), **Set as Default** (radio-button: only one CV can be default; updates `SeekerProfile.PreferredCvId` on backend), **Delete** (confirmation dialog, calls `DELETE /api/cv/{id}`).
- Swipe discovery uses only the default CV — no CV selection during swiping.
- **If no CV is selected and the user swipes right:** Backend returns 400. Catch this in Flutter, show a bottom-sheet: "Choose a CV to apply" → redirect to `CvManagerScreen`.
- **If the default CV is deleted:** Backend sets `PreferredCvId` to null. Show a banner in the app: "Default CV was deleted. Choose a new one."

---

## Swipe Card Stack — Core Widget (Highest Priority)

This is the centerpiece of the app. Comments in code must explain the design rationale.

**Architecture:**

- Render 3 cards simultaneously: the top card is interactive, the bottom two are decorative (mimic mockup's `translateY`/`scale` stacking effect).
- Use `GestureDetector.onPanUpdate` to track drag distance.
- **Rotation formula**: rotate card by `dx / 18` radians as user drags (matches mockup logic).
- **Threshold**: When `dx.abs() > 90`, swipe is confirmed. Card exits screen with fling animation via `AnimationController`.
- **Optimistic UI** (critical): The moment a swipe is confirmed (threshold crossed), the card disappears and the next card appears. Do **not** wait for backend response. `POST /api/swipes` happens in the background.
  - If network fails: Show "Retry" prompt, card re-appears.
  - **Exception**: If backend returns 400 (no CV selected), this is not a network error — show the CV-selection bottom-sheet instead.
- **Right swipe creates an Application**: Backend creates an `Application` record (email sent, CV attached). Immediately add a "Sending..." status entry to `AppliedListScreen` (optimistic), then poll or use WebSocket to update status when backend confirms (Sent / Failed).

**Why this matters:** Swipe UX must feel instant. Waiting for the backend to respond before showing the next card breaks the flow.

---

## User Flows (Step-by-Step)

**Flow 1: First-time Seeker**
1. Role Select → choose Seeker
2. Profile Setup Wizard (3 steps) → skills, salary, work-style
3. CV Manager (mandatory): generate CV or upload file, set as default
4. Discover Screen opens (swipe begins)

**Flow 2: Applying**
1. User on Discover Screen
2. Swipes right (swiping left = reject, no action)
3. Optimistic UI: card disappears, next card appears
4. Backend creates Application in background
5. Applied tab immediately shows new entry with "Sending..." badge
6. Status updates to "Sent" when backend confirms

**Flow 3: No CV Selected**
1. User swipes right
2. Backend returns 400 (no PreferredCvId)
3. Flutter catches error, shows bottom-sheet: "Choose a CV to apply"
4. User taps → navigates to CV Manager
5. User sets default, returns to Discover
6. Swipe succeeds

---

## Project Structure

```
/lib
  /core
    /constants       -- colors, text styles, mockup metrics
    /theme           -- ThemeData matching mockup
    /network         -- Dio client with JWT interceptor
  /features
    /auth            -- login, role selection
    /profile         -- ProfileSetupWizard (3 steps)
    /cv              -- CvManagerScreen, generate/upload/delete logic
    /discover        -- DiscoverScreen, SwipeCardStack
    /matches         -- MatchesListScreen, MatchBreakdownScreen
    /applied         -- AppliedListScreen
  /shared_widgets    -- JobCard, SkillChip, PrimaryButton, etc. (reusable UI from mockup)
  /models            -- Job, Application, Seeker, CV, etc.
  /providers         -- Riverpod state management
```

---

## Testing Requirements

Write tests with this focus:

1. **Widget test: `SwipeCardStack`**
   - Programmatically drag past threshold (dx > 90)
   - Verify card is removed from state after drag completes
   - Verify next card appears

2. **Widget test: `ProfileSetupWizard`**
   - When no skills are selected, "Continue" button is disabled
   - Selecting a skill enables the button
   - All 3 steps progress correctly via PageView

3. **Widget test: `CvManagerScreen`**
   - Only one CV can have "default" status at a time (radio-button logic)
   - Deleting a CV shows confirmation dialog
   - Delete button fires correctly after confirmation

4. **Widget test: CV Selection Before Swipe**
   - User attempts to swipe right without a default CV selected
   - Bottom-sheet appears with "Choose a CV to apply" message
   - Tapping the prompt navigates to `CvManagerScreen`

5. **Integration test: Complete Flow**
   - Mock API with typical responses
   - Flow: login → profile setup → CV generation/upload → set default → discover → swipe right → verify Application in Applied list with correct CV label

---

## Key Implementation Notes

**Mockup Fidelity:**
- Every screen widget should have a 1–2 line comment explaining which mockup screen it corresponds to and the UI rationale (e.g., "CV selection happens before swipe to preserve the 'one card = one decision' principle").
- Preserve color palette, typography (Fraunces + IBM Plex Sans), and "ticket/index-card" visual style throughout.

**Error Handling:**
- Network errors: Show retry prompt or snackbar, don't silently fail.
- Backend validation (e.g., no CV selected): Catch HTTP 400, show contextual UI (not a generic error).
- File upload errors: Provide clear feedback ("PDF/DOCX only", "File too large", etc.).

**Optimization:**
- Run `flutter analyze` and `flutter test` after every major change (before committing to a real build).
- Lazy-load images in job cards; use `CachedNetworkImage` if appropriate.
- Use const constructors where possible to reduce rebuilds.

**Before Building:**
- Without a real device/emulator, `flutter build` only catches compile errors, not UI issues.
- Use `flutter analyze` and `flutter test` to validate logic and widget trees.
- Only move to a real build after local tests pass.

---

Start by setting up the project structure, core theme, and Dio client. Then implement screens in this order: (1) Auth/Role Select, (2) Profile Wizard, (3) CV Manager, (4) SwipeCardStack + Discover, (5) Applied/Matches. Each screen should have comments explaining its mockup correspondence and design decisions.