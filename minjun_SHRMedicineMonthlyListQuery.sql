IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'minjun_SHRMedicineMonthlyListQuery' AND xtype = 'P')    
    DROP PROC minjun_SHRMedicineMonthlyListQuery
GO
    
/*************************************************************************************************    
 ��  �� - SP-�����Ǿ�ǰ��ȸ:ListQuery_minjun
 �ۼ��� - '2020-03-31
 �ۼ��� - �����
 ������ - 
*************************************************************************************************/    
CREATE PROCEDURE dbo.minjun_SHRMedicineMonthlyListQuery
    @ServiceSeq    INT          = 0 ,   -- ���� �����ڵ�
    @WorkingTag    NVARCHAR(10) = '',   -- WorkingTag
    @CompanySeq    INT          = 1 ,   -- ���� �����ڵ�
    @LanguageSeq   INT          = 1 ,   -- ��� �����ڵ�
    @UserSeq       INT          = 0 ,   -- ����� �����ڵ�
    @PgmSeq        INT          = 0 ,   -- ���α׷� �����ڵ�
    @IsTransaction BIT          = 0     -- Ʈ������ ����
AS
	-- ��������
    DECLARE 
                 @YM        NCHAR(6)
                ,@MedName   NVARCHAR(100)
                ,@MedNo     NVARCHAR(100)

           

    -- ��ȸ���� �޾ƿ���
    SELECT  @YM        = RTRIM(LTRIM(ISNULL(M.YM         , '')))
           ,@MedName   = RTRIM(LTRIM(ISNULL(M.MedName    , '')))
           ,@MedNo     = RTRIM(LTRIM(ISNULL(M.MedNo      , '')))


      FROM  #BIZ_IN_DataBlock1      AS M

	/*************************************************
	-- #Title : �����
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
	-- #FixCol : ������
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
	-- #Value ������
	*************************************************/
	CREATE TABLE #Value(
        ColIDX          INT
       ,RowIDX          INT
       ,Value           DECIMAL(19,5)
    )




    -- ���ں� �Ǿ�ǰ�� ������
    -- Group by ����, �Ǿ�ǰ
    -- Sum (������)

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
	-- ��ȸ��� SELECT
	*************************************************/
    SELECT * FROM #Title
    SELECT * FROM #FixCol
    SELECT * FROM #Value

RETURN  
/******************************************************************************************/  
GO