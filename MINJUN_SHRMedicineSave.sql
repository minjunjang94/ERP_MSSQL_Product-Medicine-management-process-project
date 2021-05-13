IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineSave' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineSave
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ���:Save_MINJUN
 �ۼ��� - '2020.03.25
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineSave
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
    SELECT  @TblName        = N'MINJUN_THRMedicine'
           ,@ItemTblName    = N''
           ,@SeqName        = N'MedSeq'

    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #THRMedicine (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#THRMedicine' 
    
    IF @@ERROR <> 0 RETURN
      
    -- �α����̺� �����(������ �Ķ���ʹ� �ݵ�� ���ٷ� ������)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- ���̺��      
                  '#THRMedicine'    ,		-- �ӽ� ���̺��      
                  @SeqName      ,   -- CompanySeq�� ������ Ű(Ű�� �������� ���� , �� ���� )      
                  @TblColumns   ,   -- ���̺� ��� �ʵ��
                  ''            ,
                  @PgmSeq





    IF @WorkingTag = 'STOP'
    BEGIN
        update A
           set IsNotUse  = M.IsNotUse
          from    #THRMedicine            AS M
                JOIN MINJUN_THRMedicine AS A        with(nolock) on A.CompanySeq    = @CompanySeq
                                                                AND A.MedSeq        = M.MedSeq
        where M.WorkingTag = 'U'
          AND M.Status     = 0
    END
    else
    begin
                    



    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #THRMedicine WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN        
        -- Master���̺� ������ ����
        DELETE  A
          FROM  #THRMedicine                AS M
                JOIN MINJUN_THRMedicine      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                               AND  A.MedSeq        = M.MedSeq
         WHERE  M.WorkingTag    = 'D'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- Update
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #THRMedicine WHERE WorkingTag = 'U' AND Status = 0 )    
    BEGIN
        UPDATE  A 
           SET  MedName         = M.MedName     
               ,MedNo           = M.MedNo       
               ,RegDate         = M.RegDate     
               ,ExpDate         = M.ExpDate     
               ,EmpSeq          = M.EmpSeq      
               ,DeptSeq         = M.DeptSeq     
               ,Caution         = M.Caution     
               ,Qty             = M.Qty         
               ,IsNotUse        = M.IsNotUse    
               ,LastUserSeq     = @UserSeq 
               ,LastDateTime    = GETDATE()
               ,PgmSeq          = @PgmSeq      
          FROM  #THRMedicine                AS M
                JOIN MINJUN_THRMedicine      AS A  WITH(NOLOCK)  ON  A.CompanySeq    = @CompanySeq
                                                               AND  A.MedSeq        = M.MedSeq
         WHERE  M.WorkingTag    = 'U'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END

    -- =============================================================================================================================================
    -- INSERT
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #THRMedicine WHERE WorkingTag = 'A' AND Status = 0 )    
    BEGIN
        INSERT INTO MINJUN_THRMedicine (
            CompanySeq
           ,MedSeq
           ,MedName
           ,MedNo
           ,RegDate
           ,ExpDate
           ,EmpSeq
           ,DeptSeq
           ,Caution
           ,Qty
           ,IsNotUse
           ,LastUserSeq
           ,LastDateTime
           ,PgmSeq
        )
        SELECT  @CompanySeq
               ,M.MedSeq
               ,M.MedName
               ,M.MedNo
               ,M.RegDate
               ,M.ExpDate
               ,M.EmpSeq
               ,M.DeptSeq
               ,M.Caution
               ,M.Qty
               ,M.IsNotUse
               ,@UserSeq
               ,GETDATE()
               ,@PgmSeq
          FROM  #THRMedicine          AS M
         WHERE  M.WorkingTag    = 'A'
           AND  M.Status        = 0

        IF @@ERROR <> 0 RETURN
    END
    

    End

    SELECT * FROM #THRMedicine
   
RETURN