package LMP_Classes
{
	
	// 
	// Matrixbookmarkヘッダ配列 　
	// ヘッダと呼んでいるが、しおりを置けないセルは全てヘッダ扱いとしている。
	//
	
	
	public class MatrixBookmarkHdr
	{
		public var caption : String; // ヘッダテキスト
		public var offset : int; // 頭から何要素目からか。
		public var lines : int; 　// 占有行(列）数

		public function MatrixBookmarkHdr()
		{
			// constructor code
			caption = "";
			offset = -1;
			lines = 0;
		}

	}
	
}
