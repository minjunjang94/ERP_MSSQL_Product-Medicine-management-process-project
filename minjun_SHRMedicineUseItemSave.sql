IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseItemSave' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseItemSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ����Է�:ItemSave_minjun
 �ۼ��� - '2020-03-27
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseItemSave
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
    SELECT  @TblName        = N'minjun_THRMedicineUseItem'
           ,@SeqName        = N'UseSeq'
           ,@SerlName       = N'Serl'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_THRMedicineUseItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#_THRMedicineUseItem' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#_THRMedicineUseItem'       ,		-- �ӽ� ���̺��      
                  'UseSeq, Serl'     ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineUseItem WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #_THRMedicineUseItem                 AS M
                JOIN minjun_THRMedicineUseItem       AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.UseSeq        = M.UseSeq
                                                                       AND  A.Serl          = M.Serl
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineUseItem WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET  MedSeq              = M.MedSeq          
               ,Qty                 = M.Qty             
               ,LastUserSeq         = @UserSeq     
               ,LastDateTime        = GETDATE()
               ,PgmSeq              = @PgmSeq          
          FROM  #_THRMedicineUseItem                 AS M
                JOIN minjun_THRMedicineUseItem       AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                       AND  A.UseSeq        = M.UseSeq
                                                                       AND  A.Serl          = M.Serl
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineUseItem WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_THRMedicineUseItem (
            CompanySeq
           ,UseSeq
           ,Serl
           ,MedSeq
           ,Qty
           ,LastUserSeq
           ,LastDateTime
           ,PgmSeq
        )
        SELECT  @CompanySeq
               ,M.UseSeq
               ,M.Serl
               ,M.MedSeq
               ,M.Qty
               ,@UserSeq
               ,GETDATE()
               ,@PgmSeq
          FROM  #_THRMedicineUseItem          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    
    SELECT * FROM #_THRMedicineUseItem
   
RETURN  
 /***************************************************************************************************************/