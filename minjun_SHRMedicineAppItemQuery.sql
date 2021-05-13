IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineAppItemQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineAppItemQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품신청:ItemQuery_minjun
 작성일 - 2020-03-26
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineAppItemQuery
    @xmlDocument    NVARCHAR(MAX)          -- Xml데이터
   ,@xmlFlags       INT            = 0     -- XmlFlag
   ,@ServiceSeq     INT            = 0     -- 서비스 번호
   ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
   ,@CompanySeq     INT            = 1     -- 회사 번호
   ,@LanguageSeq    INT            = 1     -- 언어 번호
   ,@UserSeq        INT            = 0     -- 사용자 번호
   ,@PgmSeq         INT            = 0     -- 프로그램 번호
AS
    -- 변수선언
    DECLARE @docHandle      INT
           ,@AppSeq       INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @AppSeq            = ISNULL(AppSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (AppSeq        INT)
    
    -- 최종Select
    SELECT  
            B.AppSeq
            ,B.Serl
            ,E.MedName
            ,E.MedNo
            ,B.Qty
            ,E.RegDate
            ,E.ExpDate
            ,D.DeptName
            ,C.EmpName
            ,E.Caution



      FROM  minjun_THRMedicineApp                   AS  A   WITH(NOLOCK)
            JOIN minjun_THRMedicineAppItem          AS  B   WITH(NOLOCK) ON B.CompanySeq        = A.CompanySeq
                                                                        AND B.AppSeq            = A.AppSeq
            LEFT OUTER JOIN minjun_THRMedicine      AS  E   WITH(NOLOCK) ON E.CompanySeq        = B.CompanySeq
                                                                        AND E.MedSeq            = B.MedSeq
            LEFT OUTER JOIN _TDAEmp                 AS  C   WITH(NOLOCK) ON C.CompanySeq        = E.CompanySeq
                                                                        AND C.EmpSeq            = E.EmpSeq
            LEFT OUTER JOIN _TDADept                AS  D   WITH(NOLOCK) ON D.CompanySeq        = E.CompanySeq
                                                                        AND D.DeptSeq           = E.DeptSeq 




     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.AppSeq      = @AppSeq
  
RETURN