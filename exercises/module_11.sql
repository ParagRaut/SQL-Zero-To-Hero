/*==============================================================
  Module 11 — Constraints & Data Integrity
  Topics: PRIMARY KEY, FOREIGN KEY (+cascade), UNIQUE, CHECK,
          DEFAULT, NOT NULL, referential integrity, orphans,
          surrogate vs natural keys.
  --------------------------------------------------------------
  Practice in the sandbox schema. Clean up at the end.
  ==============================================================*/

USE TechShop;
GO
IF SCHEMA_ID('sandbox') IS NULL EXEC('CREATE SCHEMA sandbox');
GO

-- 11.1  Parent table with a PRIMARY KEY and a UNIQUE constraint.
IF OBJECT_ID('sandbox.Club') IS NOT NULL DROP TABLE sandbox.Club;
GO
CREATE TABLE sandbox.Club
(
    ClubID   INT IDENTITY(1,1) CONSTRAINT PK_Club PRIMARY KEY,
    ClubName NVARCHAR(100) NOT NULL CONSTRAINT UQ_Club_Name UNIQUE
);
GO

-- 11.2  Child table with a FOREIGN KEY, CHECK, DEFAULT and NOT NULL.
IF OBJECT_ID('sandbox.Member') IS NOT NULL DROP TABLE sandbox.Member;
GO
CREATE TABLE sandbox.Member
(
    MemberID  INT IDENTITY(1,1) CONSTRAINT PK_Member PRIMARY KEY,
    ClubID    INT NOT NULL
        CONSTRAINT FK_Member_Club REFERENCES sandbox.Club(ClubID)
        ON DELETE CASCADE,                       -- delete members with the club
    FullName  NVARCHAR(100) NOT NULL,
    Age       INT NOT NULL
        CONSTRAINT CK_Member_Age CHECK (Age >= 0 AND Age < 150),
    JoinedOn  DATE NOT NULL CONSTRAINT DF_Member_JoinedOn DEFAULT (CAST(SYSDATETIME() AS DATE))
);
GO

-- 11.3  Insert valid data.
INSERT INTO sandbox.Club (ClubName) VALUES ('Chess'), ('Robotics');
INSERT INTO sandbox.Member (ClubID, FullName, Age) VALUES (1, 'Maya', 21);

-- 11.4  Watch the constraints fire (each of these should ERROR — try them one by one).
-- Duplicate club name (UNIQUE):
-- INSERT INTO sandbox.Club (ClubName) VALUES ('Chess');
-- Bad age (CHECK):
-- INSERT INTO sandbox.Member (ClubID, FullName, Age) VALUES (1, 'Bad', 999);
-- Orphan child — no such ClubID (FOREIGN KEY):
-- INSERT INTO sandbox.Member (ClubID, FullName, Age) VALUES (999, 'Ghost', 30);

-- 11.5  ON DELETE CASCADE in action — deleting a club removes its members.
-- DELETE FROM sandbox.Club WHERE ClubID = 1;   -- Maya goes too.

/*  Surrogate vs natural keys:
    - Surrogate: system-generated (IDENTITY ClubID). Stable, meaningless, compact.
    - Natural:   real-world unique value (e.g., Email). Meaningful but can change.
    TechShop uses surrogate PKs + a UNIQUE natural key where useful
    (e.g., Customers.Email is UNIQUE).                                      */

/*---------------- YOUR TURN ----------------
  a) In sandbox, create a Team table (TeamID PK, TeamName UNIQUE NOT NULL).
  b) Create a Player table with FK to Team (ON DELETE CASCADE), a CHECK that
     JerseyNumber is between 1 and 99, and a DEFAULT SignedOn date.
  c) Insert a team + two players.
  d) Try to insert a player with JerseyNumber = 100 and note the error.
  e) Delete the team and confirm the players are gone too.
-------------------------------------------------*/

-- a)


-- b)


-- c)


-- d)


-- e)


-- Clean up:
-- DROP TABLE IF EXISTS sandbox.Player;  DROP TABLE IF EXISTS sandbox.Team;
-- DROP TABLE IF EXISTS sandbox.Member;  DROP TABLE IF EXISTS sandbox.Club;

/*==============================================================
  Solutions
  --------------------------------------------------------------
  a) CREATE TABLE sandbox.Team (
        TeamID   INT IDENTITY(1,1) PRIMARY KEY,
        TeamName NVARCHAR(100) NOT NULL UNIQUE);
  b) CREATE TABLE sandbox.Player (
        PlayerID     INT IDENTITY(1,1) PRIMARY KEY,
        TeamID       INT NOT NULL REFERENCES sandbox.Team(TeamID) ON DELETE CASCADE,
        FullName     NVARCHAR(100) NOT NULL,
        JerseyNumber INT NOT NULL CHECK (JerseyNumber BETWEEN 1 AND 99),
        SignedOn     DATE NOT NULL DEFAULT (CAST(SYSDATETIME() AS DATE)));
  c) INSERT INTO sandbox.Team (TeamName) VALUES ('Falcons');
     INSERT INTO sandbox.Player (TeamID, FullName, JerseyNumber)
     VALUES (1, 'Sam', 7), (1, 'Lee', 10);
  d) INSERT INTO sandbox.Player (TeamID, FullName, JerseyNumber)
     VALUES (1, 'Nope', 100);   -- violates CK constraint
  e) DELETE FROM sandbox.Team WHERE TeamName = 'Falcons'; -- players cascade-deleted
  ==============================================================*/
