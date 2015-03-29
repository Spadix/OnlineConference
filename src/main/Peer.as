package main 
{
	import flash.events.NetStatusEvent;
	import flash.external.ExternalInterface;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
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
		public function debug(value:Object):void {
			ExternalInterface.call("eval", "alert('"+ JSON.stringify(value) +"')");
		}
		
		//
		// несовсем КОНСТАНТЫ
		//
		private var SERVER_URL:String;
		private var DEVELOP_KEY:String;
		
		//
		// ПЕРЕМЕННЫЕ
		//
		protected var _connection:NetConnection;
		protected var _group:NetGroup;
		protected var _nameGroup:String;
		protected var _userManager:UserManager;
		
		public var _username:String;
		
		//
		// КОНСТРУКТОР и INIT'ы
		//
		public function Peer(serverUrl:String, developKey:String):void {
			this.SERVER_URL = serverUrl;
			this.DEVELOP_KEY = developKey;
			_nameGroup = "test";
			_userManager = new UserManager();
		}
		
		private function initConnection():void {
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionEvent);
			_connection.connect(SERVER_URL, DEVELOP_KEY);
		}
		
		private function initGroup():void {
			_group = new NetGroup(_connection, this.groupSpecifier.groupspecWithAuthorizations());
			_group.addEventListener(NetStatusEvent.NET_STATUS, onGroupEvent);
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
		
		protected function get groupSpecifier():GroupSpecifier {
			var grSpec = new GroupSpecifier(_nameGroup);
			grSpec.multicastEnabled = true;
            grSpec.serverChannelEnabled = true;
            grSpec.postingEnabled = true;
			return grSpec;
		}
		
		//
		// МЕТОДЫ
		//
		public function connect():void {
			if (!this.connected) {
				this.initConnection();
			}
		}
		
		protected function onConnectionEvent(e:NetStatusEvent):void {
			trace(e.info.code);
			switch (e.info.code) {
				// peer успешно подключился к серверу авторизации
				case "NetConnection.Connect.Success":
					this.initGroup();
					break;
			}
		}
		
		protected function onGroupEvent(e:NetStatusEvent):void {
			trace(e.info.code);
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
		
		public function listUsers():Object {
			return _userManager.listUsers();
		}
		
		protected function postIamMessage():void {
			var message = new Object();
			message.type = "iam";
			message.peerID = _connection.nearID;
			message.username = _username;
			_group.post(message);
		}
		
		protected function onInputMessage(message:Object, messageID:String):void {
			if (message.type == "iam" && !_userManager.exist(message.peerID)) {
				_userManager.add(message.peerID, message.username);
			}
		}
	}
}