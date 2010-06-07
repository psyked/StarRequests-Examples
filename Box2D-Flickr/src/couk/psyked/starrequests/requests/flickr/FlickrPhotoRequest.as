package couk.psyked.starrequests.requests.flickr
{
	import com.adobe.webapis.flickr.Photo;

	import couk.markstar.starrequests.requests.AbstractRequest;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	public class FlickrPhotoRequest extends AbstractRequest
	{
		protected var _photo:Photo;

		protected var _url:String;

		public static const SIZE_SQUARE:String = "_s";

		public static const SIZE_THUMBNAIL:String = "_t";

		public static const SIZE_SMALL:String = "_m";

		public static const SIZE_MEDIUM:String = "";

		public static const SIZE_LARGE:String = "_l";

		public static const SIZE_ORIGINAL:String = "_o";

		public function FlickrPhotoRequest( photo:Photo, size:String = "_t" )
		{
			_photo = photo;

			_url = 'http://farm' + photo.farmId + '.static.flickr.com/' + photo.server + '/' + photo.id + '_' + photo.secret + size + '.jpg';

			_completedSignal = new Signal( Bitmap );

		}

		protected var _loader:Loader;

		override public function send():void
		{
			super.send();

			var context:LoaderContext = new LoaderContext( true );
			context.checkPolicyFile = true;

			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, completeListener );
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
			_loader.load( new URLRequest( _url ), context );
		}

		override protected function cleanup():void
		{
			super.cleanup();
			_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, progressListener );
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, completeListener );
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorListener );
			_loader = null;
			_photo = null;
			_url = null;
		}

		override public function get completedSignal():ISignal
		{
			return super.completedSignal;
		}

		/**
		 * @private
		 */
		protected function progressListener( e:ProgressEvent ):void
		{
			trace( "progressListener", e );
			_progressSignal.dispatch( e.bytesLoaded / e.bytesTotal );
		}

		/**
		 * @private
		 */
		protected function completeListener( e:Event ):void
		{
			trace( "completeListener", e );
			var loaderInfo:LoaderInfo = LoaderInfo( e.currentTarget );
			var rtnObject:Bitmap = _loader.content as Bitmap;

			_completedSignal.dispatch( rtnObject );
			cleanup();
		}

		/**
		 * @private
		 */
		protected function ioErrorListener( e:IOErrorEvent ):void
		{
			trace( "ioErrorListener", e );
			_failedSignal.dispatch( e.text );
			cleanup();
		}
	}
}