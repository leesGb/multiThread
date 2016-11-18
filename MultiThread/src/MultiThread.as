package
{
	import com.utils.FpsUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
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
			
			Enviroment.ConfigRootPath = "E:/project/flash/game/MT/MTClient/MTArt/assets/config/";
			Enviroment.ResourceRootPath = "E:/project/flash/game/MT/MTClient/MTArt/assets/data/";
			
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