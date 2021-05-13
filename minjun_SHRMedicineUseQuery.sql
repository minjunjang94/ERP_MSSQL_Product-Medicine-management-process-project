IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ����Է�:Query_minjujn
 �ۼ��� - '2020-03-27
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseQuery
    @xmlDocument    NVARCHAR(MAX)           -- Xml������
   ,@xmlFlags       INT             = 0     -- XmlFlag
   ,@ServiceSeq     INT             = 0     -- ���� ��ȣ
   ,@WorkingTag     NVARCHAR(10)    = ''    -- WorkingTag
   ,@CompanySeq     INT             = 1     -- ȸ�� ��ȣ
   ,@LanguageSeq    INT             = 1     -- ��� ��ȣ
   ,@UserSeq        INT             = 0     -- ����� ��ȣ
   ,@PgmSeq         INT             = 0     -- ���α׷� ��ȣ
AS
    -- ��������
    DECLARE @docHandle      INT
           ,@UseSeq         INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @UseSeq         = ISNULL(UseSeq         ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (UseSeq          INT)
    
    -- ����Select
    SELECT  A.UseSeq
           ,A.UseDate
           ,A.UseNo
           ,D.DeptName
           ,D.DeptSeq
           ,E.EmpName
           ,E.EmpSeq
           ,A.Remark
           ,B.CfmCode
      FROM  minjun_THRMedicineUse                            AS A   WITH(NOLOCK)
            LEFT OUTER JOIN minjun_THRMedicineUse_Confirm     AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                               AND  B.CfmSeq            = A.UseSeq
            LEFT OUTER JOIN _TDAEmp                         AS E   WITH(NOLOCK) ON  E.CompanySeq        = A.CompanySeq
                                                                               AND  E.EmpSeq            = A.EmpSeq
            LEFT OUTER JOIN _TDADept                        AS D   WITH(NOLOCK) ON  D.CompanySeq        = A.CompanySeq
                                                                               AND  D.DeptSeq           = A.DeptSeq
     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.UseSeq        = @UseSeq  
  
RETURN