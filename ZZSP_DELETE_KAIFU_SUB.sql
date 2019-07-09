USE [RabitFlow]
GO
/****** Object:  StoredProcedure [dbo].[ZZSP_DELETE_KAIFU_SUB]    Script Date: 2019/07/09 10:26:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--【ZZSP_DELETE_KAIFU_SUB】
--【概要】
--    回付ルート種別選択のキャンセルボタン押下時、サブフォームのデータを削除する
--　　
--【引数】
--    @IDDOC：文書ID
--    @PARENTDOC：回付ルート設定の非表示親文書ID(仮)
ALTER PROCEDURE [dbo].[ZZSP_DELETE_KAIFU_SUB]

	@IDDOC INT,							-- 文書ID
    @PARENTDOC NVARCHAR(20),			-- 承認書の文書ID
    @UUID NVARCHAR(64)                  -- 文書キャッシュID

AS

DECLARE @OPERATE NVARCHAR(100)		-- 処理内容
DECLARE @PG NVARCHAR(100)			-- プログラム名
DECLARE @MSG NVARCHAR(MAX)          -- 文書キャッシュID

DECLARE @IDFRM_U06 NVARCHAR(4)      -- IDFRM（確認者設定）
DECLARE @IDFRM_U07 NVARCHAR(4)      -- IDFRM（起案箇所設定）
DECLARE @IDFRM_U23 NVARCHAR(4)      -- IDFRM（申請箇所設定）
DECLARE @IDFRM_U31 NVARCHAR(4)      -- IDFRM（合議箇所設定）

DECLARE @IDFRM_UD1 NVARCHAR(4)      -- IDFRM（確認者設定）
DECLARE @IDFRM_UD2 NVARCHAR(4)      -- IDFRM（合議箇所設定）
SELECT @OPERATE = '回付ルート設定(パターン登録)サブフォーム削除', @PG = 'ZZSP_DELETE_KAIFU_SUB', @MSG = '開始'
      ,@IDFRM_U06 = '1206', @IDFRM_U07 = '1207', @IDFRM_U23 = '1223', @IDFRM_U31 = '1231', @IDFRM_UD1 = '1111', @IDFRM_UD2 = '1112'

BEGIN TRY

	-- ログ
	EXEC ZZSP_INFO_LOG @MSG,@PG,@OPERATE,@IDDOC

	BEGIN TRANSACTION;
	-- 回付ルート設定の一時テーブルへ登録
	EXEC ZZSP_CREATE_CACHED_KAIFU @UUID,@IDDOC

	-- サブフォームの削除フラグを1に更新する
	UPDATE EGGA0001
	SET FGDEL = N'1'
	FROM EGGA0001 EGG
		-- 回付ルート設定
		LEFT JOIN CUD001206 U06			-- 確認者設定
			ON EGG.IDDOC = U06.IDDOC
		LEFT JOIN CUD001207 U07			-- 起案箇所設定
			ON EGG.IDDOC = U07.IDDOC
		LEFT JOIN CUD001223 U23			-- 申請箇所設定
			ON EGG.IDDOC = U23.IDDOC
		LEFT JOIN CUD001231 U31			-- 合議箇所設定
			ON EGG.IDDOC = U31.IDDOC
		-- 回付ルートパターン登録
		LEFT JOIN VW_UD001111 UD1			-- 確認者設定
		 	ON EGG.IDDOC = UD1.IDDOC
		LEFT JOIN VW_UD001112 UD2			-- 合議箇所設定
			ON EGG.IDDOC = UD2.IDDOC
	-- それぞれの親画面の文書IDと一致するか判別
	WHERE EGG.FGDEL = N'0'
	AND (
		-- 回付ルート設定
		U06.GUIItem275 = @PARENTDOC			-- 確認者設定の文書ID
		OR U07.GUIItem368 = @PARENTDOC		-- 起案箇所確認の文書ID
		OR U23.GUIItem368 = @PARENTDOC		-- 申請箇所確認の文書ID
		OR U31.GUIItem354 = @PARENTDOC		-- 合議箇所設定の文書ID
		-- 回付ルートパターン登録
		OR UD1.GUIItem357 = @IDDOC		-- 確認者設定の文書ID
		OR UD2.GUIItem174 = @IDDOC		-- 合議箇所設定の文書ID
	)

	-- サブフォーム紐付けテーブル
	UPDATE EGGA0020
	SET FGDEL = N'1'
	FROM EGGA0020 EGG
	WHERE EGG.FGDEL = N'0'
	AND EGG.IDDOC = @IDDOC

    -- キャッシュデータの削除
    DELETE FROM ZZHDK_DOCUMENT WHERE UUID=@UUID AND
                                (
                                    IDDOC=@IDDOC
                                    OR
                                    IDDOC IN (
										SELECT IDSUBDOC FROM DBO.EGGA0020 WHERE IDDOC=@IDDOC 
										AND IDSUBFRM IN (@IDFRM_U06,@IDFRM_U07,@IDFRM_U23,@IDFRM_U31
                                         ,@IDFRM_UD1,@IDFRM_UD2))
                                )

	COMMIT;

END TRY

BEGIN CATCH

	ROLLBACK TRANSACTION;

    -- エラーログ  
	EXEC ZZSP_ERR_LOG @PG,@OPERATE,@IDDOC;
	THROW;

END CATCH
