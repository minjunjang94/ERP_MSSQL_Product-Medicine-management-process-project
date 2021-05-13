IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineAppListQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineAppListQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ����û��ȸ_minjun
 �ۼ��� - '2020-03-26
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineAppListQuery
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
            ,@AppDateFr     NCHAR(8)
            ,@AppDateTo     NCHAR(8)
            ,@AppNo         NVARCHAR(100)
            ,@DeptSeq       INT
            ,@EmpSeq        INT
            ,@MedName       NVARCHAR(100)
            ,@MedNo         NVARCHAR(100)
            ,@UMStatusSeq   INT


    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT 
             @AppDateFr       = RTRIM(LTRIM(ISNULL(AppDateFr      , '')))
            ,@AppDateTo       = RTRIM(LTRIM(ISNULL(AppDateTo      , '')))
            ,@AppNo           = RTRIM(LTRIM(ISNULL(AppNo          , '')))
            ,@DeptSeq         = RTRIM(LTRIM(ISNULL(DeptSeq        ,  0)))
            ,@EmpSeq          = RTRIM(LTRIM(ISNULL(EmpSeq         ,  0)))
            ,@MedName         = RTRIM(LTRIM(ISNULL(MedName        , '')))
            ,@MedNo           = RTRIM(LTRIM(ISNULL(MedNo          , '')))
            ,@UMStatusSeq     = RTRIM(LTRIM(ISNULL(UMStatusSeq    ,  0)))


      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (    
                AppDateFr     NCHAR(8)
                ,AppDateTo     NCHAR(8)
                ,AppNo         NVARCHAR(100)
                ,DeptSeq       INT
                ,EmpSeq        INT
                ,MedName       NVARCHAR(100)
                ,MedNo         NVARCHAR(100)
                ,UMStatusSeq   INT

           )

          IF @AppDateFr = '' SET @AppDateFr = '19000101'
          IF @AppDateTo = '' SET @AppDateTo = '99991231'       
    
    -- ����Select
    SELECT  
                     '' as SEL
                    ,'' as UMStatusName
                    ,'' as UMStatusSeq
                    ,F.CfmCode  
                    ,G.EmpName  as CfmEmpName
                    ,F.CfmDate
                    ,A.AppSeq
                    ,B.Serl
                    ,A.AppNo
                    ,A.AppDate
                    ,D.DeptName
                    ,E.EmpName
                    ,B.MedSeq
                    ,C.MedName
                    ,C.MedNo
                    ,B.Qty          As    AppQty
                    --,UseQty
                    --,RemQty
                    


                    INTO #TEMP_Data --select�� ������� �ӽ����̺� ���



      FROM  minjun_THRMedicineApp                             AS A  WITH(NOLOCK)
            LEFT OUTER JOIN minjun_THRMedicineAppItem         AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                                 AND  B.AppSeq            = A.AppSeq
            LEFT OUTER JOIN minjun_THRMedicine                AS C   WITH(NOLOCK) ON  C.CompanySeq        = B.CompanySeq
                                                                                 AND  C.MedSeq            = B.MedSeq
            LEFT OUTER JOIN _TDAEmp                           AS E   WITH(NOLOCK) ON  E.CompanySeq        = A.CompanySEq
                                                                                 AND  E.EmpSeq            = A.EmpSeq
            LEFT OUTER JOIN _TDADept                          AS D   WITH(NOLOCK) ON  D.CompanySeq        = A.CompanySeq
                                                                                 AND  D.DeptSeq           = A.DeptSeq
            LEFT OUTER JOIN minjun_THRMedicineApp_Confirm     AS F   WITH(NOLOCK) ON  F.CompanySeq        = A.CompanySeq
                                                                                 AND  F.CfmSeq            = A.AppSeq
            LEFT OUTER JOIN _TDAEmp                           AS G   WITH(NOLOCK) ON  G.CompanySeq        = F.CompanySeq
                                                                                 AND  G.EmpSeq            = F.CfmEmpSeq

     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.AppDate BETWEEN @AppDateFr And @AppDateTo
       AND (@AppNo                = ''                 OR  A.AppNo           LIKE @AppNo     + '%'         )
       AND (@DeptSeq              = 0                  OR  A.DeptSeq         = @DeptSeq                    )
       AND (@EmpSeq               = 0                  OR  A.EmpSeq          = @EmpSeq                     )
       AND (@MedName              = ''                 OR  C.MedName         LIKE @MedName   + '%'         )
       AND (@MedNo                = ''                 OR  C.MedNo           LIKE @MedNo     + '%'         )
       --AND (@UMStatusSeq          = 0                  OR  .UMStatusSeq     = @UMStatusSeq                )
      
      
      
         
 --***************************************************************************************************************
   -- ===================================================
-- �������� �ӽ����̺� ����
-- ===================================================
-- ���� ã�� ������̺�
CREATE TABLE #TMP_ProgressTable(
    IDOrder     INT
   ,TableName   NVARCHAR(100)
)

-- ����� ���� ���̺�
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

-- ���� ã�� ���
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
-- ��� ���
-- ===================================================
-- ������̺� ���
INSERT INTO #TMP_ProgressTable(IDOrder, TableName)
VALUES  ( 1, 'minjun_THRMedicineUseItem')

-- ������� ���
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

-- ���� ã��
EXEC _SCOMProgressTracking @CompanySeq, 'minjun_THRMedicineAppItem', '#TMP_ProgressItem', 'Seq', 'Serl', ''

select  A.*
       ,C.UseQty
       ,A.AppQty - ISNULL(C.UseQty, 0) AS RemQty


  from #TEMP_Data               AS A
        JOIN #TMP_ProgressItem  AS B    WITH(NOLOCK) ON B.Seq       = A.AppSeq      
                                                    AND B.Serl      = A.Serl
        LEFT OUTER JOIN (SELECT IDX_NO, IDOrder, SUM(Qty) AS UseQty
                           FROM #TCOMProgressTracking
                           WHERE IDOrder = 1
                           GROUP BY IDX_NO, IDOrder 
                           )        AS C        ON C.IDX_NO       = B.IDX_NO

---







 --***************************************************************************************************************  
        
            
      
      
        
  
RETURN