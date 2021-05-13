IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineSave' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineSave
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품등록:Save_MINJUN
 작성일 - '2020.03.25
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineSave
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS
    DECLARE @TblName        NVARCHAR(MAX)   -- Table명
           ,@ItemTblName    NVARCHAR(MAX)   -- 상세Table명
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName        = N'MINJUN_THRMedicine'
           ,@ItemTblName    = N''
           ,@SeqName        = N'MedSeq'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #THRMedicine (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#THRMedicine' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- 테이블명      
                  '#THRMedicine'    ,		-- 임시 테이블명      
                  @SeqName      ,   -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,   -- 테이블 모든 필드명
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
        -- Master테이블 데이터 삭제
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