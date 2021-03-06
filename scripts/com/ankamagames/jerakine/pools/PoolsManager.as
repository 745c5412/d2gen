package com.ankamagames.jerakine.pools
{
   import com.ankamagames.jerakine.JerakineConstants;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import flash.utils.getQualifiedClassName;
   
   public class PoolsManager
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(PoolsManager));
      
      private static var _self:PoolsManager;
       
      
      private var _loadersPool:Pool;
      
      private var _urlLoadersPool:Pool;
      
      private var _rectanglePool:Pool;
      
      private var _pointPool:Pool;
      
      private var _soundPool:Pool;
      
      public function PoolsManager()
      {
         super();
         if(_self)
         {
            throw new SingletonError("Direct initialization of singleton is forbidden. Please access PoolsManager using the getInstance method.");
         }
      }
      
      public static function getInstance() : PoolsManager
      {
         if(_self == null)
         {
            _self = new PoolsManager();
         }
         return _self;
      }
      
      public function getLoadersPool() : Pool
      {
         if(this._loadersPool == null)
         {
            this._loadersPool = new Pool(PoolableLoader,JerakineConstants.LOADERS_POOL_INITIAL_SIZE,JerakineConstants.LOADERS_POOL_GROW_SIZE,JerakineConstants.LOADERS_POOL_WARN_LIMIT);
         }
         return this._loadersPool;
      }
      
      public function getURLLoaderPool() : Pool
      {
         if(this._urlLoadersPool == null)
         {
            this._urlLoadersPool = new Pool(PoolableURLLoader,JerakineConstants.URLLOADERS_POOL_INITIAL_SIZE,JerakineConstants.URLLOADERS_POOL_GROW_SIZE,JerakineConstants.URLLOADERS_POOL_WARN_LIMIT);
         }
         return this._urlLoadersPool;
      }
      
      public function getRectanglePool() : Pool
      {
         if(this._rectanglePool == null)
         {
            this._rectanglePool = new Pool(PoolableRectangle,JerakineConstants.RECTANGLE_POOL_INITIAL_SIZE,JerakineConstants.RECTANGLE_POOL_GROW_SIZE,JerakineConstants.RECTANGLE_POOL_WARN_LIMIT);
         }
         return this._rectanglePool;
      }
      
      public function getPointPool() : Pool
      {
         if(this._pointPool == null)
         {
            this._pointPool = new Pool(PoolablePoint,JerakineConstants.POINT_POOL_INITIAL_SIZE,JerakineConstants.POINT_POOL_GROW_SIZE,JerakineConstants.POINT_POOL_WARN_LIMIT);
         }
         return this._pointPool;
      }
      
      public function getSoundPool() : Pool
      {
         if(this._soundPool == null)
         {
            this._soundPool = new Pool(PoolableSound,JerakineConstants.SOUND_POOL_INITIAL_SIZE,JerakineConstants.SOUND_POOL_GROW_SIZE,JerakineConstants.SOUND_POOL_WARN_LIMIT);
         }
         return this._soundPool;
      }
   }
}
