You are an expert backend architect specializing in ASP.NET Core microservices and clean architecture patterns. Your task is to scaffold a complete, production-ready backend for Stackt — a job search platform combining TikTok-style swiping with Tinder-style mutual matching.

**Critical constraint:** Every class, method, property, and interface must include a comment explaining *why* it exists and what business problem it solves — not what it does (the code shows that). For example: "CvSnapshotUrl is separate from FileUrl so that Application records preserve an immutable copy of the CV that was sent, preventing audit history corruption if the user deletes the original file later."

---

## Core Requirements

**Tech Stack (non-negotiable):**
- ASP.NET Core Web API (latest LTS)
- Entity Framework Core with PostgreSQL
- Hangfire for background jobs (email sending must be fully asynchronous — see section on email workflow below)
- JWT authentication with role-based claims (`Seeker` or `Employer`)
- Abstracted interfaces for all external dependencies: `IEmailSender` (SMTP/SendGrid interchangeable), `ICvGenerator` (QuestPDF or alternate), `IFileStorage` (local disk MVP, upgradeable to S3/Blob)
- Clean Architecture with separate layers: `Domain`, `Application`, `Infrastructure`, `Api`

**Domain Model (scaffold with complete entities):**

```
User
  - Id, Email, PasswordHash, Role (Seeker | Employer), CreatedAt
  
SeekerProfile
  - Id, UserId (FK), Skills (List<string>), MinSalary (int),
    WorkStyle (Remote | Hybrid | OnSite), Location, ExperienceLevel,
    PreferredCvId (FK → CvDocument, nullable) -- CV sent with right swipes; if null, swipes return 400
    
EmployerProfile
  - Id, UserId (FK), CompanyName, Website

JobPosting
  - Id, EmployerId (FK), Title, OneLinePitch, RequiredSkills (List<string>),
    SalaryMin, SalaryMax, WorkStyle, ExperienceLevel, IsActive, CreatedAt

Swipe
  - Id, UserId (FK), JobPostingId (FK), Direction (Left | Right), CreatedAt
  - Unique constraint: (UserId, JobPostingId) — prevents duplicate swipes on same job

Match
  - Id, SeekerId (FK), JobPostingId (FK),
    SeekerSwipedRight (bool), EmployerSwipedRight (bool),
    Status (Pending | Matched), MatchedAt

CvDocument
  - Id, SeekerId (FK), Source (Generated | Uploaded), FileUrl,
    FileName, CreatedAt, IsDeleted (bool, soft delete)
  - Generated: created via ICvGenerator from SeekerProfile data
  - Uploaded: user-provided PDF/DOCX file

Application
  - Id, SeekerId (FK), JobPostingId (FK), CvDocumentId (FK),
    CvSnapshotUrl (string) -- immutable copy of FileUrl at send time; preserved even if CV deleted
    Status (PendingSend | Sent | Failed), SentAt, ErrorMessage
  - Unique constraint: (SeekerId, JobPostingId) — prevents duplicate emails for same job
```

---

## API Endpoints (scaffold controllers with these routes)

