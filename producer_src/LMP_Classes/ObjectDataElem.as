package LMP_Classes
{
	import flash.net.dns.AAAARecord;
	import flash.display.MovieClip;
	import fl.motion.Color;
	import flash.display.Loader;
	import flash.display.Shape; 
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.events.*;


	public class ObjectDataElem
	{
	
		public var id : String;
		public var type : String;          //↑ OBJECTTYPE_*が代入される
		
		public var filename : String;   // type が、OBJECTTYPE_PICTURE　のとき

		public var Cues : Array;		// ObjectCues の配列。将来的に複数もつことも想定

		public var belongto_ef : EffectFiles;		// エフェクトならエフェクトファイル、字幕なら字幕ファイルへのポインタ
		public var belongto_st : SubtitleFiles;
		
		public var belongto_pf : ProjectFiles;		// Matrixしおりの時のみ
		
//     エフェクト

		public var cx : int;			// エフェクトの原点座標(内部/ピクセル単位）
		public var cy : int;
		public var w : int;				// エフェクトの幅・高さ(内部/ピクセル単位）
		public var h : int;
		
		public var mc : MovieClip;		// エフェクトの本体・トップレベル
		public var eff_mc : MovieClip;  // エフェクトの本体
		public var il : Loader;			// 画像
		public var mask_sh : Shape;　　 // マスク用シェイプ


//		字幕
		public var fontsize : int;		// フォントサイズ
//		しおり
		public var favorite : Boolean;	// お気に入り
		
		
//		字幕＆しおり
		public var labeltext : String; // 字幕の場合は字幕テキスト、しおりの場合はラベル。
		
//		リスト表示用アイコン
		public var icon_mc : MovieClip;  // エフェクトのリスト表示用アイコン　しおりの場合はお気に入りアイコン 字幕の場合は字幕ファイルA
		public var blank_mc : MovieClip; // しおりの場合のブランクアイコン　字幕の場合は字幕ファイルB

		public var ed : ObjectData; // 上階層
		
		public var DragStart : Object; // エレメントのドラッグスタートイベントハンドら
		public var DragEnd : Object; // エレメントのドラッグスタートイベントハンドら

		// コンストラクタ
		public function ObjectDataElem( _mask_sh : Shape )
		{

			Cues = new Array();

			// constructor code
			var ec : ObjectCues = new ObjectCues();
			Cues.push( ec );
		    ec = new ObjectCues(); 
			Cues.push( ec );
			
		
			if ( _mask_sh != null )
			{
			    mc = new MovieClip();
				eff_mc = null;
				
				icon_mc = new MovieClip();
				blank_mc = new MovieClip();
				
			    il = null;
			    mask_sh = _mask_sh;
			}
			else
			{
				mc = null;
				eff_mc = null;
				
				icon_mc = null;
				blank_mc = null;
				
				il = null;
				mask_sh = null;
			}
			
			belongto_ef = null;
			belongto_st = null;
			
			belongto_pf = null;
	
			favorite = false;
			fontsize = ObjectDataConstants.DEFAULT_FONTSIZE;
			
			DragStart = null;
			DragEnd = null;
			
		
		}
		
		// Cues 配列の破棄。ガベージコレクタが自動で良きに計らってくれるとも限らないらしいので。
		public function Clear()
		{

			if ( mc != null )
			{
				if ( il != null ) mc.removeChild( il );
		    	mc.parent.removeChild( mc );
			}
		
		    id = null;
			filename = null;
			mc = null;
			
			icon_mc = null;
			blank_mc = null;
			
			il = null;
		
			while( Cues.length>0 )
			{
			    var cue : ObjectCues;								
				
				cue = Cues.pop();
				cue.Clear();
	
				cue = null;
			}
		}


        // エフェクト開始・終了時刻の調整( 開始時刻が終了時刻より後なら、Cueの並びを反転する　）
		
		public function AdjustShowTime()
		{
			var cue0, cue1 : ObjectCues;

			cue0 = Cues[0];
			cue1 = Cues[Cues.length-1];
		
			if (cue0.seconds>cue1.seconds) Cues.reverse();
			
		}
		

		// エフェクトの表示開始時刻設定
		public function SetStartTime( ct : Number )
		{
			var cue : ObjectCues;

			cue = Cues[0];
			cue.seconds = ct;
			
			AdjustShowTime();
		
		}
		
		// エフェクトの表示終了時刻設定
		public function SetEndTime( ct : Number )
		{
			var cue : ObjectCues;
			
			cue = Cues[Cues.length-1];
			cue.seconds = ct;
			
			AdjustShowTime();
		
		}

		// エフェクトを表示できるか(表示期間に現在時刻を含み、カレントビデオに属し、カレントエフェクトファイルが表示状態になっているもの）
		public function isShowEffect( ct : Number, cue0 : ObjectCues, cue1 : ObjectCues ) : Boolean
		{
			var rv : Boolean;
			
			rv = false;
			if ((cue0.seconds<=ct) && (cue1.seconds>=ct))
			{
				if (belongto_ef.checked)
				{
					if (belongto_ef.belongto_vf.current) rv = true;
				}
		
			}
			return rv;
		}


		// エフェクトを選択出来るか（カレントビデオに属し、カレントエフェクトファイルが表示状態になっているもの）
		public function isSelectableEffect() : Boolean
		{
			var rv : Boolean = false;
	
			if (belongto_ef.checked)
			{
				if (belongto_ef.belongto_vf.current) rv = true;
			}

			return rv;
		}

  	    // 指定時刻におけるエフェクトの表示制御。将来的にディゾルブやモーション補間などが入る場合はこのメソッドを拡張する。
		public function AnimateEffectElem( ct : Number )
		{
		    var cue0, cue1 : ObjectCues;
			var hh : Number;
			
			cue0 = Cues[0]; cue1 = Cues[1];

			if ( belongto_ef == null ) return;   // mcを持たないのは字幕かしおり 
/*			
　　		if ((cue0.seconds<=ct) && (cue1.seconds>=ct))
			{
				mc.alpha = 1;
			}					
			else
			{
				mc.alpha = 0;
			}
*/

			if (isShowEffect( ct, cue0, cue1 ))
			{
				mc.alpha = 1; mc.parent.setChildIndex( mc, mc.parent.numChildren-1 );
			}
			else
			{
				mc.alpha = 0; mc.parent.setChildIndex( mc, 0 ); 
			}


			if (isSelectableEffect())
			{
				mc.enabled = true; mc.visible = true; 
			}
			else
			{
				mc.enabled = false; mc.visible = false;
			}



			mc.x = cue0.nx*mask_sh.height + mask_sh.x + (ed.porg_w - ed.parentobj.width)/2;
			mc.y = cue0.ny*mask_sh.height + mask_sh.y +(ed.porg_h - ed.parentobj.height)/2; // 縦幅を１とするため。heightを使う。
			mc.rotation = cue0.angledegree;

			hh =  (ed.parentobj.height/ed.porg_h);   // 縦幅が16:9（デフォルト）より狭いアスペクト比の場合の補正
			mc.scaleX = cue0.scalex * hh;
			mc.scaleY = cue0.scaley * hh;
//			trace( cue0.seconds, ct, cue1.seconds );
		}

		// エフェクトの形状を作成する。typeがOBJECTTYPE_PICTURE　の場合は、画像を読み込む。
		public function EffectShape( type : String, filename : String )
		{
		var itm : Class;
		var cue0 : ObjectCues;
		
			switch (type)
			{
				case ObjectDataConstants.OBJECTTYPE_EFFECT_CIRCLE:
				{
					eff_mc = new eff_circle();
					//w = mask_sh.width/10;
					//h = w * ( eff_mc.height/eff_mc.width);
					
					h = ed.porg_h/5;
					w = h*( eff_mc.width/eff_mc.height);
					
					cx = 0;
					cy = 0;					
					cue0 = Cues[0];
					
					mc.addChild( eff_mc );
					eff_mc.mask = mask_sh;
					//eff_mc.addEventListener( MouseEvent.CLICK, fl_ElemSelectHandler );
					eff_mc.addEventListener( MouseEvent.MOUSE_DOWN, fl_ElemDragStartHandler );
					eff_mc.addEventListener( MouseEvent.MOUSE_UP, fl_ElemDragEndHandler );
					ed.updatefnc["UpdateChangeCurrentElem"]();
					
					icon_mc = new Eff_Circle_Icn_mc();
					break;
				}	
							
				case ObjectDataConstants.OBJECTTYPE_EFFECT_ARROW: 
				{
					eff_mc = new eff_arrow();
//					w = mask_sh.width/10;
//					h = w * ( eff_mc.height/eff_mc.width );
					
					h = ed.porg_h/5;
					w = h*( eff_mc.width/eff_mc.height);


					cx = -w/2;
					cy = 0;					
					cue0 = Cues[0];
					
					mc.addChild( eff_mc );
					eff_mc.mask = mask_sh;
					//eff_mc.addEventListener( MouseEvent.CLICK, fl_ElemSelectHandler );
					eff_mc.addEventListener( MouseEvent.MOUSE_DOWN, fl_ElemDragStartHandler );
					eff_mc.addEventListener( MouseEvent.MOUSE_UP, fl_ElemDragEndHandler );
					ed.updatefnc["UpdateChangeCurrentElem"]();
					
					icon_mc = new Eff_Arrow_Icn_mc();
					break;					
				}

				/*
				    新しいエフェクトを組み込む場合はこのあたりに、そのためのコードを追加する。
				*/
			
				case ObjectDataConstants.OBJECTTYPE_EFFECT_PICTURE:
				{
					var picurl : URLRequest;
					picurl = new URLRequest( filename );
					il = new Loader();
					il.contentLoaderInfo.addEventListener( Event.COMPLETE,pictureloadcompleted );
					il.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, pictureloaderror );
					il.load( picurl );
					
					icon_mc = new Eff_Image_Icn_mc();
					break;
				}

				/*
					しおり
				
				*/

				case ObjectDataConstants.OBJECTTYPE_BOOKMARK:
				{
					icon_mc = new FavoriteBookmark_mc();
					blank_mc = new NonFavBookmark_mc();
					break;
				}

				/*
					字幕。現在は何もない。
				*/

				case ObjectDataConstants.OBJECTTYPE_SUBTITLE:
				{
					icon_mc = new CaptionA_icn_mc();
					blank_mc = new CaptionB_icn_mc();
					break;
					
				}
	
			}
			
			if (mc!=null) mc.mouseEnabled = true;
	
		}
		
		// 画像エフェクトの読み込み完了処理
		
		private function pictureloadcompleted( e : Event )
		{
		var cue0 : ObjectCues;
	
			w = il.width;
			h = il.height;                                                                                                                                                        

			//cx = il.width/2;
			//cy = il.height/2;
			
			cx = 0;
			cy = 0;
			cue0 = Cues[0];
			
			il.x=-il.width/2;
			il.y=-il.height/2;
			
			mc.x = cue0.nx*mask_sh.height + mask_sh.x + (ed.porg_w - ed.parentobj.width)/2;
			mc.y = cue0.ny*mask_sh.height + mask_sh.y + (ed.porg_h- ed.parentobj.height)/2; // 縦幅を１とするため。heightを使う。
			mc.rotation = cue0.angledegree;

			eff_mc = null;

//			mc.addChild( eff_mc );
//			eff_mc.mask = mask_sh; 

			mc.addChild( il );
			il.mask = mask_sh;	

			il.contentLoaderInfo.removeEventListener( Event.COMPLETE,pictureloadcompleted );
			il.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, pictureloaderror );

			//il.addEventListener( MouseEvent.CLICK, fl_ElemSelectHandler );
			il.addEventListener( MouseEvent.MOUSE_DOWN, fl_ElemDragStartHandler );
			il.addEventListener( MouseEvent.MOUSE_UP, fl_ElemDragEndHandler );
			mc.addEventListener( MouseEvent.MOUSE_DOWN, fl_ElemDragStartHandler );
			mc.addEventListener( MouseEvent.MOUSE_UP, fl_ElemDragEndHandler );
		
			ed.updatefnc["UpdateChangeCurrentElem"]();
		}


		private function pictureloaderror( e : Event )
		{
			il.contentLoaderInfo.removeEventListener( Event.COMPLETE,pictureloadcompleted );
			il.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, pictureloaderror );
			ed.errormes = "LoadEffect:File I/O Error";
		}

