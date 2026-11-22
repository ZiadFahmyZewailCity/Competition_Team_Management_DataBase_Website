SET XACT_ABORT ON; -- Automatically rolls back if any runtime error occurs
BEGIN TRANSACTION;

-- SQL for using correct database
USE competition_team_manager;
GO

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
-- Test inputs for PAGE 2
DECLARE @Team_ID       INT           = 1;
DECLARE @Team_Mission  VARCHAR(MAX)  = 'New mission text';
DECLARE @Team_Vision   VARCHAR(MAX)  = 'New vision text';
DECLARE @Address       VARCHAR(255)  = 'New address';
DECLARE @Team_Email    VARCHAR(100)  = 'team@example.com';
DECLARE @Team_Phone    VARCHAR(50)   = '01000000000';


-- 2.1 SELECT: Load team mission, vision, and contact info (TEAM)
SELECT Team_Name, Team_Mission, Team_Vision, Address, Email, Phone
FROM [TEAM];


-- 2.2 UPDATE: Edit team info (Admin)
UPDATE [TEAM]
SET Team_Mission = @Team_Mission,
    Team_Vision  = @Team_Vision,
    Address      = @Address,
    Email        = @Team_Email,
    Phone        = @Team_Phone
WHERE Team_ID = @Team_ID;

-- ============================================================
-- PAGE 3: TEAM MEMBERS & SUB-TEAM MEMBERS
-- ============================================================

-- 3.1 SELECT: List all active members with their subteams and projects
SELECT
    U.UserID,
    U.First_Name,
    U.Last_Name,
    U.Email,
    U.Major,
    S.Subteam_Name,
    P.Project_Name
FROM [User] U
JOIN [MEMBER] M ON U.UserID = M.UserID
LEFT JOIN [BELONGS_TO] B ON M.UserID = B.Member_ID
LEFT JOIN SUBTEAM S ON B.Subteam_ID = S.Subteam_ID
LEFT JOIN SUBTEAM_WORKS_ON_PROJECT SWP ON S.Subteam_ID = SWP.Subteam_ID
LEFT JOIN PROJECT P ON SWP.Project_ID = P.Project_ID
WHERE U.IsActive = 1
ORDER BY U.First_Name, U.Last_Name;

-- 3.1b SELECT: Search active members by Name or Subteam Name
SELECT
    U.UserID,
    U.First_Name,
    U.Last_Name,
    S.Subteam_Name
FROM [User] U
JOIN [MEMBER] M ON U.UserID = M.UserID
LEFT JOIN [BELONGS_TO] B ON M.UserID = B.Member_ID
LEFT JOIN SUBTEAM S ON B.Subteam_ID = S.Subteam_ID
WHERE U.IsActive = 1
  AND (
      U.First_Name   LIKE '%' + @SearchTerm + '%'
      OR U.Last_Name LIKE '%' + @SearchTerm + '%'
      OR S.Subteam_Name LIKE '%' + @SearchTerm + '%'
  );

-- 3.1c SELECT: View a single member's full profile
SELECT
    U.UserID,
    U.Username,
    U.First_Name,
    U.Last_Name,
    U.Email,
    U.Major,
    U.Enrollment_Year,
    M.Team_join_date,
    S.Subteam_Name,
    CASE
        WHEN EXISTS (
            SELECT 1 FROM LEADS_SUBTEAM L
            WHERE L.Member_ID = M.UserID AND L.Subteam_ID = S.Subteam_ID
        ) THEN 'Subteam Lead'
        ELSE 'Member'
    END AS SubteamRole
FROM [User] U
JOIN [MEMBER] M ON U.UserID = M.UserID
LEFT JOIN [BELONGS_TO] B ON M.UserID = B.Member_ID
LEFT JOIN SUBTEAM S ON B.Subteam_ID = S.Subteam_ID
WHERE U.UserID = @MemberID;

-- 3.2 SELECT: Load members belonging to a specific subteam
SELECT
    U.UserID,
    U.First_Name,
    U.Last_Name,
    U.Email,
    M.Team_join_date
FROM [BELONGS_TO] B
JOIN [MEMBER] M ON B.Member_ID = M.UserID
JOIN [User]   U ON M.UserID    = U.UserID
WHERE B.Subteam_ID = @SubteamID
  AND U.IsActive   = 1;

