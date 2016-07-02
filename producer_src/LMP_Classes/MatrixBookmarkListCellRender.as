package LMP_Classes
{ 

//
//	AIRで利用可能なMXDataGridはセル単体での選択ができないため、選択対象セル上にテキストフィールドによるカーソルを表示し
//  セル選択状態を表現する。
//


    import fl.controls.listClasses.CellRenderer; 
 	import flash.text.*;

    public class MatrixBookmarkListCellRender extends CellRenderer 
    { 
		public var cursor = null;
		public var par = null;
		
		public var cell_selected : Boolean;
		public var cell_text_color : uint;
		public var cell_alpha : Number;
	

		public function MatrixBookmarkListCellRender() 
        { 
			this.textField.multiline = true;
			this.textField.wordWrap = true;
			
			if (cursor==null)
			{
				cursor = new TextField();
				
				cursor.defaultTextFormat = this.textField.defaultTextFormat;
				
　	　　		cursor.border = true;
				cursor.background = true;
			}

			this.cell_selected = false;
			this.cell_text_color = 0x000000;
			this.cell_alpha = 1; // ※0が完全透明、1不透明。（背景色はこの場合グレー）
			
			
			

		}
					
		public function CreateCursor()
　　	{
　	　　	//ボーダーとして使うテキストフィールドを作成
　	　　	//大きさはセル自体より一回り小さくする

			if (cursor==null) return;

			cursor.borderColor = 0x112222;
			cursor.backgroundColor = 0x00ffff;
			cursor.alpha = 0.3;
		

			cursor.x = 3; 
			cursor.y = 3; 
			cursor.width = _width - 6;
			cursor.height = _height - 6;
	
			cursor.text = "";
	
			//trace( "w:" + cell.width + "   h:" + cell.height + "   txt:" + this.textField.text );
		
			if (par != null)
			{
//				trace( par == this );
//		
//				//trace( "RemoveChild" );
				par.removeChild( cursor );
				par = null;
			}

			if ( this.cell_selected )
			{
				var tf : TextFormat = new TextFormat();
				tf.size = 12;
				tf.bold = true;
				this.textField.setTextFormat( tf );

				this.addChild( cursor );
			
				par = this;
			}
			
　　	}

		const MATRIXBOOKMARKEDITOR_EDITSTARTCOLUMUN = 2;

        override protected function drawLayout():void
		{   
			//trace('drawLayout');
				
			this.textField.textColor = cell_text_color;
			this.alpha = cell_alpha;
			
			cursor.visible = false;
			CreateCursor();
			super.drawLayout();
			
			cursor.visible = true;

        }
		
    } 
}