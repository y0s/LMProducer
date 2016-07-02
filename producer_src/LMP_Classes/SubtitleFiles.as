/*
    字幕クラス
*/

package LMP_Classes
{
	import flash.filesystem.File;

	public class SubtitleFiles
	{
		public var subtitlefile : File;

		public var cursubtitle : ObjectDataElem;
		public var update_f : Boolean;
		
		public var xmldata : XML;
		
		// コンストラクタ
		public function SubtitleFiles()
		{
			subtitlefile = new File();
			cursubtitle = null;
			update_f = true;     // 新規作成したときは初期値true、ファイルから読み込んだ時はfalse(別口で設定）
			
			xmldata = null;
		}
	}
}
	
	