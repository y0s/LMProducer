/*
	プロジェクトファイル管理クラス
*/


package LMP_Classes
{
	import flash.filesystem.File;
	
	public class ProjectFiles
	{

		public var filename : String;
		
		public var vf_index : int; // videofileの番号
		public var videofilename : String;
		
		public function ProjectFiles()
		{
			filename = "";
			vf_index = -1;
			videofilename = "";
		}

	}
	
}
