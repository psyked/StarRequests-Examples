package couk.psyked.utils
{
	import flash.filesystem.File;

	public class NativeFileUtils
	{
		public static function getFilesRecursive( folder:String ):Array
		{
			var fileList:Array = new Array();
			var currentFolder:File = new File( folder );
			var files:Array = currentFolder.getDirectoryListing();

			//iterate and put files in the result and process the sub folders recursively
			for ( var f:uint = 0; f < files.length; f++ )
			{
				if ( files[ f ].isDirectory )
				{
					if ( files[ f ].name != "." && files[ f ].name != ".." )
					{
						//it's a directory
						fileList = fileList.concat( getFilesRecursive( files[ f ].nativePath ));
					}
				}
				else
				{
					//it's a file yupeee
					fileList.push( files[ f ]);
				}
			}
			return fileList;
		}
	}
}