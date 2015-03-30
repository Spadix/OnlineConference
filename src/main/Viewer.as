package main 
{
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	/**
	 * Просмоторщик
	 * 
	 * Функции:
		 * трансляция (просмотр) входящего потока
	 */
	public class Viewer extends Peer
	{
		//
		// ПЕРЕМЕННЫЕ
		//
		protected var _inputStream:NetStream;
		protected var _video:Video;
		
		//
		// КОНСТРУКТОР и INIT'ы
		//
		public function Viewer(serverUrl:String, developKey:String, video:Video)
		{
			super(serverUrl, developKey);
			_video = video;
		}
		
		private function initStream():void {
			_inputStream = new NetStream(_connection, _groupSpec.groupspecWithAuthorizations());
			_inputStream.addEventListener(NetStatusEvent.NET_STATUS, onInputStream);
		}
		
		//
		// МЕТОДЫ
		//
		private function reception(nameStream:String) {
			this.initStream();
			_inputStream.play(nameStream);
		}
		
		override protected function onGroupEvent(e:NetStatusEvent):void 
		{
			switch(e.info.code) {
				case "NetGroup.MulticastStream.PublishNotify":
					debug(e.info.code);
					this.reception(e.info.name);
					break;
				default:
					super.onGroupEvent(e);
			}
		}
		
		protected function onInputStream(e:NetStatusEvent):void {
			debug(e.info.code);
			switch (e.info.code) {
				case "NetStream.Play.Start":
					this.attachStreamToVideo();
			}
		}
		
		protected function attachStreamToVideo():void {
			_video.attachNetStream(_inputStream);
		}
	}
}