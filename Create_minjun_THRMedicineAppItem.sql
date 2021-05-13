IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineAppItem' AND xtype = 'U' )
    Drop table minjun_THRMedicineAppItem

CREATE TABLE minjun_THRMedicineAppItem
(
    CompanySeq		INT 	 NOT NULL, 
    AppSeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    MedSeq		INT 	 NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKminjun_THRMedicineAppItem PRIMARY KEY CLUSTERED (CompanySeq ASC, AppSeq ASC, Serl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineAppItemLog' AND xtype = 'U' )
    Drop table minjun_THRMedicineAppItemLog

CREATE TABLE minjun_THRMedicineAppItemLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    AppSeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    MedSeq		INT 	 NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_THRMedicineAppItemLog ON minjun_THRMedicineAppItemLog (LogSeq)
go