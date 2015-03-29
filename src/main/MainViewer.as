package main 
{
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.media.Video;
	
	/**
	 * Главный класс
	 */
	public class MainViewer extends Sprite
	{
		private const SERVER_URL:String = "rtmfp://p2p.rtmfp.net";
		private const DEVELOP_KEY:String = "3c4f5f1ade545334033a3d06-805376d8c198";
		
		private var _viewer:Viewer;
		private var _video:Video;
		
		public function MainViewer():void
		{
			this.initVideo();
			_viewer = new Viewer(SERVER_URL, DEVELOP_KEY, _video);
			ExternalInterface.addCallback("getPeerId", getPeerId);
			ExternalInterface.addCallback("connect", connect);
		}
		
		private function initVideo():void {
			_video = new Video(this.width, this.height);
			_video.x = 0;
			_video.y = 0;
			this.addChild(_video);
		}
		
		public function getPeerId():String {
			if (_viewer.connected)
				return _viewer.id;
			return "";
		}
		
		public function connect():void {
			_viewer.connect();
		}
	}
}