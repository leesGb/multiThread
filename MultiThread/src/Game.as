package
{
	import flash.display.DisplayObjectContainer;
	import flash.utils.setTimeout;
	
	import deltax.appframe.BaseApplication;
	import deltax.gui.component.event.DXWndMouseEvent;
	
	
	/**
	 *
	 *@author lees
	 *@date 2016-11-7
	 */
	
	public class Game extends BaseApplication
	{
		private var _gameStart:Function;
		private var _middleMouseDown:Boolean;
		private var _ox:int;
		private var _oy:int;
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
		
		override protected function onMiddleMouseDown(evt:DXWndMouseEvent):void
		{
			_middleMouseDown = true;
			_ox = evt.globalX;
			_oy = evt.globalY;
		}
		
		override protected function onMiddleMouseUp(evt:DXWndMouseEvent):void
		{
			_middleMouseDown = false;
		}
		
		override protected function onMouseMove(evt:DXWndMouseEvent):void
		{
			if(_middleMouseDown && camController)
			{
				var xx:int = _ox - evt.globalX;
				var yy:int = _oy - evt.globalY;
				camController.translateXZ(xx,-yy);
				_ox = evt.globalX;
				_oy = evt.globalY;
			}
		}
		
		
		
	}
}