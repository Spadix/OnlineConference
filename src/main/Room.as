package  
{
	import flash.net.GroupSpecifier;
	import flash.net.NetGroup;
	
	/**
	 * Комната (группа)
	 */
	public class Room 
	{
		private final var nameGroup:String;
		
		private var users:Array;
		private var group:NetGroup;
		private var owner:Peer;
		
		private function get groupSpecifier():GroupSpecifier {
			var grSpec = new GroupSpecifier(this.nameGroup);
			grSpec.multicastEnabled = true;
            grSpec.serverChannelEnabled = true;
            grSpec.postingEnabled = true;
			return grSpec;
		}
		
		public function Room(owner:Peer, nameGroup:String):void {
			this.owner = owner;
			this.nameGroup = nameGroup;
			this.group = new NetGroup(this.owner.connectionObj, this.groupSpecifier.groupspecWithAuthorizations());
			this.group.addEventListener(NetStatusEvent.NET_STATUS, function(event:NetStatusEvent) {
				switch (event) {
					// к группе подключился новый peer
					case "NetGroup.Neighbor.Connect":
						this.addNewUser(event.info.neighbor, event.info.peerID);
						break;
					// получение сообщения для данного узла или для все группы
					case "NetGroup.SendTo.Notify":
					case "NetGroup.Posting.Notify":
						this.owner.Receive(event.info.message);
						break;
				}
			});
		}
		
		public function post(message:Object):String {
			return this.group.post(message);
		}
		
		/**
		 * Добавление пира к группе
		 * @param	groupAddress	групповой адрес пира
		 */
		private function addNewUser(groupAddress:String, peerId:String):void {
			if (this.findUser("id", peerId) < 0) {
				this.users.push({id: peerId, groupAddress: groupAddress});
			}
		}
		
		/**
		 * Поиск пользователя по указанному свойству
		 * @param	property	ключ свойства по котороу проходит поиск
		 * @param	value		значение свойства
		 * @return	номер индекса элемента, если совпадение найдено. Иначе -1
		 */
		private function findUser(property:String, value:String):Number {
			for (var i:Number = 0; i < this.users.length; i++) {
				if (this.users[i][property] == value)
					return i;
			}
			return -1;
		}
	}
}