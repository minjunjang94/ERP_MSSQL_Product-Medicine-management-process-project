IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineListQuery' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineListQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-의약픔조회:Query_MINJUN
 작성일 - '2020.03.25
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineListQuery
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
           ,@MedName        NVARCHAR(100)
           ,@MedNo          NVARCHAR(100)
           ,@DeptSeq        INT 
           ,@EmpSeq         INT 
           ,@RegDateFr      NCHAR(8)
           ,@RegDateTo      NCHAR(8)
           ,@ExpDateFr      NCHAR(8)
           ,@ExpDateTo      NCHAR(8)
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @MedName        = RTRIM(LTRIM(ISNULL(MedName    , '')))
           ,@MedNo          = RTRIM(LTRIM(ISNULL(MedNo      , '')))
           ,@DeptSeq        = RTRIM(LTRIM(ISNULL(DeptSeq    ,  0)))
           ,@EmpSeq         = RTRIM(LTRIM(ISNULL(EmpSeq     ,  0)))
           ,@RegDateFr      = RTRIM(LTRIM(ISNULL(RegDateFr  , '')))
           ,@RegDateTo      = RTRIM(LTRIM(ISNULL(RegDateTo  , '')))
           ,@ExpDateFr      = RTRIM(LTRIM(ISNULL(ExpDateFr  , '')))
           ,@ExpDateTo      = RTRIM(LTRIM(ISNULL(ExpDateTo  , '')))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (MedName         NVARCHAR(100)
           ,MedNo           NVARCHAR(100)
           ,DeptSeq         INT 
           ,EmpSeq          INT 
           ,RegDateFr       NCHAR(8)
           ,RegDateTo       NCHAR(8)
           ,ExpDateFr       NCHAR(8)
           ,ExpDateTo       NCHAR(8)
           )

    IF @RegDateFr = '' SET @RegDateFr = '19000101'
    IF @RegDateTo = '' SET @RegDateTo = '99991231'
    IF @ExpDateFr = '' SET @ExpDateFr = '19000101'
    IF @ExpDateTo = '' SET @ExpDateTo = '99991231'
    
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
           ,A0.CfmDate
           ,E0.EmpName  As CfmEmpName
           ,E0.EmpSeq   As CfmEmpSeq

      FROM  MINJUN_THRMedicine                              AS A   WITH(NOLOCK)
            LEFT OUTER JOIN minjun_THRMedicine_Confirm      AS A0  WITH(NOLOCK) ON  A0.CompanySeq        = A.CompanySeq
                                                                               AND  A0.CfmCode           = A.Medseq
            LEFT OUTER JOIN _TDADept                        AS D   WITH(NOLOCK) ON  D.CompanySeq         = A.CompanySeq
                                                                               AND  D.DeptSeq            = A.DeptSeq
            LEFT OUTER JOIN _TDAEmp                         AS E   WITH(NOLOCK) ON  E.CompanySeq         = A.CompanySeq
                                                                               AND  E.EmpSeq             = A.EmpSeq
            LEFT OUTER JOIN _TDAEmp                         AS E0  WITH(NOLOCK) ON  E0.CompanySeq        = A0.CompanySeq
                                                                               AND  E0.EmpSeq            = A0.CfmEmpSeq
     WHERE  A.CompanySeq    = @CompanySeq
       AND (@MedName        = ''            OR  A.MedName    LIKE @MedName + '%'    )
       AND (@MedNo          = ''            OR  A.MedNo      LIKE @MedNo + '%'      )
       AND (@DeptSeq        =  0            OR  D.DeptSeq       = @DeptSeq          )
       AND (@EmpSeq         =  0            OR  E.EmpSeq        = @EmpSeq           )
       AND  A.RegDate BETWEEN @RegDateFr    AND @RegDateTo
       AND  A.ExpDate BETWEEN @ExpDateFr    AND @ExpDateTo
  
RETURN