-- 3.3 INSERT: Add an existing member to a subteam
INSERT INTO [BELONGS_TO] (Subteam_ID, Member_ID)
VALUES (@SubteamID, @MemberID);

-- 3.4 DELETE: Remove a member from a subteam
DELETE FROM [BELONGS_TO]
WHERE Subteam_ID = @SubteamID
  AND Member_ID  = @MemberID;



-- ============================================================
-- PAGE 4: SUBTEAMS
-- ============================================================

-- Test inputs for PAGE 4
DECLARE @Subteam_ID           INT           = 1;
DECLARE @Subteam_Name         VARCHAR(100)  = 'Software';
DECLARE @Subteam_Description  VARCHAR(MAX)  = 'Responsible for the software of the robot';
DECLARE @Team_ID              INT           = 1;
DECLARE @Lead_Member_ID       INT           = 5;
DECLARE @New_Lead_Member_ID   INT           = 6;

-- 4.1 SELECT: Load all subteams, descriptions, and leads (SUBTEAM + LEADS_SUBTEAM)
SELECT S.Subteam_ID, S.Subteam_Name, S.Subteam_Description,
       U.UserID AS Lead_ID, U.First_Name, U.Last_Name
FROM [SUBTEAM] S
LEFT JOIN [LEADS_SUBTEAM] L
    ON L.Subteam_ID = S.Subteam_ID
LEFT JOIN [User] U
    ON U.UserID = L.Member_ID
ORDER BY S.Subteam_Name;


-- 4.2 INSERT: Create a new subteam (SUBTEAM) and assign lead(s) (LEADS_SUBTEAM)

-- Admin creates a subteam
INSERT INTO [SUBTEAM] (Subteam_ID, Subteam_Name, Subteam_Description, Team_ID)
VALUES (@Subteam_ID, @Subteam_Name, @Subteam_Description, @Team_ID);

-- Assign a lead to the subteam
INSERT INTO [LEADS_SUBTEAM] (Subteam_ID, Member_ID)
VALUES (@Subteam_ID, @Lead_Member_ID);


-- 4.3 UPDATE / DELETE: Edit subteam details or update/remove leads (SUBTEAM, LEADS_SUBTEAM)

-- Edit subteam details
UPDATE [SUBTEAM]
SET Subteam_Name        = @Subteam_Name,
    Subteam_Description = @Subteam_Description
WHERE Subteam_ID = @Subteam_ID;

-- Change the lead of the subteam
UPDATE [LEADS_SUBTEAM]
SET Member_ID = @New_Lead_Member_ID
WHERE Subteam_ID = @Subteam_ID
  AND Member_ID  = @Lead_Member_ID;

-- Remove a lead from the subteam
DELETE FROM [LEADS_SUBTEAM]
WHERE Subteam_ID = @Subteam_ID
  AND Member_ID  = @New_Lead_Member_ID;


-- 4.4 DELETE: Delete a subteam (clean up junction rows first)
DELETE FROM [LEADS_SUBTEAM]            WHERE Subteam_ID = @Subteam_ID;
DELETE FROM [SUBTEAM_WORKS_ON_PROJECT] WHERE Subteam_ID = @Subteam_ID;
DELETE FROM [SUBTEAM]                  WHERE Subteam_ID = @Subteam_ID;


-- ============================================================
-- PAGE 5: PROJECTS
-- ============================================================

-- 5.1 SELECT: Load all projects with assigned subteams (Internal view)
SELECT
    P.Project_ID,
    P.Project_Name,
    P.Project_Status,
    P.P_Start_Date_Day,
    P.P_Start_Date_Month,
    P.P_Start_Date_Year,
    P.Project_IsVisible,
    S.Subteam_Name
FROM PROJECT P
LEFT JOIN SUBTEAM_WORKS_ON_PROJECT SWP ON P.Project_ID = SWP.Project_ID
LEFT JOIN SUBTEAM S ON SWP.Subteam_ID = S.Subteam_ID
ORDER BY P.P_Start_Date_Year DESC, P.P_Start_Date_Month DESC, P.P_Start_Date_Day DESC;

-- 5.2 SELECT: Load public projects only (Guest view)
SELECT
    P.Project_ID,
    P.Project_Name,
    P.Project_Status,
    P.P_Start_Date_Day,
    P.P_Start_Date_Month,
    P.P_Start_Date_Year,
    S.Subteam_Name