/*
		// 選択されているかどうか
		
		public function isselect() : Boolean
		{
			if ( this==ed.CurElem) return true;
			
			var rv : Boolean = false;
			
			for( var i : int = 0; i< ed.MultiSelection.length; i++)
			{
				var tmp : ObjectDataElem = ed.MultiSelection[i];
				
				if (this==tmp)
				{
					rv = true; break;
				}
	
			}
			
			return rv;
		}
*/
		// エレメントの選択イベントハンドラ
		
		private function fl_ElemSelectHandler( event: MouseEvent ) : void
		{
			ed.CurElem = this;
			
			if ( event.shiftKey )
			{
				if (!ed.isselect(this)) ed.MultiSelection.push( this ); // Shiftクリックで加算選択
			} else	{
				ed.MultiSelection = [];
				ed.MultiSelection.push( this ); // クリックでの選択は単数
			}
			//trace( "Select:" );
			
			if (ed.updatefnc["UpdateChangeCurrentElem3"]!=null) ed.updatefnc["UpdateChangeCurrentElem3"]();
		}
		
		// エレメントのドラッグスタートイベントハンドら
		
		private function fl_ElemDragStartHandler( event: MouseEvent ) : void
		{
			ed.Drx = event.stageX;
			ed.Dry = event.stageY;

			if (DragStart != null) DragStart( event );
		}
		
		
		const selectth : int = 4; // クリック判定のためのマウス座標の変化量上限 X,Y ともに4ピクセルいないならクリックと見做し、DragEndの後にエレメントの選択を実行する。
		
		private function fl_ElemDragEndHandler( event: MouseEvent ) : void
		{

			if (DragEnd != null) DragEnd( event );
			
			if (( Math.abs(ed.Drx-event.stageX)<selectth ) &&  ( Math.abs(ed.Dry-event.stageY)<selectth ) ) fl_ElemSelectHandler( event );
			
			ed.DispBxs( true );
		}
			
		
	
	}
}
