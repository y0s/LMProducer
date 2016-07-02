//
// Matrixしおりデータトップレベル
//

package LMP_Classes
{
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import LMP_Classes.*
	import flash.geom.Point;
	import fl.video.INCManager;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.events.*;
	import flash.utils.escapeMultiByte;
	import flash.filesystem.*;
	import flash.errors.*;
	import flash.xml.XMLDocument;

	public class MatrixBookmarkData
	{
		
		public var CurMatrixBookmark : ObjectDataElem;
		
		// Matrixしおりデータファイル
		public var xmlmatrixbookmarkfilen : String; 
		public var xmlmatrixbookmarkfile : File;
		public var xmlmatrixbookmarkurl : String;
		
		public var xmlmatrixbookmarkdata : XML;
	
		// Matrixテンプレートファイル
		public var csvmatrixtemplatefilen : String;
		public var csvmatrixtemplatefile : File;
		public var csvmatrixtemplatestring : String;
		
		
		public var xmlfilefilter : FileFilter; 
		public var csvfilefilter : FileFilter; 


		// 行と列の原点オフセット座標(DataGrid原点）
		// セル「No.」の位置で自動判別する予定。
		public var offset_x : int;
		public var offset_y : int;

		public var cells : Array; // Array（　MatrixBookmarkCell　）二次元配列
		public var curcell : MatrixBookmarkCell;
		　
		public var titles : Array; // Array( String ) 二次元配列
		
		public var titl : String; // タイトルバーキャプション。Matrixしおりテンプレートの最初の要素
		
		public var update_f : Boolean;
		

		public const OffsetWord : String = "NO.";
		
		public var errormes  : String = "";
		private const xmlheadder = '<?xml version="1.0" encoding="UTF-8" ?>\n';
		
		public var nowloading : Boolean = false;

		public var setupgrid : Boolean = false;

		private var xr, xc : int; // XMLLoad用内部変数
		

		public function MatrixBookmarkData()
		{
			// constructor code
			
			CurMatrixBookmark = null;
			
			xmlmatrixbookmarkfilen = ""; 
			xmlmatrixbookmarkfile = null;
			xmlmatrixbookmarkurl = "";
			
			xmlmatrixbookmarkdata = null;

			csvmatrixtemplatefilen = "";
			csvmatrixtemplatefile = null;
			csvmatrixtemplatestring = "";
			
			xmlfilefilter = new FileFilter( "MatrixしおりXMLファイル(XML files)","*.xml" );
			csvfilefilter = new FileFilter( "Matrixしおりテンプレートファイル（CSV files)","*.csv" );
	
			offset_x = -1;
			offset_y = -1;
		

			cells = null;
			titles = null;

			titl = "";

			update_f = true;	// テンプレートを読み込んだ時もtrue、XMLファイル読み込んだ時はfalse(別口で設定）
								// Matrixしおりに新規作成は無い。テンプレートを作成する機能が無い以上、
								// テンプレート読み込みが新規作成に相当する
								
			curcell = null;
			
			nowloading = false;
			
			xr = -1;
			xc = -1;
			
			setupgrid = false;
			
			
		}
		
		// パブリッシュ前の環境保存／復帰
		private var purl : String;
		private var pfilen : String;
		private var pfile : File;
	
		public function PushEnv()
		{
			purl = xmlmatrixbookmarkurl;
			pfilen = xmlmatrixbookmarkfilen;
			pfile = xmlmatrixbookmarkfile;
		}
	
		public function PopEnv()
		{
			xmlmatrixbookmarkurl = purl;
			xmlmatrixbookmarkfilen = pfilen;
			xmlmatrixbookmarkfile = pfile;
		}
	
	
		// 文字列中の改行コード等を潰す
		
		private function killcr_simp( txt : String ) : String
		{
			var rv : String = "";
			
			for (var i:int =0; i< txt.length; i++ )
			{
			    var ch : String = txt.charAt(i);
				if (ch.charCodeAt(0)<0x20) ch = " ";
					
				rv=rv+ch;
			}
		
			return rv;
		}
		
		
		// ブラウズしてMatrixしおりXMLをファイルから読み込む
		public function LoadMatrixBookmarkXMLFromFile()
		{
			errormes = "";
			
			if ( xmlmatrixbookmarkurl == "" ) xmlmatrixbookmarkurl = File.documentsDirectory.url;
			
			xmlmatrixbookmarkfile = new File(xmlmatrixbookmarkurl);
			xmlmatrixbookmarkfile.browseForOpen( "MatrixしおりXMLファイルを指定してください",[xmlfilefilter]);

			xmlmatrixbookmarkfile.addEventListener( Event.SELECT, loadfileselected );
			nowloading = true;
		}
				
		private function loadfileselected( e : Event )
		{
			
			xmlmatrixbookmarkfile.removeEventListener( Event.SELECT, loadfileselected );
			
			xmlmatrixbookmarkurl = xmlmatrixbookmarkfile.parent.url;

			xmlmatrixbookmarkfile.addEventListener( Event.COMPLETE, loadcomplete );
			xmlmatrixbookmarkfile.addEventListener( IOErrorEvent.IO_ERROR, loaderror );
			
			xmlmatrixbookmarkfile.load();

			//trace( "loadselected .. " );
		}	
		
		private function loadcomplete( e : Event )
		{
			xmlmatrixbookmarkfilen = xmlmatrixbookmarkfile.url;
	
			xmlmatrixbookmarkdata = null;
			xmlmatrixbookmarkdata = new XML( xmlmatrixbookmarkfile.data );
			
			if (xmlmatrixbookmarkdata.name() != 'lmMatrix' )
			{
				errormes = "MatrixしおりXMLファイルではありません";
				return;
			}

			SetupMatrixBookmarkFromXML();

			xmlmatrixbookmarkfile.removeEventListener( Event.SELECT, loadfileselected );
			xmlmatrixbookmarkfile.removeEventListener( Event.COMPLETE, loadcomplete );
			xmlmatrixbookmarkfile.removeEventListener( IOErrorEvent.IO_ERROR, loaderror );
			
			nowloading = false;
		}		
		
	
		private function loaderror( e :Event )
		{
			xmlmatrixbookmarkfile.removeEventListener( Event.SELECT, loadfileselected );
			xmlmatrixbookmarkfile.removeEventListener( Event.COMPLETE, loadcomplete );
			xmlmatrixbookmarkfile.removeEventListener( IOErrorEvent.IO_ERROR, loaderror );
			errormes = "LoadMatrixBookmark : File I/O Error";
			
			nowloading = false;
		}
	
	
		// cellsにカラム数cnからなる空行を一行追加。	
		public function addblankline( cn : int ) : void
		{
			var lin : Array = [];

			for ( var i : int =0; i<cn; i++ )
			{
				var mbc : MatrixBookmarkCell = new MatrixBookmarkCell();
				lin.push( mbc );
			}
			cells.push( lin );
		}

		// 表示用プロジェクト名を生成する
		public function GenDispProjectName( url : String ) : String
		{
			var f : File = new File( url );
			
			return delext( f.name );
			
			//return delext( genmbprojectfilename( url ) );
		}
	
		// XMLデータに書かれているプロジェクトパス名（相対、html)からProducer上で使用するパス名(絶対url、xml)を生成する。
		public function genchildprojectname( n : String ) : String
		{
			var ft : File = new File( xmlmatrixbookmarkurl );
			var ft2 : File = ft.resolvePath( n ); 
			
			//trace( 'n=' + n );
			
			return delext( ft2.url ) + '.xml';
		}
	

		// XMLデータからMatrixしおり配列をセットアップする
		
		public function SetupMatrixBookmarkFromXML()
		{
			var itm : XML = null;
			var tableHeader : XMLList = xmlmatrixbookmarkdata.tableHeader;
			var tableBody : XMLList = xmlmatrixbookmarkdata.tableBody;
			var columns : int = xmlmatrixbookmarkdata.columns;
			var headerColumns : int = xmlmatrixbookmarkdata.headerColumns;
			var multiRowHeaderColumns : int = xmlmatrixbookmarkdata.multiRowHeaderColumns;
			var dataColumns : int = xmlmatrixbookmarkdata.dataColumns;
			
			/*
			trace( "columns =" + columns );
			trace( "headerColumns =" + headerColumns );
			trace( "multiRowHeaderColumns =" + multiRowHeaderColumns );
			trace( "dataColumns =" + dataColumns );
			*/
			
			cells = new Array();
			offset_x = -1;
			offset_y = -1;
		
			addblankline( columns ); xr=0;
			cells[xr][0].caption = xmlmatrixbookmarkdata.title;
			//trace( "title=" + cells[row][0].caption );
			titl = xmlmatrixbookmarkdata.title;

			addblankline( columns ); xr++;
			xc = 0;
			for each ( itm in tableHeader.item ) 
			{
				cells[xr][xc].caption = killcr_simp(itm.text);
				//trace( "item.text=" + itm.text );
				
				if ( itm.text.toUpperCase() == OffsetWord)
				{
					offset_x = xc; offset_y = xr; //trace( "offset=" + offset_x + "," + offset_y );
				}
				
				xc++;
			}
			
			xr++;
			
			for each ( itm in tableBody.item )
			{
				var rows : int = itm.rows;
				for ( var i : int = 0; i< rows; i++ ) addblankline( columns );
		
				xc=0;
				cellsetrecursive( itm );
			}
			
			setupgrid = true;
		}

		function  cellsetrecursive( itm : XML )
		{
			var iitm : XML = null;
			var iiitm : XML = null;
			var hdr : XML = null;
			var tc : int;
			var f : Boolean;
			
			if ( itm.type=="multiRow" )
			{
				cells[xr][xc].caption = killcr_simp(itm.text);
				// trace( 'tit:xr, xc = ' + xr +',' + xc + "  text=" + cells[xr][xc].caption );					
				xc++;
			}
			
			
			for each ( iitm in itm.item )
			{
				cellsetrecursive( iitm );
			}
			
			tc = xc;
			
			f = false;
			
			for each ( iitm in itm.item )
			{
				for each ( iiitm in iitm.header.item )
				{
					cells[xr][xc].caption = killcr_simp(iiitm.text); //trace( 'hdr:xr, xc = ' + xr +',' + xc + "  text=" + cells[xr][xc].caption );
					xc++
				}
			
				for each ( iiitm in iitm.data.item )
				{
					cells[xr][xc].caption = killcr_simp(iiitm.text); //trace( 'dat:xr, xc = ' + xr +',' + xc + "  text=" + cells[xr][xc].caption );

					var bm : XML;
					
					for each ( bm in iiitm.bookmark )
					{
						curcell = cells[xr][xc];
						
						CurMatrixBookmark = AddMatrixBookmarkElem( ObjectDataConstants.OBJECTTYPE_MATRIXBOOKMARK, killcr_simp(bm.text), bm.startTime, bm.endTime, bm.startTime, null );
						
						CurMatrixBookmark.belongto_pf.filename = genchildprojectname( bm.path );
						//trace( "pf =" + CurMatrixBookmark.belongto_pf.filename );

						CurMatrixBookmark.belongto_pf.vf_index = bm.videoId;
						CurMatrixBookmark.belongto_pf.videofilename = "";
					
					}
					

					xc++
					if (xc>=cells[xr].length) xr++;
				}
				
				xc = tc;
				
				f=true;
			}
			
			if (f) xc--;
			
		}
		
		// 指定ファイル名で指定XMLオブジェクトをファイルに書き出す。
		private function xml_savetofile( file : File, xmldata : XML )
		{  
			var stream : FileStream = new FileStream();

			if (file.name.indexOf(".")<0) { file = new File( file.url + ".xml" ); }

			try
			{
				stream.open( file, FileMode.WRITE);
				stream.writeUTFBytes( xmlheadder + xmldata.toXMLString() );
		
				
			} catch( error:IOError ) {

				errormes = "xml_savetofile:File I/O Error";
	
			} finally {
				
				stream.close();
				
			}
		}

		// 上書き保存 xmlprojectfile.urlが""の場合はSaveAsを呼ぶこと。
		// パブリッシュに使う場合は publishmodeをtrueで呼ぶ。
		public function SaveMatrixBookmarkXMLToFile( publishmode : Boolean )
		{
			var stream : FileStream = new FileStream();

			if ( !publishmode )
			{
				if (xmlmatrixbookmarkfilen == "") { errormes = "SaveMatrixBookmark: Matrixbookmark filename is not specified."; return; }
				xmlmatrixbookmarkfile = new File( xmlmatrixbookmarkfilen );
			}
			
			xmlmatrixbookmarkdata = GenMatrixBookmarkXML( xmlmatrixbookmarkfile, publishmode );

			xml_savetofile( xmlmatrixbookmarkfile, xmlmatrixbookmarkdata );

		}

		// 拡張子がついていなかったら補う。
		private function addextention( f : File, ext : String ) : File
		{
			var url : String = f.url;
			var eext : String = "."+getext( url );
		
			if ( ext.toUpperCase() == eext.toUpperCase())
			{
				return f;
			}
			else
			{
				return new File(url+ext);
			}
		
		}

		// ファイル名から拡張子を取得(ピリオド含まない）
		private function getext( filename : String ) : String
		{
			if (filename.indexOf(".")<0) return "";

			return filename.substring( filename.indexOf(".")+1, filename.length );
		}

		// ファイル名から拡張子以外を取得
		private function delext( filename : String ) : String
		{
			return filename.substring( 0, filename.indexOf(".") );
		}


		// Matrixしおりをブラウズして保存
		
		public function SaveAsMatrixBookmarkXMLToFile( projectpath : String ) : void
		{
			var pjp : File = new File( projectpath );
			
			xmlmatrixbookmarkfile = pjp.resolvePath( '..' );
			//trace( xmlmatrixbookmarkfile.nativePath );

		
			errormes = "";
			xmlmatrixbookmarkfile.addEventListener( Event.SELECT, savembfileselected );

			xmlmatrixbookmarkfile.browseForSave( "MatrixしおりXMLファイルを保存します" /*,[filter] */ ); // 第二引数がありそうなものだが。
		}

		private function savembfileselected( e : Event )
		{
			xmlmatrixbookmarkfile.removeEventListener( Event.SELECT, savembfileselected );
	 
			xmlmatrixbookmarkfile = addextention( xmlmatrixbookmarkfile, ".xml" );

			xmlmatrixbookmarkurl = xmlmatrixbookmarkfile.parent.url;
			xmlmatrixbookmarkfilen = xmlmatrixbookmarkfile.url;
			
//			trace( "filen=" + xmlprojectfilen );
			
			SaveMatrixBookmarkXMLToFile( false );
		}


		//
		// cells上のmultiRowで子階層の項目数(親の占有行数）をカウントする。
		// cells[r][c]は親階層の一番上のセルと仮定
		//
		
		function countchilditems( r : int, c : int ) : int
		{
			var cc : int = 0;
			var i : int = r;
			
			do
			{
				if ( i >= cells.length ) break;
				
				if ((i!=r) && (cells[i][c].caption != "" )) break;
				cc++;
				
				i++;
				
			} while( true );
			
			return cc;
		}
	
	
		// プロジェクト名内部形式（絶対url、xml)からXML出力形式(相対、html)に変換
		function genmbprojectfilename( fullpath : String ) : String
		{
		    //trace( 'x =' + xmlmatrixbookmarkurl + '      f =' + fullpath );
		
			var f1 : File = new File( xmlmatrixbookmarkurl );
			var f2 : File = new File( fullpath );
			
			var rv : String = f1.getRelativePath( f2 );
			
			rv = delext( rv ) + '.html';
		
			//trace ( 'genmbprojectfilename =' + rv ); 			
			return rv;
		}


		// プロジェクト名内部形式（絶対url、xml)からXML出力形式(相対、html)に変換のパブリッシュモード用
		// (パス構成固定）
		function genmbprojectfilename_forpub( fullpath : String ) : String
		{
			var rv : String = "";
			var f : Boolean = false;
			
			for ( var i = fullpath.length-1; i>=0; i-- )
			{
				var c : String = fullpath.charAt( i );
				
				if (f)
				{
					if ((c=="/") || ( c== "\\" )) break;
				}
				else
				{
					if ((c=="/") || ( c== "\\" )) f = true;  
				}
				
				rv = c + rv;                         // 後ろから舐めてパスデミリタを二回引っかけたら終わり。
			}
		
			rv = delext( rv ) + '.html';
		
			//trace ( 'genmbprojectfilename =' + rv ); 			
			return rv;
		}

		//
		//	保存用にMatrixしおりXML生成
		//
		
		public function GenMatrixBookmarkXML( basefile : File, publishmode : Boolean ) : XML
		{
			if ( cells == null ) return null; // cellsが生成されてなかったら帰る

			errormes = "";
			
			var rv : XML = null;
			var itm : XML = null;
			var iitm : XML = null;
				
			var i : int = 0;
			var j : int = 0;
			
			//if (basefile.extension!= "xml") basefile.extension = "xml";
			if (basefile.name.indexOf(".")<0) { basefile = new File( basefile.url + ".xml" ); } 
			
			rv = new XML( '<?xml version="1.0" encoding="UTF-8" ?><lmMatrix></lmMatrix>' );
			
			var columns : int = cells[0].length;
			var headercolumns : int = offset_x + 2;
			var multirowheadercolumns : int = offset_x;
			var datacolumns : int = columns-headercolumns;
			
			rv.appendChild( new XML( '<title>' + titl + '</title>' ) );
			rv.appendChild( new XML( '<columns>' + columns.toString()  + '</columns>' ) ); // カラム数
			rv.appendChild( new XML( '<headerColumns>' + headercolumns.toString()  + '</headerColumns>' ) ); // 行ヘッダカラム数
			rv.appendChild( new XML( '<multiRowHeaderColumns>' + multirowheadercolumns.toString()  + '</multiRowHeaderColumns>' ) ); // 先頭木構造ヘッダカラム数
			rv.appendChild( new XML( '<dataColumns>' + datacolumns.toString()  + '</dataColumns>' ) ); // データカラム（しおり登録操作可能カラム）数 
			
			var th : XML = new XML( '<tableHeader></tableHeader>' );
			
			for ( i = 0; i< columns; i++ )   // 見出し
			{
				itm = new XML( '<item></item>' );
				
				itm.appendChild( new XML( '<index>' + i.toString() + '</index>' ));
				itm.appendChild( new XML( '<text>'+cells[offset_y][i].caption+'</text>') );
				
				th.appendChild( itm );
			}
			
			rv.appendChild( th );
			
			var tb : XML = new XML( '<tableBody></tableBody>' );


			var hdrindex : int = 0;
		
			var indexes : Array =[];
		
			for ( i=0; i<columns; i++ )
			{
				indexes.push( 0 );
			}
			
			var itms : Array = [];

			
			for ( i=0; i<headercolumns; i++ )
			{
				itms.push( null );
			}
			
			var hdrdat : XML = null;

			for ( i=offset_y+1; i< cells.length; i++ )
			{
				for ( j = 0; j < columns; j++ )
				{
					var inde : int = indexes[j];

					var mbc : MatrixBookmarkCell = cells[i][j];
					var capt : String = mbc.caption;

					if ( j< multirowheadercolumns ) // マルチロウ領域
					{
						if (capt !="" )
						{
							itm = new XML( '<item></item>' );			
							
							itm.appendChild( new XML( '<index>' + inde.toString() + '</index>' ) );
							itm.appendChild( new XML( '<type>multiRow</type>' ) );
							
							var cn : int = countchilditems( i, j );
							
							itm.appendChild( new XML( '<rows>' + cn.toString() + '</rows>' ));
														
							indexes[j]++;
							
							if ( j>0 ) itms[j-1].appendChild( itm ); 
							if ( j==0 ) tb.appendChild( itm );					

							itms[j] = itm;						
						}
					}
					else  // シングルロウ領域
					{
						if ( j == multirowheadercolumns )　// ヘッダ領域開始
						{
							iitm = new XML( '<item></item>' );
							iitm.appendChild( new XML( '<index>' + hdrindex.toString() + '</index>' ) ); hdrindex++;
							iitm.appendChild( new XML( '<type>row</type>' ) );
							itms[j-1].appendChild( iitm );
						
							hdrdat = new XML( '<header></header>' );
							iitm.appendChild( hdrdat ); 

						}
						else
						{
							if (j == headercolumns ) // データ領域開始
							{
								hdrdat = new XML( '<data></data>' );
								iitm.appendChild( hdrdat ); 
							}
						}
						
						itm =  new XML( '<item></item>' );
						hdrdat.appendChild( itm );

					}

					if (itm==null) { errormes = "Matrixしおりの構造に問題があります。必要な見出しが無いなどです。テンプレートをご確認ください"; return null; }
					
					var idx : int =  j-headercolumns; // データ領域のインデックス
					
					if ( (j>=multirowheadercolumns) && (j<headercolumns ))
					{
						idx = j-multirowheadercolumns; // ヘッダ領域のインデックス
					}
					
					
					if (idx>=0)
					{
						itm.appendChild( new XML( '<index>' + idx.toString() + '</index>' ) ) 
					}
					
					if (capt!="")
					{
						itm.appendChild( new XML( '<text>' + capt + '</text>' ) );
					}
					else
					{
						if( j >= multirowheadercolumns ) itm.appendChild( new XML( '<text/>' ) ); // マルチロウ領域の空白セルはスキップ
					}
					
					
					if ( mbc.bookmarks.length!=0 ) // bookmark登録  内部的にはどのセルにもしおりは登録可能。UIで制約している。
					{
						for( var k :int = 0; k<mbc.bookmarks.length; k++ )
						{
							var bm : XML = new XML( '<bookmark></bookmark>' );
							bm.appendChild( new XML( '<index>' + k.toString() + '</index>' ) );
							
							var el : ObjectDataElem = mbc.bookmarks[k];
							
							bm.appendChild( new XML( '<text>' + el.labeltext + '</text>' ) );
							
							if ( publishmode )
							{
								bm.appendChild( new XML( '<path>' + genmbprojectfilename_forpub( el.belongto_pf.filename )+ '</path>' ) ); 
							}
							else
							{
								bm.appendChild( new XML( '<path>' + genmbprojectfilename( el.belongto_pf.filename )+ '</path>' ) );               // !!!!!!!!!!!						
							}
							
							bm.appendChild( new XML( '<videoId>' + el.belongto_pf.vf_index + '</videoId>' ) );
							bm.appendChild( new XML( '<startTime>' + el.Cues[0].seconds + '</startTime>' ) );
							bm.appendChild( new XML( '<endTime>' + el.Cues[1].seconds + '</endTime>' ) );
						
							itm.appendChild( bm );
						}
						
					}
					
				}
				
			}
		
			rv.appendChild( tb );
			
			return rv;
		}
		
		
		// 読み込まれたCSVデータ(csvmatrixtemplate.data) から、MatrixBookmarkCell による、二次元配列を作る
		
		public function CreateArray() : String // "":正常終了　それ以外：エラー　戻り値：エラー文字列
		{
			var ctl : CSVTemplateLoader = new CSVTemplateLoader();
			var txt : String = ctl.Killcr( String(csvmatrixtemplatestring) ); // ダブルクォーテーション内の改行コードを潰す
			
			var lines : Array = txt.split( "\n" );
		
			var i : int = 0;
			var j : int = 0;
			var maxcol : int = 0;
			var mbc : MatrixBookmarkCell;

			cells = new Array();
			offset_x = -1;
			offset_y = -1;

			for ( i = 0; i< lines.length; i++ )
			{
				var line : String = lines[i];
				var linea : Array = new Array();

				j = 0;
				
				do
				{
					var tok : String = ctl.GetToken( line ); line = ctl.LeftToken;

					mbc = new MatrixBookmarkCell();
					
					mbc.caption = tok;
					
					linea.push( mbc );
					
					if (tok.toUpperCase() == OffsetWord)
					{
						offset_x = j; offset_y = i; //trace( "offset=" + offset_x + "," + offset_y );
					}
					
					//trace( j + "["+ tok+ "]" );
					
					j++;
					
					if ( line==null ) break; // !!!!!!

				}
				while ( line != "" );
				
				if ( j　>　maxcol ) maxcol = j;
				
				//trace( i + " len =" + linea.length );
			
				cells.push( linea );
			}
			
			// 各行の長さを揃える
			for( i = 0; i< cells.length; i++ )
			{
				if ( cells[i].length<maxcol )
				{
					for (j=0; j<maxcol; j++)
					{
						cells[i].push( new MatrixBookmarkCell());
					}
				}
				
			}
			
			if ( offset_x <0 )
			{
				cells = null;
	
				return "Matrixしおりテンプレートファイルに問題があります（半角'No.'セルがありません）";
			}
			
			titl = cells[0][0].caption;

			setupgrid = true;

			return "";

		}


		// クリックしたセル座標（行列）から、実際のデータ位置(2次元配列上のインデックス）を出す。
		
		public function Screen2Cell( p : Point ) : Point
		{
			return new Point( p.x+offset_x, p.y+offset_y+1 ); // 一番上の行は見出しなので+1する。
		}



		// セル座標から、当該のセルデータを返す。
		// なお、ここで得られたセルデータのcaptionを書き替えることで、データグリッド側の表示が更新される
		// といった機能はない。
		
		public function GetCell( row : int, col : int ) : MatrixBookmarkCell
		{
			var p  : Point = Screen2Cell( new Point( row, col ) );
		 	return cells[p.x][p.y];
		}


		// 新規Matrixしおり追加メソッド XMLからの読み込み時などは、ed はNULLで呼ぶ。
		
		
		public function AddMatrixBookmarkElem( type : String, labeltext : String, ts : Number, te : Number, ct : Number, ed : ObjectData )
		{
　          var el : ObjectDataElem = new ObjectDataElem( null );
			var cue0, cue1 : ObjectCues;

			el.type = type;
			el.labeltext = labeltext;
			
			cue0 = ObjectCues(el.Cues[0]); cue1 = ObjectCues(el.Cues[el.Cues.length-1]);
			
			cue0.item_id = "0";
			cue0.nx = 0;
			cue0.ny = 0;
			cue0.angledegree = 0;
			cue0.scalex = 1;
			cue0.scaley = 1;
			cue0.seconds = ts;
			
			
			cue1.item_id = "1";
			cue1.nx = 0;
			cue1.ny = 0;
			cue1.angledegree = 0;
			cue1.scalex = 1;
			cue1.scaley = 1;
			cue1.seconds = te;
		
			el.ed = null;
				
			el.EffectShape( type, "" );	
			
			el.id = curcell.bookmarks.length.toString();
			
			el.AnimateEffectElem( ct );
			
			el.belongto_pf = new ProjectFiles();

			trace( "Paste:" + (el.belongto_pf == null) );

			if (ed != null)
			{
				el.belongto_pf.filename = ed.xmlprojectfilen;
				el.belongto_pf.vf_index = ed.GetCurvideoIndex();
				el.belongto_pf.videofilename = ed.curvideofile.filename;
			}
			
			curcell.bookmarks.push( el );
			
			return (el);
	    }

	
	}
	
}
