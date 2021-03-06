package com.ankamagames.jerakine.managers
{
   import by.blooddy.crypto.MD5;
   import com.ankamagames.jerakine.JerakineConstants;
   import com.ankamagames.jerakine.interfaces.Secure;
   import com.ankamagames.jerakine.logger.Log;
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.types.CustomSharedObject;
   import com.ankamagames.jerakine.types.DataStoreType;
   import com.ankamagames.jerakine.types.enums.DataStoreEnum;
   import com.ankamagames.jerakine.types.events.RegisterClassLogEvent;
   import com.ankamagames.jerakine.utils.crypto.Base64;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import flash.net.ObjectEncoding;
   import flash.net.registerClassAlias;
   import flash.utils.Dictionary;
   import flash.utils.IExternalizable;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class StoreDataManager
   {
      
      protected static const _log:Logger = Log.getLogger(getQualifiedClassName(StoreDataManager));
      
      private static var _self:StoreDataManager;
       
      
      private var _aData:Array;
      
      private var _bStoreSequence:Boolean;
      
      private var _nCurrentSequenceNum:uint = 0;
      
      private var _aStoreSequence:Array;
      
      private var _aSharedObjectCache:Array;
      
      private var _aRegisteredClassAlias:Dictionary;
      
      private var _describeType:Function;
      
      public function StoreDataManager()
      {
         var oClass:Class = null;
         var className:String = null;
         var s:String = null;
         this._describeType = DescribeTypeCache.typeDescription;
         super();
         if(_self != null)
         {
            throw new SingletonError("DataManager is a singleton and should not be instanciated directly.");
         }
         this._bStoreSequence = false;
         this._aData = new Array();
         this._aSharedObjectCache = new Array();
         this._aRegisteredClassAlias = new Dictionary();
         var aClass:Array = this.getData(JerakineConstants.DATASTORE_CLASS_ALIAS,"classAliasList");
         var nonVectorClass:Array = [];
         var vectorClass:Array = [];
         for(s in aClass)
         {
            className = Base64.decode(s);
            _log.logDirectly(new RegisterClassLogEvent(className));
            try
            {
               oClass = Class(getDefinitionByName(className));
               registerClassAlias(aClass[s],oClass);
            }
            catch(e:ReferenceError)
            {
               _log.warn("Impossible de trouver la classe " + className);
            }
            this._aRegisteredClassAlias[className] = true;
         }
      }
      
      public static function getInstance() : StoreDataManager
      {
         if(_self == null)
         {
            _self = new StoreDataManager();
         }
         return _self;
      }
      
      public function getData(dataType:DataStoreType, sKey:String) : *
      {
         var so:* = null;
         if(dataType.persistant)
         {
            switch(dataType.location)
            {
               case DataStoreEnum.LOCATION_LOCAL:
                  so = this.getSharedObject(dataType.category);
                  if(so.data)
                  {
                     return so.data[sKey];
                  }
                  break;
               case DataStoreEnum.LOCATION_SERVER:
            }
            return null;
         }
         if(this._aData[dataType.category] != null)
         {
            return this._aData[dataType.category][sKey];
         }
         return null;
      }
      
      public function registerClass(oInstance:*, deepClassScan:Boolean = false, keepClassInSo:Boolean = true) : void
      {
         var className:String = null;
         var sAlias:String = null;
         var aClassAlias:Array = null;
         var desc:Object = null;
         var key:String = null;
         var tmp:String = null;
         var leftBracePos:int = 0;
         if(oInstance is IExternalizable)
         {
            throw new ArgumentError("Can\'t store a customized IExternalizable in a shared object.");
         }
         if(oInstance is Secure)
         {
            throw new ArgumentError("Can\'t store a Secure class");
         }
         if(this.isComplexType(oInstance))
         {
            className = getQualifiedClassName(oInstance);
            if(this._aRegisteredClassAlias[className] == null)
            {
               sAlias = MD5.hash(className);
               _log.logDirectly(new RegisterClassLogEvent(className));
               try
               {
                  registerClassAlias(sAlias,Class(getDefinitionByName(className)));
                  _log.warn("Register " + className);
               }
               catch(e:Error)
               {
                  _aRegisteredClassAlias[className] = true;
                  _log.fatal("Impossible de trouver la classe " + className + " dans l\'application domain courant");
                  return;
               }
               if(keepClassInSo)
               {
                  aClassAlias = this.getSetData(JerakineConstants.DATASTORE_CLASS_ALIAS,"classAliasList",new Array());
                  aClassAlias[Base64.encode(className)] = sAlias;
                  this.setData(JerakineConstants.DATASTORE_CLASS_ALIAS,"classAliasList",aClassAlias);
               }
               this._aRegisteredClassAlias[className] = true;
            }
            else
            {
               return;
            }
         }
         if(deepClassScan)
         {
            if(oInstance is Dictionary || oInstance is Array || oInstance is Vector.<*> || oInstance is Vector.<uint>)
            {
               desc = oInstance;
               if(oInstance is Vector.<*>)
               {
                  tmp = getQualifiedClassName(oInstance);
                  leftBracePos = tmp.indexOf("<");
                  tmp = tmp.substr(leftBracePos + 1,tmp.lastIndexOf(">") - leftBracePos - 1);
                  this.registerClass(new (getDefinitionByName(tmp) as Class)(),true,keepClassInSo);
               }
            }
            else
            {
               desc = this.scanType(oInstance);
            }
            for(key in desc)
            {
               if(this.isComplexType(oInstance[key]))
               {
                  this.registerClass(oInstance[key],true);
               }
               if(desc === oInstance)
               {
                  break;
               }
            }
         }
      }
      
      public function getClass(item:Object) : void
      {
         var s:* = undefined;
         var description:XML = this._describeType(item);
         this.registerClass(item);
         for(s in description..accessor)
         {
            if(this.isComplexType(s))
            {
               this.getClass(s);
            }
         }
      }
      
      public function setData(dataType:DataStoreType, sKey:String, oValue:*, deepClassScan:Boolean = false) : Boolean
      {
         var so:* = null;
         if(this._aData[dataType.category] == null)
         {
            this._aData[dataType.category] = new Dictionary(true);
         }
         this._aData[dataType.category][sKey] = oValue;
         if(dataType.persistant)
         {
            switch(dataType.location)
            {
               case DataStoreEnum.LOCATION_LOCAL:
                  this.registerClass(oValue,deepClassScan);
                  so = this.getSharedObject(dataType.category);
                  if(!so.data)
                  {
                     so.data = new Object();
                  }
                  so.data[sKey] = oValue;
                  if(!this._bStoreSequence)
                  {
                     if(!so.flush())
                     {
                        return false;
                     }
                  }
                  else
                  {
                     this._aStoreSequence[dataType.category] = dataType;
                  }
                  return true;
               case DataStoreEnum.LOCATION_SERVER:
                  return false;
            }
         }
         return true;
      }
      
      public function getKeys(dataType:DataStoreType) : Array
      {
         var data:* = null;
         var so:* = null;
         var key:* = undefined;
         var result:* = [];
         if(dataType.persistant)
         {
            switch(dataType.location)
            {
               case DataStoreEnum.LOCATION_LOCAL:
                  so = this.getSharedObject(dataType.category);
                  data = so.data;
                  break;
               case DataStoreEnum.LOCATION_SERVER:
            }
         }
         else if(this._aData[dataType.category] != null)
         {
            data = this._aData[dataType.category];
         }
         if(data)
         {
            for(key in data)
            {
               result.push(key);
            }
         }
         return result;
      }
      
      public function getSetData(dataType:DataStoreType, sKey:String, oValue:*) : *
      {
         var o:* = this.getData(dataType,sKey);
         if(o != null)
         {
            return o;
         }
         this.setData(dataType,sKey,oValue);
         return oValue;
      }
      
      public function startStoreSequence() : void
      {
         this._bStoreSequence = true;
         if(!this._nCurrentSequenceNum)
         {
            this._aStoreSequence = new Array();
         }
         this._nCurrentSequenceNum++;
      }
      
      public function stopStoreSequence() : void
      {
         var dt:* = null;
         var s:* = null;
         this._bStoreSequence = --this._nCurrentSequenceNum != 0;
         if(this._bStoreSequence)
         {
            return;
         }
         for(s in this._aStoreSequence)
         {
            dt = this._aStoreSequence[s];
            switch(dt.location)
            {
               case DataStoreEnum.LOCATION_LOCAL:
                  this.getSharedObject(dt.category).flush();
                  continue;
               case DataStoreEnum.LOCATION_SERVER:
                  continue;
               default:
                  continue;
            }
         }
         this._aStoreSequence = null;
      }
      
      public function clear(dataType:DataStoreType) : void
      {
         this._aData = new Array();
         var so:CustomSharedObject = this.getSharedObject(dataType.category);
         so.clear();
      }
      
      public function reset() : void
      {
         var s:* = null;
         for each(s in this._aSharedObjectCache)
         {
            try
            {
               s.clear();
               s.close();
            }
            catch(e:Error)
            {
               continue;
            }
         }
         this._aSharedObjectCache = [];
         _self = null;
      }
      
      public function close(dataType:DataStoreType) : void
      {
         switch(dataType.location)
         {
            case DataStoreEnum.LOCATION_LOCAL:
               this._aSharedObjectCache[dataType.category].close();
               delete this._aSharedObjectCache[dataType.category];
         }
      }
      
      private function getSharedObject(sName:String) : CustomSharedObject
      {
         if(this._aSharedObjectCache[sName] != null)
         {
            return this._aSharedObjectCache[sName];
         }
         var so:CustomSharedObject = CustomSharedObject.getLocal(sName);
         so.objectEncoding = ObjectEncoding.AMF3;
         this._aSharedObjectCache[sName] = so;
         return so;
      }
      
      private function isComplexType(o:*) : Boolean
      {
         switch(true)
         {
            case o is int:
            case o is uint:
            case o is Number:
            case o is Boolean:
            case o is Array:
            case o is String:
            case o == null:
            case o == undefined:
               return false;
            default:
               return true;
         }
      }
      
      private function isComplexTypeFromString(name:String) : Boolean
      {
         var o:* = undefined;
         switch(name)
         {
            case "int":
            case "uint":
            case "Number":
            case "Boolean":
            case "Array":
            case "String":
               return false;
            default:
               o = this._aRegisteredClassAlias[name];
               if(this._aRegisteredClassAlias[name] === true)
               {
                  return false;
               }
               return true;
         }
      }
      
      private function scanType(obj:*) : Object
      {
         var accessor:* = null;
         var variable:* = null;
         var result:Object = new Object();
         var def:XML = this._describeType(obj);
         for each(accessor in def..accessor)
         {
            if(this.isComplexTypeFromString(accessor.@type))
            {
               result[accessor.@name] = true;
            }
         }
         for each(variable in def..variable)
         {
            if(this.isComplexTypeFromString(variable.@type))
            {
               result[variable.@name] = true;
            }
         }
         return result;
      }
   }
}
