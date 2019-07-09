  
  
  
/*回付者一覧印刷用*/  
CREATE PROCEDURE [ZZSP_REP_KAIFUJYOKYO_1121]  
 @IDDOC  AS int,  
 @UUID      AS nvarchar(64)  
AS   
--EXEC ZZSP_INFO_LOG '回付者一覧印刷','USPPRN11215EX','帳票',@IDDOC  
DECLARE @KIAN_USERNAME NVARCHAR(20)  
DECLARE @KIAN_SYOZOKU  NVARCHAR(100)  
DECLARE @IDDOC_KAIFU AS INT  
DECLARE @IDDOC_SUB AS INT  
DECLARE @IDFRM AS INT   
BEGIN   
    IF ISNULL(@UUID,'')!=''  
    BEGIN  
        BEGIN TRY  
            BEGIN TRANSACTION  
            SELECT @IDDOC_KAIFU=IDNEWDOC  FROM UC001600 WHERE IDDOC=@IDDOC  
            --キャッシュデータ取得  
            EXEC ZZSP_CREATE_CACHED_KAIFU @UUID,@IDDOC_KAIFU  
            --通知者取得  
            DELETE FROM CUD001123 WHERE UUID=@UUID  
            SET @IDFRM=1123  
            SELECT @IDDOC_SUB=IDSUBDOC FROM EGGA0020 WHERE IDDOC=@IDDOC AND IDSUBFRM=@IDFRM AND FGDEL=0  
            EXEC ZZSP_INSERT_CUDTABLE @UUID,@IDFRM,@IDDOC_SUB  
            COMMIT  
        END TRY  
        BEGIN CATCH  
            ROLLBACK TRANSACTION  
            THROW  
        END CATCH  
    END  
  
    SELECT   
    [GPIDDOC]  
    ,[PIDDOC]  
    ,[IDDOC]  
    ,[FORMID]  
    ,[FORMNM]  
    ,[SORT_NO] AS [NO]  
    ,[SORT_NO2] AS [NO2]  
    ,[SORT_NO3] AS [NO3]  
    ,[KAIFUSYA]  
    ,[SYOZOKUCD]  
    ,[SYOZOKUNM]  
    ,[YAKUSYOKU]  
    ,[USERID]  
    ,[NAME] AS [NAME]  
    ,[JOUKYOU]  
    INTO    
    #VW_KAIFUROUTE_REPORT  
    FROM dbo.ZZFN_CACHE_KAIFUROUTE(@UUID,@IDDOC,1)  
  
    SELECT   
    @KIAN_USERNAME=USERNM_06,@KIAN_SYOZOKU=SYOZOKUNM_06    
    FROM VW_KAIFU_MAIN   
    WHERE PIDDOC= CAST(@IDDOC AS NVARCHAR(20))  
  
    SELECT  
    NO AS CH1,  
    V.NO2 AS CH2,  
    M.GUIITEM2 AS [起案年月日] ,  
    M.GUIITEM3 AS [決裁年月日] ,  
    @KIAN_USERNAME AS [起案者],  
    @KIAN_SYOZOKU AS [出力箇所],  
    '' AS [出力箇所タイトル],  
    '共通承認書' AS [案件種別],  
    REPLACE(CAST(M.GUIITEM7 AS NVARCHAR(MAX)),'<BR>',CHAR(13) + CHAR(10))  AS [実施件名],  
    CAST(GUIItem352 AS NVARCHAR) AS [管理番号],  
    V.[FORMID],  
    V.[FORMNM],  
    V.[NO],  
    V.[KAIFUSYA],  
    V.[SYOZOKUCD],  
    V.[SYOZOKUNM],  
    V.[YAKUSYOKU],  
    V.[USERID],  
    V.[NAME],  
    CASE WHEN ISNULL(V.[JOUKYOU],'')='' AND V.FORMNM!='通知者設定' THEN '待機' ELSE V.[JOUKYOU] END AS [JOUKYOU]  
    FROM   
    EGGA0001 AS CM   
    INNER JOIN UD001121 AS M ON (CM.IDDOC = M.IDDOC)  
    INNER JOIN #VW_KAIFUROUTE_REPORT V ON(V.GPIDDOC = CM.IDDOC)  
    WHERE   
    CM.IDDOC=@IDDOC  
    ORDER BY  
    NO,NO2,NO3  
    DROP TABLE #VW_KAIFUROUTE_REPORT  
  
    IF ISNULL(@UUID,'')!=''  
    BEGIN  
        BEGIN TRY  
            BEGIN TRANSACTION   
            --キャッシュ情報削除  
            EXEC ZZSP_DELETE_CACHED_KAIFU @UUID  
            DELETE FROM CUD001123 WHERE UUID=@UUID  
            COMMIT  
        END TRY  
        BEGIN CATCH  
            ROLLBACK TRANSACTION  
            THROW  
        END CATCH  
    END  
END  
  