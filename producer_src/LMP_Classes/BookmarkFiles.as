/*
    しおりクラス
*/

package LMP_Classes
{
	import flash.filesystem.File;

	public class BookmarkFiles
	{
		public var bookmarkfile : File;

		public var curbookmark : ObjectDataElem;
		public var update_f : Boolean;

		public var xmldata : XML; 


		// コンストラクタ
		public function BookmarkFiles()
		{
			bookmarkfile = new File();
			curbookmark = null;
			update_f = true;     // 新規作成したときは初期値true、ファイルから読み込んだ時はfalse(別口で設定）
			xmldata = null;
			
		}
	}
	

}
	