FROM PROJECT P
LEFT JOIN SUBTEAM_WORKS_ON_PROJECT SWP ON P.Project_ID = SWP.Project_ID
LEFT JOIN SUBTEAM S ON SWP.Subteam_ID = S.Subteam_ID
WHERE P.Project_IsVisible = 1
ORDER BY P.P_Start_Date_Year DESC, P.P_Start_Date_Month DESC, P.P_Start_Date_Day DESC;

-- 5.3a SELECT: Load documents attached to a specific project
SELECT
    D.Document_ID,
    D.Document_Filename,
    D.Document_FilePath,
    D.Document_Type,
    D.Document_Fileformat,
    D.D_Upload_Date_Day,
    D.D_Upload_Date_Month,
    D.D_Upload_Date_Year,
    U.First_Name + ' ' + U.Last_Name AS UploadedBy
FROM [ATTACHED_TO] A
JOIN DOCUMENT D ON A.Document_ID = D.Document_ID
JOIN [User]   U ON D.[User_ID]   = U.UserID
WHERE A.Project_ID = @ProjectID;

-- 5.3b SELECT: Load milestones required for a specific project
SELECT
    M.mileStone_ID,
    M.title,
    M.status_,
    M.target_date,
    M.DESCRIPTION_
FROM [MILESTONE_PROJECT] MP
JOIN [MILESTONE] M ON MP.mileStone_ID = M.mileStone_ID
WHERE MP.Project_ID = @ProjectID
ORDER BY M.target_date ASC;

-- 5.4 INSERT: Create a new project & link subteam(s)
INSERT INTO PROJECT (
    Project_ID, Project_Name, Project_Status,
    P_Start_Date_Day, P_Start_Date_Month, P_Start_Date_Year, Project_IsVisible
)
VALUES (@ProjectID, 'Wind Turbine Braking System', 'In Progress', 22, 11, 2026, 1);

INSERT INTO SUBTEAM_WORKS_ON_PROJECT (Subteam_ID, Project_ID)
VALUES (@SubteamID, @ProjectID);

-- 5.5 INSERT: Upload a document & attach it to a project
INSERT INTO DOCUMENT (
    Document_ID, Document_Filename, Document_FilePath, Document_Type,
    Document_Fileformat, D_Upload_Date_Day, D_Upload_Date_Month, D_Upload_Date_Year, [User_ID]
)
VALUES (@DocumentID, 'Braking_Design.pdf', '/docs/braking_design.pdf', 'Report', 'pdf', 22, 11, 2026, @UserID);

INSERT INTO [ATTACHED_TO] (Project_ID, Document_ID)
VALUES (@ProjectID, @DocumentID);

-- 5.6 UPDATE: Edit project details, status, or visibility
UPDATE PROJECT
SET Project_Name      = 'Updated Braking System',
    Project_Status    = 'Completed',
    Project_IsVisible = 1
WHERE Project_ID = @ProjectID;

-- 5.7 DELETE: Unlink junction rows & delete project
DELETE FROM SUBTEAM_WORKS_ON_PROJECT WHERE Project_ID = @ProjectID;
DELETE FROM [ATTACHED_TO]            WHERE Project_ID = @ProjectID;
DELETE FROM [MILESTONE_PROJECT]      WHERE Project_ID = @ProjectID;
DELETE FROM PROJECT                  WHERE Project_ID = @ProjectID;



-- ============================================================
-- PAGE 6: TASK LIST & TASK DETAILS
-- ============================================================

-- 6.1a SELECT: Load Task List assigned to a specific member
SELECT
    T.Task_ID,
    T.Task_Title,
    T.Task_Status,
    T.Task_Priority,
    T.T_Due_Date_Day,
    T.T_Due_Date_Month,
    P.Project_Name,
    S.Subteam_Name
FROM TASK T
JOIN MEMBER_WORKS_ON_TASK MWT ON T.Task_ID    = MWT.Task_ID
JOIN PROJECT P                ON T.Project_ID = P.Project_ID
JOIN SUBTEAM S                ON T.Subteam_ID = S.Subteam_ID
WHERE MWT.Member_ID = @MemberID
ORDER BY T.T_Due_Date_Month ASC, T.T_Due_Date_Day ASC;

