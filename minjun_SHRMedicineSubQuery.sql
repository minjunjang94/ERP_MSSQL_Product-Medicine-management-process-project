IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineSubQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineSubQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ���:SubQuery_minjun
 �ۼ��� - 2020-03-30
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineSubQuery
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
           ,@MedSeq         INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @MedSeq         = RTRIM(LTRIM(ISNULL(MedSeq         ,  0)))
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (MedSeq          INT
           )
    
    -- �����
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