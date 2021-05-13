IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineQuery' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ���:Query_MINJUN
 �ۼ��� - '2020.03.25
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineQuery
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
           ,@MedSeq         INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @MedSeq         = ISNULL(MedSeq     ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (MedSeq          INT)
    
    -- ����Select
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