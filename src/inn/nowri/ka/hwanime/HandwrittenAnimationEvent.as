package inn.nowri.ka.hwanime
{
	import flash.events.Event;
	/**
	 * @author ka
	 */
	public class HandwrittenAnimationEvent extends Event
	{
		public static const CREATE_COMPLETE : String = "CREATE_COMPLETE";
	
		public function HandwrittenAnimationEvent(type:String) 
		{
			super(type);
		}
		
		public override function clone() : Event 
		{
			return new HandwrittenAnimationEvent(type);
		}
	}
}
