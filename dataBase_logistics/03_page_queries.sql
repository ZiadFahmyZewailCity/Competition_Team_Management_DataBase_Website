
-- SQL for using correct database
USE compeition_team_manager;
GO

-- ============================================================
-- PAGE 1: SIGN IN & ROLE CHECK
-- ============================================================

-- 1.1 SELECT: Verify active user credentials ([USER])

SELECT UserID, Username, First_Name, Last_Name, Email
FROM [User]
WHERE Username = 'ziad123'
  AND Password_ = 'pass123'
  AND IsActive = 1;


-- 1.2 SELECT: Check user role (ADMIN, MEMBER, or Subteam Lead via LEADS_SUBTEAM)



-- ============================================================
-- PAGE 2: HOME & CONTACT
-- ============================================================

-- 2.1 SELECT: Load team mission, vision, and contact info (TEAM)

SELECT Team_Name, Team_Mission, Team_Vision, Address, Email, Phone
FROM [TEAM];


-- 2.2 UPDATE: Edit team info (Admin)
UPDATE [TEAM]
SET Team_Mission = 'New mission text',
    Team_Vision  = 'New vision text',
    Address      = 'New address',
    Email        = 'team@example.com',
    Phone        = '01000000000'
WHERE Team_ID = 1;


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


SELECT Achievement_ID, Title, Description,
       Day, Month, Year,
       Rank, Placement_Rank, Placement_Category
FROM [ACHIEVEMENT]
ORDER BY Year DESC, Month DESC, Day DESC;

-- 8.2 INSERT / UPDATE / DELETE: Manage achievements (Admin)
INSERT INTO [ACHIEVEMENT]
    (Achievement_ID, Title, Description, Day, Month, Year, Rank, Placement_Rank, Placement_Category)
VALUES
    (1, 'ACM Regional Contest', 'Won first place in the regional contest', 15, 3, 2026, 'Gold', '1st', 'Programming');



-- 8.3 SELECT: Load sponsors and contribution details (SPONSOR + SPONSOR_CONTRIBUTION if used)
SELECT S.Sponsor_ID, S.Sponsor_Name, S.Sponsor_Logo, S.Sponsor_Type,
       S.Email, S.Phone,
       C.Contract_Details
FROM [SPONSOR] S
LEFT JOIN [SPONSOR_CONTRACT_DETAILS] C
    ON C.Sponsor_ID = S.Sponsor_ID
ORDER BY S.Sponsor_Name;


-- 8.4 INSERT / UPDATE / DELETE: Manage sponsors & contributions (Admin)

INSERT INTO [SPONSOR]
    (Sponsor_ID, Sponsor_Name, Sponsor_Logo, Sponsor_Type, Email, Phone)
VALUES
    (1, 'TechCorp', 'logos/techcorp.png', 'Gold', 'info@techcorp.com', '01000000000');
INSERT INTO [SPONSOR_CONTRACT_DETAILS] (Sponsor_ID, Contract_Details)
VALUES (1, 'Provides 50,000 EGP yearly funding');
UPDATE [SPONSOR]
SET Sponsor_Name = 'TechCorp Egypt',
    Sponsor_Type = 'Platinum',
    Phone = '01111111111'
WHERE Sponsor_ID = 1;
-- UPDATE contract detail (it is part of the PK, so we match on the old value)
UPDATE [SPONSOR_CONTRACT_DETAILS]
SET Contract_Details = 'Provides 75,000 EGP yearly funding'
WHERE Sponsor_ID = 1
  AND Contract_Details = 'Provides 50,000 EGP yearly funding';
DELETE FROM [SPONSOR_CONTRACT_DETAILS]
WHERE Sponsor_ID = 1
  AND Contract_Details = 'Provides 75,000 EGP yearly funding';
DELETE FROM [SPONSOR_CONTRACT_DETAILS] WHERE Sponsor_ID = 1;
DELETE FROM [SPONSOR] WHERE Sponsor_ID = 1;




-- 8.5 SELECT: Load gallery photos (DOCUMENT where Document_Type = 'Gallery')
SELECT Document_ID, Document_Filename, Document_FilePath, Document_Fileformat,
       D_Upload_Date_Day, D_Upload_Date_Month, D_Upload_Date_Year
FROM [DOCUMENT]
WHERE Document_Type = 'Gallery'
ORDER BY D_Upload_Date_Year DESC, D_Upload_Date_Month DESC, D_Upload_Date_Day DESC;


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
