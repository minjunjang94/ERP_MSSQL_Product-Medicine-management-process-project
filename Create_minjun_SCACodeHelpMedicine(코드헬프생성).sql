IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SCACodeHelpMedicine' AND xtype = 'P')    
    DROP PROC minjun_SCACodeHelpMedicine
GO
    
/*************************************************************************************************    
 설  명 - SP-코드도움: 의약품_minjun
 작성일 - '2020-03-16
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/ 
CREATE PROCEDURE dbo.minjun_SCACodeHelpMedicine
    @WorkingTag         NVARCHAR(1)
   ,@LanguageSeq        INT
   ,@CodeHelpSeq        INT
   ,@DefQueryOption     INT                 -- 2: direct search
   ,@CodeHelpType       TINYINT
   ,@PageCount          INT             = 50
   ,@CompanySeq         INT             = 0
   ,@Keyword            NVARCHAR(50)    = ''
   ,@Param1             NVARCHAR(50)    = ''
   ,@Param2             NVARCHAR(50)    = ''
   ,@Param3             NVARCHAR(50)    = ''
   ,@Param4             NVARCHAR(50)    = ''
   ,@SubConditionSeq    NVARCHAR(200)   = ''
    -- 로그인정보 사용 체크된 경우 아래 Parameter값 추가
   ,@AccUnit            INT             = NULL
   ,@BizUnit            INT             = NULL
   ,@FactUnit           INT             = NULL
   ,@DeptSeq            INT             = NULL
   ,@WkDeptSeq          INT             = NULL
   ,@EmpSeq             INT             = NULL
   ,@UserSeq            INT             = NULL
AS
	SET ROWCOUNT @PageCount

    SELECT  
       A.MedSeq
       ,A.MedName
       ,A.MedNo
       ,A.RegDate
       ,A.ExpDate
       ,C.DeptName
       ,B.EmpName
       ,A.Caution


    FROM minjun_THRMedicine   AS  A  With(NOLOCK)
            LEFT OUTER JOIN _TDAEmp             AS B    WITH(NOLOCK) ON B.CompanySeq      = A.CompanySeq
                                                                    AND B.EmpSeq          = A.EmpSeq
            LEFT OUTER JOIN _TDADept            AS C    WITH(NOLOCK) ON C.CompanySeq      = A.CompanySeq
                                                                    AND C.Deptseq         = A.Deptseq
    where A.CompanySeq  =   @CompanySeq
    AND  A.MedSeq LIKE MedSeq

    SET ROWCOUNT 0

RETURN
GO