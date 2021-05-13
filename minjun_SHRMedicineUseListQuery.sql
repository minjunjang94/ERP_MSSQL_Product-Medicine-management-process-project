IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineUseListQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineUseListQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�Ǿ�ǰ��볻����ȸ_minjun
 �ۼ��� - '2020-03-27
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROC dbo.minjun_SHRMedicineUseListQuery
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
            ,@UseDateFr     NCHAR(8)
            ,@UseDateTo     NCHAR(8)
            ,@UseNo         NVARCHAR(100)
            ,@DeptName      NVARCHAR(100)
            ,@MedNo         NVARCHAR(100)
            ,@MedName       NVARCHAR(100)
            ,@CfmCode       NVARCHAR(100)
            ,@DeptSeq       INT
            ,@EmpSeq        INT



  
    -- Xml������ ������ ���
    EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlDocument      

    SELECT 
            @UseDateFr  = RTRIM(LTRIM(ISNULL(UseDateFr   , '')))
           ,@UseDateTo  = RTRIM(LTRIM(ISNULL(UseDateTo   , ''))) 
           ,@UseNo      = RTRIM(LTRIM(ISNULL(UseNo       , ''))) 
           ,@DeptName   = RTRIM(LTRIM(ISNULL(DeptName    , ''))) 
           ,@MedNo      = RTRIM(LTRIM(ISNULL(MedNo       , '')))
           ,@MedName    = RTRIM(LTRIM(ISNULL(MedName     , '')))  
           ,@CfmCode    = RTRIM(LTRIM(ISNULL(CfmCode     , ''))) 
           ,@DeptSeq    = RTRIM(LTRIM(ISNULL(DeptSeq     ,  0))) 
           ,@EmpSeq     = RTRIM(LTRIM(ISNULL(EmpSeq      ,  0))) 



      FROM  OPENXML(@docHandle, N'/ROOT/DataBlock1', @xmlFlags)
      WITH (    
                UseDateFr     NCHAR(8)
                ,UseDateTo     NCHAR(8)
                ,UseNo         NVARCHAR(100)
                ,DeptName      NVARCHAR(100)
                ,MedNo         NVARCHAR(100)
                ,MedName       NVARCHAR(100)
                ,CfmCode       NVARCHAR(100)
                ,DeptSeq       INT
                ,EmpSeq        INT            
           )


          IF @UseDateFr = '' SET @UseDateFr = '19000101'
          IF @UseDateTo = '' SET @UseDateTo = '99991231'    
   
       -- ����Select
    SELECT  
             '' as SEL
            ,'' as UMStatusName
            ,'' as UMStatusSeq
            ,C.CfmCode
            ,C.CfmEmpSeq
            ,C.CfmDate
            ,A.UseSeq
            ,A.UseNo
            ,A.UseDate
            ,D.DeptName
            ,E.EmpName
            ,F.MedSeq
            ,F.MedName
            ,F.MedNo
            ,B.Qty      as UseQty



      


      FROM  minjun_THRMedicineUse                             AS A  WITH(NOLOCK)
            LEFT OUTER JOIN minjun_THRMedicineUseItem         AS B   WITH(NOLOCK) ON  B.CompanySeq        = A.CompanySeq
                                                                                 AND  B.UseSeq            = A.UseSeq
            LEFT OUTER JOIN minjun_THRMedicineUse_Confirm     AS C   WITH(NOLOCK) ON  C.CompanySeq        = A.CompanySeq
                                                                                 AND  C.CfmSeq            = A.UseSeq
            LEFT OUTER JOIN _TDAEmp                           AS E   WITH(NOLOCK) ON  E.CompanySeq        = A.CompanySEq
                                                                                 AND  E.EmpSeq            = A.EmpSeq
            LEFT OUTER JOIN _TDADept                          AS D   WITH(NOLOCK) ON  D.CompanySeq        = A.CompanySeq
                                                                                 AND  D.DeptSeq           = A.DeptSeq
            LEFT OUTER JOIN minjun_THRMedicine                AS F   WITH(NOLOCK) ON  F.CompanySeq        = B.CompanySeq
                                                                                 AND  F.MedSeq            = B.MedSeq
            


     WHERE  A.CompanySeq    = @CompanySeq
       AND  A.UseDate BETWEEN @UseDateFr And @UseDateTo
       AND (@UseNo                = ''                 OR  A.UseNo         LIKE @UseNo      + '%'         )
       AND (@MedNo                = ''                 OR  F.MedNo         LIKE @MedNo      + '%'         )
       AND (@MedName              = ''                 OR  F.MedName       LIKE @MedName    + '%'         )
       AND (@CfmCode              = ''                 OR  C.CfmCode       LIKE @CfmCode    + '%'         )
       AND (@DeptSeq              = 0                  OR  D.DeptSeq          = @DeptSeq                  )   
       AND (@EmpSeq               = 0                  OR  E.EmpSeq           = @EmpSeq                   )
   
   
   

RETURN