package LMP_Classes
{
	import fl.motion.easing.Back;
	import flash.filesystem.File;

	// パブリッシュする際に必要な、対になった画像や映像ファイル名のコピー配列を保持する。
	// パブリッシュの際、各ファイルはベース名の重複を避け、同じ階層にコピーされる。
	
　　public class FilePublisher
	{
		public var srcfiles : Array;
		public var dstfiles : Array; // ベース名のみ
		
		public var filecopycount : int; // 現在コピー中のファイルインデックス。-1のときはコピー動作していない。

		public function FilePublisher() {
			
			srcfiles = new Array();  // Fileの配列
			dstfiles = new Array();
			filecopycount = -1;
		}

		// 	ダブりの無いファイルを生成する。
		public function NewFile( dst_folder : String, f : File ) : File
		{
			//trace( "f.basename=["+f.basename+"]" );
			
			var c : int = 0;
			var ext : String = getext( f.name ); 
			//trace( "ext =["+ext+"]" );
			var bas : String = delext( f.name );
	
			var filen : String;
	
		    for (var i : int = 0; i< dstfiles.length; i++ )
			{
				var df : File = dstfiles[i];
				
				if (df.name == f.name) c++;
				
				filen = bas+"_";
				
				if ( df.name.substring( 0, filen.length )==filen) c++
			}
			
			if (c==0) { filen = f.name; } else { filen = bas + "_" +  c.toString() + "."+ ext; }

			return new File( dst_folder + filen );
		}

		// ファイル名リストにファイルを追加。
		public function AddCopyFile( dst_folder : String, filename : String	) : String
		{
			if (filename == "" ) return "";
			
			var sf : File = new File( filename );
			var dst : File = NewFile( dst_folder, sf );
		
			srcfiles.push( sf );
			dstfiles.push( dst );
			
//			trace( "filename=[" + filename + "] dst.name=["+dst.url+"]" );
			
			return dst.url;
			
		}

		// コピーリストにあるファイルをまとめてコピーする。
		// 引数はプログレスバーの更新関数。
		
		public function CopyExecute( progressbarfnc : Object )
		{
			
			for (var i : int = 0; i< srcfiles.length; i++ )
			{
				var s : File = srcfiles[i];
				var d : File = dstfiles[i];
				
				s.copyTo(d,true);
				
				progressbarfnc( i+1, srcfiles.length+1 ); // 主にムービー等のコピーに時間が掛かると想定
			}
		
		}
		
		// タイマーでのコピー

		// コピー開始手続き
		public function CopyExecuteByTimer_Start( )
		{
			filecopycount = 0; // Copy スタート
		}
							
		// タイマーから呼ぶコピールーチン
		public function CopyExecuteByTimer_CopyAFile() : Number    // -1のときはコピー動作不可、2以上が戻ってきたら最後のファイルをコピーした(ダイアログを消して再描画など必要）
		{														   // 0-1のときはプログレス値
			if (filecopycount<0) return -1;
			
			if (filecopycount >= srcfiles.length)
			{
				filecopycount =-1; return 2;
			}
		
			var s : File = srcfiles[filecopycount];
			var d : File = dstfiles[filecopycount];
				
			s.copyTo(d,true);
			
			filecopycount++;
			
			return filecopycount/srcfiles.length;
		}
		

		// ファイル名を示す文字列からパス部分だけ取りだす。
		private function getpath( filename : String ) : String
		{
		     var i : int;
			 
			 for ( i=filename.length-1; i>=0; i--)
			 {
				 if (filename.charAt(i)=="/") 
				 {
					 return filename.substring( 0, i+1 );
				 }
	 
			 }
			 
			return "";
		}
		
		// ファイル名から拡張子以外を取得
		private function delext( filename : String ) : String
		{
			return filename.substring( 0, filename.indexOf(".") );
		}
		
		// ファイル名から拡張子を取得
		private function getext( filename : String ) : String
		{
			return filename.substring( filename.indexOf(".")+1, filename.length );
		}
		
		
		
    }
}