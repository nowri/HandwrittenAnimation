package inn.nowri.ka.hwanime
{
	/**
	 * @author ka
	 */
	public class HandwrittenAnimationVO
	{
		private var _time:Number;
		private var _fps:int;
		private var _lineWeight:int;
		private var _lineDensitydensity:Number;
		private var _isSync:Boolean;
		private var _color:int;
		private var _radius:int;
		
		public function HandwrittenAnimationVO(time:Number=1, fps:int=20, radius:int=5, line_weight:Number=0.5, line_densitydensity:Number=0.3, color:int=-1, is_sync:Boolean=false)
		{
			this._time=time;
			this._fps=fps;
			this._lineWeight=line_weight;
			this._lineDensitydensity=line_densitydensity;
			this._isSync=is_sync;
			this._color = color;
			this._radius = radius;
		}
		
		public function get time():Number
		{
			return _time;
		}
	
		public function get fps():int
		{
			return _fps;
		}
	
		public function get lineWeight():int
		{
			return _lineWeight;
		}
	
		public function get lineDensitydensity():Number
		{
			return _lineDensitydensity;
		}
	
		public function get isSync():Boolean
		{
			return _isSync;
		}
	
		public function get color():int
		{
			return _color;
		}
	
		public function get radius():int
		{
			return _radius;
		}
	}
}
