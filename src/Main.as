package
{
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Rainssong
	 */
	
	[SWF(width=320,height=480,framerate=60)]
	
	public class Main extends Sprite
	{
		public static var stageWidth:Number;
		public static var stageHeight:Number;
		
		public static const V0:Number = -20;
		public static const S:Number = 20 * 20 / 2;
		public static const GRAVITY:Number = 1;
		
		private var doodle:Doodle;
		private var time:Number;
		
		private var keyDictionary:Dictionary;
		
		private var score:int;
		private var scoreText:TextField
		
		private var sceneLayer:Sprite;
		private var charLayer:Sprite;
		private var uiLayer:Sprite;
		private var bgLayer:Sprite;
		
		private var normalStickArr:Vector.<NormalStick>;
		private var stageStickArr:Vector.<Stick>;
		private var movingStickArr:Vector.<MovingStick>;
		private var brokenStickArr:Vector.<BrokenStick>;
		private var glassStickArr:Vector.<GlassStick>;
		
		public function Main():void
		{
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stageWidth = stage.stageWidth;
			stageHeight = stage.stageHeight;
			
			addChild(sceneLayer = new Sprite());
			addChild(charLayer = new Sprite());
			addChild(uiLayer = new Sprite());
			keyDictionary = new Dictionary();
			
			normalStickArr = new Vector.<NormalStick>;
			movingStickArr = new Vector.<MovingStick>;
			brokenStickArr = new Vector.<BrokenStick>;
			glassStickArr = new Vector.<GlassStick>;
			
			doodle = new Doodle();
			
			scoreText = new TextField;
			uiLayer.addChild(scoreText);
			
			resetGame();
			startGame();
		}
		
		private function resetGame():void
		{
			score = 0;
			time = 0;
			doodle.vVelocity = 0;
			doodle.hVelocity = 0;
			
			charLayer.addChild(doodle);
			doodle.x = stage.stageWidth / 2;
			doodle.y = stage.stageHeight - 100;
			
			sceneLayer.removeChildren();
			stageStickArr = new Vector.<Stick>;
			
			stageStickArr.push(new NormalStick());
			sceneLayer.addChild(stageStickArr[0]);
			stageStickArr[0].x = stage.stageWidth / 2;
			stageStickArr[0].y = stage.stageHeight - 30;
		
		}
		
		private function gameOver():void
		{
			//addChild(gameOverPanel);
			//so.data["highScores"] = so.data["highScores"].sortOn("score",Array.NUMERIC+Array.DESCENDING);
			//gameOverPanel.loadHighScore(so.data["highScores"]);
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function startGame():void
		{
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function restart():void
		{
			//removeChild(gameOverPanel);
			resetGame()
			startGame();
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			keyDictionary[e.keyCode] = false;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			keyDictionary[e.keyCode] = true;
			if (e.keyCode == Keyboard.R)
				restart();
		}
		
		private function onEnterFrame(e:Event):void
		{
			time += 1 / stage.frameRate;
			//move control
			if (keyDictionary[Keyboard.LEFT])
				doodle.hVelocity -= 4;
			if (keyDictionary[Keyboard.RIGHT])
				doodle.hVelocity += 4;
				
			//moving visual
			doodle.x += doodle.hVelocity;
			if (doodle.y <= stage.stageHeight - S - 35 && doodle.vVelocity < 0)
			{
				for each (var stick:Stick in stageStickArr)
					stick.y -= doodle.vVelocity;
				score -= doodle.vVelocity;
				scoreText.text = String(score);
			}
			else
			{
				for (var i:int = 0; i < 2; i++)   //incase break through
				{
					
					if (doodle.vVelocity >= 0)
						for each (stick in stageStickArr)
							if (doodle.legs.hitTestObject(stick))
								if (stick is BrokenStick)
									BrokenStick(stick).drop();
								else
								{
									doodle.vVelocity = V0;
									if (stick is GlassStick)
										stick.y = stageHeight + 200;
								}
					doodle.y += doodle.vVelocity / 2;
				}
			}
			
			//moving sticks  the Math.random()<0.01 drive them crazy
			for each (stick in stageStickArr)
			{
				if (stick is MovingStick)
				{
					var temp:MovingStick = stick as MovingStick;
					temp.x += temp.hVelocity;
					if ((temp.x > stageWidth-temp.width) && temp.hVelocity > 0 || (temp.x < temp.width) && temp.hVelocity < 0 || Math.random()<0.01)
						temp.hVelocity *= -1;
				}
			}
			
			refreashSticks();
			doodle.vVelocity += GRAVITY;
			doodle.hVelocity *= 0.5;
			
			//outside
			if (doodle.x > stage.stageWidth + 25)
				doodle.x -= stage.stageWidth + 25;
			if (doodle.x < -25)
				doodle.x += stage.stageWidth + 25;
				
			//char direction
			if (doodle.hVelocity > 0)
				doodle.scaleX = -1;
			else if (doodle.hVelocity < 0)
				doodle.scaleX = 1;
		}
		
		private function refreashSticks():void
		{
			var stick:Stick;
			//add new sticks
			while (stageStickArr[0].y > stage.stageHeight)
			{
				sceneLayer.removeChild(stageStickArr[0]);
				stick = stageStickArr.shift();
				if (stick is NormalStick)
					normalStickArr.push(stick);
				else if (stick is MovingStick)
					movingStickArr.push(stick);
				else if (stick is GlassStick)
					glassStickArr.push(stick);
			}
			//remove old sticks
			while (stageStickArr[stageStickArr.length - 1].y > -300)
			{
				stick = getNewStick();
				stick.x = Math.random() * (stage.stageWidth - stick.width) + stick.width / 2;
				var max:Number = -S * Math.min(1, score / 10000 + 0.5) + 10;
				var min:Number = -S * Math.min(0.5, score / 10000) - 20;
				stick.y = stageStickArr[stageStickArr.length - 1].y  + min + Math.random()*(max-min);
				stageStickArr.push(stick);
				sceneLayer.addChild(stick);
				var distance:Number = stageStickArr[stageStickArr.length - 2].y - stageStickArr[stageStickArr.length - 1].y;
				if (Math.random() < 0.1 && distance>60)
				{
					stick = new BrokenStick();
					stick.x = Math.random() * (stage.stageWidth - stick.width) + stick.width / 2;
					stick.y = stageStickArr[stageStickArr.length - 1].y + Math.random() * (distance-40) + 20;
					stageStickArr.splice(stageStickArr.length - 1,0, stick);
					sceneLayer.addChild(stick);
				}
			}
		}
		
		public function getNewStick():Stick
		{
			if (Math.random() < (score<85000?(9000-score)/10000:0.05))
			{
				if (normalStickArr.length)
					return normalStickArr.pop();
				return new NormalStick();
			}
			else if (Math.random() < 0.5)
			{
				if (movingStickArr.length)
					return movingStickArr.pop();
				return new MovingStick();
			}
			else
			{
				if (glassStickArr.length)
					return glassStickArr.pop();
				return new GlassStick();
			}
		}
	}
}

import flash.display.BlendMode;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

class Doodle extends Sprite
{
	//public var body:Shape;
	public var legs:Shape;
	public var vVelocity:Number;
	public var hVelocity:Number;
	private var direction:String = "left";
	
	public function Doodle():void
	{
		//body = new Shape();
		legs = new Shape();
		//addChild(body);
		addChild(legs);
		hVelocity = 0;
		hVelocity = 0;
		
		
			graphics.beginFill(0xC3CC00);
			graphics.lineStyle(1);
			graphics.moveTo(-25, -4);
			graphics.lineTo(-15, -4);
			graphics.cubicCurveTo( -10, -24, 10, -24, 15, -4);
			//graphics.beginFill(0x61A82A);
			//graphics.endFill();
			graphics.lineTo(15, 18);
			
			graphics.lineTo( -15, 18);
			
			graphics.lineTo(-15, 2);
			graphics.lineTo( -25, 2);
			//Nose
			graphics.drawEllipse( -30, -5, 5, 8);
			//Eyes
			graphics.drawCircle(-10, -6, 1);
			graphics.drawCircle( -4, -6, 1);
			
			graphics.beginFill(0x61A82A);
			graphics.drawRect(-15, 5,30,13);
			drawLine(-15, 10, 15, 10);
			drawLine(-15, 15, 15, 15);
		
			drawLine(-10, 18, -10, 20);
			drawLine(-2, 18, -2, 20);
			drawLine(4, 18, 4, 20);
			drawLine(12, 18, 12, 20);
			drawLine(-10, 20, -15, 20);
			drawLine(-2, 20, -7, 20);
			drawLine(4, 20, -1, 20);
			drawLine(12, 20, 7, 20);
			graphics.endFill();
			
		with (legs)
		{
			graphics.drawRect(-15, 18, 30, 2);
		}
	}
	
	public function setDirection(direction:String):void
	{
		if (direction == "right")
			this.scaleX = -1;
		else
			this.scaleX = 1;
	}
	
	private function drawLine(x1:Number, y1:Number, x2:Number, y2:Number):void
	{
		graphics.lineStyle(1);
		graphics.moveTo(x1, y1);
		graphics.lineTo(x2, y2);
	}
}

class Stick extends Sprite
{
	public static const STICK_WIDTH:Number = 50;
	static public const STICK_HEIGHT:Number = 10;
	
	public function Stick():void
	{
		
	}
}

class NormalStick extends Stick
{
	public function NormalStick():void
	{
		graphics.lineStyle(1);
		graphics.beginFill(0x6BB600);
		graphics.drawRoundRect(-STICK_WIDTH / 2, -STICK_HEIGHT / 2, STICK_WIDTH, STICK_HEIGHT, 10);
		graphics.endFill();
	}
}

class MovingStick extends Stick
{
	public var hVelocity:Number;
	public static const SPEED_X:Number = 3.5;
	
	public function MovingStick():void
	{
		graphics.lineStyle(1);
		graphics.beginFill(0x0998C2);
		graphics.drawRoundRect(-STICK_WIDTH / 2, -STICK_HEIGHT / 2, STICK_WIDTH, STICK_HEIGHT, 10);
		graphics.endFill();
		hVelocity = Math.random() > 0.5 ? SPEED_X : -SPEED_X;
	}
}

class BrokenStick extends Stick
{
	public var leftPart:Shape = new Shape();
	public var rightPart:Shape = new Shape();
	private var vVelocity:Number = 0;
	
	public function BrokenStick():void
	{
		graphics.lineStyle(1);
		addChild(leftPart);
		addChild(rightPart);
		
		leftPart.graphics.lineStyle(1);
		leftPart.graphics.beginFill(0x7C5A2C);
		leftPart.graphics.drawRoundRectComplex(-STICK_WIDTH / 2, -STICK_HEIGHT / 2, 23, 10, 10, 0, 10, 0);
		
		rightPart.graphics.lineStyle(1);
		rightPart.graphics.beginFill(0x7C5A2C);
		rightPart.graphics.drawRoundRectComplex(2, -5, STICK_WIDTH / 2-2, STICK_HEIGHT, 0, 10, 0, 10);
		//graphics.endFill();
		addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
	}
	
	public function drop():void
	{
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	private function onEnterFrame(e:Event):void
	{
		leftPart.y += vVelocity;
		leftPart.x -= 2;
		rightPart.y += vVelocity;
		rightPart.x += 2;
		vVelocity += Main.GRAVITY;
	}
	
	private function onRemove(e:Event):void
	{
		removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
}

class GlassStick extends Stick
{
	public function GlassStick():void
	{
		graphics.lineStyle(1);
		graphics.beginFill(0xFFFFFF);
		graphics.drawRoundRect(-STICK_WIDTH / 2, -STICK_HEIGHT / 2, STICK_WIDTH, STICK_HEIGHT, 10);
		graphics.endFill();
	}
}