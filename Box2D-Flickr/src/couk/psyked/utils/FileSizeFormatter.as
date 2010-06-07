package couk.psyked.utils
{

	public class FileSizeFormatter
	{

		/**
		 * Returns the file size (in bytes) as a logical string.
		 */
		public static function GetFileSize( num:Number ):String
		{
			var bytes:Number = num;
			var kilobytes:Number = num / 1024;
			var megabytes:Number = kilobytes / 1024;
			var gigabytes:Number = megabytes / 1024;

			if ( gigabytes > 1 )
			{
				return Math.ceil( gigabytes * 100 ) / 100 + " GB";
			}
			else if ( megabytes > 1 )
			{
				return Math.ceil( megabytes * 100 ) / 100 + " MB";
			}
			else if ( kilobytes > 1 )
			{
				return Math.ceil( kilobytes ) + " KB";
			}
			else
			{
				return Math.ceil( bytes ) + " Bytes";
			}
		}
	}
}