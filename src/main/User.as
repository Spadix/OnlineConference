package main 
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * Пользователь конфернции
	 */
	public class User 
	{
		private var _id:String;
		private var _username:String;
		
		public function get id():String { return _id; };
		public function get username():String { return _username; };
		
		public function User(id:String, username:String)
		{
			_id = id;
			_username = username;
		}
	}
}