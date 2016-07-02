package LMP_Classes
{
	import flashx.textLayout.factory.StringTextLineFactory;
	import LMP_Classes.QTST_Color;

	public class QTST_Importer
	{
		public const QI_QTTEXT : String = "QTtext"; // roottag 
		public const QI_TIMESCALE : String = "timescale";
		public const QI_FONT : String = "font";
		public const QI_PLAIN : String = "plain";
		public const QI_SIZE : String = "size";
		public const QI_BACKCOLOR : String = "backColor";
		public const QI_TEXTCOLOR : String = "textColor";
		public const QI_WIDTH : String = "width";
		public const QI_HEIGHT : String = "height";
		public const QI_JUSTIFY : String = "justify";
		public const QI_TEXTENCODING : String = "textEncoding";

		public const QI_COMMAND_SEPARATOR_S : String = "{";
		public const QI_COMMAND_SEPARATOR_E : String = "}";
		public const QI_TIMECORD_S : String = "[";
		public const QI_TIMECORD_E : String = "]";
		
		
		public var timescale : Number;
		public var font : String;
		public var size : Number;
		public var bColor : QTST_Color;
		public var tColor : QTST_Color;
		public var w :Number;
		public var h : Number;
		public var justify : String;
		public var textEncoding : Number;
		
		public var cue0,cue1 : Number;
		public var subtitle : String;
	
		public function QTST_Importer()
		{
			// constructor code
			
			timescale = 0; // 100
			font = ""; // "Arial Unicode MS"
			size = 0; // 12
			
			bColor = new QTST_Color;
			tColor = new QTST_Color;
		
			bColor.r = 0; // 0
			bColor.g = 0; // 0
			bColor.b = 0; // 0
			tColor.r = 0; // 65535
			tColor.g = 0; // 65535
			tColor.b = 0; // 65535 
			w = 0; // 1280
			h = 0; // 0
			justify = ""; // "left";
			textEncoding = 0; // 256
			
			cue0 = 0;
			cue1 = 0;
			subtitle = "";
	
		}


		// txtがQTSubtitleファイルか。
		
		public function isQTSubtitle( txt : String ) : Boolean
		{
			var qi : QTST_Importer = new QTST_Importer();
			
			if (txt.indexOf( qi.QI_QTTEXT )>-1)
			{
				return true;
			}
			return false;
		}
	

		public var leftToken : String;

		// 文字が空白か
		
		private function isBlank( ch : String ) : Boolean
		{
			if (ch==null) return true;
			
			if (ch=="") return true;
			
			if (ch.charAt(0)==" ") return true; //　半角
			if (ch.charAt(0)=="　") return true; // 全角
			
			if (ch.charCodeAt(0)<0x20) return true;
			
			return false;
			
		}

		// '}'を区切り文字とし、'}'まで含む次のトークン取得。
		public function GetToken_m( txt : String ) : String
		{
			return GetToken_include( txt, QI_COMMAND_SEPARATOR_E );
		}
	
	
		// ']'を区切り文字とし、']'まで含む次のトークン取得
		public function GetToken_l( txt : String ) : String
		{
			return GetToken_include( txt, QI_TIMECORD_E );
		}
		
		// 指定区切り文字でトークン取得
		public function GetToken( txt : String, sepa : String ) : String
		{
			var i : int;
			var rv : String;
			
			rv = "";
			
			for( i=0; i<txt.length; i++ )
			{
				var tmp : String = txt.charAt( i );
				
				if (tmp==sepa)
				{
					break;
				}
				
				rv = rv + tmp;
			}
			
						
		    leftToken = txt.slice( rv.length, txt.length );
	
			return rv;
		}


		// 指定区切り文字でトークン取得 最後の区切り文字含む
		public function GetToken_include( txt : String, sepa : String ) : String
		{
			var i : int;
			var rv : String;
			
			rv = "";
			
			for( i=0; i<txt.length; i++ )
			{
				var tmp : String = txt.charAt( i );

				rv = rv + tmp;
				
				if (tmp==sepa)
				{
					break;
				}
				
			}
					
		    leftToken = txt.slice( rv.length, txt.length );
	
			return rv;
		}

		// 文字列前後の空白と括弧文字を削る
		public function Trim( txt : String, sepa : String ) : String
		{
			var i : int;
			var rv, tmp : String;
			
			rv = "";
			
			i = 0;
			
//			if (sepa == "") sepa = "  ";  // 括弧文字を指定しない場合はブランクのみ削る。
			
			while( i<txt.length )
			{
				tmp = txt.charAt( i );
				
				if (sepa.length<2)
				{
					if (!isBlank( tmp )) break
				}
				else
				{
					if ( (!isBlank( tmp )) &&  (tmp != sepa.charAt(0)  &&  (tmp != sepa.charAt(1)) ) ) break;
				}
				
				i++;
			}
			
			while( i<txt.length )
			{
				tmp = txt.charAt( i );
				
				if ((sepa.length>1) && (tmp == sepa.charAt(1))) break;
				
				rv = rv + tmp;
				
				i++;
			}
			
			i = rv.length-1;

			while( i>=0 )
			{
				tmp = rv.charAt( i )
				if ( !isBlank( tmp ) ) break;
			
				i--;
			}
			
//			trace( "<"+rv.slice( 0, i+1 )+">" );
			
			return rv.slice( 0, i+1 );
		}


		// Paramで指定されるデータを読み込む
	 
	
		function readparamcmd( param : String ) : String
		{
		// lefttoken潰すから注意。
			return GetToken( param	,":" );
		}

		function readparamvalue( param : String ) : String
		{
			var pos : int;
		
			pos = param.indexOf( ":" );
		
			if ((pos<0) || (pos>=param.length)) return "";
		
			return param.slice( pos+1, param.length );
		}
	
		public function ReadParam( param : String ) : void
		{
			var cmd, val : String;
			
			cmd = readparamcmd( param );	
			val = readparamvalue( param );

			trace( "REadParam:["+cmd+"]["+val+"]" );

			if (val=="") return; // パラメ－タを持たないコマンドを憶え無きゃならない事態
		　　　　　　　　　　　// になったらこの判定を外す。
		
		
			if ( cmd==QI_QTTEXT ) return;
		
			if ( cmd==QI_TIMESCALE )
			{
				timescale  = parseInt( val ); return;
			}
		
		
			if ( cmd==QI_FONT  )
			{
				font = val; return;
			}
		
				
			if ( cmd==QI_PLAIN  ) return;
				
		
			if ( cmd==QI_SIZE  )
			{
				size  = parseInt( val ); return;
			}
		
		
			if ( cmd==QI_BACKCOLOR )
			{
				bColor.r = parseInt( GetToken(val,",") ); val = leftToken;
				bColor.g = parseInt( GetToken(val,",") ); val = leftToken;
				bColor.b = parseInt( val );
				return;
			}
		
		
			if ( cmd==QI_TEXTCOLOR  )
			{
				tColor.r = parseInt( GetToken(val,",") ); val = leftToken;
				tColor.g = parseInt( GetToken(val,",") ); val = leftToken;
				tColor.b = parseInt( val );
				return;
			}
		
		
			if ( cmd==QI_WIDTH )
			{
				w  = parseInt( val ); return;
			}
		
			if ( cmd==QI_HEIGHT )
			{
				h  = parseInt( val ); return;
			}
		
			if ( cmd==QI_JUSTIFY )
			{
				justify = val; return;
			}
		
			if ( cmd==QI_TEXTENCODING  )
			{
				textEncoding  = parseInt( val ); return;
			}
		}
		
		
		public function ReadTimeCode( tc : String ) : void
		{
			
			
		}
		
	}

}