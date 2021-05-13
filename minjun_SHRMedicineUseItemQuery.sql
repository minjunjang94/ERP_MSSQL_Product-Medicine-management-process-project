IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseItemQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseItemQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ����Է�:ItemQuery_minjun
 �ۼ��� - '2020-03-27
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseItemQuery
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
      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock2', @xmlFlags)
      WITH (UseSeq          INT)
    
    -- ����Select
    SELECT  A.UseSeq
           ,A.Serl
           ,M.MedSeq
           ,M.MedName
           ,M.MedNo
           ,A.Qty
      FROM  minjun_THRMedicineUseItem                        AS A   WITH(NOLOCK)
            JOIN minjun_THRMedicineUse                       AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                               AND  B.UseSeq            = A.UseSeq
            LEFT OUTER JOIN minjun_THRMedicine               AS M   WITH(NOLOCK) ON  M.CompanySeq        = A.CompanySeq
                                                                               AND  M.MedSeq            = A.MedSeq
     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.UseSeq        = @UseSeq  
  
RETURN