-- 6.1b SELECT: Load Task List for a specific subteam (Lead view)
SELECT
    T.Task_ID,
    T.Task_Title,
    T.Task_Status,
    T.Task_Priority,
    T.T_Due_Date_Day,
    T.T_Due_Date_Month,
    U.First_Name + ' ' + U.Last_Name AS AssignedTo
FROM TASK T
LEFT JOIN MEMBER_WORKS_ON_TASK MWT ON T.Task_ID     = MWT.Task_ID
LEFT JOIN [User] U                 ON MWT.Member_ID = U.UserID
WHERE T.Subteam_ID = @SubteamID
ORDER BY T.T_Due_Date_Month ASC, T.T_Due_Date_Day ASC;

-- 6.2a SELECT: Load full Task Details
SELECT
    T.Task_ID,
    T.Task_Title,
    T.Task_Description,
    T.Task_Deliverables,
    T.Task_Status,
    T.Task_Priority,
    T.T_Start_Date_Day,
    T.T_Start_Date_Month,
    T.T_Start_Date_Year,
    T.T_Due_Date_Day,
    T.T_Due_Date_Month,
    P.Project_Name,
    S.Subteam_Name,
    L.First_Name + ' ' + L.Last_Name AS AssignedByLead
FROM TASK T
JOIN PROJECT P ON T.Project_ID = P.Project_ID
JOIN SUBTEAM S ON T.Subteam_ID = S.Subteam_ID
LEFT JOIN [User] L ON T.Lead_Member_ID = L.UserID
WHERE T.Task_ID = @TaskID;

-- 6.2b SELECT: Load documents submitted for a task and any lead feedback on them
SELECT
    D.Document_ID,
    D.Document_Filename,
    D.Document_FilePath,
    D.Document_Type,
    F.Feedback_ID,
    F.Comment,
    F.Rating,
    F.feedback_date,
    U.First_Name + ' ' + U.Last_Name AS ReviewedBy
FROM TASK_DOCUMENT TD
JOIN DOCUMENT D ON TD.Document_ID = D.Document_ID
LEFT JOIN [FEEDBACK] F ON D.Document_ID = F.Document_ID
LEFT JOIN [User]     U ON F.UserID      = U.UserID
WHERE TD.Task_ID = @TaskID;

-- 6.2c SELECT: Load assistance requests submitted by a member
-- (Add WHERE AR.Task_ID = @TaskID once Task_ID is added to ASSISTANCE_REQUEST)
SELECT
    AR.Request_ID,
    AR.Title,
    AR.Description,
    AR.Status,
    AR.feedback_date,
    U.First_Name + ' ' + U.Last_Name AS RequestedBy
FROM [ASSISTANCE_REQUEST] AR
JOIN [User] U ON AR.UserID = U.UserID
WHERE AR.UserID = @MemberID;

-- 6.3 INSERT: Create a new task & assign member(s)
INSERT INTO TASK (
    Task_ID, Task_Title, Task_Description, Task_Deliverables,
    Task_Status, Task_Priority,
    T_Start_Date_Day, T_Start_Date_Month, T_Start_Date_Year,
    T_Due_Date_Day, T_Due_Date_Month,
    Project_ID, Subteam_ID, Lead_Member_ID
)
VALUES (
    @TaskID, 'Brake Simulink Model', 'Build friction model', 'Simulink .slx file + PDF report',
    'Pending', 'High', 22, 11, 2026, 30, 11,
    @ProjectID, @SubteamID, @LeadMemberID
);

INSERT INTO MEMBER_WORKS_ON_TASK (Member_ID, Task_ID)
VALUES (@MemberID, @TaskID);

-- 6.4 UPDATE: Toggle/update Task_Status
UPDATE TASK
SET Task_Status = 'Completed'
WHERE Task_ID = @TaskID;

-- 6.5 UPDATE: Edit task details (Lead)
UPDATE TASK
SET Task_Title        = 'Updated Brake Simulink Model',
    Task_Description  = 'Include thermal calculations',
    Task_Deliverables = 'Simulink model + report',
    Task_Priority     = 'Medium',
    T_Due_Date_Day    = 5,
    T_Due_Date_Month  = 12
WHERE Task_ID = @TaskID;

-- 6.6 DELETE: Unlink junction rows & delete task
DELETE FROM MEMBER_WORKS_ON_TASK WHERE Task_ID = @TaskID;
DELETE FROM TASK_DOCUMENT        WHERE Task_ID = @TaskID;
DELETE FROM TASK                 WHERE Task_ID = @TaskID;