| Method | Route | Purpose |
|---|---|---|
| POST | `/api/auth/register` | Register seeker or employer (role in body) |
| POST | `/api/auth/login` | Return JWT token |
| POST | `/api/profile/seeker` | Save/update seeker skills, salary, work style |
| POST | `/api/profile/employer` | Save/update employer company info |
| POST | `/api/jobs` | Create new job posting |
| GET | `/api/deck` | Return jobs not yet swiped, ranked by compatibility score (threshold: > 0.5, configurable in appsettings) |
| POST | `/api/swipes` | Accept `{ jobPostingId, direction }` — if right, create Application (PendingSend status, use seeker's PreferredCvId) and enqueue Hangfire job; return 400 if PreferredCvId is null |
| GET | `/api/applied` | List seeker's applications (Applied tab) |
| GET | `/api/matches` | List jobs where both seeker and employer swiped right |
| GET | `/api/matches/{jobPostingId}/breakdown` | Show which skills matched, which filters fell short (e.g., salary 5k below range) |
| POST | `/api/jobs/{id}/swipe` | Employer swipes on candidate (for mutual matching) |
| POST | `/api/cv/generate` | Generate PDF CV from current seeker profile (creates CvDocument with Source=Generated) |
| POST | `/api/cv/upload` | Upload CV file (creates CvDocument with Source=Uploaded) |
| GET | `/api/cv` | List all seeker's CVs (generated + uploaded) with indication of PreferredCvId |
| PUT | `/api/cv/{id}/set-preferred` | Set CV as default for future swipes |
| DELETE | `/api/cv/{id}` | Soft-delete CV; if it was PreferredCvId, set to null and notify seeker |

---

## Compatibility Scoring (simple weighted formula, MVP-grade)

Scaffold a `IMatchingService` that implements:

```
score = (skillOverlapRatio × 0.5) 
      + (salaryFit ? 0.25 : 0) 
      + (workStyleMatch ? 0.15 : 0) 
      + (experienceLevelMatch ? 0.10 : 0)
```

- `skillOverlapRatio` = count(seeker skills ∩ job required skills) / count(job required skills)
- `/api/deck` returns only jobs with score > 0.5 (threshold configurable in `appsettings.json`)
- Exclude jobs already swiped in either direction

---

## Email Auto-Apply Workflow (critical: must be fully async)

**The flow is synchronous response, asynchronous execution:**

1. `POST /api/swipes` receives right swipe → immediately create `Application` record with status `PendingSend` (set `CvDocumentId` to seeker's current `PreferredCvId`) and **return HTTP response instantly** (UI card animates away immediately, as per mockup).
   - If `PreferredCvId` is null, return **400 Bad Request** — mobile app catches this and redirects user to CV selection screen; no incomplete profiles can swipe.

2. Enqueue Hangfire background job `SendApplicationEmailJob` for async execution.

3. Before sending, **copy `CvDocument.FileUrl` to `Application.CvSnapshotUrl`** to create an immutable snapshot. This preserves the CV version that was sent, even if the seeker deletes the original file later.

4. Send email with CV attachment to employer contact. On success: set `Application.Status = Sent`, `SentAt = now`. On failure: set `Status = Failed`, populate `ErrorMessage`, and configure Hangfire retry policy (3 attempts, exponential backoff).

5. The DB unique constraint `(SeekerId, JobPostingId)` prevents duplicate emails: even if user undoes and re-swipes, the constraint blocks a second Application record.

---

## CV Deletion Rules

- User can delete any `CvDocument` via `DELETE /api/cv/{id}` — this is a **soft delete** (`IsDeleted = true`), file is not physically removed so existing `Application.CvSnapshotUrl` references remain valid.
- If deleted CV is the current `PreferredCvId`: set `SeekerProfile.PreferredCvId = null` and notify seeker ("Default CV deleted, select a new one"). Subsequent right swipes return 400 until a new preferred CV is set.
- Deleted CVs must not appear in `GET /api/cv` list.

---

## Test Coverage (scaffold all of these)

**Unit Tests:**
- Compatibility score calculation across different skill/salary/work-style combinations
- Duplicate swipe constraint enforcement
- `/api/swipes` returns 400 when PreferredCvId is null
- PreferredCvId becomes null when that CV is deleted
- `CvSnapshotUrl` is correctly copied from `FileUrl` at application creation time

**Integration Tests:**
- `POST /api/swipes` → Application record created → Hangfire job enqueued (mock `IEmailSender`, no real emails)
- `/api/deck` returns only jobs above threshold and not yet swiped
- CV deleted after Application sent → `Application.CvSnapshotUrl` still accessible, original `CvDocument` marked soft-deleted
- Unique constraint prevents second Application for same (SeekerId, JobPostingId)
- `PreferredCvId = null` blocks swipes until a CV is set as preferred

---

## Folder Structure (scaffold project files in this layout)

```
/src
  /Stackt.Domain
    -- Entities (User, SeekerProfile, EmployerProfile, JobPosting, Swipe, Match, CvDocument, Application)
    -- Enums (Role, Direction, CvSource, ApplicationStatus, WorkStyle, ExperienceLevel)
    
  /Stackt.Application
    -- Use cases / services (IMatchingService, IApplicationService, etc.)
    -- Interfaces: IEmailSender, ICvGenerator, IFileStorage
    -- DTOs
    
  /Stackt.Infrastructure
    -- EF Core DbContext and migrations
    -- Hangfire configuration and job implementations (SendApplicationEmailJob)
    -- Email implementations (SMTP, SendGrid)
    -- CV generation (QuestPDF wrapper)
    -- File storage (local disk, S3 stub)
    
  /Stackt.Api
    -- Controllers (Auth, Profile, Jobs, Swipes, Matches, Cv)
    -- JWT middleware setup
    -- Dependency injection configuration
    -- appsettings.json (with score threshold, retry policy config)
    
/tests
  /Stackt.UnitTests
  /Stackt.IntegrationTests
```

---

## Additional Guidance

- Every public class and method must have a summary comment explaining *why* it exists, not *what* it does.
- Use dependency injection throughout; no hardcoded implementations.
- Implement soft deletes consistently (query filters, `IsDeleted` checks).
- Configure Hangfire with PostgreSQL for job persistence.
- Seed the database with test data (sample users, job postings, skills) for manual testing.
- Ensure all endpoints are secured with JWT validation (use `[Authorize]` attributes appropriately).
- Structure error responses consistently (include error codes, messages).