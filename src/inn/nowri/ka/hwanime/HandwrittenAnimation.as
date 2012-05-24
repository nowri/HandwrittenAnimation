package inn.nowri.ka.hwanime
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	[Event(name="CREATE_COMPLETE", type="inn.nowri.ka.hwanime.HandwrittenAnimationEvent")]
	public class HandwrittenAnimation extends Sprite
	{
		//---------------------------------------------------------------------------------------------------------------------------------------------
		// Public Properties
		//---------------------------------------------------------------------------------------------------------------------------------------------
		
		
		//---------------------------------------------------------------------------------------------------------------------------------------------
		// Internal Properties
		//---------------------------------------------------------------------------------------------------------------------------------------------
		private var timer:Timer;
		private var vo:HandwrittenAnimationVO;
		private var src:BitmapData;
		private var color:uint;
		private var bmp:Bitmap;
		private var bmdVec:Vector.<BitmapData>;
		private var cloneBmd:BitmapData;
		private var current:int=0;
		
		//---------------------------------------------------------------------------------------------------------------------------------------------
		// Public Methods
		//---------------------------------------------------------------------------------------------------------------------------------------------
		public function HandwrittenAnimation(bmd:BitmapData, vo:HandwrittenAnimationVO)
		{
			this.vo = vo;
			this.src = bmd;
			init();
		}
		
		public function play():void
		{
			pause();
			timer = new Timer(int(1000/vo.fps),0);
			timer.addEventListener(TimerEvent.TIMER, update);
			timer.start();
		}
		
		public function pause():void
		{
			if(timer)
			{
				timer.stop();
				if(timer.hasEventListener(TimerEvent.TIMER))timer.removeEventListener(TimerEvent.TIMER, update);
			}
		}
		// getter setter
		
		//---------------------------------------------------------------------------------------------------------------------------------------------
		// Internal Methods
		//---------------------------------------------------------------------------------------------------------------------------------------------
		private function init():void
		{
			if(!vo.isSync)
			{
				var t:Timer = new Timer(1,1);
				t.addEventListener(TimerEvent.TIMER, _init);
				t.start();
				return;
			}
			_init();
		}
		
		private function _init(e:TimerEvent=null):void
		{
			var vec:Vector.<uint>=src.getVector(new Rectangle(0,0,src.width,src.height));
	 		var w:int=src.width;
			var h:int=src.height;
			var pos:uint=0;
			var add:int = int(10*(1-vo.lineDensitydensity));
			var srcPos:Vector.<Vector.<uint>>;
			var minX:int, minY:int, maxX:int, maxY:int = int.MIN_VALUE;
			srcPos=Vector.<Vector.<uint>>([]);
			for(var y:int=0; y<h; y++)	
			{
				for(var x:int=0; x<w; x+=add)
				{
					pos=w*y+x;
					if(vec[pos])
					{
						if(minX != int.MIN_VALUE)
						{
							minX = (x>=minX)? minX:x;
						}
						else
						{
							minX = x;
						}	
						
						if(minY != int.MIN_VALUE)
						{
							minY = (y>=minY)? minY:y;
						}
						else
						{
							minY = y;
						}
						
						if(maxX != int.MIN_VALUE)
						{
							maxX = (x<=maxX)? maxX:x;
						}
						else
						{
							maxX = minX+1;
						}
						
						if(maxY != int.MIN_VALUE)
						{
							maxY = (y<=maxY)? maxY:y;
						}
						else
						{
							maxY = minY+1;
						}
						srcPos.push(Vector.<uint>([x,y]));
					}
				}
			}
			var bmdW:int = maxX - minX;
			var bmdH:int = maxY - minY;
			cloneBmd = new BitmapData(bmdW+add*2, bmdH+add*2,true,0x00);
			color = (vo.color!=-1)? vo.color:src.getPixel32(srcPos[0][0], srcPos[0][1]);
			createBmdVec(srcPos,add);
			bmp = new Bitmap(bmdVec[0]);
			bmp.x = minX-add;
			bmp.y = minY-add;
			addChild(bmp);
			if(!vo.isSync)
			{
				dispatchEvent(new HandwrittenAnimationEvent(HandwrittenAnimationEvent.CREATE_COMPLETE));
			}
		}	
		
		private function createBmdVec(pos:Vector.<Vector.<uint>>, radius:int):void
		{
			bmdVec = Vector.<BitmapData>([]);
			var len:int = vo.time*vo.fps;
			for (var i:int=0; i<len; i++) 
			{
				bmdVec.push(createBmd(pos, radius));
			}
		}
	
		private function createBmd(pos:Vector.<Vector.<uint>>, radius:int):BitmapData
		{
			var sh:Shape = new Shape();
			var len:int = pos.length;
			var mat:Matrix = new Matrix(1,0,0,1,radius,radius);
			var col:ColorTransform = new ColorTransform();
			var rect:Rectangle = new Rectangle(0,0,cloneBmd.width,cloneBmd.height);
			for(var i:int = 0; i<len; i++) 
			{
				var x:int = pos[i][0];
				var y:int = pos[i][1];
				drawSpline(createRandomCircleVector(x, y, (vo.radius!=-1)? vo.radius:radius), sh);
			}
			var bmd:BitmapData = cloneBmd.clone();
			bmd.draw(sh, mat, col, null, rect);
			return bmd;
		}
	
		private function createRandomCircleVector(x:int, y:int, max_radius:int):Vector.<Vector.<Number>>
		{
			var vec:Vector.<Vector.<Number>> = Vector.<Vector.<Number>>([]);
			var len:int = vo.lineDensitydensity*4+4;
			for (var i : int = 0; i<len; i++) 
			{
				vec.push(randomCirclePos(x,y,max_radius));
			}
			return vec;
		}
		
		private function randomCirclePos(_x:Number, _y:Number, max_radius:int):Vector.<Number>
		{
			var radius:Number = Math.sqrt(Math.random())*max_radius;
			var angle:Number = Math.random()*(Math.PI*2);
			return Vector.<Number>([
				_x+Math.cos(angle)*radius,
				_y+Math.sin(angle)*radius
			]);
		}
		
		private function update(e:TimerEvent=null):void
		{
			current++;
			if(bmdVec.length==current)
			{
				current=0;
			}
			bmp.bitmapData=bmdVec[current];
		}
	
		private function drawSpline(v:Vector.<Vector.<Number>>, sh:Shape):void
		{
			if(v.length<2)
			{
				 return;
			}
	//		v.splice(0,0,v[0]);
	//		v.push(v[v.length-1]);
			
			var numSegments:uint = 5;//曲線分割数（補完する数）
			for(var i:uint=0; i<v.length-3; i++){
				var p0:Vector.<Number> = v[i];
				var p1:Vector.<Number> = v[i+1];
				var p2:Vector.<Number> = v[i+2];
				var p3:Vector.<Number> = v[i+3];
				splineTo(p0, p1, p2, p3, numSegments,sh);
			}
		}
	
		private function splineTo(p0:Vector.<Number>, p1:Vector.<Number>, p2:Vector.<Number>,	p3:Vector.<Number>, numSegments:uint, sh:Shape):void {
			sh.graphics.lineStyle(vo.lineWeight, color, 1);
			sh.graphics.moveTo(p1[0], p1[1]);
			for(var i:uint=0; i<numSegments; i++){
				var t:Number = (i+1)/numSegments;
				sh.graphics.lineTo(
					catmullRom(p0[0], p1[0], p2[0], p3[0], t),catmullRom(p0[1], p1[1], p2[1], p3[1], t)
				);
			}
		}
	
		private function catmullRom(p0:Number,p1:Number,p2:Number,p3:Number,t:Number):Number{
			var v0:Number = (p2 - p0) * 0.5;
			var v1:Number = (p3 - p1) * 0.5;
			return (2*p1 - 2*p2 + v0 + v1)*t*t*t +
			(-3*p1 + 3*p2 - 2*v0 - v1)*t*t + v0*t + p1;
		}
	}
}
