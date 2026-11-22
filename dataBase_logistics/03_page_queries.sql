
-- SQL for using correct database
USE compeition_team_manager;
GO

-- Test inputs for SSMS (matched to VARCHAR(50) in [User])
DECLARE @Username VARCHAR(50) = 'Guardiansof_Galaxy';
DECLARE @Password VARCHAR(50) = 'myPassword123';
DECLARE @UserID   INT         = 1;

-- 1.1 SELECT: Verify active user credentials ([User])
SELECT UserID, Username, First_Name, Last_Name, Password_
FROM [User]
WHERE Username  = @Username
  AND Password_ = @Password
  AND IsActive  = 1;

-- 1.2 SELECT: Check user role (Admin, Subteam Lead, or Member)
SELECT
    U.UserID,
    CASE
        WHEN A.UserID IS NOT NULL THEN 'Admin'
        WHEN EXISTS (
            SELECT 1
            FROM LEADS_SUBTEAM L
            WHERE L.Member_ID = U.UserID
        ) THEN 'Subteam Lead'
        WHEN M.UserID IS NOT NULL THEN 'Member'
        ELSE 'Unknown'
    END AS UserRole
FROM [User] U
LEFT JOIN [ADMIN]  A ON U.UserID = A.UserID
LEFT JOIN [MEMBER] M ON U.UserID = M.UserID
WHERE U.UserID = @UserID;

-- 1.3 SELECT: Combined Login + Role Check (Single Query)
SELECT
    U.UserID,
    U.Username,
    U.First_Name,
    U.Last_Name,
    CASE
        WHEN A.UserID IS NOT NULL THEN 'Admin'
        WHEN EXISTS (
            SELECT 1
            FROM LEADS_SUBTEAM L
            WHERE L.Member_ID = U.UserID
        ) THEN 'Subteam Lead'
        WHEN M.UserID IS NOT NULL THEN 'Member'
        ELSE 'Unknown'
    END AS UserRole
FROM [User] U
LEFT JOIN [ADMIN]  A ON U.UserID = A.UserID
LEFT JOIN [MEMBER] M ON U.UserID = M.UserID
WHERE U.Username  = @Username
  AND U.Password_ = @Password
  AND U.IsActive  = 1;

-- 1.4 SELECT: Get Subteam(s) Led (If UserRole = 'Subteam Lead')
SELECT S.Subteam_ID, S.Subteam_Name
FROM LEADS_SUBTEAM L
JOIN SUBTEAM S ON L.Subteam_ID = S.Subteam_ID
WHERE L.Member_ID = @UserID;


-- ============================================================
-- PAGE 2: HOME & CONTACT
-- ============================================================

-- 2.1 SELECT: Load team mission, vision, and contact info (TEAM)



-- 2.2 UPDATE: Edit team info (Admin)



-- ============================================================
-- PAGE 3: TEAM MEMBERS & SUB-TEAM MEMBERS
-- ============================================================

-- 3.1 SELECT: List/search all active members with subteams (BELONGS_TO) and projects



-- 3.2 SELECT: Load members belonging to a specific subteam (BELONGS_TO)



-- 3.3 INSERT: Add an existing member to a subteam (BELONGS_TO)



-- 3.4 DELETE: Remove a member from a subteam (BELONGS_TO)



-- ============================================================
-- PAGE 4: SUBTEAMS
-- ============================================================

-- 4.1 SELECT: Load all subteams, descriptions, and leads (SUBTEAM + LEADS_SUBTEAM)



-- 4.2 INSERT: Create a new subteam (SUBTEAM) and assign lead(s) (LEADS_SUBTEAM)



-- 4.3 UPDATE / DELETE: Edit subteam details or update/remove leads (SUBTEAM, LEADS_SUBTEAM)



-- 4.4 DELETE: Delete a subteam (clean up junction rows first)



-- ============================================================
-- PAGE 5: PROJECTS
-- ============================================================

-- 5.1 SELECT: Load all projects (Internal view)



-- 5.2 SELECT: Load public projects where Project_IsVisible = 1 (Guest view)



-- 5.3 SELECT: Load attached documents (ATTACHED_TO) and milestones (MILESTONE_PROJECT) for a project



-- 5.4 INSERT: Create a new project & link subteam(s) (SUBTEAM_WORKS_ON_PROJECT)



-- 5.5 INSERT: Attach an uploaded document to a project (DOCUMENT + ATTACHED_TO)



