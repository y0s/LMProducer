//
//	Matrixしおりのセル単位のデータ
//

package LMP_Classes
{
	
	public class MatrixBookmarkCell
	{
		public var caption : String; // テンプレ文字列
		public var bookmarks : Array;  // ObjectDataElem (type = OBJECTTYPE_BOOKMARK ) の配列
		
		public var x, y : Number; // クリック可能セルの左上を原点とする、座標

		public function MatrixBookmarkCell()
		{
			caption = "";
			bookmarks = new Array();
			
		}

	}
	
}