-- 6.7 INSERT: Upload a document & attach to a task (Submission)
INSERT INTO DOCUMENT (
    Document_ID, Document_Filename, Document_FilePath, Document_Type,
    Document_Fileformat, D_Upload_Date_Day, D_Upload_Date_Month, D_Upload_Date_Year, [User_ID]
)
VALUES (@DocumentID, 'Brake_Model_v1.slx', '/submissions/brake_v1.slx', 'Submission', 'slx', 22, 11, 2026, @MemberID);

INSERT INTO TASK_DOCUMENT (Task_ID, Document_ID)
VALUES (@TaskID, @DocumentID);

-- 6.8 UPDATE / DELETE: Edit or delete a document
UPDATE DOCUMENT
SET Document_Filename = 'Brake_Model_Final.slx',
    Document_Type     = 'Submission'
WHERE Document_ID = @DocumentID;

DELETE FROM [FEEDBACK]    WHERE Document_ID = @DocumentID;
DELETE FROM TASK_DOCUMENT WHERE Document_ID = @DocumentID;
DELETE FROM [ATTACHED_TO] WHERE Document_ID = @DocumentID;
DELETE FROM DOCUMENT      WHERE Document_ID = @DocumentID;

-- 6.9 INSERT / UPDATE / DELETE: Manage lead feedback on a document
INSERT INTO [FEEDBACK] (Feedback_ID, Comment, Rating, feedback_date, UserID, Document_ID)
VALUES (@FeedbackID, 'Missing friction coefficient calculations.', 4, '2026-11-22', @LeadMemberID, @DocumentID);

UPDATE [FEEDBACK]
SET Comment = 'Calculations added — looks solid.',
    Rating  = 5
WHERE Feedback_ID = @FeedbackID;

DELETE FROM [FEEDBACK]
WHERE Feedback_ID = @FeedbackID;

-- 6.10 INSERT: Submit an assistance request
INSERT INTO [ASSISTANCE_REQUEST] (Request_ID, Title, Status, feedback_date, Description, UserID)
VALUES (@RequestID, 'Brake material selection', 'Pending', '2026-11-22', 'Need advice on pad thermal limits.', @MemberID);

-- 6.11 UPDATE / DELETE: Resolve or delete an assistance request
UPDATE [ASSISTANCE_REQUEST]
SET Status = 'Resolved'
WHERE Request_ID = @RequestID;

DELETE FROM [ASSISTANCE_REQUEST]
WHERE Request_ID = @RequestID;


-- ============================================================
-- PAGE 7: TIMELINE, EVENTS & TEAM HISTORY (MILESTONES)
-- ============================================================

-- 7.1a SELECT: Load timelines with linked events (add AND T.isVisible = 1 for Guests)
SELECT
    T.timeLine_ID,
    T.title AS TimelineTitle,
    T.DESCRIPTION_ AS TimelineDescription,
    E.Event_ID,
    E.Event_Title,
    E.Event_Date_Day,
    E.Event_Date_Month,
    E.Event_Date_Year
FROM [TIMELINE] T
LEFT JOIN [TIMELINE_EVENT] TE ON T.timeLine_ID = TE.timeLine_ID
LEFT JOIN EVENT E             ON TE.Event_ID   = E.Event_ID
WHERE T.isVisible = 1
ORDER BY T.timeLine_ID, E.Event_Date_Year ASC, E.Event_Date_Month ASC, E.Event_Date_Day ASC;

-- 7.1b SELECT: Load timelines with linked milestones
SELECT
    T.timeLine_ID,
    T.title AS TimelineTitle,
    M.mileStone_ID,
    M.title AS MilestoneTitle,
    M.status_,
    M.target_date
FROM [TIMELINE] T
LEFT JOIN [TIMELINE_MILESTONE] TM ON T.timeLine_ID  = TM.timeLine_ID
LEFT JOIN [MILESTONE] M           ON TM.mileStone_ID = M.mileStone_ID
WHERE T.isVisible = 1
ORDER BY T.timeLine_ID, M.target_date ASC;

-- 7.2 SELECT: Load upcoming events ordered chronologically
SELECT
    Event_ID,
    Event_Title,
    Event_Description,
    Event_Date_Day,
    Event_Date_Month,
    Event_Date_Year
