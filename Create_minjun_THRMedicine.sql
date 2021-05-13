IF EXISTS (SELECT * FROM Sysobjects where Name = 'MINJUN_THRMedicine' AND xtype = 'U' )
    Drop table MINJUN_THRMedicine

CREATE TABLE MINJUN_THRMedicine
(
    CompanySeq		INT 	 NOT NULL, 
    MedSeq		INT 	 NOT NULL, 
    MedName		NVARCHAR(100) 	 NULL, 
    MedNo		NVARCHAR(50) 	 NULL, 
    RegDate		NCHAR(8) 	 NULL, 
    ExpDate		NCHAR(8) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    DeptSeq		INT 	 NULL, 
    Caution		NVARCHAR(MAX) 	 NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    IsNotUse		NCHAR(1) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKMINJUN_THRMedicine PRIMARY KEY CLUSTERED (CompanySeq ASC, MedSeq ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'MINJUN_THRMedicineLog' AND xtype = 'U' )
    Drop table MINJUN_THRMedicineLog

CREATE TABLE MINJUN_THRMedicineLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    MedSeq		INT 	 NOT NULL, 
    MedName		NVARCHAR(100) 	 NULL, 
    MedNo		NVARCHAR(50) 	 NULL, 
    RegDate		NCHAR(8) 	 NULL, 
    ExpDate		NCHAR(8) 	 NULL, 
    EmpSeq		INT 	 NULL, 
    DeptSeq		INT 	 NULL, 
    Caution		NVARCHAR(MAX) 	 NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    IsNotUse		NCHAR(1) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempMINJUN_THRMedicineLog ON MINJUN_THRMedicineLog (LogSeq)

go