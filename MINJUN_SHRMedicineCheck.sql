IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineCheck' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineCheck
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품등록:Check_MINJUN
 작성일 - '2020.03.25
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- 서비스 번호
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- 회사 번호
    ,@LanguageSeq    INT            = 1     -- 언어 번호
    ,@UserSeq        INT            = 0     -- 사용자 번호
    ,@PgmSeq         INT            = 0     -- 프로그램 번호
 AS    
    DECLARE @MessageType    INT             -- 오류메시지 타입
           ,@Status         INT             -- 상태변수
           ,@Results        NVARCHAR(250)   -- 결과문구
           ,@Count          INT             -- 채번데이터 Row 수
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- 채번 데이터 최대 No
           ,@Date           NCHAR(8)        -- Date
           ,@TblName        NVARCHAR(MAX)   -- Table명
           ,@SeqName        NVARCHAR(MAX)   -- Table 키값 명
    
    -- 테이블, 키값 명칭
    SELECT  @TblName    = N'MINJUN_THRMedicine'
           ,@SeqName    = N'MedSeq'
    
    -- Xml데이터 임시테이블에 담기
    CREATE TABLE #THRMedicine (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#THRMedicine' 
    
    IF @@ERROR <> 0 RETURN
/*    
    -- 체크구문
    EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,0                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%%'
                           ,@LanguageSeq
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
    UPDATE  #THRMedicine
       SET  Result          = @Results
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #THRMedicine     AS M
     WHERE  M.WorkingTag IN('')
       AND  M.Status = 0
*/
    -- 채번해야 하는 데이터 수 확인
    SELECT @Count = COUNT(1) FROM #THRMedicine WHERE WorkingTag = 'A' AND Status = 0 
     
    -- 채번
    IF @Count > 0
    BEGIN
        -- 내부코드채번 : 테이블별로 시스템에서 Max값으로 자동 채번된 값을 리턴하여 채번
        EXEC @Seq = dbo._SCOMCreateSeq @CompanySeq, @TblName, @SeqName, @Count
        
        UPDATE  #THRMedicine
           SET  MedSeq = @Seq + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
        
        -- 외부번호 채번에 쓰일 일자값
        SELECT @Date = CONVERT(NVARCHAR(8), GETDATE(), 112)        
        
        -- 외부번호채번 : 업무별 외부키생성정의등록 화면에서 정의된 채번규칙으로 채번
        EXEC dbo._SCOMCreateNo 'HR', @TblName, @CompanySeq, '', @Date, @MaxNo OUTPUT
        
        UPDATE  #THRMedicine
           SET  MedNo = @MaxNo
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #THRMedicine
    
RETURN