package  
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	/**
	 * Элемент (один) группы
	 */
	public class Peer 
	{
		private var connection:NetConnection;
		private var room:Room;
		
		public function get peerId():String {
			return this.connection.nearID;
		}
		
		public function get connectionObj():NetConnection {
			return this.connection;
		}
		
		public function Peer(serverUrl:String, developKey:String) {
			this.initConnection();
			this.connection.connect(serverUrl, developKey);
		}
		
		private function initConnection() {
			this.connection = new NetConnection();
			this.connection.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
				switch (event) {
					// peer успешно подключился к серверу авторизации
					case "NetConnection.Connect.Success":
						this.room = new Room(this, "Name of room");
						break;
				}
			});
		}
		
		/**
		 * Отправка сообщения кому то конкретно, либо всей группе
		 * @param	message		сообщение
		 * @param	groupAddres групповой адрес получателя
		 */
		public function Send(message:Object) {
			this.room.post(message);
		}
		
		/**
		 * Получение сообщения
		 */
		public function Receive(message:Object) {
			// посылка команды JS с сообщением 
		}
		
		/**
		 * Проигрывание медиа (видео- аудио-)
		 */
		public function PlayMedia() {
			
		}
	}
}