/* Create Data Base */
CREATE DATABASE compeition_team_manager

/* MAIN TABLES */

/* User Table */
CREATE TABLE [User]
(
UserID INT,
Username varchar (50) UNIQUE,
First_Name varchar (50) NOT NULL,
Last_Name varchar (50) NOT NULL,
Password_ varchar (50) NOT NULL,
IsActive BIT,
Enrollment_Year INT,
Email varchar (100) NOT NULL UNIQUE,
Major varchar (50),
Join_Day INT,
Join_Month INT,
Join_year INT,

PRIMARY KEY (UserID)
);



/* Admin Table */
CREATE TABLE [Admin]
(
UserID INT,
Appointment_Date Date,
Admin_Leave_Date Date,

PRIMARY KEY (UserID),

Foreign Key (UserID) REFERENCES [USER] (UserID)
);


/* Member Table */
CREATE TABLE [MEMBER]
(
UserID INT,
Team_join_date DATE,
Leave_Date DATE,

PRIMARY KEY (UserID),

Foreign Key (UserID) REFERENCES [USER] (UserID)
);

/* Team Table */
CREATE TABLE [TEAM]
(
Team_ID INT,
Team_Name varchar (100) NOT NULL,
Team_Mission varchar (MAX),
Team_Vision varchar (MAX),
Address varchar (255),
Email varchar (100),
Phone varchar (50),

PRIMARY KEY (Team_ID)

);

/* Subteam table */
CREATE TABLE SUBTEAM (
    Subteam_ID          INT PRIMARY KEY,
    Subteam_Name        VARCHAR(100) NOT NULL,
    Subteam_Description TEXT,
    Team_ID             INT NOT NULL,
    FOREIGN KEY (Team_ID) REFERENCES TEAM(Team_ID)
);

/* Project table */
CREATE TABLE PROJECT (
    Project_ID         INT PRIMARY KEY,
    Project_Name       VARCHAR(150) NOT NULL,
    Project_Status     VARCHAR(30),
    P_Start_Date_Day   INT,
    P_Start_Date_Month INT,
    P_Start_Date_Year  INT,
    Project_IsVisible  BIT DEFAULT 1
);

/* Task table */
CREATE TABLE TASK (
    Task_ID            INT PRIMARY KEY,
    Task_Title         VARCHAR(150) NOT NULL,
    Task_Description   TEXT,
    Task_Deliverables  TEXT,
    Task_Status        VARCHAR(30),
    Task_Priority      VARCHAR(20),
    T_Start_Date_Day   INT,
    T_Start_Date_Month INT,
    T_Start_Date_Year  INT,
    T_Due_Date_Day     INT,
    T_Due_Date_Month   INT,
    Project_ID         INT NOT NULL,
    Subteam_ID         INT NOT NULL,
    Lead_Member_ID     INT,
    FOREIGN KEY (Project_ID)     REFERENCES PROJECT(Project_ID),
    FOREIGN KEY (Subteam_ID)     REFERENCES SUBTEAM(Subteam_ID),
    FOREIGN KEY (Lead_Member_ID) REFERENCES MEMBER(UserID)
);

/* Document table */
CREATE TABLE DOCUMENT (
    Document_ID         INT PRIMARY KEY,
    Document_Filename   VARCHAR(255) NOT NULL,
    Document_FilePath   VARCHAR(500),
    Document_Type       VARCHAR(50),
    Document_Fileformat VARCHAR(20),
    D_Upload_Date_Day   INT,
    D_Upload_Date_Month INT,
    D_Upload_Date_Year  INT,
    [User_ID]             INT NOT NULL,
    FOREIGN KEY ([User_ID]) REFERENCES [USER](UserID)
);

/* Event table */
CREATE TABLE EVENT (
    Event_ID          INT PRIMARY KEY,
    Event_Title       VARCHAR(150) NOT NULL,
    Event_Description TEXT,
    Event_Date_Day    INT,
    Event_Date_Month  INT,
    Event_Date_Year   INT,
    Member_ID         INT,
    Admin_ID          INT,
    FOREIGN KEY (Member_ID) REFERENCES MEMBER(UserID),
    FOREIGN KEY (Admin_ID)  REFERENCES ADMIN(UserID)
);

/* Timeline table */
CREATE TABLE [TIMELINE]
(
    timeLine_ID INT,
    title VARCHAR(500) NOT NULL,
    DESCRIPTION_ VARCHAR(MAX),
    isVisible BIT NOT NULL DEFAULT 1,
    member_ID INT,
    Admin_ID INT,

    PRIMARY KEY (timeLine_ID),
    FOREIGN KEY (Member_ID) REFERENCES [MEMBER](UserID),
    FOREIGN KEY (Admin_ID)  REFERENCES [ADMIN](UserID)

);

/* Milestone table */
CREATE TABLE [MILESTONE]
(
    mileStone_ID INT,
    title VARCHAR(500) NOT NULL,
    status_ VARCHAR(250) NOT NULL,
    target_date DATE,
    DESCRIPTION_ VARCHAR(MAX),
    Admin_ID INT NOT NULL,

    PRIMARY KEY (mileStone_ID),
    FOREIGN KEY (Admin_ID)  REFERENCES [ADMIN](UserID)

);

