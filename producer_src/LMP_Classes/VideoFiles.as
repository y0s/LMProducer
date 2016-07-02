/*
    ビデオファイルクラス
*/

package LMP_Classes
{
	import flash.filesystem.File;
	
	public class VideoFiles
	{
		
		public var filename : String;
		
		public var effectfiles : Array; 
		public var cureffectfile : EffectFiles;
		
		public var current : Boolean;
		
		public var update_f : Boolean; // 更新フラグ
		
		public var movieLength : Number;
		
		public var framestep : Number; // コマ送りキーの動作間隔（単位：秒）
		
		public var fitscreen : Boolean;	// 映像をスクリーン外形(16:9)にFitさせる
	
		// コンストラクタ
		public function VideoFiles()
		{
			effectfiles = new Array( new EffectFiles( "エフェクトA", this ), new EffectFiles( "エフェクトB", this ),
								 	 new EffectFiles( "エフェクトC", this ), new EffectFiles( "エフェクトD", this ) );
	
			filename = "";
			
			cureffectfile = effectfiles[0];
			current = false;
			update_f = false;
			
			framestep = 1/29.97; // 29.97fps
			
			fitscreen = false;
			
			movieLength = -1;
			
		}
	}

}
