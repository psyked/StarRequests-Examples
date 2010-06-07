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
			//trace( url );
			_url = url;
			_data = data;

			alpha = 0.4;

			var context:LoaderContext = new LoaderContext( true );
			context.checkPolicyFile = true;
			
			var ldr:Loader = new Loader();
			ldr.contentLoaderInfo.addEventListener( Event.COMPLETE, handleLoadComplete );
			ldr.load( new URLRequest( _url ), context );

			buttonMode = true;
			mouseChildren = false;

		/*addEventListener( MouseEvent.ROLL_OVER, this.handleRollOver );
		   addEventListener( MouseEvent.ROLL_OUT, this.handleRollOut );
		 addEventListener( MouseEvent.CLICK, this.handleRelease );*/
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

		private function handleLoadComplete( event:Event ):void
		{
			_image = event.target.content;
			addChild( _image );
			//_image.alpha = 0;
			_image.smoothing = true;
			//TweenMax.to( _image, 0.5, { alpha: 1, ease: Quint.easeOut });
			dispatchEvent( new Event( "allLoaded" ));
		}

	/*private function handleRollOver( event:MouseEvent ):void
	   {
	   //TweenMax.to( event.target, 0.5, { glowFilter: { color: 0x0022ff, alpha: 1, blurX: 7, blurY: 7 }, scaleX: 1.1, scaleY: 1.1, alpha: 1, ease: Quint.easeOut });
	   dispatchEvent( new Event( "showCallout" ));
	   }

	   private function handleRollOut( event:MouseEvent ):void
	   {
	   //TweenMax.to( event.target, 0.5, { glowFilter: { alpha: 0, blurX: 0, blurY: 0 }, scaleX: 1.0, scaleY: 1.0, alpha: 0.4, ease: Quint.easeOut });
	   dispatchEvent( new Event( "hideCallout" ));
	   }

	   private function handleRelease( event:MouseEvent ):void
	   {
	   var url:String = "http://www.flickr.com/photos/" + _data.ownerId + "/" + _data.id;
	   navigateToURL( new URLRequest( url ));
	 }*/
	}
}