FROM EVENT
ORDER BY Event_Date_Year ASC, Event_Date_Month ASC, Event_Date_Day ASC;

-- 7.3 SELECT: Load milestones filtered by date range (Team History)
SELECT
    mileStone_ID,
    title,
    status_,
    target_date,
    DESCRIPTION_
FROM [MILESTONE]
WHERE target_date BETWEEN @StartDate AND @EndDate
ORDER BY target_date ASC;

-- 7.4 INSERT: Create a timeline, event, milestone & link them
INSERT INTO [TIMELINE] (timeLine_ID, title, DESCRIPTION_, isVisible, member_ID, Admin_ID)
VALUES (@TimelineID, 'Competition Run-up', 'Key deadlines before nationals', 1, NULL, @AdminID);

INSERT INTO EVENT (Event_ID, Event_Title, Event_Description, Event_Date_Day, Event_Date_Month, Event_Date_Year, Member_ID, Admin_ID)
VALUES (@EventID, 'Weekly Control Sync', 'Review PID tuning', 25, 11, 2026, @LeadMemberID, NULL);

INSERT INTO [MILESTONE] (mileStone_ID, title, status_, target_date, DESCRIPTION_, Admin_ID)
VALUES (@MilestoneID, 'Prototype Tested', 'In Progress', '2026-12-15', 'Complete full wind tunnel test', @AdminID);

INSERT INTO [TIMELINE_EVENT] (timeLine_ID, Event_ID)
VALUES (@TimelineID, @EventID);

INSERT INTO [TIMELINE_MILESTONE] (timeLine_ID, mileStone_ID)
VALUES (@TimelineID, @MilestoneID);

-- 7.5 UPDATE: Edit a timeline, event, or milestone
UPDATE [TIMELINE]
SET title        = 'Updated Run-up Timeline',
    DESCRIPTION_ = 'Revised schedule',
    isVisible    = 1
WHERE timeLine_ID = @TimelineID;

UPDATE EVENT
SET Event_Title      = 'Updated Control Sync',
    Event_Date_Day   = 26,
    Event_Date_Month = 11,
    Event_Date_Year  = 2026
WHERE Event_ID = @EventID;

UPDATE [MILESTONE]
SET title       = 'Prototype Tested & Approved',
    status_     = 'Completed',
    target_date = '2026-12-10'
WHERE mileStone_ID = @MilestoneID;

-- 7.6 DELETE: Unlink junction tables & delete timeline, event, or milestone
DELETE FROM [TIMELINE_EVENT]     WHERE Event_ID     = @EventID;
DELETE FROM EVENT                WHERE Event_ID     = @EventID;

DELETE FROM [TIMELINE_MILESTONE] WHERE mileStone_ID = @MilestoneID;
DELETE FROM [MILESTONE_PROJECT]  WHERE mileStone_ID = @MilestoneID;
DELETE FROM [MILESTONE]          WHERE mileStone_ID = @MilestoneID;

DELETE FROM [TIMELINE_EVENT]     WHERE timeLine_ID  = @TimelineID;
DELETE FROM [TIMELINE_MILESTONE] WHERE timeLine_ID  = @TimelineID;
DELETE FROM [TIMELINE]           WHERE timeLine_ID  = @TimelineID;


-- ============================================================
-- PAGE 8: ACHIEVEMENTS, SPONSORS & GALLERY
-- ============================================================

-- 8.1 SELECT: Load public achievements (optional date range filter)
SELECT
    Achievement_ID,
    Title,
    Category,
    [Rank],
    Description,
    Achievement_date
FROM [ACHIEVEMENT]
WHERE IsVisible = 1
  AND Achievement_date BETWEEN @StartDate AND @EndDate
ORDER BY Achievement_date DESC;

-- 8.2 INSERT / UPDATE / DELETE: Manage achievements (Admin)
INSERT INTO [ACHIEVEMENT] (Achievement_ID, Category, [Rank], Title, Description, Achievement_date, IsVisible, Team_ID)
VALUES (@AchievementID, 'National Competition', '2nd Place', 'Wind Turbine Finals 2026', 'Awarded for best braking efficiency', '2026-08-15', 1, @TeamID);

UPDATE [ACHIEVEMENT]
SET Title       = 'Wind Turbine Finals 2026 (Updated)',
    [Rank]      = '1st Place',
    IsVisible   = 1
WHERE Achievement_ID = @AchievementID;

