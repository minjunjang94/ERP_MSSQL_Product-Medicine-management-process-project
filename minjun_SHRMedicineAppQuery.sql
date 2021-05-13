IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineAppQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineAppQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ��û:Query_minjun	
 �ۼ��� - '2020-03-26
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineAppQuery
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
           ,@AppSeq       INT
  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT  @AppSeq       = ISNULL(AppSeq       ,  0)
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (AppSeq        INT)
    
    -- ����Select
    SELECT  
             A.AppDate
            ,C.DeptSeq
            ,C.DeptName
            ,B.EmpSeq
            ,B.EmpName
            ,A.AppSeq
            ,A.Reason
            ,A.AppNo

            

      FROM  minjun_THRMedicineApp               AS A  WITH(NOLOCK)
            LEFT OUTER JOIN _TDAEmp             AS B    WITH(NOLOCK) ON B.CompanySeq      = A.CompanySeq
                                                                    AND B.EmpSeq          = A.EmpSeq
            LEFT OUTER JOIN _TDADept            AS C    WITH(NOLOCK) ON C.CompanySeq      = A.CompanySeq
                                                                    AND C.Deptseq         = A.Deptseq




     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.AppSeq      = @AppSeq
  
RETURN