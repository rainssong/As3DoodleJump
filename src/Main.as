package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Rainssong
	 */
	
[SWF(width=768,height=1024,framerate=60)]
	public class Main extends Sprite
	{
		private var doodle:Doodle;
		private var timer:Timer;
		private var time:int;
		private var woodArr:Vector.<Wood>;
		private var score:int;
		
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
			// entry point
			woodArr = new Vector.<Wood>;
			
			timer = new Timer(1000);
			
			createWoods()
			doodle = new Doodle();
			
		}
		
		private var resetGame():void
		{
			score = 0;
			time = 0;
			
			
			
			addChild(doodle);
			doodle.x = stage.width / 2;
			doodle.y = stage.height - 100;
			
		}
		
		private function createWoods():void
		{
			woodArr = new Vector.<Wood>;
			var i:int = 30;
			while (i)
			{
				woodArr.push(new Wood());
				i--;
			}
		}
	
	}

}
import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Matrix;

class Doodle extends Shape
{
	public function Doodle():void
	{
		this.graphics.beginFill(0xFF0000);
		this.graphics.drawCircle(-25, -25, 50);
		this.graphics.endFill();
	}
}

class Wood extends Shape
{
	public function Wood():void
	{
		//var myMatrix:Matrix = new Matrix();
		//myMatrix.createGradientBox(200, 200, 1.6, 50, 50);
		//var myColors:Array = [0xFF3300, 0xFFCC66];
		//var myAlphaS:Array = [100, 100];
		//var myRalphaS:Array = [0, 225];
		//graphics.beginGradientFill(GradientType.LINEAR, myColors, myAlphaS, myRalphaS, null);
		graphics.lineStyle(1);
		graphics.drawRoundRectComplex(-50, -50, 100, 10, 10, 10, 10, 10);
	}
}


class BrokenWood extends Wood
{
	public var movingWidth:Number;
	public var direction:String="right";
	public function BrokenWood():void
	{
		movingWidth = Math.random() * stage.width;
	}
}