package main 
{
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	import flash.utils.SetIntervalTimer;
	
	/**
	 * Участник группы (пир)
	 * 
	 * Функции:
		 * подключение к группе и соединению
		 * обработка сообщений группы
		 * управление пользователями группы
	 */
	public class Peer 
	{
		//
		// Для отладки
		//
		public function debug(value:Object):void {
			ExternalInterface.call("eval", "alert('"+ JSON.stringify(value) +"')");
		}
		
		//
		// несовсем КОНСТАНТЫ
		//
		
		private var SERVER_URL:String;
		
		//
		// ПЕРЕМЕННЫЕ
		//
		
		protected var _connection:NetConnection;
		protected var _group:NetGroup;
		protected var _groupSpec:GroupSpecifier;
		protected var _nameGroup:String;
		protected var _userManager:UserManager;
		protected var _username:String;
		
		//
		// КОНСТРУКТОР и INIT'ы
		//
		
		public function Peer(serverUrl:String, developKey:String):void {
			this.SERVER_URL = serverUrl + developKey;
			_nameGroup = "test";
			_username = "Translator";
			_userManager = new UserManager();
		}
		
		private function initConnection():void {
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionEvent);
			_connection.connect(SERVER_URL);
		}
		
		private function initGroup():void {
			this.initGroupSpecifier();
			_group = new NetGroup(_connection, _groupSpec.groupspecWithAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, onGroupEvent);
		}
		
		private function initGroupSpecifier():void {
			_groupSpec = new GroupSpecifier(_nameGroup);
			_groupSpec.multicastEnabled = true;
            _groupSpec.serverChannelEnabled = true;
            _groupSpec.postingEnabled = true;
		}
		
		//
		// ОБРАБОТЧИКИ СОБЫТИЙ
		//
		
		protected function onConnectionEvent(e:NetStatusEvent):void {
			debug(e.info.code);
			switch (e.info.code) {
				// peer успешно подключился к серверу авторизации
				case "NetConnection.Connect.Success":
					this.initGroup();
					break;
			}
		}
		
		protected function onGroupEvent(e:NetStatusEvent):void {
			debug(e.info.code);
			switch (e.info.code) {
				// к группе подключился новый peer (рассказываем о себе)
				case "NetGroup.Neighbor.Connect":
					this.postIamMessage();
					break;
				// обработка сообщений группы
				case "NetGroup.Posting.Notify":
					this.onInputMessage(e.info.message, e.info.messageID);
					break;
				// отключение пользователя от группы
				case "NetGroup.Neighbor.Disconnect":
					_userManager.remove(e.info.peerID);
					break;
			}
		}
		
		protected function onInputMessage(message:Object, messageID:String):void {
			if (message.type == "iam" && !_userManager.exist(message.peerID)) {
				_userManager.add(message.peerID, message.username);
			}
		}
		
		//
		// GET'еры
		//
		
		public function get connected():Boolean {
			if (_connection != null) {
				return _connection.connected;
			}
			return false;
		}
		
		public function get id():String {
			if (this.connected) {
				return _connection.nearID;
			}
			return "";
		}
		
		//
		// МЕТОДЫ
		//
		public function connect():void {
			if (!this.connected) {
				this.initConnection();
			}
		}
		
		public function listUsers():Object {
			return _userManager.listUsers();
		}
		
		protected function postIamMessage():void {
			_group.post({
				type: "iam",
				username: _username,
				peerId: this.id
			});
		}
	}
}