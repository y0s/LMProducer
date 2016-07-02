package LMP_Classes
{
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;

    // 形状編集用ハンドルに関するクラス

    public class EditMarkers
	{
		public var type : int;
		
		public var cp : Point;
		public var pos : Point;
		public var org : Point;
		public var orgscalex, orgscaley, orglength, orgrot, orgx, orgy, onx, ony : Number;
		
		public var mc : MovieClip;

		public var scalex, scaley : Number;
		public var rot : Number;

		public var CurElem : ObjectDataElem;
		public var updatefnc : Object; // 表示要素更新関数
		
		public var eg : EditGUI; // 上階層
		
		public var evlis : Boolean; // イベントリスナの有無。表示中はイベントリスナが存在する。
		
		public var elem : ObjectDataElem;

		public function EditMarkers( _updatefnc : Object )
		{
			cp = new Point();
			pos = new Point();
			org = new Point();
			
			orgscalex = 1;
			orgscaley = 1;
			orglength = 0;
			orgrot = 0;
			orgx = 0;
			orgy = 0;
			onx =0;
			ony = 0;
			
			scalex = 1;
			scaley = 1;
			rot = 0;
	
			updatefnc = new Object;
			updatefnc["UpdateCurrentElem"] = _updatefnc;

			evlis = false;
			elem = null;
		}

		public function Hypot( p : Point ) : Number
		{
			return Math.sqrt( p.x*p.x+p.y*p.y );
		}

	    public function Angle( p : Point ) : Number
		{
			var s : Number;
			s = (Math.acos( p.x/Hypot( p ) ) / Math.PI)*180;
			
			if ( p.y<0 ) s = 360-s;
			
			return s;
		}

		private function em_dragstart( e : MouseEvent )
		{
			var tmp_p : Point = new Point();
			var cue0, cue1 : ObjectCues;
			
			//trace( "dragstart :" + pos.x + "," + pos.y );
	
			if (eg.ed.CurElem == null) return; 

			//trace( "dragstart :A" );


			org.x = pos.x; org.y = pos.y;
			
			scalex =1; scaley = 1; rot = 0;
			
			tmp_p.x = org.x-cp.x; tmp_p.y = org.y-cp.y;

			cue0 = eg.ed.CurElem.Cues[0];
//			cue1 = eg.ed.CurElem.Cues[eg.ed.CurElem.Cues.length-1]; エフェクトを動かすときはここを生かす。


			orgscalex = cue0.scalex; orgscaley = cue0.scaley;
			orglength = Hypot( tmp_p );


			orgrot = Angle( tmp_p ) - cue0.angledegree;


			orgx = e.stageX; orgy = e.stageY;
			onx = cue0.nx; ony = cue0.ny;

			for ( var i : int = 0; i<eg.ed.MultiSelection.length; i++ )
			{
				var el : ObjectDataElem = eg.ed.MultiSelection[i];
				
				for ( var j=0; j<el.Cues.length; j++ )
				{
					var cue : ObjectCues = el.Cues[j];
					
					cue.onx = cue.nx;
					cue.ony = cue.ny;
					
				}
			
			}

			mc.mouseEnabled = false;

			eg.ed.MovDrf = true;
			eg.ed.SelDrf = false;

			eg.CurEditMarker = this;
		
		}
		
		private function em_dragend( e : MouseEvent )
		{
			mc.mouseEnabled = true;
			
			eg.ed.MovDrf = false;
			eg.ed.SelDrf = false;
		
			eg.CurEditMarker = null;
		}
		
	
		public function Visible()
		{
			if (mc==null) return;
			mc.alpha = 1.0;
			
			if (!evlis)
			{
				if (elem != null)
				{
					//trace("set event handler" );
					elem.DragStart = em_dragstart;
					elem.DragEnd = em_dragend;
				}
				else
				{
					mc.addEventListener( MouseEvent.MOUSE_DOWN, em_dragstart );
					mc.addEventListener( MouseEvent.MOUSE_UP, em_dragend );
				}
				mc.mouseEnabled = true;
				evlis = true;
			}
		}
		
		public function Invisible()
		{
			if (mc==null) return;
			mc.alpha = 0;

			if (evlis)
			{
				
				if (elem!=null)
				{
					elem.DragStart = null;
					elem.DragEnd = null;
				}
				else
				{
					mc.removeEventListener( MouseEvent.MOUSE_DOWN, em_dragstart );
					mc.removeEventListener( MouseEvent.MOUSE_UP, em_dragend );
				}
				mc.mouseEnabled = false;
				evlis = false;
			}
		}
		
	}

}