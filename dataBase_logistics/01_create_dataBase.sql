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


/* Project table */


/* Task table */


/* Document table */


/* Event table */


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


/* Assistance_Request table */


/* Achievement table */


/* Sponsor table */


/* Relational Tables TABLES */

/* SUBTEAM_WORKS_ON_PROJECT */

/* BELONGS_TO */

/* MEMBER_WORKS_ON_TASK */

/* SPONSOR_CONTRIBUTION */

/* LEADS_SUBTEAM */

/* ATTACHED_TO */

/* TASK_DOCUMENT */

/* MILESTONE_PROJECT */

/* TIMELINE_EVENT */

/* TIMELINE_MILESTONE */

/* SUBTEAM_ASSOCIATED_TO_DISCUSSION_PAGE */
