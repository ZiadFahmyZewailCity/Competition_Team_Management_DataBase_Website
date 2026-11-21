CREATE TABLE [User]
(
UserID INT,
Username varchar (50),
First_Name varchar (50),
Last_Name varchar (50),
Password_ varchar (50),
IsActive BIT,
Enrollment_Year INT,
Email varchar (50),
Major varchar (50),
Join_Day INT,
Join_Month INT,
Join_year INT,

PRIMARY KEY (UserID,Username)
);




CREATE TABLE [Admin]
(
UserID INT,
Username varchar (50),
Appointment_Date Date,
Admin_Leave_Date Date,

PRIMARY KEY (UserID,Username),

Foreign Key (UserID,Username)
REFERENCES [USER] (UserID,Username)
);





CREATE TABLE [MEMBER]
(
UserID INT,
Username varchar (50),
Team_Join_Day INT,
Team_Join_Month INT,
Team_Join_Year INT,
Leave_Date DATE,

PRIMARY KEY (UserID,Username),

Foreign Key (UserID,Username)
REFERENCES [USER] (UserID,Username)
);



CREATE TABLE [TEAM]
(
Team_ID INT,
Team_Name varchar (50),
Team_Mission varchar (50),
Team_Vision varchar (50),
Address varchar (50),
Email varchar (50),
Phone varchar (50),

PRIMARY KEY (Team_ID,Team_Name)

);





CREATE TABLE [User_PhoneNumber]
(
UserID INT,
Username VARCHAR(50),
PhoneNumber VARCHAR(50),

PRIMARY KEY (UserID,Username,PhoneNumber),

Foreign Key (UserID,Username)
REFERENCES [USER] (UserID,Username)

);

SELECT* FROM[USER];
SELECT* FROM[Admin];
SELECT* FROM[MEMBER];
SELECT* FROM[TEAM];


/*

CREATE TABLE [ORGANIZES_EVENT]
(
TEAM_ID INT,
EVENT_ID INT,

PRIMARY KEY (TEAM_ID,EVENT_ID),

Foreign Key (TEAM_ID) REFERENCES [TEAM] (TEAM_ID),

Foreign Key (EVENT_ID) REFERENCES [EVENT] (EVENT_ID)

);

CREATE TABLE [SUBTEAM_WORKS_ON_PROJECT]
(
Subteam_ID INT,
Project_ID INT,

PRIMARY KEY (Subteam_ID,Project_ID),

Foreign Key (Subteam_ID) REFERENCES [SUBTEAM] (Subteam_ID),

Foreign Key (Project_ID) REFERENCES [PROJECT] (Project_ID)

);


SELECT* FROM[ORGANIZES_EVENT];
SELECT* FROM[SUBTEAM_WORKS_ON_PROJECT];
*/