/* Discussion_page table */
CREATE TABLE [DISCUSSION_PAGE]
(
    page_ID INT,
    title VARCHAR(500) NOT NULL,
    topic VARCHAR(MAX) NOT NULL,
    creation_date DATE,
    User_ID INT,

    PRIMARY KEY (page_ID),
    FOREIGN KEY (User_ID)  REFERENCES [User](UserID)

);

/* Message table */
CREATE TABLE [MESSAGE]
(
    msg_ID INT,
    Content VARCHAR(MAX) NOT NULL,
    post_date DATE,
    User_ID INT NOT NULL,
    Page_ID INT NOT NULL,

    PRIMARY KEY (msg_ID),
    FOREIGN KEY (User_ID)  REFERENCES [User](UserID),
    FOREIGN KEY (Page_ID)  REFERENCES [DISCUSSION_PAGE](Page_ID)

);

/* Feedback table */
CREATE TABLE [FEEDBACK]
(
    Feedback_ID INT,
    Comment VARCHAR(MAX),
    Rating INT,
    feedback_date DATE,
    UserID INT,
    Document_ID INT,

    PRIMARY KEY (Feedback_ID),
    FOREIGN KEY (UserID)      REFERENCES [MEMBER](UserID),
    FOREIGN KEY (Document_ID) REFERENCES [DOCUMENT](Document_ID)
);

/* Assistance_Request table */
CREATE TABLE [ASSISTANCE_REQUEST]
(
  
    Request_ID INT,
    Status VARCHAR(100),
    feedback_date DATE,
    Description VARCHAR(MAX),
    UserID INT,
    PRIMARY KEY (Request_ID),
    FOREIGN KEY (UserID) REFERENCES [MEMBER](UserID)
);


/* Achievement table */
CREATE TABLE [ACHIEVEMENT]
(
    Achievement_ID INT,
    Title VARCHAR(500),
    Description VARCHAR(MAX),
    feedback_date DATE,
    Rank VARCHAR(100),
    Placement_Rank VARCHAR(100),
    Placement_Category VARCHAR(100),

    PRIMARY KEY (Achievement_ID)
);


/* Sponsor table */

CREATE TABLE [SPONSOR]
(
    Sponsor_ID INT,
    Sponsor_Name VARCHAR(255),
    Sponsor_Type VARCHAR(100),
    Sponsor_Logo VARCHAR(500),
    Email VARCHAR(255),
    Phone VARCHAR(20),
    Sponsor_Description VARCHAR(MAX),
    Team_ID INT,

    PRIMARY KEY (Sponsor_ID),
    FOREIGN KEY (Team_ID) REFERENCES [TEAM](Team_ID)
);
CREATE TABLE [SPONSOR_CONTRACT_DETAILS]
(
    Sponsor_ID INT,
    Contract_Details VARCHAR(MAX),

    PRIMARY KEY (Sponsor_ID, Contract_Details),
    FOREIGN KEY (Sponsor_ID) REFERENCES [SPONSOR](Sponsor_ID)
);


/* Relational Tables TABLES */

/* SUBTEAM_WORKS_ON_PROJECT */
CREATE TABLE SUBTEAM_WORKS_ON_PROJECT (
    Subteam_ID INT NOT NULL,
    Project_ID INT NOT NULL,
    PRIMARY KEY (Subteam_ID, Project_ID),
    FOREIGN KEY (Subteam_ID) REFERENCES SUBTEAM(Subteam_ID),
    FOREIGN KEY (Project_ID) REFERENCES PROJECT(Project_ID)
);
/* BELONGS_TO */
CREATE TABLE [PROJECT_DOCUMENT]
(
    Project_ID INT,
    Document_ID INT,

    PRIMARY KEY (Project_ID, Document_ID),

    FOREIGN KEY (Project_ID)
        REFERENCES [PROJECT](ProjectID),

    FOREIGN KEY (Document_ID)
        REFERENCES [DOCUMENT](DocumentID)
);

/* MEMBER_WORKS_ON_TASK */
CREATE TABLE MEMBER_WORKS_ON_TASK (
    Member_ID INT NOT NULL,
    Task_ID   INT NOT NULL,
    PRIMARY KEY (Member_ID, Task_ID),
    FOREIGN KEY (Member_ID) REFERENCES MEMBER(UserID),
    FOREIGN KEY (Task_ID)   REFERENCES TASK(Task_ID)
);

/* SPONSOR_CONTRIBUTION */

/* LEADS_SUBTEAM */
CREATE TABLE LEADS_SUBTEAM (
    Subteam_ID INT NOT NULL,
    Member_ID  INT NOT NULL,
    PRIMARY KEY (Subteam_ID, Member_ID),
    FOREIGN KEY (Subteam_ID) REFERENCES SUBTEAM(Subteam_ID),
    FOREIGN KEY (Member_ID)  REFERENCES MEMBER(UserID)
);

/* ATTACHED_TO */

/* TASK_DOCUMENT */
CREATE TABLE TASK_DOCUMENT (
    Task_ID     INT NOT NULL,
    Document_ID INT NOT NULL,
    PRIMARY KEY (Task_ID, Document_ID),
    FOREIGN KEY (Task_ID)     REFERENCES TASK(Task_ID),
    FOREIGN KEY (Document_ID) REFERENCES DOCUMENT(Document_ID)
    );

/* MILESTONE_PROJECT */

/* TIMELINE_EVENT */

/* TIMELINE_MILESTONE */

/* SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE */
