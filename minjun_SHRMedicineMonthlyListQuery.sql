IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineMonthlyListQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineMonthlyListQuery
GO
    
/*************************************************************************************************    
 설  명 - SP-월별의약품조회:ListQuery_minjun
 작성일 - '2020-03-31
 작성자 - 장민준
 수정자 - 
*************************************************************************************************/    
CREATE PROCEDURE dbo.minjun_SHRMedicineMonthlyListQuery
    @ServiceSeq    INT          = 0 ,   -- 서비스 내부코드
    @WorkingTag    NVARCHAR(10) = '',   -- WorkingTag
    @CompanySeq    INT          = 1 ,   -- 법인 내부코드
    @LanguageSeq   INT          = 1 ,   -- 언어 내부코드
    @UserSeq       INT          = 0 ,   -- 사용자 내부코드
    @PgmSeq        INT          = 0 ,   -- 프로그램 내부코드
    @IsTransaction BIT          = 0     -- 트랜젝션 여부
AS
	-- 변수선언
    DECLARE 
                 @YM        NCHAR(6)
                ,@MedName   NVARCHAR(100)
                ,@MedNo     NVARCHAR(100)

           

    -- 조회조건 받아오기
    SELECT  @YM        = RTRIM(LTRIM(ISNULL(M.YM         , '')))
           ,@MedName   = RTRIM(LTRIM(ISNULL(M.MedName    , '')))
           ,@MedNo     = RTRIM(LTRIM(ISNULL(M.MedNo      , '')))


      FROM  #BIZ_IN_DataBlock1      AS M

	/*************************************************
	-- #Title : 헤더부
	*************************************************/
	CREATE TABLE #Title(
        ColIDX      INT             IDENTITY(0, 1)
       ,Title       NVARCHAR(200)
       ,TitleSeq    INT
	)

	INSERT INTO #Title(
        Title
       ,TitleSeq
	)
	SELECT	 A.SDay
            ,CONVERT(INT, A.Solar)

	  FROM  _TCOMCalendar               AS A  WITH(NOLOCK)
     WHERE  LEFT(A.Solar, 6) = @YM

     ORDER BY A.SDay

	/*************************************************
	-- #FixCol : 고정부
	*************************************************/
	CREATE TABLE #FixCol(
		RowIDX		INT IDENTITY(0, 1)
	   ,MedSeq      INT
       ,MedName     NVARCHAR(100)
       ,MedNo       NVARCHAR(50)
	)

	INSERT INTO #FixCol(
        MedSeq  
       ,MedName 
	   ,MedNo  
    ) 
    SELECT   MedSeq  
            ,MedName 
            ,MedNo  

           
      FROM  minjun_THRMedicine               AS A  WITH(NOLOCK)
	 WHERE  A.CompanySeq    = @CompanySeq
       AND	(@MedName       = ''        OR  A.MedName LIKE @MedName + '%' )
       AND  (@MedNo         = ''        OR  A.MedNo   LIKE @MedNo   + '%' )


	/*************************************************
	-- #Value 가변부
	*************************************************/
	CREATE TABLE #Value(
        ColIDX          INT
       ,RowIDX          INT
       ,Value           DECIMAL(19,5)
    )




    -- 일자별 의약품별 사용수량
    -- Group by 일자, 의약품
    -- Sum (사용수량)

    select  A.UseDate
           ,B.MedSeq
           ,SUM(B.Qty) AS Qty

      into #TEMP_data

      from minjun_THRMedicineUse            AS A    WITH(NOLOCK)
           JOIN minjun_THRMedicineUseItem   AS B    WITH(NOLOCK)  ON    B.CompanySeq        = A.CompanySeq
                                                                 AND    B.UseSeq            = A.UseSeq

     where A.CompanySeq         = @CompanySeq
       and left(A.UseDate, 6)   = @YM

     Group by A.UseDate, B.MedSeq






	INSERT INTO #Value (
        ColIDX
       ,RowIDX
       ,Value
    )
	SELECT  X.ColIDX
           ,Y.RowIDX
           ,A.Qty
      FROM  #TEMP_data              AS A  WITH(NOLOCK)
            JOIN #Title             AS X  WITH(NOLOCK)  ON  X.TitleSeq      = A.UseDate
            JOIN #FixCol            AS Y  WITH(NOLOCK)  ON  Y.MedSeq        = A.MedSeq
     --WHERE  A.CompanySeq    = @CompanySeq
        

	/*************************************************
	-- 조회결과 SELECT
	*************************************************/
    SELECT * FROM #Title
    SELECT * FROM #FixCol
    SELECT * FROM #Value

RETURN  
/******************************************************************************************/  
GO