package main
{
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.net.NetStream;

	import flash.external.ExternalInterface;
	
	/**
	 * Элемент (один) группы
	 */
	public class Peer 
	{
		//
		// ПЕРЕМЕННЫЕ
		//
		private var _nameGroup:String;
		private var _users:Object;
		private var _connection:NetConnection;
		private var _group:NetGroup;
		private var _inVideo:Video;
		
		//
		// ПОТОКИ
		//
		private var _inStream:NetStream;
		private var _outStream:NetStream;
		
		//
		// GET'еры
		//
		public function get peerId():String {
			return _connection.nearID;
		}
		
		public function get connected():Boolean {
			return _connection.connected;
		}
		
		public function get inputStream():NetStream {
			return _inStream;
		}
		
		public function get outputStream():NetStream {
			return _outStream;
		}
		
		private function get groupSpecifier():GroupSpecifier {
			var grSpec = new GroupSpecifier(_nameGroup);
			grSpec.multicastEnabled = true;
            grSpec.serverChannelEnabled = true;
            grSpec.postingEnabled = true;
			return grSpec;
		}
		
		//
		// КОНСТРУКТОР и INIT'ы
		//
		public function Peer(serverUrl:String, developKey:String, nameGroup:String = "Название комнаты") {
			this.initConnection();
			_nameGroup = nameGroup;
			_connection.connect(serverUrl, developKey);
		}
		
		private function initConnection() {
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionEvent);
		}
		
		public function initGroup():void {
			_group = new NetGroup(_connection, this.groupSpecifier.groupspecWithAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, onGroupEvent);
		}
		
		private function initInputStream():void {
			_inStream = new NetStream(_connection,  this.groupSpecifier.groupspecWithAuthorizations());
			_inStream.addEventListener(NetStatusEvent.NET_STATUS, onInputStreamEvent);
		}
		
		//
		// ОБРАБОТЧИКИ СОБЫТИЙ
		//
		
		private function onConnectionEvent(e:NetStatusEvent):void {
			switch (e) {
				// peer успешно подключился к серверу авторизации
				case "NetConnection.Connect.Success":
					this.initGroup();
					break;
				// трансляция видео с камеры
				case "NetStream.Connect.Success":
					this.attachVideoAudioOuputStream();
					break;
			}
		}
		
		private function onGroupEvent(e:NetStatusEvent):void {
			switch (e) {
				// к группе подключился новый peer
				case "NetGroup.Neighbor.Connect":
					this.addNewUser(e.info.neighbor, e.info.peerID);
					break;
				// отключение пользователя от группы
				case "NetGroup.Neighbor.Disconnect":
					this.deleteUser(e.info.peerID);
					break;
				// обработка входящего потока
				case "NetGroup.MulticastStream.PublishNotify":
					this.receptionInputStream(e.info.name);
					break;
			}
		}
		
		private function onInputStreamEvent(e:NetStatusEvent):void {
			switch(e) {
				// трансляция видео
				case "NetStream.Play.Start":
					this.playVideo();
					break;
			}
		}
		
		//
		// МЕТОДЫ ЛОГИКИ
		//
		
		/**
		 * Начала трансляции видео
		 */
		public function beginVideoTranslation(video:Video):void {
			_inVideo = video;
			_outStream = new NetStream(_connection, this.groupSpecifier.groupspecWithAuthorizations());
		}
		
		/**
		 * Добавление пользователя
		 */
		private function addNewUser(groupAddress:String, peerId:String):void {
			if (!_users.hasOwnProperty(peerId))
				_users[peerId] = { groupAddress: groupAddress };
		}
		
		/**
		 * Удаление пользователя
		 */
		private function deleteUser(peerId:String):void {
			if (_users.hasOwnProperty(peerId))
				delete _users[peerId];
		}

		/**
		 * Трансляция входящего потока
		 */
		private function receptionInputStream(name:String):void {
			this.initInputStream();
			_inStream.play(name);
		}
		
		private function playVideo():void {
			_inVideo.attachNetStream(_inStream);
		}
		
		private function attachVideoAudioOuputStream():void {
			var nameStream:String = _connection.nearID;
			
			_outStream.attachCamera(Camera.getCamera());
			_outStream.attachAudio(Microphone.getMicrophone());
			_outStream.publish(nameStream);
			
			this.receptionInputStream(nameStream);
		}
	}
}