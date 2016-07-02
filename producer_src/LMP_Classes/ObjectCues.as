package LMP_Classes
{
	import fl.motion.Color;


　　public class ObjectCues
	{
	    public var item_id : String;
		public var seconds : Number;
		public var nx : Number;			// エフェクトの座標（画面左上を原点、画面縦幅を1.0とする実数座標）
		public var ny : Number;
		
		public var onx, ony : Number;
		
    	public var angledegree : Number;
		public var scalex : Number;
		public var scaley : Number;
		
		public var col : Color;

		public function ObjectCues() {
			// constructor code
			col = new Color();
			
			item_id = "";
			scalex = 1.0;
			scaley = 1.0;
			seconds = 0;
			nx = 0;
			ny = 0;
			
			onx = 0; ony = 0;
			
			angledegree = 0;
		}
		
		public function Clear()
		{
			item_id = null;
			col = null;
		}
		
    }
}