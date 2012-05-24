/**
 * copyright(c) flair4.jp
 */
package jp.flair4.lib.events {
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.utils.Dictionary;
    
    /**
    * TimerEventの処理を最適化するクラスです.
    * Timer 関連の処理をこのクラスが一括で行うことにより、パフォーマンスが飛躍的に向上します.
    * :::使用上の注意:::
    * このクラスを用いた場合 useCapture, priority, weakReference の各項目を扱うことは出来ません.
    * また delay の変更, start, stop, reset といった処理は, 登録しているリスナ全体に影響します.
    * 変更の際には,挙動を十分に理解したうえで変更してください.
    * @author KAWAKITA Hirofumi
    * @version 0.1
    */
    public class TimerEventOptimizer {
        
        //------- MEMBER -----------------------------------------------------------------------
        private var _provider:TimerProvider;
        
        //------- PUBLIC -----------------------------------------------------------------------
        /**
         * コンストラクタ.
         */
        public function TimerEventOptimizer( delay:Number, repeatCount:int = 0 ) {
            _provider = new TimerProvider( delay, repeatCount );
        }
        
        //--- Instance Method. -----------------------------------------------------------
        /** 現在の Timer カウント. */
        public function get currentCount():int { return _provider.currentCount; }
        
        /** 現在登録されているリスナ数. */
        public function get numListeners():Number { return _provider.numListeners; }
        
        /** Timerが実行されているか. */
        public function get running():Boolean { return _provider.running; }
        
        public function get delay():Number { return _provider.delay;  }
        public function set delay( value:Number ):void {
            _provider.delay = value;
        }
        
        
        public function reset():void { _provider.reset(); }
        
        public function start():void { _provider.start(); }
        
        public function stop():void { _provider.stop(); }
        
        /**
         * TimerEventのリスナを追加します.
         * 追加したリスナは,このクラスの管理下に置かれるため,解除する際には
         * このクラスの removeEventListener を実行してください.
         * @param	listener コールバック.
         */
        public function addEventListener( type:String, listener:Function, repeatCount:int = 0 ):void {
            _provider.add( type, listener, repeatCount );
        }
        
        /**
         * TimerEventのリスナを削除します.
         * @param	listener コールバック.
         */
        public function removeEventListener( type:String, listener:Function ):void {
            _provider.remove( type, listener );
        }
        
    }
    
}

import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;
/**
 * TimerEventを扱うプライベートクラスです.
 * このクラスを用いてTimerEventが管理されます.
 */
class TimerProvider extends Timer {
    
    //------- MEMBER -----------------------------------------------------------------------
    private var _num:uint;
    private var _onTimerDict:Dictionary;
    private var _onTimerCompleteDict:Dictionary;
    private var _onTimerReallyCompleteDict:Dictionary;
    
    //------- PUBLIC -----------------------------------------------------------------------
    
    /**
     * コンストラクタ.
     */
    public function TimerProvider( delay:Number, repeatCount:int = 0 ):void {
        super( delay, repeatCount );
        _num = 0;
        _onTimerDict               = new Dictionary();
        _onTimerCompleteDict       = new Dictionary();
        _onTimerReallyCompleteDict = new Dictionary();
        addEventListener( TimerEvent.TIMER, _onTimer );
        addEventListener( TimerEvent.TIMER_COMPLETE, _onTimerComplete );
    }
    
    /** 現在登録されているリスナ数. */
    public function get numListeners():Number { return _num; }
    
    /**
     * リスナを追加します.
     * @param	listener
     */
    public function add( type:String, listener:Function, repeatCount:int ):void {
        remove( type, listener );
        var repeat:uint = repeatCount;
        switch( type ){
            case TimerEvent.TIMER :
                if( 0 < repeat){
                    _onTimerDict[listener] = function(e:TimerEvent) {
                        if ( repeat-- <= 0 ) {
                            remove( type, listener );
                        }else{
                            listener(e);
                        }
                    }
                }else {
                    _onTimerDict[listener] = listener;
                }
                break;
            case TimerEvent.TIMER_COMPLETE :
                if( 0 < repeat){
                    _onTimerCompleteDict[listener] = function(e:TimerEvent) {
                        if ( repeat-- <= 0 ) {
                            listener(e);
                            remove( TimerEvent.TIMER_COMPLETE, listener );
                        }
                    }
                    _onTimerReallyCompleteDict[listener] = function(e:TimerEvent) {
                        listener(e);
                        remove( TimerEvent.TIMER_COMPLETE, listener );
                    }
                }else {
                    _onTimerReallyCompleteDict[listener] = listener;
                }
                break;
            default :
                return;
        }
        _num++;
    }
    
    /**
     * リスナを削除します.
     * @param	listener
     */
    public function remove( type:String, listener:Function ):void {
        switch( type ){
            case TimerEvent.TIMER :
                if ( !_onTimerDict[listener] ) return;
                delete _onTimerDict[listener];
                break;
            case TimerEvent.TIMER_COMPLETE :
                if ( !_onTimerCompleteDict[listener] && !_onTimerReallyCompleteDict[listener] ) return;
                delete _onTimerCompleteDict[listener];
                delete _onTimerReallyCompleteDict[listener];
                break;
            default :
                return;
        }
        _num--;
    }
    
    //------- PRIVATE ----------------------------------------------------------------------
    /**
     * Timer実行処理.
     * @param	e
     */
    private function _onTimer(e:TimerEvent):void {
        var fnc:Function;
        for each( fnc in _onTimerDict ) fnc(e);
        for each( fnc in _onTimerCompleteDict ) fnc(e);
    }
    
    /**
     * TimerComplete実行処理.
     * @param	e
     */
    private function _onTimerComplete(e:TimerEvent):void {
        for each( var fnc:Function in _onTimerReallyCompleteDict ) fnc(e);
    }
    
}