package main
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import flash.external.ExternalInterface;
	
	[SWF(backgroudColor="0x000000")]
	public class Main extends Sprite 
	{
		private const SERVER_URL:String = "rtmfp://p2p.rtmfp.net";
		private const DEVELOP_KEY:String = "3c4f5f1ade545334033a3d06-805376d8c198";
		
		private var _peer:Peer;
		
		private function get _isConnected():Boolean {
			return _peer.connectionObj.connected;
		}
		
		public function Main():void 
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//
			ExternalInterface.addCallback("getPeerId", getPeerId);
			ExternalInterface.addCallback("beginTranslation", beginTranslation);
			ExternalInterface.addCallback("connect", connect);
		}
		
		public function getPeerId():String {
			if (_isConnected)
				return _peer.peerId;
			return "";
		}
		
		public function connect():void {
			_peer = new Peer(SERVER_URL, DEVELOP_KEY);
		}
		
		public function beginTranslation():void {
			if (!_isConnected)
				this.connect();
		}
	}
}