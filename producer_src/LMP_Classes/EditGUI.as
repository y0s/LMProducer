package LMP_Classes
{
import flash.display.MovieClip;
import flash.events.MouseEvent;	
import flash.display.Shape;
import flash.geom.*; 
	
	public class EditGUI
	{
		public var CurEditMarker : EditMarkers = null;
		public var ed : ObjectData;
		
		public var stageobj : Object; 
		public var markers : Array; // EditMarkersの配列。現在は9個固定
		public var num_markers : int;  // 純粋なEditMarkerの数。複数選択時にはすべての選択エレメントのムービークリップが移動マーカー扱いになるため。
		
		public var makemask : Object;
		public var updatefnc : Object;
		public var deselectmatrixfnc : Object;

		const ROTSNAP : int = 3;     // 0,90,180,270 度近辺でのスナップ
		const ROTGRID : int = 15;	 // シフトキー押しながら回転刺せたときのグリッド
		
　　　　public var RubberbandBox_sh : Shape;
		
		public function EditGUI( _stageobj : Object, _ed : ObjectData, _updatefnc : Object, _deselectmatrix : Object )
		{
			stageobj = _stageobj;
			ed = _ed;
		
			updatefnc = new Object;
			updatefnc["UpdateCurrentElem"] = _updatefnc;
			
			deselectmatrixfnc = new Object;
			deselectmatrixfnc["deselectmatrix"] = _deselectmatrix;
			
			num_markers = 0;
	
			InitEditmarkers();
			
			stageobj.addEventListener(MouseEvent.MOUSE_DOWN,ST_DragStart);
			stageobj.addEventListener(MouseEvent.MOUSE_MOVE,ST_Dragging);
			stageobj.addEventListener(MouseEvent.MOUSE_UP,ST_DragEnd);
						
			ed.SelectedBx.addEventListener(MouseEvent.MOUSE_DOWN,ST_DragStart);
			ed.SelectedBx.addEventListener(MouseEvent.MOUSE_MOVE,ST_Dragging);
			ed.SelectedBx.addEventListener(MouseEvent.MOUSE_UP,ST_DragEnd);
			
			RubberbandBox_sh = new Shape();
			RubberbandBox_sh.graphics.clear();
			
			RubberbandBox_sh.mask = ed.makemask["makemask"]( ed.rootobj );
			
			stageobj.addChild( RubberbandBox_sh );
		
		}
		
		//
		// エディットマーカーの初期化
		//

		// X,Y軸個別拡大縮小マーカー
		private function makemonoscalemarker( mc : MovieClip )
		{
   			var marker:Shape = new Shape(); 

    		marker.graphics.lineStyle(0,0x000000); 
    		marker.graphics.beginFill(0xEEFFFF, 1); 
			marker.graphics.drawRect(-4,-4,8,8); 
   			marker.graphics.endFill(); 
   			mc.addChild(marker); 
		}

		// X,Y同時拡大縮小マーカー（SHIFT+で相似拡大）
		private function makemultiscalemarker( mc : MovieClip )
		{
   			var marker:Shape = new Shape(); 

    		marker.graphics.lineStyle(0,0x000000); 
    		marker.graphics.beginFill(0xEEFFFF,1); 
			marker.graphics.drawCircle(0,0,4); 
   			marker.graphics.endFill(); 
   			mc.addChild(marker); 
		}


		// 回転マーカー（SHIFT+で15度単位回転、SHIFTなしでも0度90度180度270度近傍はスナップ）
		private function makerotmarker( mc : MovieClip )
		{
   			var marker:Shape = new Shape(); 

    		marker.graphics.lineStyle(0,0x000000); 
			marker.graphics.moveTo(0,-4);
			marker.graphics.lineTo(0,-12);
    		marker.graphics.beginFill(0xBBFFBB,1); 
			marker.graphics.drawCircle(0,-16,4); 
   			marker.graphics.endFill(); 

   			mc.addChild(marker); 
		}
		// マーカー配列の初期化

		public function Clear()
		{
		var i : int;
		var em : EditMarkers;
		
		    if (num_markers > 0)
			{
				if (markers!=null)
				    for( i=0; i<num_markers-1; i++ )
				    {
					    em=markers[i];
					    //ed.rootobj.removeChild( em.mc );  // 最後のマーカー【以】降はバウンディングボックスなのでremoveChildできない。
					    em.mc.parent.removeChild( em.mc );
				    }
			}
				
			markers = new Array();
		}

		// 移動は強調表示のバウンディングボックスを兼用する。

		public	function InitEditmarkers()
		{
			var em : EditMarkers;
			var emc : EditMarkerConstants = new EditMarkerConstants();
			var i : int;

			Clear();


			// 拡大縮小回転
			for ( i=0; i<4; i++ ) // 0-3 は軸独立スケール用
			{
				em = new EditMarkers( updatefnc["UpdateCurrentElem"] );

				if ((i % 2)==0) em.type = emc.EDITMARKER_SCALE_Y else em.type = emc.EDITMARKER_SCALE_X;
				em.eg = this;
		
				em.mc = new MovieClip();
				ed.rootobj.addChild( em.mc );
//				ed.SelectedBx.addChild( em.mc )
				
				makemonoscalemarker( em.mc );
		
				em.mc.alpha=0;
				em.mc.mask = ed.makemask["makemask"]( ed.rootobj );
	
				markers.push( em );
			}
	
			for (i=4; i<8; i++) // 4-7 は2軸スケール用
			{
				em = new EditMarkers( updatefnc["UpdateCurrentElem"] );
				em.type = emc.EDITMARKER_SCALE_XY;
				em.eg = this;

				em.mc = new MovieClip();
				ed.rootobj.addChild( em.mc );
//				ed.SelectedBx.addChild( em.mc );

				makemultiscalemarker( em.mc );

				em.mc.alpha=0;
				em.mc.mask = ed.makemask["makemask"]( ed.rootobj );
		
				markers.push( em );
			}

			// 8は回転用
			em = new EditMarkers( updatefnc["UpdateCurrentElem"] );
			em.type = emc.EDITMARKER_ROTATION;
			em.eg = this;

			em.mc = new MovieClip();
			ed.rootobj.addChild( em.mc );

			makerotmarker( em.mc );

			em.mc.alpha=0;
			em.mc.mask = ed.makemask["makemask"]( ed.rootobj );
		
			markers.push( em );

/*
			//　枠
			em = new EditMarkers( updatefnc["UpdateCurrentElem"] );
			em.type = emc.EDITMARKER_MOVE;
			em.eg = this;
			
			em.mc = ed.SelectedBx;
//			ed.Bxs.addChild( em.mc );
			
			if (em.mc.mask!=null) em.mc.mask.parent.removeChild( em.mc.mask ); 
			em.mc.mask = ed.makemask["makemask"]( ed.rootobj );
		
			markers.push( em );
*/

			// 移動マーカー
			em = new EditMarkers( updatefnc["UpdateCurrentElem"] );
			em.type = emc.EDITMARKER_MOVE;
			em.eg = this;
			
			em.mc = ed.SelectedBx; // ダミー。後ほど ObjectData.DispSelectedBxにてエフェクトのmcを設定。

			if (em.mc.mask!=null) em.mc.mask.parent.removeChild( em.mc.mask ); 
			em.mc.mask = ed.makemask["makemask"]( ed.rootobj );
		
			markers.push( em );
			num_markers = markers.length;

			// 複数選択時の移動用
			for ( i = 0; i < ed.MultiSelection.length; i++ )
			{
				//trace("Here is InitEditMarkers" );
				
				var el : ObjectDataElem = ed.MultiSelection[i];
				
				if (el.mc==null) continue;
				
				em = new EditMarkers( updatefnc["UpdateCurrentElem"] );
				em.type = emc.EDITMARKER_MOVE;
				em.eg = this;
			
				em.mc = el.mc;

				if (em.mc.mask!=null) em.mc.mask.parent.removeChild( em.mc.mask ); 
				em.mc.mask = ed.makemask["makemask"]( ed.rootobj );
				em.elem = el;
				markers.push( em );				
			}
		}

		// マーカーの見た目を回転させる
		public function rot_markers( rot : Number )
		{
			var i : int;
			var em : EditMarkers;
			if (markers==null) return;
			for( i=0; i<num_markers-1; i++ ) 
			{
				em=markers[i];
				if ( em.scaley<0 ) // Yスケールが負なら方向反転
				{
					trace( "em.scaley:" + em.scaley );
					em.mc.rotation = (rot+180)%360;
				} else {
					em.mc.rotation = rot;
				}
	  	 	}
		}

		private function rad( d : Number ) : Number
		{
			return (Math.PI / 180) * d;
		}

 		private function rotz( p : Point, d : Number ) : Point
		{
			var  r, s, c : Number;
			var rx, ry : Number;

		    r = rad( d );
     		s = Math.sin( r ); c = Math.cos( r );
     		rx = p.x * c -  p.y * s; ry = p.x * s + p.y * c;
			
			p.x = rx; p.y = ry;
			
			return p;
		}


		// ラバーバンドボックス
		// draw_fをFalseにして呼ぶと消すだけ。

		public function RubberbandBox( x1, y1, x2, y2 : Number, draw_f : Boolean )
		{
			RubberbandBox_sh.graphics.clear();
			if (!draw_f) return;

			RubberbandBox_sh.graphics.lineStyle(2,0xFFFFFF,1.0);
			RubberbandBox_sh.graphics.moveTo( x1, y1 );
			RubberbandBox_sh.graphics.lineTo( x2, y1 );
			RubberbandBox_sh.graphics.lineTo( x2, y2 );
			RubberbandBox_sh.graphics.lineTo( x1, y2 );
			RubberbandBox_sh.graphics.lineTo( x1, y1 );			
			
		}

/*
		// 選択されているかどうか
		
		private function isselect( el : ObjectDataElem )
		{
			if (el==null) return false;
			if (el==ed.CurElem) return true;
			
			var rv : Boolean = false;
			
			for( var i = 0; i< ed.MultiSelection.length; i++)
			{
				var tmp : ObjectDataElem = ed.MultiSelection[i];
				
				if (el==tmp)
				{
					rv = true; break;
				}
	
			}
			
			return rv;
		}
*/

		// 矩形で選択する

		public function SelectByRectangle( x1, y1, x2, y2 : Number, shift : Boolean )
		{
			var tmp : Number;
			
			if (!shift) // SHIFTキーで追加選択
			{
				ed.CurElem = null;
				ed.MultiSelection = []; // 選択解除
			}
			
			if (x1>x2)
			{
				tmp = x1;
				x1 = x2;
				x2 = tmp; // swap x1, x2
			}
			
			if (y1>y2)
			{
				tmp = y1;
				y1 = y2;
				y2 = tmp; // swap y1, y2
			}
			
			var el : ObjectDataElem;
			
			for( var i : int = 0; i < ed.Elem.length; i++ )
			{
				el = ed.Elem[i];
				
				if (el.Cues.length == 0) continue;

				var cue : ObjectCues = el.Cues[0];

				if ( cue ==null ) continue;
				if ( el.mask_sh==null ) continue;
			
				//var x : Number = cue.nx * el.mask_sh.height + (ed.porg_w - ed.parentobj.width)/2;
				//var y : Number = cue.ny * el.mask_sh.height + (ed.porg_h - ed.parentobj.height)/2;	
		
				var x : Number = el.mc.x - ed.SelectedBx.x;
				var y : Number = el.mc.y - ed.SelectedBx.y;
		
		
				//trace( x1,y1,x2,y2, x, y );
	
		
				if ( ( x>x1 )&&( x<x2 ) && ( y>y1 ) && ( y<y2 ) && (el.belongto_ef.belongto_vf == ed.curvideofile ) )
				{
					if (!ed.isselect(el)) ed.MultiSelection.push( el )
					ed.CurElem = el;
				}
			}
		
	
		}

		// stageオブジェクト用イベントハンドラ

		public function ST_DragStart( e : MouseEvent )
		{
			if ((e.stageX<ed.parentobj.x) || (e.stageX>(ed.parentobj.x+ed.parentobj.width))
			 || (e.stageY<ed.parentobj.y) || (e.stageY>(ed.parentobj.y+ed.parentobj.height))) return; // Player面の外ははじいておかないと、
			 																						  // ボタンを操作するだけで選択が解除されたりする。
			
		
			ed.Drx = e.stageX;
			ed.Dry = e.stageY;
		
			if (!(ed.MovDrf)) ed.SelDrf = true else ed.SelDrf = false; 
		}
		
		public function ST_Dragging( e : MouseEvent )
		{
			var tmp_p : Point = new Point();
			var cue0, cue1 : ObjectCues;


			// trace( ed.SelDrf, ed.MovDrf );

			if (ed.MovDrf) ed.SelDrf = false;

			if (ed.SelDrf)
			{
				RubberbandBox( ed.Drx, ed.Dry, e.stageX, e.stageY, true ); 
				ed.MovDrf = false;
				return;
			}

			//trace( "SelDrf:" + ed.SelDrf +  "   MovDrf:" + ed.MovDrf  );

			var emc : EditMarkerConstants = new EditMarkerConstants();

			//trace("Dragging");


			if (!e.buttonDown) return;
    		if (CurEditMarker==null) return;

			//trace("Dragging_A");

			CurEditMarker.pos.x = e.stageX; CurEditMarker.pos.y = e.stageY;	
			
			tmp_p.x = CurEditMarker.pos.x-CurEditMarker.cp.x;
			tmp_p.y = CurEditMarker.pos.y-CurEditMarker.cp.y;
			
			//cue0 = ed.CurElem.Cues[0];
			//cue1 = ed.CurElem.Cues[ed.CurElem.Cues.length-1];


			for ( var i : int = 0; i < ed.MultiSelection.length; i++ )
			{
				var el : ObjectDataElem = ed.MultiSelection[i];
				
				cue0 = el.Cues[0];
				cue1 = el.Cues[el.Cues.length-1];

				switch (CurEditMarker.type)
				{
					case emc.EDITMARKER_SCALE_X:
					{
						if (CurEditMarker.orglength==0) return;
						CurEditMarker.scalex = CurEditMarker.Hypot( tmp_p )/CurEditMarker.orglength;
			
						cue0.scalex = CurEditMarker.scalex * CurEditMarker.orgscalex;
						cue1.scalex = CurEditMarker.scalex * CurEditMarker.orgscalex;
						break;	
					}
				
				
					case emc.EDITMARKER_SCALE_Y:
					{
						if (CurEditMarker.orglength==0) return;
						CurEditMarker.scaley = CurEditMarker.Hypot( tmp_p )/CurEditMarker.orglength;
						cue0.scaley = CurEditMarker.scaley * CurEditMarker.orgscaley;
						cue1.scaley = CurEditMarker.scaley * CurEditMarker.orgscaley;
						break;	
					}
				
				
					case emc.EDITMARKER_SCALE_XY:
					{
						if (CurEditMarker.orglength==0) return;
					
						if ( e.shiftKey )
						{
							CurEditMarker.scalex = CurEditMarker.Hypot( tmp_p )/CurEditMarker.orglength;
							CurEditMarker.scaley = CurEditMarker.scalex;
			
							cue0.scalex = CurEditMarker.scalex * CurEditMarker.orgscalex;
							cue0.scaley = CurEditMarker.scaley * CurEditMarker.orgscaley;
							cue1.scalex = CurEditMarker.scalex * CurEditMarker.orgscalex;
							cue1.scaley = CurEditMarker.scaley * CurEditMarker.orgscaley;
						} else {
						
							var _org : Point = new Point;
							var _tmp : Point = new Point;

							_org.x = CurEditMarker.org.x - CurEditMarker.cp.x;
							_org.y = CurEditMarker.org.y - CurEditMarker.cp.y;
							rotz( _org, -cue0.angledegree );
							_tmp.x = tmp_p.x; _tmp.y = tmp_p.y;
							rotz( _tmp, -cue0.angledegree );
						
							if (_org.x!=0) CurEditMarker.scalex = _tmp.x/_org.x else CurEditMarker.scalex = 1;
							if (_org.y!=0) CurEditMarker.scaley = _tmp.y/_org.y else CurEditMarker.scaley = 1;
			
							cue0.scalex = Math.abs(CurEditMarker.scalex * CurEditMarker.orgscalex);
							cue0.scaley = Math.abs(CurEditMarker.scaley * CurEditMarker.orgscaley);
							cue1.scalex = cue0.scalex;
							cue1.scaley = cue0.scaley;					}
					
						break;	
					}

					case emc.EDITMARKER_ROTATION: 
					{
						CurEditMarker.rot = CurEditMarker.Angle( tmp_p ) - CurEditMarker.orgrot;

						if (e.shiftKey)
						{
							CurEditMarker.rot = int(CurEditMarker.rot - ( CurEditMarker.rot % ROTGRID ));
						}
						else
						{
							if (Math.abs(CurEditMarker.rot)<ROTSNAP) CurEditMarker.rot = 0;
							if (Math.abs(CurEditMarker.rot-90)<ROTSNAP) CurEditMarker.rot = 90;
							if (Math.abs(CurEditMarker.rot-180)<ROTSNAP) CurEditMarker.rot = 180;
							if (Math.abs(CurEditMarker.rot-270)<ROTSNAP) CurEditMarker.rot = 270;
							if (Math.abs(CurEditMarker.rot-360)<ROTSNAP) CurEditMarker.rot = 360;
						}

	
						CurEditMarker.rot = (CurEditMarker.rot+360) % 360;

						cue0.angledegree = CurEditMarker.rot;
						cue1.angledegree = CurEditMarker.rot;

						break;
					}
				
					case emc.EDITMARKER_MOVE: 
					{
						var vx, vy : Number;
					
						vx =  (CurEditMarker.pos.x - CurEditMarker.orgx)/ed.SelectedBx.mask.height;
						vy =  (CurEditMarker.pos.y - CurEditMarker.orgy)/ed.SelectedBx.mask.height;
					

						if ( e.shiftKey )
						{
							if (Math.abs(vx)<Math.abs(vy))
							{
//								cue0.nx = CurEditMarker.onx;
//								cue0.ny = CurEditMarker.ony + vy;

								cue0.nx = cue0.onx;
								cue0.ny = cue0.ony + vy;

　
							} else {
//								cue0.nx = CurEditMarker.onx + vx;
//								cue0.ny = CurEditMarker.ony ;

								cue0.nx = cue0.onx + vx;
								cue0.ny = cue0.ony;
							}
						
						} else {
//							cue0.nx = CurEditMarker.onx + vx;
//							cue0.ny = CurEditMarker.ony + vy;　

							cue0.nx = cue0.onx + vx;
							cue0.ny = cue0.ony + vy;
						}

						cue1.nx = cue0.nx;
						cue1.ny = cue0.ny;

						break;
					}
			
				}
				el.belongto_ef.update_f = true;
			}
			
//			ed.CurElem.belongto_ef.update_f = true; // 現在のところ、この関数で編集されるのはエフェクトだけ。
			
			rot_markers( CurEditMarker.rot );
			
			updatefnc["UpdateCurrentElem"]();
		}


		public function ST_DragEnd( e : MouseEvent )
		{
			if (CurEditMarker!=null) CurEditMarker.mc.mouseEnabled = true;
			CurEditMarker = null;
			
			if (ed.SelDrf)
			{
				SelectByRectangle( ed.Drx, ed.Dry, e.stageX, e.stageY, e.shiftKey );
				updatefnc["UpdateCurrentElem"]();
				if (ed.updatefnc["UpdateChangeCurrentElem3"]!=null) ed.updatefnc["UpdateChangeCurrentElem3"]();
				
				deselectmatrixfnc[ "deselectmatrix" ]();
				
			}
		
			RubberbandBox( ed.Drx, ed.Dry, e.stageX, e.stageY, false ); 		
			ed.SelDrf = false;
			ed.MovDrf = false;
			
			ed.EnableMouseEventALL();
			
		}

	}
}


