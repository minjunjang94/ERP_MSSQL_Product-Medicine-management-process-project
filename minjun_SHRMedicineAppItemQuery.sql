IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineAppItemQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineAppItemQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ��û:ItemQuery_minjun
 �ۼ��� - 2020-03-26
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineAppItemQuery
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
           ,@AppSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @AppSeq            = ISNULL(AppSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (AppSeq        INT)
    
    -- ����Select
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