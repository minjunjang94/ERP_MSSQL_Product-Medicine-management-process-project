IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineUse' AND xtype = 'U' )
    Drop table minjun_THRMedicineUse

CREATE TABLE minjun_THRMedicineUse
(
    CompanySeq		INT 	 NOT NULL, 
    UseSeq		INT 	 NOT NULL, 
    UseDate		NCHAR(8) 	 NULL, 
    UseNo		NVARCHAR(50) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    DeptSeq		INT 	 NULL, 
    Remark		NVARCHAR(1000) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKminjun_THRMedicineUse PRIMARY KEY CLUSTERED (CompanySeq ASC, UseSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineUseLog' AND xtype = 'U' )
    Drop table minjun_THRMedicineUseLog

CREATE TABLE minjun_THRMedicineUseLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    UseSeq		INT 	 NOT NULL, 
    UseDate		NCHAR(8) 	 NULL, 
    UseNo		NVARCHAR(50) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    DeptSeq		INT 	 NULL, 
    Remark		NVARCHAR(1000) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_THRMedicineUseLog ON minjun_THRMedicineUseLog (LogSeq)
go