DELETE FROM [ACHIEVEMENT]
WHERE Achievement_ID = @AchievementID;

-- 8.3 SELECT: Load sponsors and their contribution details
SELECT
    S.Sponsor_ID,
    S.Sponsor_Name,
    S.Sponsor_Type,
    S.Sponsor_Logo,
    S.Email,
    S.Phone,
    S.Sponsor_Description,
    SC.Contract_Details
FROM [SPONSOR] S
LEFT JOIN [SPONSOR_CONTRIBUTION] SC ON S.Sponsor_ID = SC.Sponsor_ID
ORDER BY S.Sponsor_Name;

-- 8.4 INSERT / UPDATE / DELETE: Manage sponsors & contributions (Admin)
INSERT INTO [SPONSOR] (Sponsor_ID, Sponsor_Name, Sponsor_Type, Sponsor_Logo, Email, Phone, Sponsor_Description, Team_ID)
VALUES (@SponsorID, 'GreenPower Corp', 'Gold', '/logos/greenpower.png', 'contact@greenpower.com', '01000000000', 'Renewable energy partner', @TeamID);

INSERT INTO [SPONSOR_CONTRIBUTION] (Sponsor_ID, Contract_Details)
VALUES (@SponsorID, '50,000 EGP hardware grant for 2026 season');

UPDATE [SPONSOR]
SET Sponsor_Type        = 'Platinum',
    Sponsor_Description = 'Main competition sponsor'
WHERE Sponsor_ID = @SponsorID;

DELETE FROM [SPONSOR_CONTRIBUTION] WHERE Sponsor_ID = @SponsorID;
DELETE FROM [SPONSOR]              WHERE Sponsor_ID = @SponsorID;

-- 8.5 SELECT: Load gallery photos (DOCUMENT where Document_Type = 'Gallery')
SELECT
    Document_ID,
    Document_Filename,
    Document_FilePath,
    D_Upload_Date_Day,
    D_Upload_Date_Month,
    D_Upload_Date_Year
FROM DOCUMENT
WHERE Document_Type = 'Gallery'
ORDER BY D_Upload_Date_Year DESC, D_Upload_Date_Month DESC, D_Upload_Date_Day DESC;


-- ============================================================
-- PAGE 9: DISCUSSION PAGES & MESSAGES
-- ============================================================

-- 9.1 SELECT: Load discussion pages with associated subteams and creator
SELECT
    DP.page_ID,
    DP.title,
    DP.topic,
    DP.creation_date,
    U.First_Name + ' ' + U.Last_Name AS CreatedBy,
    S.Subteam_Name
FROM [DISCUSSION_PAGE] DP
JOIN [User] U ON DP.User_ID = U.UserID
LEFT JOIN [SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE] SADP ON DP.page_ID     = SADP.page_ID
LEFT JOIN SUBTEAM S                                    ON SADP.Subteam_ID = S.Subteam_ID
ORDER BY DP.creation_date DESC;

-- 9.2 INSERT: Create a discussion page & link subteam(s)
INSERT INTO [DISCUSSION_PAGE] (page_ID, title, topic, creation_date, User_ID)
VALUES (@PageID, 'Braking Feasibility', 'Material & cost trade-offs', '2026-11-22', @UserID);

INSERT INTO [SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE] (Subteam_ID, page_ID)
VALUES (@SubteamID, @PageID);

-- 9.3 UPDATE / DELETE: Edit or delete a discussion page
UPDATE [DISCUSSION_PAGE]
SET title = 'Braking Feasibility (Updated)',
    topic = 'Final material sign-off'
WHERE page_ID = @PageID;

DELETE FROM [MESSAGE]                               WHERE Page_ID = @PageID;
DELETE FROM [SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE] WHERE page_ID = @PageID;
DELETE FROM [DISCUSSION_PAGE]                       WHERE page_ID = @PageID;

-- 9.4 SELECT: Load all messages in a discussion page ordered by post_date
SELECT
    M.msg_ID,
    M.Content,
    M.post_date,
    U.Username,
    U.First_Name + ' ' + U.Last_Name AS SenderName
FROM [MESSAGE] M
JOIN [User] U ON M.User_ID = U.UserID
WHERE M.Page_ID = @PageID
ORDER BY M.post_date ASC, M.msg_ID ASC;

