package main 
{
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.media.Camera;
	import flash.media.Microphone;
	
	/**
	 * Viewr + Translator
	 */
	public class Translator extends Peer
	{
		//
		// ПЕРЕМЕННЫЕ
		//
		protected var _outputStream:NetStream;
		protected var _inputStream:NetStream;
		protected var _video:Video;
		
		//
		// КОНСТРУКТОР и INIT'ы
		//
		
		public function Translator(serverUrl:String, video:Video)
		{
			super(serverUrl);
			_video = video;
		}
		
		private function initOutputStream():void {
			_outputStream = new NetStream(_connection, _groupSpec.groupspecWithAuthorizations());
		}
		
		private function initInputStream():void {
			_inputStream = new NetStream(_connection, _groupSpec.groupspecWithAuthorizations());
			_inputStream.addEventListener(NetStatusEvent.NET_STATUS, onInputStream);
		}
		
		//
		// ОБРАБОТЧИКИ СОБЫТИЙ
		//
		
		override protected function onConnectionEvent(e:NetStatusEvent):void 
		{
			switch(e.info.code) {
				case "NetStream.Connect.Success":
					this.publishCameraAndMicrophone();
					break;
				default:
					super.onConnectionEvent(e);
			}
		}
		
		override protected function onGroupEvent(e:NetStatusEvent):void 
		{
			switch(e.info.code) {
				case "NetGroup.MulticastStream.PublishNotify":
					this.playStream(e.info.name);
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
		
		//
		// ОБРАБОТКА ИСХОДЯЩЕГО ПОТОКА
		//
		
		public function beginTranslation():void {
			this.initOutputStream();
		}
		
		private function publishCameraAndMicrophone():void {
			var nameStream:String = _connection.nearID;
			var cam:Camera = Camera.getCamera();
				cam.setMode(800, 600, 25);
				cam.setQuality(0, 90);
			var mic:Microphone = Microphone.getMicrophone();
				mic.setLoopBack(true);
				mic.setUseEchoSuppression(true);
			// публикация потока
			_outputStream.attachCamera(cam);
			_outputStream.attachAudio(mic);
			_outputStream.publish(nameStream);
			
			// трансляция самого себя
			_video.attachCamera(cam);
		}
		
		//
		// ОБРАБОТКА ВХОДЯЩЕГО ПОТОКА
		//
		
		private function playStream(nameStream:String) {
			this.initInputStream();
			_inputStream.play(nameStream);
		}
		
		protected function attachStreamToVideo():void {
			_video.attachNetStream(_inputStream);
		}
	}
}