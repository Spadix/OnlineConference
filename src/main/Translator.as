package main 
{
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.media.Camera;
	import flash.media.Microphone;
	
	/**
	 * Транслятор
	 * 
	 * Функции:
		 * трансляция (передача) видео с камеры и аудио с микрофона
	 */
	public class Translator extends Peer
	{
		//
		// ПЕРЕМЕННЫЕ
		//
		protected var _outputStream:NetStream;
		private var _video:Video;
		
		//
		// КОНСТРУКТОР и INIT'ы
		//
		public function Translator(serverUrl:String, developKey:String, video:Video)
		{
			super(serverUrl, developKey);
			_video = video;
		}
		
		private function initStream():void {
			_outputStream = new NetStream(_connection, _groupSpec.groupspecWithAuthorizations());
		}
		
		//
		// МЕТОДЫ
		//
		public function begin():void {
			this.initStream();
		}
		
		override protected function onConnectionEvent(e:NetStatusEvent):void 
		{
			switch(e.info.code) {
				case "NetStream.Connect.Success":
					this.attachCameraAndMicrophone();
					break;
				default:
					super.onConnectionEvent(e);
			}
		}
		
		private function attachCameraAndMicrophone():void {
			var nameStream:String = _connection.nearID;
			
			_outputStream.attachCamera(Camera.getCamera());
			_outputStream.attachAudio(Microphone.getMicrophone());
			_outputStream.publish(nameStream);
			
			_video.attachCamera(cam);
		}
	}
}