-- 9.5 INSERT: Post a new message
INSERT INTO [MESSAGE] (msg_ID, Content, post_date, User_ID, Page_ID)
VALUES (@MsgID, 'Has anyone checked the rotor clearance yet?', '2026-11-22', @UserID, @PageID);

-- 9.6 UPDATE / DELETE: Edit or delete a message
UPDATE [MESSAGE]
SET Content = 'Updated: rotor clearance looks good.'
WHERE msg_ID = @MsgID;

DELETE FROM [MESSAGE]
WHERE msg_ID = @MsgID;



-- Test inputs for ADMIN PAGE
DECLARE @UserID           INT          = 10;
DECLARE @Username         VARCHAR(50)  = 'new_member01';
DECLARE @First_Name       VARCHAR(50)  = 'Sara';
DECLARE @Last_Name        VARCHAR(50)  = 'Ahmed';
DECLARE @Password         VARCHAR(50)  = 'tempPass123';
DECLARE @IsActive         BIT          = 1;
DECLARE @Enrollment_Year  INT          = 2024;
DECLARE @Email            VARCHAR(100) = 'sara.ahmed@example.com';
DECLARE @Major            VARCHAR(50)  = 'Mechatronics';
DECLARE @Join_Day         INT          = 22;
DECLARE @Join_Month       INT          = 11;
DECLARE @Join_Year        INT          = 2026;
DECLARE @Appointment_Date DATE         = '2026-11-22';
DECLARE @Leave_Date       DATE         = '2026-11-22';

DECLARE @Project_ID       INT          = 1;
DECLARE @timeLine_ID      INT          = 1;
DECLARE @Achievement_ID   INT          = 1;
DECLARE @IsVisible        BIT          = 1;

-- PAGE 10: ADMIN USER & VISIBILITY MANAGEMENT
-- 10.1 INSERT: Register a new user ([User]) and assign disjoint role (ADMIN or MEMBER)

-- Admin inserts the account of the new user
INSERT INTO [User] (
    UserID, Username, First_Name, Last_Name, Password_,
    IsActive, Enrollment_Year, Email, Major,
    Join_Day, Join_Month, Join_Year
)
VALUES (
    @UserID, @Username, @First_Name, @Last_Name, @Password,
    @IsActive, @Enrollment_Year, @Email, @Major,
    @Join_Day, @Join_Month, @Join_Year
);

-- Run if new user is a admin
INSERT INTO [ADMIN] (UserID, Appointment_Date, Admin_Leave_Date)
VALUES (@UserID, @Appointment_Date, NULL);

-- Run if new user is a member
INSERT INTO [MEMBER] (UserID, Team_join_date, Leave_Date)
VALUES (@UserID, '2026-11-22', NULL);


-- Admin Edits user profile details
UPDATE [User]
SET First_Name      = @First_Name,
    Last_Name       = @Last_Name,
    Email           = @Email,
    Major           = @Major,
    Enrollment_Year = @Enrollment_Year
WHERE UserID = @UserID;

-- Deactivate user account
UPDATE [User]
SET IsActive = 0
WHERE UserID = @UserID;

-- Record leave date if user is an ADMIN
UPDATE [ADMIN]
SET Admin_Leave_Date = @Leave_Date
WHERE UserID = @UserID;

-- Record leave date if user is a MEMBER
UPDATE [MEMBER]
SET Leave_Date = @Leave_Date
WHERE UserID = @UserID;

-- Deleting the admin or member type user
DELETE FROM [ADMIN]  WHERE UserID = @UserID;
DELETE FROM [MEMBER] WHERE UserID = @UserID;
DELETE FROM [User]   WHERE UserID = @UserID;


-- 10.4 UPDATE: Toggle visibility flags (Project_IsVisible, TIMELINE.isVisible, ACHIEVEMENT.IsVisible)
-- Toggle Project visibility for Guests
UPDATE PROJECT
SET Project_IsVisible = @IsVisible
WHERE Project_ID = @Project_ID;

-- Toggle Timeline visibility for Guests
UPDATE TIMELINE
SET isVisible = @IsVisible
WHERE timeLine_ID = @timeLine_ID;

-- Toggle Achievement visibility for Guests (spelled IsVisable in your sheet; change to IsVisible if renamed in DDL)
UPDATE ACHIEVEMENT
SET IsVisable = @IsVisible
WHERE Achievement_ID = @Achievement_ID;

ROLLBACK TRANSACTION; 