-- 5.6 UPDATE: Edit project details, status, or Project_IsVisible



-- 5.7 DELETE: Unlink junction rows (SUBTEAM_WORKS_ON_PROJECT, ATTACHED_TO, MILESTONE_PROJECT) & delete project



-- ============================================================
-- PAGE 6: TASK LIST & TASK DETAILS
-- ============================================================

-- 6.1 SELECT: Load Task List ordered by due date (filtered by member via MEMBER_WORKS_ON_TASK or by Subteam_ID)



-- 6.2 SELECT: Load full Task Details, attached docs (TASK_DOCUMENT), FEEDBACK, and ASSISTANCE_REQUEST



-- 6.3 INSERT: Create a new task (TASK) & assign member(s) (MEMBER_WORKS_ON_TASK)



-- 6.4 UPDATE: Toggle/update Task_Status (checkbox / status button)



-- 6.5 UPDATE: Edit task title, description, deliverables, priority, or due date (Lead)



-- 6.6 DELETE: Unlink MEMBER_WORKS_ON_TASK / TASK_DOCUMENT & delete task



-- 6.7 INSERT: Upload a document (DOCUMENT) & attach to task (TASK_DOCUMENT)



-- 6.8 UPDATE / DELETE: Edit or delete a document (DOCUMENT)



-- 6.9 INSERT / UPDATE / DELETE: Give, edit, or delete lead feedback (FEEDBACK)



-- 6.10 INSERT: Submit an assistance request linked to a task (ASSISTANCE_REQUEST)



-- 6.11 UPDATE / DELETE: Answer/resolve or delete an assistance request (ASSISTANCE_REQUEST)



-- ============================================================
-- PAGE 7: TIMELINE, EVENTS & TEAM HISTORY (MILESTONES)
-- ============================================================

-- 7.1 SELECT: Load timelines with events (TIMELINE_EVENT) and milestones (TIMELINE_MILESTONE)



-- 7.2 SELECT: Load upcoming events ordered chronologically (EVENT)



-- 7.3 SELECT: Load milestones filtered by date range (MILESTONE — Team History)



-- 7.4 INSERT: Create a timeline, event, or milestone & link via TIMELINE_EVENT / TIMELINE_MILESTONE



-- 7.5 UPDATE: Edit a timeline, event, or milestone (pencil icon)



-- 7.6 DELETE: Unlink TIMELINE_EVENT / TIMELINE_MILESTONE / MILESTONE_PROJECT & delete record



-- ============================================================
-- PAGE 8: ACHIEVEMENTS, SPONSORS & GALLERY
-- ============================================================

-- 8.1 SELECT: Load public achievements (ACHIEVEMENT)



-- 8.2 INSERT / UPDATE / DELETE: Manage achievements (Admin)



-- 8.3 SELECT: Load sponsors and contribution details (SPONSOR + SPONSOR_CONTRIBUTION if used)



-- 8.4 INSERT / UPDATE / DELETE: Manage sponsors & contributions (Admin)



-- 8.5 SELECT: Load gallery photos (DOCUMENT where Document_Type = 'Gallery')



-- ============================================================
-- PAGE 9: DISCUSSION PAGES & MESSAGES
-- ============================================================

-- 9.1 SELECT: Load discussion pages with associated subteams (SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE) and creator ([USER])



-- 9.2 INSERT: Create a discussion page (DISCUSSION_PAGE) & link subteam(s) (SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE)



-- 9.3 UPDATE / DELETE: Edit or delete a discussion page (clean up messages & subteam links first)



-- 9.4 SELECT: Load all messages in a discussion page ordered by post_date (MESSAGE + [USER])



-- 9.5 INSERT: Post a new message (MESSAGE with UserID and page_ID)



-- 9.6 UPDATE / DELETE: Edit or delete a message (MESSAGE)



-- ============================================================
-- PAGE 10: ADMIN USER & VISIBILITY MANAGEMENT
-- ============================================================

-- 10.1 INSERT: Register a new user ([USER]) and assign disjoint role (ADMIN or MEMBER)



-- 10.2 UPDATE: Edit user profile, deactivate account (IsActive = 0), or set Admin_Leave_Date / Leave_Date



-- 10.3 DELETE: Delete subtype record (ADMIN or MEMBER) and user ([USER])



-- 10.4 UPDATE: Toggle visibility flags (Project_IsVisible, TIMELINE.isVisible, ACHIEVEMENT.IsVisible)