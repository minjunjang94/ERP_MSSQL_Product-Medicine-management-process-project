IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineApp' AND xtype = 'U' )
    Drop table minjun_THRMedicineApp

CREATE TABLE minjun_THRMedicineApp
(
    CompanySeq		INT 	 NOT NULL, 
    AppSeq		INT 	 NOT NULL, 
    AppDate		NCHAR(8) 	 NULL, 
    AppNo		NVARCHAR(50) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    DeptSeq		INT 	 NULL, 
    Reason		NVARCHAR(1000) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKminjun_THRMedicineApp PRIMARY KEY CLUSTERED (CompanySeq ASC, AppSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineAppLog' AND xtype = 'U' )
    Drop table minjun_THRMedicineAppLog

CREATE TABLE minjun_THRMedicineAppLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    AppSeq		INT 	 NOT NULL, 
    AppDate		NCHAR(8) 	 NULL, 
    AppNo		NVARCHAR(50) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    DeptSeq		INT 	 NULL, 
    Reason		NVARCHAR(1000) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_THRMedicineAppLog ON minjun_THRMedicineAppLog (LogSeq)
go