package
{
	import com.adobe.webapis.flickr.Photo;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.LoaderContext;

	public class Thumb extends Sprite
	{
		private var _id:int;

		private var _url:String;

		private var _image:Bitmap;

		private var _data:Photo;

		public function Thumb( url:String, data:Photo )
		{
			_url = url;
			_data = data;

			buttonMode = true;
			mouseChildren = false;
		}

		public function get image():Bitmap
		{
			return _image;
		}

		public function set image( value:Bitmap ):void
		{
			_image = value;
		}

		public function get data():Photo
		{
			return _data;
		}

	}
}