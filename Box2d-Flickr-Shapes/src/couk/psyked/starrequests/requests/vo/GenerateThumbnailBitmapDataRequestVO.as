package couk.psyked.starrequests.requests.vo
{
	import flash.display.BitmapData;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class GenerateThumbnailBitmapDataRequestVO
	{
		public var thumbnailByteArray:ByteArray;
		public var thumbnailBitmapData:BitmapData;
		public var originalFile:File;
	}
}