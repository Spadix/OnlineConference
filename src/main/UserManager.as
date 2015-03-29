package main 
{
	import flash.net.NetGroup;
	/**
	 * Класс для работы с пользователями
	 */
	public class UserManager 
	{
		private var _users:Object;
		
		public function UserManager()
		{
			_users = new Object();
		}
		
		/**
		 * Проверяет есть ли в списке данный пользователь
		 * @param	id	ID пира
		 */
		public function exist(id:String) {
			return _users[id] != null;
		}
		
		public function listUsers():Object {
			return _users;
		}
		
		/**
		 * Добавление пользователя в группу
		 * @param	id			ID пира
		 * @param	username	имя пользователя
		 */
		public function add(id:String, username:String):void {
			if (!this.exist(id)) {
				_users[id] = new User(id, username);	
			}
		}
		
		/**
		 * Удаленеи пользователя из списка
		 * @param	id	ID пира
		 */
		public function remove(id:String):void {
			if (this.exist(id)) {
				delete _users[id];
			}
		}
	}
}