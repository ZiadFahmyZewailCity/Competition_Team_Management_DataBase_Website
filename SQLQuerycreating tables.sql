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