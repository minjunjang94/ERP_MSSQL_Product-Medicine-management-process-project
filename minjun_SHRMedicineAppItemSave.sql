IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineAppItemSave' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineAppItemSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ��û:ItemSave_minjun
 �ۼ��� - '2020-03-26
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineAppItemSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@SerlName       NVARCHAR(MAX)   -- Serl��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_THRMedicineAppItem'
           ,@SeqName        = N'AppSeq'
           ,@SerlName       = N'Serl'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_THRMedicineAppItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#_THRMedicineAppItem' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#_THRMedicineAppItem'       ,		-- �ӽ� ���̺��      
                  'AppSeq, Serl'     ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineAppItem WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #_THRMedicineAppItem               AS M
                JOIN minjun_THRMedicineAppItem          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.AppSeq      = M.AppSeq
                                                           AND  A.Serl     = M.Serl
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineAppItem WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  minjun_THRMedicineAppItem 
           SET  
                 MedSeq         =   M.MedSeq  
                ,Qty            =   M.Qty     


          FROM  #_THRMedicineAppItem          AS M
                JOIN minjun_THRMedicineAppItem          AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                           AND  A.AppSeq      = M.AppSeq
                                                           AND  A.Serl     = M.Serl
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineAppItem WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_THRMedicineAppItem (
                CompanySeq
                ,AppSeq
                ,Serl
                ,MedSeq
                ,Qty

        )
        SELECT  
                 @CompanySeq
                 ,M.AppSeq
                 ,M.Serl
                 ,M.MedSeq
                 ,M.Qty

          FROM  #_THRMedicineAppItem          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #_THRMedicineAppItem
   
RETURN  
 /***************************************************************************************************************/