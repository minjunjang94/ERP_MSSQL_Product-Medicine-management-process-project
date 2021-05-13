IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'MINJUN_SHRMedicineCheck' AND xtype = 'P')    
    DROP PROC MINJUN_SHRMedicineCheck
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ���:Check_MINJUN
 �ۼ��� - '2020.03.25
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.MINJUN_SHRMedicineCheck
     @xmlDocument    NVARCHAR(MAX)          -- Xml������
    ,@xmlFlags       INT            = 0     -- XmlFlag
    ,@ServiceSeq     INT            = 0     -- ���� ��ȣ
    ,@WorkingTag     NVARCHAR(10)   = ''    -- WorkingTag
    ,@CompanySeq     INT            = 1     -- ȸ�� ��ȣ
    ,@LanguageSeq    INT            = 1     -- ��� ��ȣ
    ,@UserSeq        INT            = 0     -- ����� ��ȣ
    ,@PgmSeq         INT            = 0     -- ���α׷� ��ȣ
 AS    
    DECLARE @MessageType    INT             -- �����޽��� Ÿ��
           ,@Status         INT             -- ���º���
           ,@Results        NVARCHAR(250)   -- �������
           ,@Count          INT             -- ä�������� Row ��
           ,@Seq            INT             -- Seq
           ,@MaxNo          NVARCHAR(20)    -- ä�� ������ �ִ� No
           ,@Date           NCHAR(8)        -- Date
           ,@TblName        NVARCHAR(MAX)   -- Table��
           ,@SeqName        NVARCHAR(MAX)   -- Table Ű�� ��
    
    -- ���̺�, Ű�� ��Ī
    SELECT  @TblName    = N'MINJUN_THRMedicine'
           ,@SeqName    = N'MedSeq'
    
    -- Xml������ �ӽ����̺� ���
    CREATE TABLE #THRMedicine (WorkingTag NCHAR(1) NULL)  
    EXEC dbo._SCAOpenXmlToTemp @xmlDocument, @xmlFlags, @CompanySeq, @ServiceSeq, 'DataBlock1', '#THRMedicine' 
    
    IF @@ERROR <> 0 RETURN
/*    
    -- üũ����
    EXEC dbo._SCOMMessage   @MessageType    OUTPUT
                           ,@Status         OUTPUT
                           ,@Results        OUTPUT
                           ,0                       -- SELECT * FROM _TCAMessageLanguage WITH(NOLOCK) WHERE LanguageSeq = 1 AND Message LIKE '%%'
                           ,@LanguageSeq
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
                           ,0, ''                   -- SELECT * FROM _TCADictionary WITH(NOLOCK) WHERE LanguageSeq = 1 AND Word LIKE '%%'
    UPDATE  #THRMedicine
       SET  Result          = @Results
           ,MessageType     = @MessageType
           ,Status          = @Status
      FROM  #THRMedicine     AS M
     WHERE  M.WorkingTag IN('')
       AND  M.Status = 0
*/
    -- ä���ؾ� �ϴ� ������ �� Ȯ��
    SELECT @Count = COUNT(1) FROM #THRMedicine WHERE WorkingTag = 'A' AND Status = 0 
     
    -- ä��
    IF @Count > 0
    BEGIN
        -- �����ڵ�ä�� : ���̺��� �ý��ۿ��� Max������ �ڵ� ä���� ���� �����Ͽ� ä��
        EXEC @Seq = dbo._SCOMCreateSeq @CompanySeq, @TblName, @SeqName, @Count
        
        UPDATE  #THRMedicine
           SET  MedSeq = @Seq + DataSeq
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
        
        -- �ܺι�ȣ ä���� ���� ���ڰ�
        SELECT @Date = CONVERT(NVARCHAR(8), GETDATE(), 112)        
        
        -- �ܺι�ȣä�� : ������ �ܺ�Ű�������ǵ�� ȭ�鿡�� ���ǵ� ä����Ģ���� ä��
        EXEC dbo._SCOMCreateNo 'HR', @TblName, @CompanySeq, '', @Date, @MaxNo OUTPUT
        
        UPDATE  #THRMedicine
           SET  MedNo = @MaxNo
         WHERE  WorkingTag  = 'A'
           AND  Status      = 0
    END
   
    SELECT * FROM #THRMedicine
    
RETURN