IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineUseItem' AND xtype = 'U' )
    Drop table minjun_THRMedicineUseItem

CREATE TABLE minjun_THRMedicineUseItem
(
    CompanySeq		INT 	 NOT NULL, 
    UseSeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    MedSeq		INT 	 NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    ProgFromTableSeq		INT 	 NULL, 
    ProgFromSeq		INT 	 NULL, 
    ProgFromSerl		INT 	 NULL, 
    ProgFromSubSerl		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL, 
CONSTRAINT PKminjun_THRMedicineUseItem PRIMARY KEY CLUSTERED (CompanySeq ASC, UseSeq ASC, Serl ASC)

)


IF EXISTS (SELECT * FROM Sysobjects where Name = 'minjun_THRMedicineUseItemLog' AND xtype = 'U' )
    Drop table minjun_THRMedicineUseItemLog

CREATE TABLE minjun_THRMedicineUseItemLog
(
    LogSeq		INT IDENTITY(1,1) NOT NULL, 
    LogUserSeq		INT NOT NULL, 
    LogDateTime		DATETIME NOT NULL, 
    LogType		NCHAR(1) NOT NULL, 
    LogPgmSeq		INT NULL, 
    CompanySeq		INT 	 NOT NULL, 
    UseSeq		INT 	 NOT NULL, 
    Serl		INT 	 NOT NULL, 
    MedSeq		INT 	 NULL, 
    Qty		DECIMAL(19,5) 	 NULL, 
    ProgFromTableSeq		INT 	 NULL, 
    ProgFromSeq		INT 	 NULL, 
    ProgFromSerl		INT 	 NULL, 
    ProgFromSubSerl		INT 	 NULL, 
    LastUserSeq		INT 	 NULL, 
    LastDateTime		DATETIME 	 NULL, 
    PgmSeq		INT 	 NULL
)

CREATE UNIQUE CLUSTERED INDEX IDXTempminjun_THRMedicineUseItemLog ON minjun_THRMedicineUseItemLog (LogSeq)
go