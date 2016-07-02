package LMP_Classes
{
	public class TimeCounter
	{
		public var underseconds : int; // 1/100 単位
		public var seconds : int;
		public var minutes : int;
		public var hours : int;
		
		public function SetSecondsInNumber( secondsInNumber : Number )　//　引数の値を時分秒、秒以下の各桁に分解する。
		{
			var sectmp : int = Math.floor( secondsInNumber );
			var mintmp : int;
			
			underseconds = Math.round((secondsInNumber-sectmp)*100);
			
			hours = sectmp / 3600;
		
			mintmp = sectmp-(hours*3600);
			minutes = mintmp/60;
			
			seconds = mintmp-(minutes*60);
		
		}

		// xx:xx:xx.xxx 形式の文字列をTimeCounterに代入する。QuickTimeSubtitle形式。入力データは1/1000秒単位

		private var	lefttoken : String;
		

		// あたえられた一文字が数字なら真。

		private function isNumber( n : String ) : Boolean
		{
			var  template : String = "0123456789";
			
			if (template.indexOf( n )<0 ) return false else return true;
		}

		// タイムカウンタ文字列分解用 次の非数字セパレータまでの数字を切り出す。セパレータは含まない。
		// 残り部分はlefttokenに代入される。

		private function gettoken_QTST( tcs : String ) : String
		{
			var i : int;
			var rv : String = "";
		
			for( i=0; i<tcs.length; i++ )
			{
				var tmp : String;
				tmp = tcs.charAt( i );
				if (!isNumber( tmp )) break;
				
				rv = rv + tmp;
			}

			if (i<tcs.length)
			{
				lefttoken = tcs.slice( i+1, tcs.length );
			}
			else
			{
				lefttoken = "";
			}
		
			return rv;
		}

		public function SetSecondsInString_QTST( secondsInString : String ) : void
		{
			
//			hours = parseInt( secondsInString.slice( 0,1 ) );
//			minutes = parseInt( secondsInString.slice( 3,4 ) );
//			seconds = parseInt( secondsInString.slice( 6,7 ) );
//			underseconds =  Math.round((parseFloat( secondsInString.slice( 9,11 ) )/10) ); // 下一桁は四捨五入

			var tmp : String;

			hours = parseInt( gettoken_QTST( secondsInString ) );
			tmp = lefttoken;
			minutes = parseInt( gettoken_QTST( tmp ) );
			tmp = lefttoken;
			seconds = parseInt( gettoken_QTST( tmp ) );
			tmp = (lefttoken+"000").slice( 0,2 );
			underseconds = Math.round( parseFloat( tmp ) /10 );
		}

		public function GetSecondsInNumber() : Number // 中身を秒数（小数点以下つき）で返す
		{
			return hours*3600+minutes*60+seconds+(underseconds/100);
		}
		
		//
		//  整数から文字列への変換で一桁なら頭にゼロを足す。
		//
		public function tostring00( i : int ) : String
		{
		var result : String;
	
	
    		result = i.toString();
			if (result.length==1) result = "0"+result;
	
			return result;
		}
		
		//
		// 文字列化
		//
		public function ToString( hms : Boolean ) : String
		{
			
			if (hms) return tostring00(hours) + 'h ' + tostring00(minutes) + 'm ' + tostring00(seconds) +'s ' +  tostring00(underseconds)
			else return tostring00(hours) + ':' + tostring00(minutes) + ':' + tostring00(seconds) +'.' +  tostring00(underseconds); 
		}

		
	}
	
}