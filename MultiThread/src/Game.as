package
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.setTimeout;
	
	import deltax.appframe.BaseApplication;
	
	
	/**
	 *
	 *@author lees
	 *@date 2016-11-7
	 */
	
	public class Game extends BaseApplication
	{
		
		private var _gameStart:Function;
		public function Game($container:DisplayObjectContainer,$gameSatart:Function=null)
		{
			_gameStart = $gameSatart;
			super($container);
		}
		
		override protected function onStarted():void
		{
			super.onStarted();
			this.camController.selfControlEvent = true;
			this.camController.enableSelfMouseWheel = true;
			
			if(_gameStart!=null)
			{
				setTimeout(_gameStart,500);
			}
		}
		
		
		
	}
}