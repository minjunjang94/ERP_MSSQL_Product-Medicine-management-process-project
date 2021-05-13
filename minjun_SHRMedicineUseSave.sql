IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseSave' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ����Է�:Save_minjujn
 �ۼ��� - '2020-03-27
 �ۼ��� - �����
 ������ -  
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseSave
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
           ,@ItemTblName    NVARCHAR(MAX)   -- ��Table��
           ,@SeqName        NVARCHAR(MAX)   -- Seq��
           ,@TblColumns     NVARCHAR(MAX)
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName        = N'minjun_THRMedicineUse'
           ,@ItemTblName    = N'minjun_THRMedicineUseItem'
           ,@SeqName        = N'UseSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #_THRMedicineUseItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#_THRMedicineUseItem' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#_THRMedicineUseItem'    ,		-- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineUseItem WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- ���������̺� �α� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
    	SELECT @TblColumns = dbo._FGetColumnsForLog(@ItemTblName)
        
        -- �����α� �����
        EXEC _SCOMDELETELog @CompanySeq   ,      
                            @UserSeq      ,      
                            @ItemTblName  ,		-- ���̺��      
                            '#_THRMedicineUseItem'       ,		-- �ӽ� ���̺��      
                            @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                            @TblColumns   ,   -- ���̺� ��� �ʵ��
                            ''            ,
                            @PgmSeq

        IF @@ERROR <> 0 RETURN

        -- Detail���̺� ������ ����
        DELETE  A
          FROM  #_THRMedicineUseItem                 AS M
                JOIN minjun_THRMedicineUseItem   AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                   AND  A.UseSeq        = M.UseSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
        
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #_THRMedicineUseItem                 AS M
                JOIN minjun_THRMedicineUse       AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                   AND  A.UseSeq        = M.UseSeq
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
           SET  UseDate         = M.UseDate     
               ,UseNo           = M.UseNo       
               ,EmpSeq          = M.EmpSeq      
               ,DeptSeq         = M.DeptSeq     
               ,Remark          = M.Remark      
               ,LastUserSeq     = @UserSeq 
               ,LastDateTime    = GETDATE()
               ,PgmSeq          = @PgmSeq      
          FROM  #_THRMedicineUseItem                 AS M
                JOIN minjun_THRMedicineUse       AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                                   AND  A.UseSeq        = M.UseSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineUseItem WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO minjun_THRMedicineUse (
            CompanySeq
           ,UseSeq
           ,UseDate
           ,UseNo
           ,EmpSeq
           ,DeptSeq
           ,Remark
           ,LastUserSeq
           ,LastDateTime
           ,PgmSeq
        )
        SELECT  @CompanySeq
               ,M.UseSeq
               ,M.UseDate
               ,M.UseNo
               ,M.EmpSeq
               ,M.DeptSeq
               ,M.Remark
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