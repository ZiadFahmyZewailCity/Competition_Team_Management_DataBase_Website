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

