IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseItemSave' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseItemSave
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품사용입력:ItemSave_minjun
 작성일 - '2020-03-27
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseItemSave
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
           ,@SeqName        NVARCHAR(MAX)   -- Seq명
           ,@SerlName       NVARCHAR(MAX)   -- Serl명
           ,@TblColumns     NVARCHAR(MAX)
    
    -- 테이블, 키값 명칭
    SELECT  @TblName        = N'minjun_THRMedicineUseItem'
           ,@SeqName        = N'UseSeq'
           ,@SerlName       = N'Serl'

    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #_THRMedicineUseItem (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock2', '#_THRMedicineUseItem' 
    
    IF @@ERROR <> 0 RETURN
      
    -- 로그테이블 남기기(마지막 파라메터는 반드시 한줄로 보내기)  	
	SELECT @TblColumns = dbo._FGetColumnsForLog(@TblName)
    
    EXEC _SCOMLog @CompanySeq   ,      
                  @UserSeq      ,      
                  @TblName      ,		-- 테이블명      
                  '#_THRMedicineUseItem'       ,		-- 임시 테이블명      
                  'UseSeq, Serl'     ,   -- CompanySeq를 제외한 키(키가 여러개일 경우는 , 로 연결 )      
                  @TblColumns   ,   -- 테이블 모든 필드명
                  ''            ,
                  @PgmSeq
                    
    -- =============================================================================================================================================
    -- DELETE
    -- =============================================================================================================================================
    IF EXISTS (SELECT 1 FROM #_THRMedicineUseItem WHERE WorkingTag = 'D' AND Status = 0 )    
    BEGIN
        -- Master테이블 데이터 삭제
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