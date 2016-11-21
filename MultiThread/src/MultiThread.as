package
{
	import com.utils.FpsUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	
	import deltax.appframe.SceneGrid;
	import deltax.common.resource.Enviroment;
	import deltax.graphic.manager.IResource;
	import deltax.graphic.scenegraph.object.ObjectContainer3D;
	import deltax.graphic.scenegraph.object.RenderObject;
	import deltax.graphic.scenegraph.object.RenderScene;
	
	
	/**
	 *
	 *@author lees
	 *@date 2016-11-7
	 */
	
	public class MultiThread extends Sprite
	{
		private var _gameContainer:Sprite;
		
		private var _game:Game;
		
		private var _renderScene:RenderScene;
		
		private var _caleThread:Worker;
		
		private var _msgToCaleThread:MessageChannel;
		private var _msgToMainThread:MessageChannel;
		
		private var _testData:ByteArray;
		
		public function MultiThread()
		{
			if(stage)
			{
				init();
			}else
			{
				this.addEventListener(Event.ADDED_TO_STAGE,init);
			}
		}
		
		private function init(evt:Event=null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE,init);
			
			this._testData = new ByteArray();
			this._testData.endian = Endian.LITTLE_ENDIAN;
			this._testData.shareable = true;
			this._testData.length = 100;
			
			
			this._caleThread = WorkerDomain.current.createWorker(Workers.CaleThreadSwf);
			this._caleThread.addEventListener(Event.WORKER_STATE,onWorkerStateHandler);
			
			this._msgToCaleThread = Worker.current.createMessageChannel(this._caleThread);
			this._msgToMainThread = this._caleThread.createMessageChannel(Worker.current);
			
			this._caleThread.setSharedProperty("toMainThread",this._msgToMainThread);
			this._caleThread.setSharedProperty("toCaleThread",this._msgToCaleThread);
			this._caleThread.setSharedProperty("shareData",this._testData);
			
			this._msgToMainThread.addEventListener(Event.CHANNEL_MESSAGE,reciveMsgHandler);
			
			this._caleThread.start();
			
			Enviroment.ConfigRootPath = "E:/project/flash/MTArt/assets/config/";
			Enviroment.ResourceRootPath = "E:/project/flash/MTArt/assets/data/";
			
			this._gameContainer = new Sprite();
			this._gameContainer.graphics.beginFill(0,0);
			this._gameContainer.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
			this._gameContainer.graphics.endFill();
			this.addChild(this._gameContainer);
			
			this._gameContainer.mouseEnabled = false;
			this._gameContainer.mouseChildren = false;
			
			_game = new Game(this._gameContainer,onGameStart);
			
			this.stage.addEventListener(Event.RESIZE,onResize);
			
			creatteUI();
			
			showFps();
		}
		
		private function onWorkerStateHandler(evt:Event):void
		{
			if(this._caleThread.state == WorkerState.RUNNING)
			{
//				sendMsgToCaleThread("test","caleThread================"+getTimer());
			}
		}
		
		public function sendMsgToCaleThread(cmd:String,value:*):void
		{
			var arr:Array=[cmd,value];
			this._msgToCaleThread.send(arr);
		}
		
		private function reciveMsgHandler(evt:Event):void
		{
			var msgArr:Array = this._msgToMainThread.receive();
			var cmd:String = msgArr[0];
			switch(cmd)
			{
				case "test":
					trace(msgArr[1]);
					break;
				case "MSG_INTERVAL":
					trace("MSG_INTERVAL==",msgArr[1]);
					break;
			}
		}
		
		private function showFps():void
		{
			var fpsInfo:FpsUtil = new FpsUtil();
			fpsInfo.alpha = 0.6;
			fpsInfo.y = 350;
			this.addChild(fpsInfo);
		}
		
		private function onResize(evt:Event):void
		{
			this._gameContainer.width = stage.stageWidth;
			this._gameContainer.height = stage.stageHeight;
			
			if(_game)
			{
				_game.width = stage.stageWidth;
				_game.height = stage.stageHeight;	
			}
		}
		
		private function onGameStart():void
		{
			_renderScene = _game.createRenderScene(999999,new SceneGrid(20,20),onComplete);
		}
		
		private function onComplete(res:IResource,isSuccess:Boolean):void
		{
			if(isSuccess)
			{
				var lookAtTarget:ObjectContainer3D = new ObjectContainer3D();
				lookAtTarget.position = new Vector3D(5120,0,5120);
				_game.camController.lookAtTarget = lookAtTarget;
				_game.camController.setCameraDistToTarget(2000);
			}
		}
		
		private var tex1:TextField;
		private var tex2:TextField;
		private var tex3:TextField;
		private var tex4:TextField;
		private var posIdx:uint = 0;
		private var startPos:Vector3D = new Vector3D(5120,0,5120);//(4370,0,4370)
		private function creatteUI():void
		{
			tex1 = new TextField();
			tex1.type = TextFieldType.INPUT;
			tex1.background = true;
			tex1.width = 100;
			tex1.height = 30;
			tex1.text = "1";
			this.addChild(tex1);
			
			tex2 = new TextField();
			tex2.type = TextFieldType.INPUT;
			tex2.background = true;
			tex2.width = 100;
			tex2.height = 30;
			tex2.text = "000";
			tex2.x = 120;
			this.addChild(tex2);
			
			tex3 = new TextField();
			tex3.type = TextFieldType.INPUT;
			tex3.background = true;
			tex3.width = 100;
			tex3.height = 30;
			tex3.text = "1";
			tex3.x = 240;
			this.addChild(tex3);
			
			tex4 = new TextField();
			tex4.type = TextFieldType.INPUT;
			tex4.background = true;
			tex4.width = 100;
			tex4.height = 30;
			tex4.text = "0";
			tex4.x = 360;
			this.addChild(tex4);
			
			var c1:Sprite = new Sprite();
			c1.buttonMode = true;
			c1.graphics.beginFill(0xff0000);
			c1.graphics.drawRect(0,0,100,30);
			c1.graphics.endFill();
			this.addChild(c1);
			c1.x = 480;
			c1.addEventListener(MouseEvent.CLICK,onClickHandler);
			
			var c12:Sprite = new Sprite();
			c12.buttonMode = true;
			c12.graphics.beginFill(0xff0000);
			c12.graphics.drawRect(0,0,100,30);
			c12.graphics.endFill();
			this.addChild(c12);
			c12.x = 600;
			c12.addEventListener(MouseEvent.CLICK,onClickHandler2);
		}
		
		private function onClickHandler2(evt:MouseEvent):void
		{
			var t:uint = getTimer();
			sendMsgToCaleThread("test",t);
//			_testData.position = 0;
//			_testData.writeByte(1);
//			_testData.length = 99;
			var i:uint = 0;
			while(i<22000)
			{
//				trace(i);
				i++;
			}
			trace("oo=============",getTimer()-t);
		}
		
		private function onClickHandler(evt:MouseEvent):void
		{
			var jobStr:String = (tex1.text == "1"?"zs_":(tex1.text == "2"?"fs_":(tex1.text == "3"?"ms_":"null")));
			if(jobStr == "null")
			{
				return;
			}
			
			var modelStr:String = Enviroment.ResourceRootPath+"role/mod/"+jobStr+tex2.text+".ams";
			
			var playAni:Boolean;
			if(tex4.text == "0" || tex4.text == "")
			{
				playAni = false;
			}else
			{
				if(tex4.text == "1")
				{
					playAni = true;
				}
			}
			
			var ansStr:String;
			if(playAni)
			{
				ansStr = Enviroment.ResourceRootPath+"role/ani/"+jobStr+tex2.text+".ans";
			}
			
			var count:uint = uint(tex3.text);
			
			var obj:RenderObject;
			var xx:uint = 0;
			var zz:uint = 0;
			var pos:Vector3D = new Vector3D();
			for(var i:uint = 0;i<count;i++)
			{
				obj = new RenderObject();
				obj.addMesh(modelStr);
				if(playAni)
				{
					obj.setAniGroupByName(ansStr);
					obj.playAni("stand");
				}
				xx = startPos.x+(posIdx%10)*150;
				zz = startPos.z+uint(posIdx/10)*150;
				pos.setTo(xx,0,zz);
				obj.position = pos;
				_renderScene.addChild(obj);
				posIdx ++;
			}
			
			
		}
		
		
		
	}
}