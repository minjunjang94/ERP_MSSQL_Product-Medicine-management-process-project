IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseItemQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseItemQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품사용입력:ItemQuery_minjun
 작성일 - '2020-03-27
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseItemQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml데이터
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- 회사 번호
   ,@LanguageSeq    INT             = 1     -- 언어 번호
   ,@UserSeq        INT             = 0     -- 사용자 번호
   ,@PgmSeq         INT             = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@UseSeq         INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @UseSeq         = ISNULL(UseSeq         ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (UseSeq          INT)
    
    -- 최종Select
    SELECT  A.UseSeq
           ,A.Serl
           ,M.MedSeq
           ,M.MedName
           ,M.MedNo
           ,A.Qty
      FROM  minjun_THRMedicineUseItem                        AS A   WITH(NOLOCK)
            JOIN minjun_THRMedicineUse                       AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                               AND  B.UseSeq            = A.UseSeq
            LEFT OUTER JOIN minjun_THRMedicine               AS M   WITH(NOLOCK) ON  M.CompanySeq        = A.CompanySeq
                                                                               AND  M.MedSeq            = A.MedSeq
     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.UseSeq        = @UseSeq  
  
RETURN