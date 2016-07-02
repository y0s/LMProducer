package LMP_Classes
{
	import flash.net.dns.AAAARecord;
	import flash.display.MovieClip;
	import fl.motion.Color;
	import flash.display.Loader;
	import flash.geom.Rectangle;
	import flash.display.Shape; 
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.events.*;
	import flash.utils.escapeMultiByte;
	import flash.filesystem.*;
	import flash.errors.*;
	import flash.xml.XMLDocument;
	import LMP_Classes.EditMarkers;
	import LMP_Classes.MatrixBookmarkData;

 	public class ObjectData
	{
		public var rootobj, parentobj : Object;
		
		public var Elem : Array;	// ObjectDataElemの配列   エフェクト／字幕／しおりの種別に関係無くここに列挙管理する。
									// Matrixしおりのみ別管理。プロジェクトの外側の存在だから。

		public var CurElem : ObjectDataElem;
		public var MultiSelection : Array; // ObjectDataElemの配列。複数選択時にはこちらを使う。
										　 // 選択数１の時にも、CurElemが0番目に入っている場合もあるが、単数の場合は従来の機構を使う。
										　 // 複数選択されているかどうかは、MultiSelection.Lengthを確認する。
										
										

		public var updatefnc : Object; // 表示要素更新関数
		public var makemask : Object; // マスク生成関数
				
		public var Bxs, SelectedBx : MovieClip; // 編集用のバウンディングボックス表示用。

		public var errormes : String;			// エラーメッセージ
		public var alartmes : String;			// 警告メッセージ

		public var xmlprojectdata : XML;
		public var porg_w, porg_h : Number; // 立ち上げ時（16:9)のPlayerのサイズ。


		public var videofiles : Array;
		public var subtitlefiles : Array;
		public var bookmarkfiles : Array;

		public var curvideofile : VideoFiles;
		public var cursubtitlefiles : SubtitleFiles;
		public var curbookmarkfiles : BookmarkFiles;


		public var projecttitle : String;
		public var returnurl : String;

		public var xmlprojectpath : String;
		
		public var xmlprojectfilen : String; 
		public var xmlprojectfile : File;
		
		public var filefilter : FileFilter; 
	
		private const xmlheadder = '<?xml version="1.0" encoding="UTF-8" ?>\n';
		private var loadcount : int = 0;

		private var xmlprojectfile_resav : File;
		private var xmlprojectfilen_resav : String;
		public var fpub : FilePublisher;
		
		
		const movieviewer_swf : String = "LMPlayer.swf";　// Movieビューワのswf
		const movieviewer_html : String = "LMPlayer_template.html"; // Movieビューワのhtmlテンプレート 
		const movieviewer_js : String = "LMPlayer.js"; // MovieビューワのJavascriptモジュール
		
		const matrixviewer_temphtml : String = "LMMatrix_template.html";
		const matrixviewer_html : String = "LMMatrix.html";
		const matrixviewer_js : String = "lmmatrix.js";
		const matrixviewer_css : String = "lmmatrix.css";
	
		
		public var htmlfile : File; 
		public var htmlfilename : String; // 配置するhtmlファイル名 
		
		
		public var Drx : int; // ドラッグ開始座標
		public var Dry : int; // (ステージ座標）		
		
	    public var SelDrf : Boolean; // 選択ドラッグ中
		public var MovDrf : Boolean; // 移動ドラッグ中。上とは排他 
		
		public var nowloading : Boolean; // ロード処理中（ダイアログ出してる間も）は真
		
		
		public var pub_mbd  : MatrixBookmarkData; // Matrixしおりを同時にパブリッシュするため
		

		// コンストラクタ
		public function ObjectData( _rootobj, _parentobj : Object, _porg_w, _porg_h : Number, _makemask : Object, _updatefnc : Object, _updatefnc2 : Object, _updatefnc3 : Object )
		{
			// constructor code
			rootobj = _rootobj;
			parentobj = _parentobj;

			makemask = new Object;
			makemask["makemask"] = _makemask;

			updatefnc = new Object;
			updatefnc["UpdateChangeCurrentElem"] = _updatefnc;
			updatefnc["UpdateChangeCurrentElem2"] = _updatefnc2;
			updatefnc["UpdateChangeCurrentElem3"] = _updatefnc3;
			Bxs = new MovieClip();
			SelectedBx = new MovieClip();

			Bxs.mask = makemask["makemask"]( rootobj ); 
			parentobj.addChild( Bxs );
			Bxs.x = -parentobj.x; //                         ←追加
			Bxs.y = -parentobj.y; //　　　　　　　　　　　　 ←追加
			
			parentobj.addChild( SelectedBx );
			SelectedBx.x = -parentobj.x; //     
			SelectedBx.y = -parentobj.y; //			
					
			
			SelectedBx.mask = makemask["makemask"]( rootobj ); 
			parentobj.addChild( SelectedBx );
			SelectedBx.x = -parentobj.x; //
			SelectedBx.y = -parentobj.y; //
			
			SelectedBx.mouseEnabled = false;

			Elem = new Array();

			xmlprojectfilen = "";
			xmlprojectfile = null;
			xmlprojectpath = "";
			
			filefilter = new FileFilter( "XML files, ELAN files, QuickTime Subtitle files","*.xml;*.eaf;*.txt" );

			errormes = "";
			alartmes = "";
			
			porg_w = _porg_w;
			porg_h = _porg_h;
			
			nowloading = false;
			
			pub_mbd = null;
			
			InitFiles();
			
			// 今回は以下のクラスは最下層のエレメントをぶら下げない実装。注意。
/*			videofiles = new Array( new VideoFiles(), new VideoFiles(), new VideoFiles() );
			subtitlefiles = new Array( new SubtitleFiles(), new SubtitleFiles() );
			bookmarkfiles = new Array( new BookmarkFiles() );
		
	 		curvideofile = videofiles[0];
			cursubtitlefiles = subtitlefiles[0];
			curbookmarkfiles = bookmarkfiles[0];
		
			
			//projecttitle = "DST映像プロジェクト編集ツール";
			projecttitle = "LMProducer";
			returnurl = 'index.html';
			
			fpub =  null;
			
			Drx = 0;
			Dry = 0;
			SelDrf = false;
			MovDrf = false;
			
			MultiSelection = new Array();
			
			htmlfile = null;
			htmlfilename = "";
*/
			
		}

		public function InitFiles()
		{
						// 今回は以下のクラスは最下層のエレメントをぶら下げない実装。注意。
			videofiles = new Array( new VideoFiles(), new VideoFiles(), new VideoFiles() );
			subtitlefiles = new Array( new SubtitleFiles(), new SubtitleFiles() );
			bookmarkfiles = new Array( new BookmarkFiles() );
		
	 		curvideofile = videofiles[0];
			cursubtitlefiles = subtitlefiles[0];
			curbookmarkfiles = bookmarkfiles[0];

			projecttitle = "LMProducer";
			returnurl = 'index.html';
			
			fpub =  null;
			
			Drx = 0;
			Dry = 0;
			SelDrf = false;
			MovDrf = false;
			
			MultiSelection = new Array();
			
			htmlfile = null;
			htmlfilename = "";
			
		}


		// 更新フラグを一斉操作
		public function AllUpdate( flag : Boolean )
		{
			
			for ( var i : int =0; i<videofiles.length; i++ )
			{
				var vf : VideoFiles = videofiles[i];
				
				vf.update_f = flag;


				for ( var j : int = 0; j<vf.effectfiles.length; j++ )
				{
					var ef : EffectFiles = vf.effectfiles[j];
					
					ef.update_f = flag;
				}
			
			}
			

			for ( i = 0; i<subtitlefiles.length; i++ )
			{
				var st : SubtitleFiles = subtitlefiles[i];
				
				st.update_f = flag;
			}


			for ( i = 0; i<bookmarkfiles.length; i++ )
			{
				var bf : BookmarkFiles = bookmarkfiles[i];
				
				bf.update_f = flag;
			}
			
		}

		// 更新フラグチェックして上書き保存ボタンを有効にする必要性があるかチェック。
		public function isUpdate() : Boolean
		{
			for ( var i : int =0; i<videofiles.length; i++ )
			{
				var vf : VideoFiles = videofiles[i];

				if (vf.update_f)
				{
					return true;
				}


				for ( var j : int = 0; j<vf.effectfiles.length; j++ )
				{
					var ef : EffectFiles = vf.effectfiles[j];
				
					if (ef.update_f)
					{
						return true;
					}
				}
			
			}
			

			for ( i = 0; i<subtitlefiles.length; i++ )
			{
				var st : SubtitleFiles = subtitlefiles[i];
				
				if (st.update_f)
				{
					return true;
				}
			}


			for ( i = 0; i<bookmarkfiles.length; i++ )
			{
				var bf : BookmarkFiles = bookmarkfiles[i];

				if (bf.update_f)
				{
					return true;
				}
			}

			return false;
		}


		// 相対パス表現からフルパスを返す
		public function GetFullPath( filen : String ) : String
		{
			var hddr :String = "file:";

//			trace( filen );
			if (filen.substr(0,hddr.length) == hddr) return filen;

			var f : File;
			
			if (xmlprojectfile==null)
			{
				return filen;
			}
			else
			{
				f = xmlprojectfile.parent.resolvePath( filen );
			}

//			trace( f.url );
			return f.url;
//			var rv : String = getpath( xmlprojectfilen ) + filen;

//			return rv;

		}
		
　       //  新規エフェクト追加メソッド 画像以外の場合は引数filenameは無視される。帰り値は、追加されたエフェクト。
	    public function AddEffectElem( type : String, filename : String, x : Number, y : Number, r : Number, scalex : Number, scaley :Number, ts : Number, te : Number, ct : Number, belongto : EffectFiles )
		{
　          var el : ObjectDataElem = new ObjectDataElem( makemask["makemask"]( rootobj ) );
			var cue0, cue1 : ObjectCues;

			el.belongto_ef = belongto;

			el.type = type;
			el.filename = filename;
		
			
			cue0 = ObjectCues(el.Cues[0]); cue1 = ObjectCues(el.Cues[el.Cues.length-1]);
			
			cue0.item_id = "0";
			cue0.nx = x;
			cue0.ny = y;
			cue0.angledegree = r;
			cue0.scalex = scalex;
			cue0.scaley = scaley;
			cue0.seconds = ts;
			
			
			cue1.item_id = "1";
			cue1.nx = x;
			cue1.ny = y;
			cue1.angledegree = r;
			cue1.scalex = scalex;
			cue1.scaley = scaley;
			cue1.seconds = te;
		
			el.ed = this;

//			trace( "parentobj = "+ parentobj + " el=" + el + " el.mc=" + el.mc );

			el.mc.x = x*parentobj.height + (porg_w - parentobj.width)/2;
			el.mc.y = y*parentobj.height + (porg_h - parentobj.height)/2; // 画面の縦幅基準なので　height を使う。、
			
			
//			trace(el.mc.x + "," + el.mc.y );
		
				
			el.EffectShape( type, filename );	
			parentobj.addChild( el.mc );
			
			el.id = Elem.length.toString();
			Elem.push( el );

			el.AnimateEffectElem( ct );
			
			return (el);
	    }

　       //  新規字幕追加メソッド。 帰り値は、追加されたエフェクト。
	    public function AddSubtitleElem( type : String, subtitle : String, ts : Number, te : Number, ct : Number, belongto : SubtitleFiles, fontsize : int )
		{
　          var el : ObjectDataElem = new ObjectDataElem( null );
			var cue0, cue1 : ObjectCues;

			el.belongto_st = belongto;

			el.type = type;
			el.labeltext = subtitle;
			el.fontsize = fontsize;
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
		
			el.ed = this;
				
			el.EffectShape( type, "" );
			
			el.id = Elem.length.toString();
			Elem.push( el );

			el.AnimateEffectElem( ct );
			
			return (el);
	    }

		// 新規しおり追加メソッド
	    public function AddBookmarkElem( type : String, labeltext : String, ts : Number, te : Number, ct : Number )
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
		
			el.ed = this;
				
			el.EffectShape( type, "" );	
			
			el.id = Elem.length.toString();
			Elem.push( el );

			el.AnimateEffectElem( ct );
			
			return (el);
	    }

		// 	ダブりの無いラベル名を生成する。
		public function NewBookmarkLabel( blabel : String ) : String
		{
			//trace( "blabel=["+blabel+"]" );
			
			var c : int = 0;
	
		    for (var i : int = 0; i< Elem.length; i++ )
			{
				var el : ObjectDataElem = Elem[i];
				
				if (el.type!=ObjectDataConstants.OBJECTTYPE_BOOKMARK) continue;
				if (blabel == el.labeltext) c++;
				
				var blabelb : String = blabel+"_";
				
				if ( el.labeltext.substring( 0, blabelb.length )==blabelb) c++
			}
			var rv : String;
			
			if (c==0) { rv =  blabel } else { rv = blabel + "_" +  c.toString(); }

			//trace( "rv=["+rv+"]" );

			return rv;
		}

		public function AnimateEffects( ct : Number )
		{
			var i : int;
			var el : ObjectDataElem;
			
			for ( i=0; i<Elem.length; i++ )
			{
				el = Elem[i];
				el.AnimateEffectElem( ct );
			}			
		}
	
		// エフェクトの再表示（表示リストの再構築　非表示から表示状態に切り替えるだけ）
		
		public function RedrawObjectData()
		{
			var i : int;
			var el : ObjectDataElem;
		
			for ( i=0; i<Elem.length; i++ )
			{
				el = Elem[i];
				
				if (el.mc!=null)
				{
					if ( el.belongto_ef.belongto_vf == curvideofile ) parentobj.addChild( el.mc );
				}
			}
				 
		}

		// エフェクトのバウンディングボックス表示(非選択エフェクト）

		public function DispBxs( f : Boolean )
		{
		var i : int;
		var el : ObjectDataElem;
		var p0, p1 : Point;

			p0 = new Point(); p1 = new Point();

			Bxs.graphics.clear();
			
			if (!f) return;

			for (i = 0; i<Elem.length; i++ )
			{
				el = Elem[i];
				if (el.mc==null) continue; // mcを持たないもの（字幕としおり）は対象外
				if ((CurElem==el)&&(MultiSelection.length<2)) continue; // 単数選択時のカレントエフェクトは対象外
				if (!el.belongto_ef.belongto_vf.current) continue; // カレントヴィデオファイル以外は対象外

				if (isselect(el))
				{
					Bxs.graphics.lineStyle(6,0xFFFFFF,1.0);
				} else {
					Bxs.graphics.lineStyle(0,0xFFFFFF,1.0);
				}
				
				p0.x = el.cx-el.w/2;
				p0.y = el.cy-el.h/2;
				
				p0 = el.mc.localToGlobal( p0 );
				Bxs.graphics.moveTo( p0.x, p0.y );
				
				p1.x = el.cx+el.w/2;
				p1.y = el.cy-el.h/2;
				
				p1 = el.mc.localToGlobal( p1 );
				Bxs.graphics.lineTo( p1.x, p1.y );
				
				p1.x = el.cx+el.w/2;
				p1.y = el.cy+el.h/2;				
				
				p1 = el.mc.localToGlobal( p1 );
				Bxs.graphics.lineTo( p1.x, p1.y );
				
				p1.x = el.cx-el.w/2;
				p1.y = el.cy+el.h/2;								
				
				p1 = el.mc.localToGlobal( p1 );
				Bxs.graphics.lineTo( p1.x, p1.y );
				
				Bxs.graphics.lineTo( p0.x, p0.y );
			
			}
		
		}

		// エフェクトのバウンディングボックス表示(選択エフェクト）

		public function DispSelectedBx( ems : Array, f : Boolean )
		{
		var el : ObjectDataElem;
		var p0, p1, p2, p3, p4, p5, p6, p7, cp  : Point;
		var em : EditMarkers;
		var archeat : Number;
		var c : ObjectCues;
		
		var i : int;
		var num_markers : int = 0;

			SelectedBx.graphics.clear();
			
			if ( ems.length>0) { em=ems[0]; num_markers = em.eg.num_markers; }
			
			for(i=0; i<num_markers-1; i++)	{ em = ems[i]; em.Invisible(); }

			if (MultiSelection.length>1) return; // 複数選択時はマーカーを描かないのでDispBxsで描画する。

			if (!f)
			{
				return;
			}
						
		    if (CurElem==null ) return;
			if (CurElem.mc==null) return;　 // mcを持たないのは字幕かしおり 
			if (!CurElem.belongto_ef.belongto_vf.current) return;　// カレントビデオファイル以外は対象外			

			el = CurElem;

			if ( el.type == ObjectDataConstants.OBJECTTYPE_EFFECT_ARROW )	archeat=el.w/4 else archeat = 0; // 矢印は原点が辺上にあるので、ドラッグマーカーをずらす。

			p0 = new Point(); p1 = new Point(); p2 = new Point(); p3 = new Point();
			p4 = new Point(); p5 = new Point(); p6 = new Point(); p7 = new Point();
			cp = new Point();

			SelectedBx.graphics.lineStyle(4,0xffffff,1.0);
			
			p0.x =  el.cx-el.w/2;
			p0.y =  el.cy-el.h/2;
				
			p0 = el.mc.localToGlobal( p0 );
			SelectedBx.graphics.moveTo( p0.x, p0.y );
				
			p1.x =  el.cx+el.w/2 + archeat;
			p1.y =  el.cy-el.h/2;
				
			p1 = el.mc.localToGlobal( p1 );
			SelectedBx.graphics.lineTo( p1.x, p1.y );
				
			p2.x =  el.cx+el.w/2 + archeat;
			p2.y =  el.cy+el.h/2;				
				
			p2 = el.mc.localToGlobal( p2 );
			SelectedBx.graphics.lineTo( p2.x, p2.y );
				
			p3.x =  el.cx-el.w/2;
			p3.y =  el.cy+el.h/2;								
				
			p3 = el.mc.localToGlobal( p3 );
			SelectedBx.graphics.lineTo( p3.x, p3.y );
				
			SelectedBx.graphics.lineTo( p0.x, p0.y );


			p4.x = (p0.x+p1.x)/2; p4.y = (p0.y+p1.y)/2;
			p5.x = (p1.x+p2.x)/2; p5.y = (p1.y+p2.y)/2;
			p6.x = (p2.x+p3.x)/2; p6.y = (p2.y+p3.y)/2;
			p7.x = (p3.x+p0.x)/2; p7.y = (p3.y+p0.y)/2;
			
			cp.x = (p0.x+p2.x)/2; cp.y = (p0.y+p2.y)/2;

			em = ems[0];
			em.pos.x = p4.x; em.pos.y= p4.y;
			
			em = ems[1];
			em.pos.x = p5.x; em.pos.y= p5.y;

			em = ems[2];
			em.pos.x = p6.x; em.pos.y= p6.y;

			em = ems[3];
			em.pos.x = p7.x; em.pos.y= p7.y;

			em = ems[4];
			em.pos.x = p0.x; em.pos.y= p0.y;

			em = ems[5];
			em.pos.x = p1.x; em.pos.y= p1.y;

			em = ems[6];
			em.pos.x = p2.x; em.pos.y= p2.y;

			em = ems[7];
			em.pos.x = p3.x; em.pos.y= p3.y;
			
			em = ems[8];
			em.pos.x = p4.x; em.pos.y= p4.y;

			c = CurElem.Cues[0];

			for(i=0; i<ems.length; i++) 
			{
				em = ems[i];
				
				em.cp.x = cp.x;
				em.cp.y = cp.y;
				
				if (i<(em.eg.num_markers-1))  // 最後とそれに続く移動マーカーの座標は変更しない。また、最後の2つは枠と移動マーカー(エフェクトmcそのもの）キメ打ち。
				{
					em.mc.x = em.pos.x;
					em.mc.y = em.pos.y;
					
					em.mc.rotation = c.angledegree; // マーカーの見た目回転
				} else {
	
					em.mc = CurElem.mc;
					
					//SelectedBx.alpha = 1;
				}
				em.CurElem = CurElem;
				em.Visible();
			}
			
			SelectedBx.parent.setChildIndex(SelectedBx,SelectedBx.parent.numChildren - 1);
		}


		// エフェクトの全非表示（表示リスト（のみ）の破棄 非表示にするだけ）
		public function RemoveObjectData()
		{
			var i : int;
			var el : ObjectDataElem;
					
			for ( i = 0; i<Elem.length; i++ )
			{
				el = Elem[i];
 				parentobj.removeChild( el.mc );
			
			}
		}


		// エフェクトの単体削除
        public function DeleteEffect( el : ObjectDataElem ) : int
		{
			var i, d : int;
			
		    for( i = 0; i < Elem.length; i++ )
			{
				if ( el==Elem[i] ) 
				{
				    el.Clear();
					d = i; break;
				}				
			
			}

			Elem.splice( d, 1 );
			

			return d;
		}
	
		// Elems配列の破棄。非表示ではなく中のデータも破棄します。ガベージコレクタが自動で良きに計らってくれるとも限らないらしいので。
		public function Clear()
		{
		    while( Elem.length>0 )
			{
				var el : ObjectDataElem;
	
				el = Elem.pop();
				el.Clear();
				el = null;
			}

			CurElem=null;
			
			while( videofiles.length >0 )
			{
				var vf : VideoFiles = videofiles.pop();
				vf = null;
			}
			
			while( subtitlefiles.length >0 )
			{
				var sf : SubtitleFiles = subtitlefiles.pop();
				sf = null;
			}

			while( bookmarkfiles.length >0 )
			{
				var bf : BookmarkFiles = bookmarkfiles.pop();
				bf = null;
			}
			
			videofiles = new Array( new VideoFiles(), new VideoFiles(), new VideoFiles() );
			subtitlefiles = new Array( new SubtitleFiles(), new SubtitleFiles() );
			bookmarkfiles = new Array( new BookmarkFiles() );
		
	 		curvideofile = videofiles[0];
			cursubtitlefiles = subtitlefiles[0];
			curbookmarkfiles = bookmarkfiles[0];
			
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
		
		// ファイル名から拡張子を取得(ピリオド含まない）
		private function getext( filename : String ) : String
		{
			if (filename.indexOf(".")<0) return "";

			
//			trace( "getext:["+filename.substring( filename.indexOf(".")+1, filename.length )+"]" );
			
			return filename.substring( filename.indexOf(".")+1, filename.length );
		}
	
		
		// 各構成ファイル名を作成する。
		
		private function genfilename( basefile : File, filekind : String, idx : int  ) : File
		{
/*
			var rv : String = delext( basefilename ) + "." + filekind + "." + idx.toString() + "." + getext( basefilename );
			
			trace("genfilename = " + rv );
			
			
			return delext( basefilename ) + "." + filekind + "." + idx.toString() + "." + getext( basefilename );
*/
			
//			trace( ">"+ basefile.url );
			
			var rv = new File( delext(basefile.url) +  "_" + filekind + "_" + idx.toString() + ".xml" );
		
//		    trace( "<" + rv.url );
		
			return rv;
		}
		
		// プロジェクト内のファイル名を一括構築する。
		private function genfilenames(basefile : File)
		{
			var i, j : int;
			var vf : VideoFiles;
			var ef : EffectFiles;
			var sf : SubtitleFiles;
			var bf : BookmarkFiles;
			
			var eft : Array= [ "A", "B", "C", "D" ]
			var eftt : String;
			

			for( i=0; i<videofiles.length; i++ )
			{
				vf = videofiles[i];
				
				for ( j=0; j<vf.effectfiles.length; j++ )
				{
					ef = vf.effectfiles[j];
					
					if (j<eft.length)
					{
						eftt = eft[j];
					}
					else
					{
						eftt = "";
					}
					
					ef.effectfile = genfilename( basefile, "effect"+ eftt, i+1 );
				}
			}
			
			for (i=0; i< subtitlefiles.length; i++ )
			{
				sf = subtitlefiles[i];
				//sf.subtitlefile = genfilename( basefile, "subtitle", i+1 );
				sf.subtitlefile = genfilename( basefile, "caption", i+1 );
				
			}
			
			for (i=0; i< bookmarkfiles.length; i++ )
			{
				bf = bookmarkfiles[i];
				bf.bookmarkfile = genfilename( basefile, "bookmark", i+1 );
				
			}
		}
		
		// 相対パスを求める 
		private function getrelativepath( from, to : String, publishmode : Boolean ) : String
		{
	
			if (publishmode)
			{
				var f : File = new File( to );
				return f.name;
			}
			
			var file1: File = File.documentsDirectory; // File(xmlfilen);
			var file2: File = File.documentsDirectory;
					
									
			file1 = file1.resolvePath( to );
			file2 = file2.resolvePath( getpath(from));			
			
			return file2.getRelativePath( file1, true );
		}


		private function getlongestmovielength( ) : Number
		{
			var rv : Number = 0;
			
			for ( var i : int = 0; i < videofiles.length; i++ )
			{
				var vf : VideoFiles = videofiles[i];
				if (rv<vf.movieLength) rv = vf.movieLength;
			}
			
			return rv;
		}


import LMP_Classes.VideoFiles;
import LMP_Classes.EffectFiles;
import LMP_Classes.SubtitleFiles;
import LMP_Classes.BookmarkFiles;
		
		// 保存用にXMLデータを作る。
		// プロジェクトファイル
		public function GenProjectXML( basefile : File, publishmode : Boolean ) : XML
		{
			var i, j : int;
			var rv, moviediscription, moviefiles, efffiles, subfiles, bookmarks, movielength, itm, itm2 : XML; 
			var vf : VideoFiles;
			var ef : EffectFiles;
			var sf : SubtitleFiles;
			var bf : BookmarkFiles;
		
		
//			if (basefile.extension!= "xml") basefile.extension = "xml";
	
			if (basefile.name.indexOf(".")<0) { basefile = new File( basefile.url + ".xml" ); } 

			genfilenames( basefile );
		
			rv = new XML( '<?xml version="1.0" encoding="UTF-8" ?><movieDescription></movieDescription>' );

			moviediscription = rv;
			moviediscription.appendChild( new XML( '<title>' + projecttitle + '</title>' ) );
			moviediscription.appendChild( new XML( '<returnUrl>' + returnurl + '</returnUrl>' ) );				
			
			moviefiles = new XML( '<movieFiles></movieFiles>' );
			
			for (i=0; i<videofiles.length; i++)
			{
				vf = videofiles[i];

				//trace( vf );
				//trace (vf.filename);
			
				var vfilen : String = vf.filename; 
			
				if (vf.filename==null) 
				{
					vf.filename = "";
				    vfilen = "";
				}
				else
				{
					if (publishmode)
					{
						vfilen = fpub.AddCopyFile( getpath( xmlprojectfilen ), vf.filename );
					}
					else
					{
						vfilen = vf.filename;
					}
				}
								
				itm = new XML( '<item id="' + i.toString() + '"></item>' );
				
				if (vfilen!="")
				{
					itm.appendChild( new XML( '<path>'+getrelativepath( basefile.url, vfilen, publishmode )+'</path>') )
				}
				else
				{
					itm.appendChild( new XML( '<path></path>') )
				}

				efffiles = new XML ( '<effectFiles></effectFiles>' );
				
				for (j=0; j<vf.effectfiles.length; j++ )
				{
					ef = vf.effectfiles[j];
					
					itm2 = new XML( '<item id="' + j.toString() + '"></item>' );
					itm2.appendChild( new XML( '<path>'+getrelativepath( basefile.url, ef.effectfile.url, false )+'</path>') );
					
					efffiles.appendChild( itm2 );
				}
			
				itm.appendChild( efffiles );
				moviefiles.appendChild( itm );
			}			

			moviediscription.appendChild( moviefiles );

//			subfiles = new XML( '<subtitleFiles></subtitleFiles>' );
			subfiles = new XML( '<captionFiles></captionFiles>' );
			
			for (i=0; i<subtitlefiles.length; i++ )
			{
				sf = subtitlefiles[i];
				itm = new XML( '<item id="' + i.toString() + '"></item>' );
				itm.appendChild( new XML( '<path>'+getrelativepath( basefile.url, sf.subtitlefile.url, false )+'</path>') );
				
				subfiles.appendChild( itm );
			}

			moviediscription.appendChild( subfiles );


			bookmarks = new XML( '<bookmarkListFiles></bookmarkListFiles>' );
			
			for (i=0; i<bookmarkfiles.length; i++ )
			{
				bf = bookmarkfiles[i];
				itm = new XML( '<item id="' + i.toString() + '"></item>' );
				itm.appendChild( new XML( '<path>'+getrelativepath( basefile.url, bf.bookmarkfile.url, false )+'</path>') );
				
				bookmarks.appendChild( itm );
			}

			moviediscription.appendChild( bookmarks );			
			

			//
			//  しおりクリッカブルマップ処理予定地
			//

//			rv.appendChild( moviediscription );

			movielength = new XML( '<movieLength></movieLength>' );
			
			var ts : TimeCounter = new TimeCounter(); ts.SetSecondsInNumber( getlongestmovielength() );
			
			movielength.appendChild( new XML( '<hmsValue>' + ts.ToString( false ) + '</hmsValue>' ) );
			movielength.appendChild( new XML( '<seconds>' + ts.GetSecondsInNumber() + '</seconds>' ) );
	
			moviediscription.appendChild( movielength );

			return rv;
		}



		// エフェクトXML生成

		public function GenEffectXML( ef : EffectFiles, publishmode : Boolean ) : XML
		{
			var i, j : int;
			var el : ObjectDataElem;
			var cue : ObjectCues;
			var filen : String;
			var tc : TimeCounter = new TimeCounter();

			var itm, img, cues, xcue, tim, pos, angle, scale : XML;
			var rv : XML = new XML( '<?xml version="1.0" encoding="UTF-8" ?><effects></effects>' );
			
			rv.appendChild( new XML('<label>'+ef.effectlabel+'</label>' ) );
			rv.appendChild( new XML('<initialVisible>'+ef.checked.toString()+'</initialVisible>' ) );
			
			for( i = 0; i < Elem.length; i++ )
			{
				el = Elem[i];
				
				switch ( el.type )
				{
					case ObjectDataConstants.OBJECTTYPE_BOOKMARK: continue;
					case ObjectDataConstants.OBJECTTYPE_SUBTITLE: continue;
					default:
						if (el.belongto_ef!=ef) continue;
				
				}

				itm = new XML( '<item></item>' );
				itm.appendChild( new XML('<id>"'+ el.id +'"</id>') );
				itm.appendChild( new XML('<type>'+el.type+'</type>') );
			
				if (el.type == ObjectDataConstants.OBJECTTYPE_EFFECT_PICTURE )
				{
/*					var file1: File = File.documentsDirectory; // File(xmlfilen);
					var file2: File = File.documentsDirectory;
					
									
					file1 = file1.resolvePath(el.filename);
					file2 = file2.resolvePath(getpath( xmlprojectfilen ));

					
					filen = file2.getRelativePath( file1, true );
*/

					var efilen : String = el.filename;

					if (publishmode)
					{
						efilen = fpub.AddCopyFile( getpath( xmlprojectfilen ), el.filename );
					}

					filen = getrelativepath( xmlprojectfilen, efilen, publishmode );


//					    filen = el.filename;

					img = new XML('<image></image>');

//					filen = escapeMultiByte( filen ); // UTF-8へのエンコード
					
					img.appendChild( new XML('<path>' + filen + '</path>') );
					
					itm.appendChild( img );
				}

				itm.appendChild( new XML( '<fade></fade>' ) );

				cues = new XML( '<cues></cues>' );
							
				for (j=0; j<el.Cues.length; j++)
				{
					cue = el.Cues[j];
					if (cue.seconds < 0.001) cue.seconds = 0.001; // 表示システムの仕様上0は使えない。
					
					xcue= new XML( '<item id="' + j + '"></item>' );
					 tim = new XML( '<time></time>' );
					 tc.SetSecondsInNumber( cue.seconds );
					 tim.appendChild( new XML('<hmsValue>'+tc.ToString( false  )+'</hmsValue>') );
					 tim.appendChild( new XML('<seconds>'+cue.seconds+'</seconds>') );
					xcue.appendChild( tim );
					
					 pos = new XML( '<pos></pos>' );
					 pos.appendChild( new XML('<x>'+cue.nx+'</x>') );
					 pos.appendChild( new XML('<y>'+cue.ny+'</y>') );
					xcue.appendChild( pos );
					
					 angle = new XML( '<angle></angle>' );
					 angle.appendChild( new XML('<degree>'+cue.angledegree+'</degree>') );
					xcue.appendChild( angle );
					
					 scale = new XML( '<scale></scale>' );
					 scale.appendChild( new XML('<x>' + cue.scalex + '</x>') );
					 scale.appendChild( new XML('<y>' + cue.scaley + '</y>') );
					xcue.appendChild( scale )
						
					cues.appendChild( xcue );
				}
				itm.appendChild( cues );
				rv.appendChild( itm );
			}
				
//			trace(rv.toXMLString());


			return rv;
		}
		

		// 字幕XML生成
		public function GenSubtitleXML( st : SubtitleFiles ) : XML
		{
			var i, j : int;
			var el : ObjectDataElem;
			var cue : ObjectCues;
			var filen : String;
			var tc : TimeCounter = new TimeCounter();

			var itm, img, starttime, endtime, fnt : XML;
			//var rv : XML = new XML( '<?xml version="1.0" encoding="UTF-8" ?><subtitles></subtitles>' );
			var rv : XML = new XML( '<?xml version="1.0" encoding="UTF-8" ?><captions></captions>' );
						
			for( i = 0; i < Elem.length; i++ )
			{
				el = Elem[i];
				
				if (el.type != ObjectDataConstants.OBJECTTYPE_SUBTITLE ) continue;
				if (el.belongto_st!=st) continue;
			
				
				itm = new XML( '<item></item>' );
				itm.appendChild( new XML('<id>"'+ el.id +'"</id>') );
				itm.appendChild( new XML('<text>'+el.labeltext+'</text>' ) );

				starttime = new XML( '<startTime></startTime>' );
				cue = el.Cues[0];
				 starttime.appendChild( new XML('<hmsValue>'+tc.ToString( false  )+'</hmsValue>') );
				 starttime.appendChild( new XML('<seconds>'+cue.seconds+'</seconds>') );				
				
				itm.appendChild( starttime );
				
				
				endtime = new XML( '<endTime></endTime>' );
				cue = el.Cues[1];
				 endtime.appendChild( new XML('<hmsValue>'+tc.ToString( false  )+'</hmsValue>') );
				 endtime.appendChild( new XML('<seconds>'+cue.seconds+'</seconds>') );				
				
				itm.appendChild( endtime );				

				fnt = new XML( '<font></font>' );
				fnt.appendChild( new XML('<size>'+ el.fontsize + '</size>' ) );
				itm.appendChild( fnt );

				rv.appendChild( itm );
			}
				
//			trace(rv.toXMLString());

			return rv;

		}


        // ブックマークリストXML生成
		public function GenBookmarkXML() : XML
		{
			var i, j : int;
			var el : ObjectDataElem;
			var cue : ObjectCues;
			var filen : String;
			var tc : TimeCounter = new TimeCounter();

			var itm, img, starttime, endtime, fontsize : XML;
			var rv : XML = new XML( '<?xml version="1.0" encoding="UTF-8" ?><bookmarkList></bookmarkList>' );
			
			for( i = 0; i < Elem.length; i++ )
			{
				el = Elem[i];
				if (el.type != ObjectDataConstants.OBJECTTYPE_BOOKMARK ) continue;
				
				itm = new XML( '<item></item>' );
				itm.appendChild( new XML('<id>"'+ el.id +'"</id>') );

				starttime = new XML( '<startTime></startTime>' );
				cue = el.Cues[0];
				 starttime.appendChild( new XML('<hmsValue>'+tc.ToString( false  )+'</hmsValue>') );
				 starttime.appendChild( new XML('<seconds>'+cue.seconds+'</seconds>') );				
				
				itm.appendChild( starttime );
				
				endtime = new XML( '<endTime></endTime>' );
				cue = el.Cues[1];
				 endtime.appendChild( new XML('<hmsValue>'+tc.ToString( false  )+'</hmsValue>' ) );
				 endtime.appendChild( new XML('<seconds>'+cue.seconds+'</seconds>') );				
				
				itm.appendChild( endtime );				

				itm.appendChild( new XML('<text>'+el.labeltext+'</text>' ) );
				itm.appendChild( new XML('<favorite>'+ el.favorite.toString() + '</favorite>' ) );

				rv.appendChild( itm );
			}
				
//			trace(rv.toXMLString());

			return rv;

		}

		// 	プロジェクトを読み込む
		public function SetupProjectFromXML()
		{
			var itm : XML;
			var effectfile, subtitlefile, bookmarklistfile : XMLList;
			var x, y, r,scalex, scaley, ts, te : Number;

			projecttitle = xmlprojectdata.title;
			returnurl = xmlprojectdata.returnUrl;

			var i : int = 0;
			var f : File;
			
			loadcount = 0;
			
			for each ( itm in xmlprojectdata.movieFiles.item )
			{
				curvideofile = new VideoFiles();
				
				if ( itm.path!="" ) /*curvideofile.filename = getpath(xmlprojectfilen) + itm.path; */  curvideofile.filename = GetFullPath( itm.path ); //xmlprojectfile.resolvePath( itm.path ).url;


				// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				
				effectfile = itm.effectFiles.item.(@id=="0");
				if ( effectfile.(path!="").toXMLString() ) { curvideofile.effectfiles[0] = LoadEffectFile( effectfile.path ); }
				
				effectfile = itm.effectFiles.item.(@id=="1");
				if ( effectfile.(path!="").toXMLString() ) { curvideofile.effectfiles[1] = LoadEffectFile( effectfile.path ); }			
				
				effectfile = itm.effectFiles.item.(@id=="2");
				if ( effectfile.(path!="").toXMLString() ) { curvideofile.effectfiles[2] = LoadEffectFile( effectfile.path ); }						
				
				effectfile = itm.effectFiles.item.(@id=="3");
				if ( effectfile.(path!="").toXMLString() ) { curvideofile.effectfiles[3] = LoadEffectFile( effectfile.path ); }


				curvideofile.cureffectfile = curvideofile.effectfiles[0];
			
				videofiles[i] = curvideofile; i++;
				if (i>(videofiles.length-1)) break;
			
			}
					
			
		    //　読み込みは、subtitleFilesとcaptionFiles 両対応、書き出しはcaptionFilesのみ。 
			if ( xmlprojectdata.subtitleFiles != undefined )
			{
				subtitlefile = xmlprojectdata.subtitleFiles.item.(@id=="0");
				if ( subtitlefile.(path != "").toXMLString() ) subtitlefiles[0] = LoadSubtitleFile( subtitlefile.path );
				
				subtitlefile = xmlprojectdata.subtitleFiles.item.(@id=="1");
				if ( subtitlefile.(path != "").toXMLString() ) subtitlefiles[1] = LoadSubtitleFile( subtitlefile.path );
				
			} else {
				subtitlefile = xmlprojectdata.captionFiles.item.(@id=="0");
				if ( subtitlefile.(path != "").toXMLString() ) subtitlefiles[0] = LoadSubtitleFile( subtitlefile.path );
				
				subtitlefile = xmlprojectdata.captionFiles.item.(@id=="1");
				if ( subtitlefile.(path != "").toXMLString() ) subtitlefiles[1] = LoadSubtitleFile( subtitlefile.path );
			}
				

			bookmarklistfile = xmlprojectdata.bookmarkListFiles.item.(@id=="0");
			if ( bookmarklistfile.(path != "").toXMLString() )  bookmarkfiles[0] = LoadBookmarkFile( bookmarklistfile.path );
			
			
			CurElem = null;
			MultiSelection =[];
			
			AllUpdate( false );
			updatefnc["UpdateChangeCurrentElem"] ();
			nowloading = false;
			
		}
	
			
		public function LoadEffectFile( filename : String ) : EffectFiles
		{
			var fullpath : String = /* getpath( xmlprojectfilen ) +  filename; */ GetFullPath( filename );
		
			var effectfile : EffectFiles = new EffectFiles( "", curvideofile);
			effectfile.effectfile = new File( fullpath );
			
			effectfile.effectfile.addEventListener( Event.COMPLETE, loadcompleteeffectfile );
			effectfile.effectfile.addEventListener( IOErrorEvent.IO_ERROR, loadeffectfileerror );

			loadcount++;
			
			effectfile.effectfile.load();

			return effectfile;
		}


		// completeイベントを受け取るべきエフェクトファイルを検索する
		
		public function searcheffectfile( f : File ) : EffectFiles
		{
			var ef : EffectFiles;
			var vf : VideoFiles;
			
			for( var i : int = 0; i< videofiles.length; i++ )
			{
				vf = videofiles[i];
				
				for ( var j : int = 0; j < vf.effectfiles.length; j++ )
				{
					ef = vf.effectfiles[j];
					
					if (f == ef.effectfile) return ef;
				}
			}
			
			return null;  // 正常に動作してる場合はここには来ないはず。
		}
			
		private function loadcompleteeffectfile( e : Event )
		{
			var effectfile : EffectFiles = searcheffectfile( (e.target) as File );
			effectfile.effectfile.removeEventListener( Event.COMPLETE, loadcompleteeffectfile );
			effectfile.effectfile.removeEventListener( IOErrorEvent.IO_ERROR, loadeffectfileerror );			
			
			effectfile.xmldata = new XML(effectfile.effectfile.data); 

//			trace( "xmldata = "+ effectfile.xmldata.toString() );
//			trace( "effects label=" + effectfile.xmldata.label );
			
			effectfile.effectlabel = effectfile.xmldata.label;
			effectfile.checked = effectfile.xmldata.initialVisible;
/*	
			for each ( itm in effectfile.xmldata.item )
			{
				
				type = itm.type;
				filename = getpath( xmlprojectfilen ) + itm.image.path;
				
//				trace( "type:" + type );
			
				cue = itm.cues.item.(@id=="0");
				ts = cue.time.seconds;
				x = cue.pos.x;
				y = cue.pos.y;
				r = cue.angle.degree;
				scalex = cue.scale.x;
				scaley = cue.scale.y;
				
				cue = itm.cues.item.(@id=="1");
				te = cue.time.seconds;


//				trace( type, x, y, r, scalex, scaley, ts, te );
				
				// まだ動きがついていないので、若干端折ったコードになっている。拡張するときは注意。（AddEffectElem()の仕様変更が必要）
				CurElem = AddEffectElem( type, filename, x, y, r, scalex, scaley, ts, te, ts, effectfile ); // 最後のパラメータはコンパイル通すためのとりあえず。
			}
//			trace(" <" );
*/
			LoadEffectFromXML( effectfile.xmldata, effectfile );


			loadcount--;
			
			if (loadcount==0) { AllUpdate( false ); updatefnc["UpdateChangeCurrentElem2"] (); }
			
		}
		
		// エフェクトをXMLデータから「追加読み込み」　effectfile.xmldataではなく第一引数のxmlから読み込む。
		// 読み込まれたエフェクトはeffectfile所属になる。また、xmlの中身はエフェクトで無いといけない。
		public function LoadEffectFromXML( xml : XML, effectfile : EffectFiles )
		{
			var itm : XML;
			var cue : XMLList;
			var type, filename : String;
			var x, y, r,scalex, scaley, ts, te : Number;
			
			CurElem = null;
			MultiSelection = [];
			
			for each ( itm in xml.item )
			{
				
				type = itm.type;
//				filename = getpath( xmlprojectfilen ) + itm.image.path;
				filename = GetFullPath( itm.image.path ); // xmlprojectfile.resolvePath( itm.image.path ).url;		
//				trace( "type:" + type );
			
				cue = itm.cues.item.(@id=="0");
				ts = cue.time.seconds;
				x = cue.pos.x;
				y = cue.pos.y;
				r = cue.angle.degree;
				scalex = cue.scale.x;
				scaley = cue.scale.y;
				
				cue = itm.cues.item.(@id=="1");
				te = cue.time.seconds;


//				trace( type, x, y, r, scalex, scaley, ts, te );
				
				// まだ動きがついていないので、若干端折ったコードになっている。拡張するときは注意。（AddEffectElem()の仕様変更が必要）
				CurElem = AddEffectElem( type, filename, x, y, r, scalex, scaley, ts, te, ts, effectfile ); // 最後のパラメータはコンパイル通すためのとりあえず。
				
				MultiSelection.push( CurElem );
				
				effectfile.update_f = true;
			}		
		}
		
		private function loadeffectfileerror( e :Event )
		{
			var effectfile : EffectFiles = searcheffectfile( (e.target) as File );
			effectfile.effectfile.removeEventListener( Event.COMPLETE, loadcompleteeffectfile );
			effectfile.effectfile.removeEventListener( IOErrorEvent.IO_ERROR, loadeffectfileerror );
			errormes = "LoadXML:File I/O Error(effect)";
			//trace("Load Error(effect)");

			loadcount--;
			
			if (loadcount==0) { AllUpdate( false ); updatefnc["UpdateChangeCurrentElem2"] (); }				
			// updatefnc["UpdateChangeCurrentElem2"] ();
		}

		public function LoadSubtitleFile( filename : String ) : SubtitleFiles
		{
			var fullpath : String = /* getpath(xmlprojectfilen) +  filename; */ GetFullPath( filename );
			var subtitlefile : SubtitleFiles = new SubtitleFiles();

			subtitlefile.subtitlefile = new File( fullpath );

			subtitlefile.subtitlefile.addEventListener( Event.COMPLETE, loadcompletesubtitlefile );
			subtitlefile.subtitlefile.addEventListener( IOErrorEvent.IO_ERROR, loadsubtitlefileerror );

			loadcount++;
			
			subtitlefile.subtitlefile.load();

			return subtitlefile;
		}


		// completeイベントを受け取るべき字幕ファイルを検索する
		
		private function searchsubtitlefile( f : File ) : SubtitleFiles
		{
			var sf : SubtitleFiles;
			
			for( var i : int = 0; i< subtitlefiles.length; i++ )
			{
				sf = subtitlefiles[i];
				
				if ( f == sf.subtitlefile ) return sf;
			}

			return null;  // 正常に動作してる場合はここには来ないはず。
		}


		private function loadcompletesubtitlefile( e : Event )
		{
			var subtitlefile : SubtitleFiles = searchsubtitlefile( (e.target) as File );
			subtitlefile.subtitlefile.removeEventListener( Event.COMPLETE, loadcompletesubtitlefile );
			subtitlefile.subtitlefile.removeEventListener( IOErrorEvent.IO_ERROR, loadsubtitlefileerror );		

			subtitlefile.xmldata = new XML(subtitlefile.subtitlefile.data); 

			cursubtitlefiles = subtitlefile;
/*			
			for each ( itm in subtitlefile.xmldata.item )
			{
				
				labeltext = itm.text;
		
				cue = itm.startTime;
				ts = cue.seconds;
				
				cue = itm.endTime;
				te = cue.seconds;

				var fs : int = parseInt(itm.font.size);
				
				trace ("fontsize=" + fs.toString() );

				if (fs==0) fs = 15;
				fontsize = fs;

//				trace( type, x, y, r, scalex, scaley, ts, te );
				
				CurElem = AddSubtitleElem( ObjectDataConstants.OBJECTTYPE_SUBTITLE, labeltext, ts, te, ts, cursubtitlefiles, fontsize );
			}
*/
			LoadSubtitleFromXML(  subtitlefile.xmldata, subtitlefile );

			loadcount--;
			
			if (loadcount==0) { AllUpdate( false ); updatefnc["UpdateChangeCurrentElem2"] (); }	
		}


		// 字幕をXMLデータから「追加読み込み」　subtitlefile.xmldataではなく第一引数のxmlから読み込む。
		// 読み込まれたエフェクトはsubtitlefile所属になる。また、xmlの中身は字幕で無いといけない。
		public function LoadSubtitleFromXML( xml : XML, subtitlefile : SubtitleFiles )
		{
			var itm, xmld : XML;
			var cue : XMLList;
			var labeltext : String;
			var ts, te : Number;
			var fontsize : int;	
			
			var ei : ELAN_Importer = new ELAN_Importer();
			
			if (xml.name()==ei.EI_ANNOTATION_DOCUMENT) // ELAN インポート
			{
				LoadSubtitleFromELAN( xml, subtitlefile );
				return;
			}
			
			CurElem=null;
			MultiSelection =[];
			
			for each ( itm in xml.item )
			{
				
				labeltext = itm.text;
		
				cue = itm.startTime;
				ts = cue.seconds;
				
				cue = itm.endTime;
				te = cue.seconds;

				var fs : int = parseInt(itm.font.size);
				
//				trace ("fontsize=" + fs.toString() );

				if (fs==0) fs = 15;
				fontsize = fs;
				
				CurElem = AddSubtitleElem( ObjectDataConstants.OBJECTTYPE_SUBTITLE, labeltext, ts, te, ts, subtitlefile, fontsize );
				subtitlefile.update_f = true;
				
				MultiSelection.push( CurElem );
				
			}
		
		}

		// 字幕をELAN仕様のXMLデータから「追加読み込み」　subtitlefile.xmldataではなく第一引数のxmlから読み込む。
		// 読み込まれた字幕はsubtitlefile所属になる。また、xmlの中身は字幕で無いといけない。
		// ELAN形式からの読み込みであること以外、基本的にLoadSubtitleFromXMLと一緒。
		
		private function gettimeslot( xml : XML, cueid : String ) : Number
		{
			var tim : XML;
			var tmp : String;
			var rv : Number = 0;
			
			//trace( "cueid=" + cueid );
			
			for each ( tim in xml.TIME_ORDER.TIME_SLOT )
			{		
				if ( tim.@TIME_SLOT_ID == cueid )
				{
					tmp = tim.@TIME_VALUE;
					rv = Number(tmp) / 1000;   // ミリセカンド
					//trace( "    id=" + tim.@TIME_SLOT_ID + "   val =" +  tmp );
					break;
				}
			}
			
			return rv;
	
		}
		
		const ELAN_DEFAULT_FONTSIZE : int = 12;
		
		public function LoadSubtitleFromELAN( xml : XML, subtitlefile : SubtitleFiles )
		{
			var ann, xmld : XML;
			var cueid : String;
			var labeltext : String;
			var ts, te : Number;
			
			var ei : ELAN_Importer = new ELAN_Importer();
			
			CurElem=null;
			MultiSelection =[];
			
			for each ( ann in xml.TIER.ANNOTATION )
			{
				
				labeltext = ann.ALIGNABLE_ANNOTATION.ANNOTATION_VALUE;
		
				cueid = ann.ALIGNABLE_ANNOTATION.@TIME_SLOT_REF1;
				ts = gettimeslot( xml, cueid );
				
				cueid = ann.ALIGNABLE_ANNOTATION.@TIME_SLOT_REF2;
				te = gettimeslot( xml, cueid );

				trace( "ts=" +ts + "    te=" + te );

				CurElem = AddSubtitleElem( ObjectDataConstants.OBJECTTYPE_SUBTITLE, labeltext, ts, te, ts, subtitlefile, ELAN_DEFAULT_FONTSIZE );
				subtitlefile.update_f = true;
				
				MultiSelection.push( CurElem );
				
			}
		
		}

		// テキスト形式字幕かチェック　現在はQuickTinmSubtitleのみ。
		
		public function isTEXTSubtitle( txt : String ) : Boolean
		{
			var qi : QTST_Importer = new( QTST_Importer );
			
			
			if ( qi.isQTSubtitle( txt ) ) return true;
			/* 将来増えたらここに増やす */				

			return false;
		}

		// 字幕をQuickTimeSubtitle形式ファイル(*.txt)から「追加読み込み」
		// QuickTimeSubtitleファイルはELANのエクスポート機能で出力したファイルを前提にしている。
		// 読み込まれた字幕はsubtitlefile所属になる。また、txtの中身は字幕で無いといけない。
		// ELAN形式からの読み込みであること以外、基本的にLoadSubtitleFromXMLと一緒。


		public function LoadSubtitleFromQTSubtitle( txt : String, subtitlefile : SubtitleFiles )
		{
			var qi : QTST_Importer = new( QTST_Importer );
			var tc : Number;
			var tcc : TimeCounter = new( TimeCounter );
/*			

			trace( "QTST_GetToken_m=" + qi.GetToken_m(txt));
			trace( "leftToken=" + qi.leftToken );
			trace( "QTST_GetToken=" + qi.GetToken( txt, "}" ));
			trace( "leftToken=" + qi.leftToken );

			trace( "txt="+ txt );
			
			trace( "Trim TestA:[" + qi.Trim( "    ABCDE F 　","{}" ) + "]" );
			trace( "Trim TestB:[" + qi.Trim( " {   G H IJK L }　","{}" ) + "]" );
*/

			var token : String;
			var left : String = qi.Trim( txt, "" );

			do
			{
				switch( left.charAt(0) )
				{
					case qi.QI_COMMAND_SEPARATOR_S:  // { で始まる各パラメータ
						token = qi.Trim( qi.GetToken_m( left ), "{}" );
						left = qi.Trim(qi.leftToken, "");

						trace( "param【" + token + "】" );
						
						qi.ReadParam( token );
	
						break;
					
					
					case qi.QI_TIMECORD_S:			// [ で始まるタイムコード
						token = qi.Trim( qi.GetToken_l( left ), "[]" );
						left = qi.Trim(qi.leftToken, "");
						
						trace( "timecode【" + token + "】" );
						
						tcc.SetSecondsInString_QTST( token );
						tc = tcc.GetSecondsInNumber();
						
						if (qi.subtitle=="") // 字幕をセットしない限りは
						{
							qi.cue0 = tc;
						}
						else				 // 字幕がセットされていたら
						{
							qi.cue1 = tc;
							
							CurElem = AddSubtitleElem( ObjectDataConstants.OBJECTTYPE_SUBTITLE, qi.subtitle, qi.cue0, qi.cue1, qi.cue0, subtitlefile, qi.size );
							
							subtitlefile.update_f = true;
							MultiSelection.push( CurElem );
							
							qi.subtitle = "";	// 登録後、テンポラリの字幕をクリア
							qi.cue0 = tc;   // 連続する場合を想定して、cue0に現在時刻をコピーしておく。
							
						}
						
						break;
				
					default:					// 字幕本体　(次の [ の直前まで）
												// { パラメータは字幕本体にも任意に埋められるという解釈も可能だが、
												// ELANのエキスポートでは想定してないっぽい。
						token = qi.GetToken( left, "[" );
						left = qi.Trim(qi.leftToken, "");
						
						trace( "subtitle【" + token + "】" );
						
						qi.subtitle = token;
					
						break;
				}
		
			} while( left != "" )
			
			//trace( "file is over left=【" + qi.leftToken + "】" );
			
			trace( "qi=" + qi );
		}

		private function loadsubtitlefileerror( e :Event )
		{
			var subtitlefile : SubtitleFiles = searchsubtitlefile( (e.target) as File );
			subtitlefile.subtitlefile.removeEventListener( Event.COMPLETE, loadcompletesubtitlefile );
			subtitlefile.subtitlefile.removeEventListener( IOErrorEvent.IO_ERROR, loadsubtitlefileerror );			
			//errormes = "LoadXML(subtitle):File I/O Error";
			errormes = "LoadSubtitle:File I/O Error(subtitle)";
			//trace("Load Error(caption/subtitle)");
			
			loadcount--;
			
			if (loadcount==0) { AllUpdate( false ); updatefnc["UpdateChangeCurrentElem2"] (); }				
//			updatefnc["UpdateChangeCurrentElem2"] ();
		}


		public function LoadBookmarkFile( filename : String ) : BookmarkFiles
		{
			var fullpath : String = /* getpath(xmlprojectfilen) +  filename; */ GetFullPath( filename );
			var bookmarkfile : BookmarkFiles = new BookmarkFiles();
			bookmarkfile.bookmarkfile = new File( fullpath );

			bookmarkfile.bookmarkfile.addEventListener( Event.COMPLETE, loadcompletebookmarkfile );
			bookmarkfile.bookmarkfile.addEventListener( IOErrorEvent.IO_ERROR, loadbookmarkfileerror );

 			loadcount++;
			
			bookmarkfile.bookmarkfile.load();

			return bookmarkfile;
		}
 
 
  		// completeイベントを受け取るべきしおりファイルを検索する
		
		private function searchbookmarkfile( f : File ) : BookmarkFiles
		{
			return bookmarkfiles[0];  // ダミー
		}
 		

		private function loadcompletebookmarkfile( e : Event )
		{
			var bookmarkfile : BookmarkFiles = searchbookmarkfile( (e.target) as File );
			bookmarkfile.bookmarkfile.removeEventListener( Event.COMPLETE, loadcompletebookmarkfile );
			bookmarkfile.bookmarkfile.removeEventListener( IOErrorEvent.IO_ERROR, loadbookmarkfileerror );		

			bookmarkfile.xmldata = new XML(bookmarkfile.bookmarkfile.data); 

			curbookmarkfiles = bookmarkfile;
/*			
			for each ( itm in bookmarkfile.xmldata.item )
			{
				cue = itm.startTime;
				ts = cue.seconds;
				
				cue = itm.endTime;
				te = cue.seconds;

				labeltext = itm.text;
				
//				trace( type, x, y, r, scalex, scaley, ts, te );
				
				CurElem = AddBookmarkElem( ObjectDataConstants.OBJECTTYPE_BOOKMARK, labeltext, ts, te, ts );

				if (itm.favorite=="true") { CurElem.favorite = true; } else { CurElem.favorite = false; }
			}
*/
			LoadBookmarkFromXML(  bookmarkfile.xmldata );

			loadcount--;
			
			if (loadcount==0) { AllUpdate( false ); updatefnc["UpdateChangeCurrentElem2"] (); }
		}


		// しおりをXMLデータから「追加読み込み」　subtitlefile.xmldataではなく第一引数のxmlから読み込む。
		// 読み込まれたエフェクトはsubtitlefile所属になる。また、xmlの中身は字幕で無いといけない。
		public function LoadBookmarkFromXML( xml : XML )
		{
			var itm, xmld : XML;
			var cue : XMLList;
			var labeltext : String;
			var ts, te : Number;

			for each ( itm in xml.item )
			{
				cue = itm.startTime;
				ts = cue.seconds;
				
				cue = itm.endTime;
				te = cue.seconds;

				labeltext = itm.text;
				
//				trace( type, x, y, r, scalex, scaley, ts, te );
				
				CurElem = AddBookmarkElem( ObjectDataConstants.OBJECTTYPE_BOOKMARK, labeltext, ts, te, ts );
				var bf : BookmarkFiles = bookmarkfiles[0];
				bf.update_f = true;

				if (itm.favorite=="true") { CurElem.favorite = true; } else { CurElem.favorite = false; }
			}			
		
		}

		private function loadbookmarkfileerror( e :Event )
		{
			var bookmarkfile : BookmarkFiles = searchbookmarkfile( (e.target) as File );
			bookmarkfile.bookmarkfile.removeEventListener( Event.COMPLETE, loadcompletebookmarkfile );
			bookmarkfile.bookmarkfile.removeEventListener( IOErrorEvent.IO_ERROR, loadbookmarkfileerror );		
			errormes = "LoadXML:File I/O Error(bookmark)";
			//trace("Load Error(bookmark)");

			loadcount--;
			
			if (loadcount==0) { AllUpdate( false ); updatefnc["UpdateChangeCurrentElem2"] (); }				
			//updatefnc["UpdateChangeCurrentElem2"] ();
		}	

/*
		// XMLデータから編集データを再構成する。
		public function SetupFromXML()
		{
			var itm : XML;
			var cue : XMLList;
			var type, filename : String;
			var x, y, r,scalex, scaley, ts, te : Number;
			
			for each ( itm in xmlprojectdata.item )
			{
				
				type = itm.type;
				filename = getpath( xmlprojectfilen ) + itm.image.path;
			
				cue = itm.cues.item.(@id=="0");
				ts = cue.time.seconds;
				x = cue.pos.x;
				y = cue.pos.y;
				r = cue.angle.degree;
				scalex = cue.scale.x;
				scaley = cue.scale.y;
				
				cue = itm.cues.item.(@id=="1");
				te = cue.time.seconds;


//				trace( type, x, y, r, scalex, scaley, ts, te );
				
				// まだ動きがついていないので、若干端折ったコードになっている。拡張するときは注意。（AddEffectElem()の仕様変更が必要）
				CurElem = AddEffectElem( type, filename, x, y, r, scalex, scaley, ts, te, ts, null ); // 最後のパラメータはコンパイル通すためのとりあえず。
			}
//			trace(" <" );
		}
*/
		// 指定ファイル名で指定XMLオブジェクトをファイルに書き出す。
		private function xml_savetofile( file : File, xmldata : XML )
		{  
			var stream : FileStream = new FileStream();

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

		// 名前をつけて保存
		public function SaveAsProjectXMLToFile()
		{
//			var filter : FileFilter = new FileFilter("XML File", "*.xml");

			if ( xmlprojectpath != "" )
			{
				xmlprojectfile = new File( xmlprojectpath );
			}
			else
			{
				xmlprojectfile = new File( File.documentsDirectory.nativePath );
			}
			
			errormes = "";
			xmlprojectfile.addEventListener( Event.SELECT, savefileselected );

//			xmlprojectfile.browseForSave( "Save Project Files" /*,[filter] */ ); // 第二引数がありそうなものだが。
			xmlprojectfile.browseForDirectory( "Save Project Folder" );
		}


		// 拡張子がついていなかったら補う。
		private function addextention( f : File, ext : String ) : File
		{
//			return new File(delext(f.url)+ext);
			
			var url : String = f.url;
			var eext : String = "."+getext( url );
			
			//if ((url.substring( (url.length-ext.length), ext.length )).toUpperCase()==ext.toUpperCase())
			
//			trace("ext=["+ext+"] eext=["+eext +"]" );
			
			if ( ext.toUpperCase() == eext.toUpperCase())
			{
				return f;
			}
			else
			{
//				trace( "f.url=["+f.url+"]  "+"rv=[" + url+ext+"]" );
				return new File(url+ext);
			}
		
		}

		// 拡張子をすげ替える
		private function  replaceextention( f : File, ext : String ) : File
		{
			trace ( "erp.ext:" + delext( f.url ) + ext );
			return new File( delext( f.url ) + ext );
		}

		// フォルダベース名を返す
		private function basename( url : String ) : String
		{
			var ch, rv : String;
			var i : int;
			
//			trace ( "basenam:url=" + url );
				
			if (url.charAt(url.length-1) == "/") i = url.length-2 else i = url.length-1;

			rv = "";
			for ( ; i>=0 ; i-- )
			{
				ch = url.charAt(i);
			
				if ( ch=="/" ) break;
				rv = ch + rv;
			}
			
			return rv;
		}

		// フォルダと拡張子からプロジェクト名を生成する
		private function genprojectname( f : File, ext : String ) : File
		{
			return new File( f.url + "/" + basename( f.url ) + ext );
		}
		
		private function savefileselected( e : Event )
		{
			xmlprojectfile.removeEventListener( Event.SELECT, savefileselected );
	 
//			xmlprojectfile = addextention(xmlprojectfile, ".xml" );

			xmlprojectpath = xmlprojectfile.nativePath;

			xmlprojectfile = genprojectname(xmlprojectfile, ".xml" );
			xmlprojectfilen = xmlprojectfile.url;
			
//			trace( "filen=" + xmlprojectfilen );
			
			AllUpdate( true ); // SaveAsのときは全更新。
			
			SaveProjectXMLToFile( false );
		}


		// パブリッシュ

		// テキストファイル読み込み(html用）
		private function readstring( f : File ) : String
		{
		 	var s : String = "";
			try
			{
				var fs = new FileStream(); 
			
				fs.open( f, FileMode.READ );
			
				s = fs.readUTFBytes( f.size );

			} catch ( error:IOError ) {

				errormes = "Publish:readstring:html file I/O Error";

			} finally {
			
				fs.close();
			}
			
			return s;
		}


		//　テキストファイル書き出し(html用）
		private function writestring( f : File, s : String )
		{
			try
			{
				var fs = new FileStream(); 
			
				fs.open( f, FileMode.WRITE );
			
				fs.writeUTFBytes( s );
			
			} catch( error:IOError ) {
				
				errormes = "Publish:writestring:html file I/O Error";
				
			} finally {
		
				fs.close();
			}
		}

		// swf、htmlを配置する。
		private function locatehtmlswf( f : File, xmlfile : File )
		{
			var appdir : File = File.applicationDirectory;
			var swforgfile : File = appdir.resolvePath( movieviewer_swf );
			var swftargfile : File = f.parent.resolvePath( movieviewer_swf );
			var jsorgfile : File = appdir.resolvePath( movieviewer_js );
			var jstargfile : File = f.parent.resolvePath( movieviewer_js );

			var htmltempfile : File = appdir.resolvePath( movieviewer_html );
			var htmltargfile : File = f.parent.resolvePath( f.nativePath  );
														   
			
			if ( (!swforgfile.exists) || (!htmltempfile.exists) )
			{			
				errormes = "Publish:locatehtmlswf:Missing html/swf files.";
				return;
			}
			
			swforgfile.copyTo( swftargfile, true );
			jsorgfile.copyTo( jstargfile, true );
			
			var s : String = readstring( htmltempfile );
			var pat:RegExp = /TARGET/g;
			
			s = s.replace( pat, xmlfile.name );
//			s = s.replace( pat, xmlfile.name ); // 置換対象が二カ所にあるため。
			
//			trace ( xmlfile.name );
			
			writestring( htmltargfile, s );

		}
		
		
		// matrix 用の js、htmlを配置する。
		private function locatehtmljs_mat( f : File, xmlfile : File )
		{
			var appdir : File = File.applicationDirectory;
			var cssorgfile : File = appdir.resolvePath( matrixviewer_css  );
			var csstargfile : File = f.parent.resolvePath( matrixviewer_css  );
			var jsorgfile : File = appdir.resolvePath( matrixviewer_js  );
			var jstargfile : File = f.parent.resolvePath( matrixviewer_js  );

			var htmltempfile : File = appdir.resolvePath( matrixviewer_temphtml );
			var htmltargfile : File = f.parent.resolvePath( f.nativePath  );
														   
			
			if ( (!jsorgfile.exists) || (!htmltempfile.exists) )
			{			
				errormes = "Publish:locatehtmljs_mat:Missing html/js files.";
				return;
			}
			
			cssorgfile.copyTo( csstargfile, true );
			jsorgfile.copyTo( jstargfile, true );
			
			var s : String = readstring( htmltempfile );
			var pat:RegExp = /TARGET/g;
			
			s = s.replace( pat, xmlfile.name );
//			s = s.replace( pat, xmlfile.name ); // 置換対象が二カ所にあるため。
			
//			trace ( xmlfile.name );
			
			writestring( htmltargfile, s );

		}

		// パブリッシュ前の環境保存／復帰
		private var ppath : String;
		private var pfilen : String;
		private var pfile : File;
	
		public function PushEnv()
		{
			ppath = xmlprojectpath;
			pfilen = xmlprojectfilen;
			pfile = xmlprojectfile;
		}
	
		public function PopEnv()
		{
			xmlprojectpath = ppath;
			xmlprojectfilen = pfilen;
			xmlprojectfile = pfile;
		}
	

		public function PublishProjectXMLToFile( mbd : MatrixBookmarkData )
		{
			xmlprojectfile = new File( xmlprojectpath );
			
			pub_mbd = mbd;
			PushEnv();
			
		
//			xmlprojectfile_resav = xmlprojectfile.clone();
//			xmlprojectfilen_resav = xmlprojectfilen;
		
			
			//			var filter : FileFilter = new FileFilter("XML File", "*.xml");
			errormes = "";
			xmlprojectfile.addEventListener( Event.SELECT, publishfileselected );

			//xmlprojectfile.browseForSave( "Publish Project Files" /*,[filter] */ ); // 第二引数がありそうなものだが。
			xmlprojectfile.browseForDirectory( "プロジェクトをパブリッシュします" );
		}

		private function publishfileselected( e : Event )
		{
			xmlprojectfile.removeEventListener( Event.SELECT, savefileselected );
	 
			//xmlprojectfile = addextention(xmlprojectfile, ".xml" );

			var basename : File = new File(xmlprojectfilen);

			trace( 'basename = ' + basename );
			xmlprojectfile = xmlprojectfile.resolvePath( delext( basename.name ) );
			xmlprojectfile.createDirectory();

			xmlprojectpath = xmlprojectfile.nativePath;
	
			xmlprojectfile = genprojectname(xmlprojectfile, ".xml" );
			xmlprojectfilen = xmlprojectfile.url;

	 		htmlfile = replaceextention(xmlprojectfile, '.html' );   // 元と違うURLの場合はファイルオブジェクトを新たに作って返す
			htmlfilename = htmlfile.url;

			locatehtmlswf( htmlfile, xmlprojectfile );

			AllUpdate( true );
//			trace( xmlprojectfilen );
			
			SaveProjectXMLToFile( true );
			
//			xmlprojectfile = xmlprojectfile_resav.clone();
//			xmlprojectfilen = xmlprojectfilen_resav;

			if ( ( pub_mbd != null ) && ( pub_mbd.cells != null ) && ( pub_mbd.cells.length>0 ) )
			{
				
				pub_mbd.PushEnv();
				
				pub_mbd.xmlmatrixbookmarkfile = new File( xmlprojectfile.parent.parent.nativePath );
				
				pub_mbd.xmlmatrixbookmarkfile.addEventListener( Event.SELECT, publishmbdselected );
				pub_mbd.xmlmatrixbookmarkfile.browseForSave( "MatrixしおりXMLをパブリッシュします" /*,[filter] */ );

			}
			PopEnv();
		}

		private function publishmbdselected( e : Event )
		{
			pub_mbd.xmlmatrixbookmarkfile.removeEventListener( Event.SELECT, publishmbdselected );
			
			pub_mbd.xmlmatrixbookmarkfile = addextention( pub_mbd.xmlmatrixbookmarkfile, ".xml" );
			
			pub_mbd.SaveMatrixBookmarkXMLToFile( true );
			
			
			var tmp : File = pub_mbd.xmlmatrixbookmarkfile.parent;
			var htmlf : File = tmp.resolvePath( matrixviewer_html );
			
			//var htmlf : File = replaceextention( pub_mbd.xmlmatrixbookmarkfile, '.html' ); // htmlファイルをMatrixしおりXMLと同じ名前にする場合
			locatehtmljs_mat( htmlf, pub_mbd.xmlmatrixbookmarkfile );			

			pub_mbd.PopEnv();

			pub_mbd = null;			
		}

		// 上書き保存 xmlprojectfile.urlが""の場合はSaveAsを呼ぶこと。
		// パブリッシュに使う場合は publishmodeをtrueで呼ぶ。
		public function SaveProjectXMLToFile( publishmode : Boolean )
		{
			var stream : FileStream = new FileStream();

			if (xmlprojectfilen == "") { errormes = "SaveProject: Project folder is not specified."; return; }

			xmlprojectfile = new File( xmlprojectfilen );

			if (publishmode)
			{
				fpub = new FilePublisher();
			}

			xmlprojectdata = GenProjectXML( xmlprojectfile, publishmode );

			xml_savetofile( xmlprojectfile, xmlprojectdata );
		
			for (var i : int = 0; i<videofiles.length; i++ )
			{
				var vf : VideoFiles = videofiles[i];
				
				for (var j : int = 0; j < vf.effectfiles.length; j++ )
				{
					var ef : EffectFiles = vf.effectfiles[j];
					
					if ( ef.update_f )
					{
						var efxml : XML = GenEffectXML( ef, publishmode );
						xml_savetofile( ef.effectfile, efxml );
					}
				}
				
			}
			
			for ( i = 0; i<subtitlefiles.length; i++ )
			{
				var st : SubtitleFiles = subtitlefiles[i];
				
				if ( st.update_f )
				{
					var stxml : XML = GenSubtitleXML( st );
					xml_savetofile( st.subtitlefile, stxml );
				}
			
			}
			
			var bm : BookmarkFiles = bookmarkfiles[0];		
			if ( bm.update_f )
			{
				var bmxml : XML = GenBookmarkXML();
				xml_savetofile( bm.bookmarkfile, bmxml );
			}
			
			if (publishmode)
			{
	//			fpub.CopyExecute( updatefnc["progressProgressDialog" ] );
	//			updatefnc["UpdateChangeCurrentElem2"] (); // パブリッシュ中ダイアログを消すため
	
				fpub.CopyExecuteByTimer_Start();
				
			}
			else
			{
				AllUpdate( false );
				updatefnc["UpdateChangeCurrentElem"] ();
			}
			
/*
			try
			{
				stream.open( file, FileMode.WRITE);
				stream.writeUTFBytes( xmlheadder + xmlprojectdata.toXMLString() );
		
				
			} catch( error:IOError ) {

				errormes = "SaveProject:File I/O Error";
	 
			} finally {
				
				stream.close();
				
			}
*/
		}

		// 

		// ブラウズしてのファイルからの読み込み
		public function LoadProjectXMLFromFile()
		{
			errormes = "";
			
			if ( xmlprojectpath == "" ) xmlprojectpath = File.documentsDirectory.nativePath;
			
			xmlprojectfile = new File(xmlprojectpath);
//			xmlprojectfile.browse([filefilter]);
			xmlprojectfile.browseForDirectory( "Load Project Folder" );
			xmlprojectfile.addEventListener( Event.SELECT, loadfileselected );
			nowloading = true;
		}
		

		// ファイル名指定で読み込む。
		public function LoadProjectXMLFromFileByName( filename : String )
		{
			errormes = "";
			
			xmlprojectfile = new File(filename);
			
			xmlprojectpath = xmlprojectfile.nativePath;
			
			xmlprojectfile.addEventListener( Event.COMPLETE, loadcomplete );
			xmlprojectfile.addEventListener( IOErrorEvent.IO_ERROR, loaderror );
			
			nowloading = true;
			
			//trace( "fullpath=" + xmlprojectfile.nativePath );
			xmlprojectfile.load();
		}
		
		private function loadfileselected( e : Event )
		{
			
			xmlprojectfile.removeEventListener( Event.SELECT, savefileselected );
			
			xmlprojectpath = xmlprojectfile.nativePath;
			
			xmlprojectfile = genprojectname(xmlprojectfile, ".xml" );

			xmlprojectfile.addEventListener( Event.COMPLETE, loadcomplete );
			xmlprojectfile.addEventListener( IOErrorEvent.IO_ERROR, loaderror );
			
			xmlprojectfile.load();

			//trace( "loadselected .. " );
		}
		
		private function loadcomplete( e : Event )
		{
			xmlprojectfilen = xmlprojectfile.url;
	
			xmlprojectdata = null;
			xmlprojectdata = new XML( xmlprojectfile.data );
			
			if (xmlprojectdata.name() != 'movieDescription' )
			{
				alartmes = "映像記述XMLファイルではありません";
//				trace (" Here ....?"+ xmlprojectdata.name() );
					   
				return;
			}
			
			//trace( "loadcomplete .. " );
			
			Clear();
			SetupProjectFromXML();

			xmlprojectfile.removeEventListener( Event.SELECT, loadfileselected );
			xmlprojectfile.removeEventListener( Event.COMPLETE, loadcomplete );
			xmlprojectfile.removeEventListener( IOErrorEvent.IO_ERROR, loaderror );
			
			//trace( "load Complete" );
			if (loadcount==0) updatefnc["UpdateChangeCurrentElem2"] ();
			
			nowloading = false;
		}
		
		private function loaderror( e :Event )
		{
			xmlprojectfile.removeEventListener( Event.SELECT, loadfileselected );
			xmlprojectfile.removeEventListener( Event.COMPLETE, loadcomplete );
			xmlprojectfile.removeEventListener( IOErrorEvent.IO_ERROR, loaderror );
			errormes = "LoadXML : File I/O Error";
			//trace("Load Error");
			
			if (loadcount==0) updatefnc["UpdateChangeCurrentElem2"] ();
			nowloading = false;
		}
		
		private function loaderror_simple( e :Event )
		{
			errormes = "LoadXML : File I/O Error";
			//trace("Load Error");
			
			if (loadcount==0) updatefnc["UpdateChangeCurrentElem2"] ();
			
			nowloading = false;
		}


		// エフェクトが選択されているかどうか
	
		public function isselect( el : ObjectDataElem ) : Boolean
		{
			for( var i : int = 0; i < MultiSelection.length; i++ )
			{	
				if (el == MultiSelection[i] ) return true;
					
			}
			return false;
		}


		// 全てのエフェクトのマウスイベントをOnにする
		
		public function EnableMouseEventALL()
		{
			for( var i : int = 0; i < Elem.length; i++ )
			{	
				var el : ObjectDataElem = Elem[i];
				
				if (el.mc!=null) { el.mc.mouseEnabled = true; el.mc.mouseChildren = true; }
				
			}
		}
		
		
		// 現在のカレントビデオ番号を返す
		
		public function GetCurvideoIndex() : int
		{
			for (var i : int = 0;  i< videofiles.length; i++ )
			{
				if (videofiles[i] == curvideofile ) return i;
			}
			return -1;
		}

	} 

}
