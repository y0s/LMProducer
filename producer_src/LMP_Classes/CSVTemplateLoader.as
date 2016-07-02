//
// csv形式のMatrixしおりテンプレートファイルを読み込むためのユーティリティークラス
//
// Excelからcsvを出してみたところ、各セルのデータは
// ・ダブルクォートを含むデータと含まないデータ
// ・ダブルクォートの内側で改行
// が認められるため、単純なカンマ区切りテキストとしては対応出来ない。
// 


package LMP_Classes
{
	import LMP_Classes.*
	import flash.filesystem.FileStream;
	
	public class CSVTemplateLoader
	{

		public var LeftToken : String = "";

		public function CSVTemplateLoader()
		{
			// constructor code
		}

 		// 文字列先頭末尾のダブルクォーテーションを取り除く
		// ダブルクォートが無い場合は何もしない。
	
	    public function Trimquaut( token : String ) : String
		{
			var qi : QTST_Importer = new QTST_Importer();
			
			token = qi.Trim( token, "" );
		
			if (token.charAt(0)=='"') token = token.substr( 1 );
			if (token.charAt( token.length-1) =='"' ) token = token.substr( 0, token.length-1 );
		
			return token;
		}

	
		// ファイル中、ダブルクオーテーション内側の復帰改行を潰す。
		// Matrixしおりテンプレートを前提とした機能。テンプレ上では、セルの内容の改行はレイアウト上意味があるが、
		// 現在のところ、LMProducerではその形の表示をしないため未サポートとする。
		// 
		// なお、最初の文字以前はダブルクオーテーションの外側想定。
		// 
		// パース前の前処理として実行する。
	
		public function Killcr( txt : String ) : String
		{
			var qf : Boolean = false;
			var rv : String = "";
			
			for (var i:int =0; i< txt.length; i++ )
			{
			    var ch : String = txt.charAt(i);
				
				if ( qf )
				{
					if (ch=='"') qf = false;
					
					if (ch.charCodeAt(0)<0x20)	ch = " ";
					
				}
				else
				{
					if (ch=='"') qf = true;
					
				}
				
				rv=rv+ch;
				

			}
		
			return rv;
		}

		// csv用トークン取得。トークンの切れ目はカンマ区切りと文字列末のみチェックする。
		// ダブルクオートの中は追う。行単位での処理を前提とするが
		// ダブルクオートの内部に改行がある場合は例外。

		public function GetToken( line : String ) : String
		{
			var rv : String = "";
			var qf : Boolean = false;
		
			for (var i : int =0; i<line.length; i++ )
			{
				var c : String = line.charAt(i);
				
				if (qf)
				{	// ダブルクオーテーションの中
					if (c =='"' ) qf = false;
					rv= rv+c;
				}
				else
				{	// ダブルクオーテーションの外
					if (c == '"' ) qf = true;
					if (c == ',' )
					{
						LeftToken = line.slice( i+1 );
						return Trimquaut(rv);
					}
					else
					{
						rv=rv+c;
					}
				}
			}
			
			if (qf) LeftToken = null else LeftToken = "";	// ダブルクオートの内部で行末に達した場合はLeftTokenがヌルになる。それ以外は""になる。
															// これでダブルクオート内での改行を検出する。
			return Trimquaut(line);
	
		}
	}
}
