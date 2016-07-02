/*
	エフェクト種別識別用定数
*/

package LMP_Classes
{

    public final class ObjectDataConstants
	{
        public static const OBJECTTYPE_EFFECT_CIRCLE : String = 'Circle'; // 円エフェクト
        public static const OBJECTTYPE_EFFECT_ARROW : String = 'Arrow'; // 矢印エフェクト

/*  今回は未実装
        public static const OBJECTTYPE_SQUARE : String = 'Square';
    	public static const OBJECTTYPE_CROSS : String = 'Cross';
	    public static const OBJECTTYPE_LINE : String = 'Line';
	
	    public static const OBJECTTYPE_*** ...
*/

        public static const OBJECTTYPE_EFFECT_PICTURE : String = 'Picture'; // 画像エフェクト

		public static const OBJECTTYPE_BOOKMARK : String = "Bookmark"; // しおり
		public static const OBJECTTYPE_SUBTITLE : String = "Subtitle"; // 字幕


		public static const OBJECTTYPE_MATRIXBOOKMARK : String = "MatrixBookmark"; // Matrixしおり


		public static const NUM_OF_VIDEOS = 3;　　　　　　// ビデオファイルの数
		public static const NUM_OF_EFFECTFILES = 4;      // エフェクトファイルの数
		public static const NUM_OF_SUBTITLEFILES = 2;		// 字幕ファイルの数
		public static const NUM_OF_BOOKMARKLISTFILES = 1;	// しおりリストファイルの数
/*		
		public static const NUM_OF_BOOKMARKMAPFILES = 1; // しおりクリッカブルマップの数
*/		

		public static const DEFAULT_FONTSIZE = 15;		// デフォルトのフォントサイズ
	}
	
}
