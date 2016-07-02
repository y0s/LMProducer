/*
    エフェクトファイルクラス

*/

package LMP_Classes
{
	import flash.filesystem.File;

	public class EffectFiles
	{
		public var effectfile : File;
		public var effectlabel : String;
		public var cureffect : ObjectDataElem;
		
		public var checked : Boolean; 
		public var update_f : Boolean;　// 更新フラグ
		
		public var belongto_vf : VideoFiles;

		public var xmldata : XML;

		// コンストラクタ
		public function EffectFiles( elabel : String, vf : VideoFiles )
		{
			this.effectlabel = elabel;
	
			effectfile = new File();
			cureffect = null;
		
		    checked = true;
			update_f = true;     // 新規作成したときは初期値true、ファイルから読み込んだ時はfalse(別口で設定）
			
			xmldata = null;
			
			belongto_vf = vf;
	
		}
	}

}
