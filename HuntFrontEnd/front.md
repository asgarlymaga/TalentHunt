You are a senior Angular architect building a world-class recruiter dashboard frontend. Your task is to implement the Stackt employer frontend according to the specification provided.

**Core Objective**
Build a production-ready Angular application (standalone components, Angular signals for state) that lets employers post job vacancies, review candidates who swiped right, and manage their hiring pipeline. The UI must match the mobile mockup's color palette (bone/ink/forest-green/clay-red) with custom, minimalist styling—no Angular Material.

**Tech Stack (Non-negotiable)**
- Angular (latest stable), standalone components only
- State management: Angular signals (no NgRx)
- HTTP: `HttpClient` with auth token interceptor
- Forms: Reactive Forms with strict validation
- Styling: Custom CSS/SCSS matching the mobile design system
- Auth: JWT stored in HttpOnly cookies (not localStorage—XSS risk)

**Route Structure**
Implement these routes exactly:
| `/login` | `LoginComponent` | Employer authentication |
| `/register` | `RegisterComponent` | Company profile creation |
| `/jobs` | `JobListComponent` | All employer jobs with status (active/draft) |
| `/jobs/new` | `JobFormComponent` | Create new job posting |
| `/jobs/:id/edit` | `JobFormComponent` | Edit existing posting (reuse same component) |
| `/jobs/:id/candidates` | `CandidatePipelineComponent` | Candidate pipeline for this job |
| `/profile` | `CompanyProfileComponent` | Company information |

**Key Component Requirements**

**`JobFormComponent`**
- Implement all fields from the backend `JobPosting` spec: title, one-line pitch, required skills (chip input where users can add/remove), salary range (two separate inputs: min/max), experience level (dropdown select)
- Required skills input must be non-empty before submit is enabled (this is the critical validation rule)
- Include a "Preview candidate's card" button that renders the job exactly as it appears on the mobile seeker side (use shared `JobCardPreview` component for code reuse)
- POST to `POST /api/jobs` for new jobs, PUT for edits
- Add a comment above the component explaining: *"This component powers vacancy creation and editing. We validate required skills to ensure recruiters don't post vague roles. The preview button lets employers see how seekers will evaluate their posting before publishing."*

**`CandidatePipelineComponent`**
- Fetch `GET /api/jobs/{id}/candidates` on load
- Display a 3-column kanban layout:
  - **Right-swiped**: Candidates who swiped right (interested) but employer hasn't responded yet
  - **Matched**: Both employer and candidate swiped right
  - **Applied**: Candidate submitted an application (has email or formal submission)
- Candidate cards show: compatibility metrics (skills overlap percentage/breakdown), NOT the candidate's name (avoid bias)
- Each card must have a clickable area to expand and view the full CV
- In the **Applied** column only: add a link to `Application.CvSnapshotUrl` with a label (`Generated` or `Uploaded`) so recruiters understand if the CV was auto-generated or the candidate's own file—this context affects their expectations
- Add an "Interested" button on each card to toggle employer swipe right (calls backend to set `Match.EmployerSwipedRight = true`)
- Add a comment above the component: *"The pipeline separates candidates by engagement stage. We hide names and show skills first so recruiters evaluate fit before unconscious bias kicks in. CV links are labeled so recruiters know what they're reviewing."*

**`JobCardPreview` (Shared Component)**
- Renders a job card in the exact visual style of the mobile seeker mockup
- Takes job data as input and displays: title, one-line pitch, required skills, salary range, experience level
- Used by both `JobFormComponent` (preview) and mobile app (if code is shared)

**`EmployerSwipeAction`**
- A reusable action component: when employer clicks "Interested" on a candidate card, it calls the backend to set `Match.EmployerSwipedRight = true`
- Provide visual feedback (button state change, toast confirmation)

**Authentication & Authorization**
- Implement `AuthGuard` that protects `/jobs/**` and `/profile` routes—only users with `role === Employer` can access
- Set up HTTP interceptor to attach JWT token from HttpOnly cookie to all outgoing requests
- Implement login and registration flows that set the HttpOnly cookie on success
- Add a comment on the `AuthGuard`: *"We protect recruiter routes to prevent seekers from accessing employer dashboards. JWT in HttpOnly cookies prevents XSS token theft."*

**Styling & Design**
- No Angular Material—build custom components
- Use the mobile mockup's color palette: bone, ink, forest-green, clay-red
- Minimize visual complexity—clean, scannable cards and forms
- Ensure responsive design (works on desktop, tablet, mobile)

**Testing Requirements**

**Unit Tests (Jasmine/Karma)**
1. `JobFormComponent`: Submit button must be disabled when required skills array is empty; enabled when at least one skill is added
2. `CandidatePipelineComponent`: Verify CV link renders with correct `Generated`/`Uploaded` label based on mock data
3. `CandidatePipelineComponent`: Verify skills overlap percentage calculates and displays correctly
4. `EmployerSwipeAction`: Verify button click triggers the API call and visual feedback appears

**E2E Tests (Cypress or Playwright)**
- User logs in with employer credentials
- User navigates to `/jobs/new`
- User fills the job form (title, pitch, adds 3 skills, sets salary range, selects experience level)
- User clicks "Preview candidate's card" and verifies the preview matches the mobile mockup style
- User submits the form
- User navigates to `/jobs/:id/candidates`
- Verify the pipeline displays with three columns populated by mock data
- User clicks on a card in the "Applied" column, verifies CV link appears with label, clicks it
- User clicks "Interested" button, verifies API call succeeds and button state updates

**Code Quality Standards**
- Add a short comment above every component explaining: (a) which backend endpoint(s) it calls, (b) which user decision it simplifies
- Use Angular signals for all component state (no RxJS observables unless absolutely necessary for HTTP streams)
- Type all inputs/outputs strictly (no `any`)
- Keep components small and focused—break into sub-components where a component handles multiple concerns
- Standalone components only; no module files

**Deliverables**
- Complete Angular application source code
- All components, services, guards, interceptors, and shared utilities
- Unit test files (spec.ts) with passing tests
- E2E test file with the full employer user journey
- README with setup instructions (npm install, ng serve, ng test, ng e2e)