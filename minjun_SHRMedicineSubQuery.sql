IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineSubQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineSubQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-의약품등록:SubQuery_minjun
 작성일 - 2020-03-30
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineSubQuery
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
           ,@MedSeq         INT
  
    -- Xml데이터 변수에 담기
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @MedSeq         = RTRIM(LTRIM(ISNULL(MedSeq         ,  0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (MedSeq          INT
           )
    
    -- 대상담기
    SELECT  A.AppSeq
           ,B.Serl
           ,A.AppNo
           ,A.AppDate
           ,D.DeptName      AS AppDeptName
           ,D.DeptSeq       AS AppDeptSeq 
           ,E.EmpName       AS AppEmpName 
           ,E.EmpSeq        AS AppEmpSeq  
           ,A.Reason        AS AppReason
           ,M.MedSeq
           ,M.MedName
           ,M.MedNo
           ,B.Qty           AS AppQty

      INTO  #TEMP_Data


      FROM  minjun_THRMedicineApp                            AS A   WITH(NOLOCK)
            JOIN minjun_THRMedicineAppItem                   AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                               AND  B.AppSeq            = A.AppSeq
            LEFT OUTER JOIN minjun_THRMedicineApp_Confirm    AS C   WITH(NOLOCK) ON  C.CompanySeq        = A.CompanySeq
                                                                               AND  C.CfmSeq            = A.AppSeq
            LEFT OUTER JOIN _TDADept                        AS D   WITH(NOLOCK) ON  D.CompanySeq        = A.CompanySeq
                                                                               AND  D.DeptSeq           = A.DeptSeq
            LEFT OUTER JOIN _TDAEmp                         AS E   WITH(NOLOCK) ON  E.CompanySeq        = A.CompanySeq
                                                                               AND  E.EmpSeq            = A.EmpSeq
            LEFT OUTER JOIN _TDAEmp                         AS F   WITH(NOLOCK) ON  F.CompanySeq        = C.CompanySeq
                                                                               AND  F.EmpSeq            = C.CfmEmpSeq
            LEFT OUTER JOIN minjun_THRMedicine               AS M   WITH(NOLOCK) ON  M.CompanySeq        = B.CompanySeq
                                                                               AND  M.MedSeq            = B.MedSeq
     WHERE  A.CompanySeq        = @CompanySeq
       AND  M.MedSeq            = @MedSeq
    



    -- ===================================================
    -- 진행추적 임시테이블 생성
    -- ===================================================
    -- 진행 찾을 대상테이블
    CREATE TABLE #TMP_ProgressTable(
        IDOrder     INT
       ,TableName   NVARCHAR(100)
    )
    
    -- 결과값 담을 테이블
    CREATE TABLE #TCOMProgressTracking(
        IDX_NO      INT
       ,IDOrder     INT
       ,Seq         INT
       ,Serl        INT
       ,SubSerl     INT
       ,Qty         DECIMAL(19,5)
       ,StdQty      DECIMAL(19,5)
       ,Amt         DECIMAL(19,5)
       ,VAT         DECIMAL(19,5)
    )
    
    -- 진행 찾을 대상
    CREATE TABLE #TMP_ProgressItem(
        IDX_NO          INT IDENTITY(1,1)
       ,Seq             INT
       ,Serl            INT
       ,SubSerl         INT
       ,Qty             DECIMAL(19,5)
       ,StdQty          DECIMAL(19,5)
       ,Amt             DECIMAL(19,5)
       ,VAT             DECIMAL(19,5)
    )
    -- ===================================================
    
    -- ===================================================
    -- 대상 담기
    -- ===================================================
    -- 대상테이블 담기
    INSERT INTO #TMP_ProgressTable(IDOrder, TableName)
    VALUES  ( 1, 'minjun_THRMedicineUseItem')
    
    -- 대상정보 담기
    INSERT INTO #TMP_ProgressItem(
        Seq
       ,Serl
       --,SubSerl
       ,Qty
       --,StdQty
       --,Amt
       --,VAT
    )
    SELECT  AppSeq
           ,Serl
           ,AppQty
      FROM  #TEMP_Data
    -- ===================================================
    
    -- 진행 찾기
    EXEC _SCOMProgressTracking @CompanySeq, 'minjun_THRMedicineAppItem', '#TMP_ProgressItem', 'Seq', 'Serl', ''

    SELECT  A.*
           ,C.UseQty    AS Qty
      FROM  #TEMP_Data                  AS A
            JOIN #TMP_ProgressItem      AS B   WITH(NOLOCK) ON  B.Seq       = A.AppSeq
                                                           AND  B.Serl      = A.Serl
            LEFT OUTER JOIN(SELECT IDX_NO, IDOrder, SUM(Qty) AS UseQty
                              FROM #TCOMProgressTracking
                             WHERE IDOrder = 1
                             GROUP BY IDX_NO, IDOrder
                                       )AS C                ON  C.IDX_NO    = B.IDX_NO
  
RETURN