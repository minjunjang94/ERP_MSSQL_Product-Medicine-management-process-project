IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineQuery' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품등록:Query_MINJUN
 작성일 - '2020.03.25
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineQuery
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
           ,@MedSeq         INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @MedSeq         = ISNULL(MedSeq     ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (MedSeq          INT)
    
    -- 최종Select
    SELECT  A.MedSeq
           ,A.RegDate
           ,A.MedName
           ,A.Qty
           ,A.MedNo
           ,A.ExpDate
           ,D.DeptName
           ,D.DeptSeq
           ,E.EmpName
           ,E.EmpSeq
           ,A.Caution
           ,A.IsNotUse
           ,A0.CfmCode


      FROM  MINJUN_THRMedicine                                   AS A   WITH(NOLOCK)
            LEFT OUTER JOIN minjun_THRMedicine_Confirm           AS A0  WITH(NOLOCK) ON  A0.CompanySeq       = A.CompanySeq
                                                                                    AND  A0.CfmCode          = A.Medseq
            LEFT OUTER JOIN _TDADept                             AS D   WITH(NOLOCK) ON  D.CompanySeq        = A.CompanySeq
                                                                                    AND  D.DeptSeq           = A.DeptSeq
            LEFT OUTER JOIN _TDAEmp                              AS E   WITH(NOLOCK) ON  E.CompanySeq        = A.CompanySeq
                                                                                    AND  E.EmpSeq            = A.EmpSeq

     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.MedSeq        = @MedSeq
  
RETURN