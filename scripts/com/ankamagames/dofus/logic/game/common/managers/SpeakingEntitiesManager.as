package com.ankamagames.dofus.logic.game.common.managers
{
   import com.ankamagames.berilia.enums.StrataEnum;
   import com.ankamagames.berilia.managers.KernelEventsManager;
   import com.ankamagames.berilia.managers.TooltipManager;
   import com.ankamagames.berilia.managers.UiModuleManager;
   import com.ankamagames.berilia.types.LocationEnum;
   import com.ankamagames.dofus.internalDatacenter.communication.ChatBubble;
   import com.ankamagames.dofus.kernel.Kernel;
   import com.ankamagames.dofus.logic.game.common.misc.DofusEntities;
   import com.ankamagames.dofus.logic.game.fight.frames.FightEntitiesFrame;
   import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayEntitiesFrame;
   import com.ankamagames.dofus.misc.lists.ChatHookList;
   import com.ankamagames.dofus.network.types.game.context.GameContextActorInformations;
   import com.ankamagames.dofus.network.types.game.context.fight.GameFightMonsterInformations;
   import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNpcInformations;
   import com.ankamagames.jerakine.entities.interfaces.IDisplayable;
   import com.ankamagames.jerakine.interfaces.IRectangle;
   import flash.utils.Dictionary;
   
   public class SpeakingEntitiesManager
   {
      
      private static var _instance:SpeakingEntitiesManager;
       
      
      private var _triggerAssoc:Dictionary;
      
      private var _entitiesAssoc:Dictionary;
      
      public function SpeakingEntitiesManager()
      {
         this._triggerAssoc = new Dictionary();
         this._entitiesAssoc = new Dictionary();
         super();
      }
      
      public static function getInstance() : SpeakingEntitiesManager
      {
         if(_instance == null)
         {
            _instance = new SpeakingEntitiesManager();
            _instance.init();
         }
         return _instance;
      }
      
      private function init() : void
      {
         var triggerType:* = undefined;
         var trigger:* = null;
         var assocByType:* = null;
         var assocByEntity:* = null;
         for(triggerType in this._triggerAssoc)
         {
            for each(trigger in this._triggerAssoc[triggerType])
            {
               if(!this._entitiesAssoc[trigger.entityType])
               {
                  this._entitiesAssoc[trigger.entityType] = new Dictionary();
               }
               assocByType = this._entitiesAssoc[trigger.entityType];
               if(!assocByType[trigger.entityId])
               {
                  assocByType[trigger.entityId] = new Dictionary();
               }
               assocByEntity = assocByType[trigger.entityId];
               if(!assocByEntity[triggerType])
               {
                  assocByEntity[triggerType] = [];
               }
               assocByEntity[triggerType].push(trigger);
            }
         }
      }
      
      public function triggerEvent(nEvent:int) : void
      {
         var entityRef:* = null;
         var mixedEntityId:* = 0;
         var entity:* = null;
         var entityId:* = undefined;
         var fef:* = null;
         var trigger:* = null;
         var totalProba:* = NaN;
         var random:Number = NaN;
         var i:int = 0;
         var matchTrigger:Dictionary = new Dictionary();
         var ref:RoleplayEntitiesFrame = Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame;
         if(ref)
         {
            entityRef = ref.getEntitiesDictionnary();
         }
         else
         {
            fef = Kernel.getWorker().getFrame(FightEntitiesFrame) as FightEntitiesFrame;
            if(fef)
            {
               entityRef = fef.getEntitiesDictionnary();
            }
            else
            {
               return;
            }
         }
         var triggers:* = [];
         for each(entity in entityRef)
         {
            triggers = null;
            mixedEntityId = uint(entity.contextualId);
            if(entity is GameRolePlayNpcInformations && this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_NPC] && this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_NPC][GameRolePlayNpcInformations(entity).npcId] && this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_NPC][GameRolePlayNpcInformations(entity).npcId][nEvent])
            {
               triggers = this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_NPC][GameRolePlayNpcInformations(entity).npcId][nEvent];
            }
            else if(entity is GameFightMonsterInformations && this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_MONSTER] && this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_MONSTER][GameFightMonsterInformations(entity).creatureGenericId] && this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_MONSTER][GameFightMonsterInformations(entity).creatureGenericId][nEvent])
            {
               triggers = this._entitiesAssoc[EntityTrigger.ENTITY_TYPE_MONSTER][GameFightMonsterInformations(entity).creatureGenericId][nEvent];
            }
            if(triggers)
            {
               for each(trigger in triggers)
               {
                  if(!(trigger.criterions != null && !trigger.criterions.isRespected))
                  {
                     if(!matchTrigger[mixedEntityId])
                     {
                        matchTrigger[mixedEntityId] = [];
                     }
                     matchTrigger[mixedEntityId].push(trigger);
                  }
               }
            }
         }
         loop2:
         for(entityId in matchTrigger)
         {
            totalProba = 0;
            for each(trigger in matchTrigger[entityId])
            {
               totalProba = Number(totalProba + trigger.probability);
            }
            random = Math.random() * (totalProba > 1?totalProba:1);
            for(i = 1; i <= matchTrigger[entityId].length; )
            {
               trigger = matchTrigger[entityId][i - 1];
               if(random > i * trigger.probability)
               {
                  i++;
                  continue;
               }
               this.speak(trigger.text,entityId,trigger.entityName,trigger.displayInChat);
               continue loop2;
            }
         }
      }
      
      private function speak(text:String, entityContextualId:int, entityName:String = null, displayInChat:Boolean = false) : void
      {
         var entitesBound:* = null;
         var bubble:* = null;
         var entite:IDisplayable = DofusEntities.getEntity(entityContextualId) as IDisplayable;
         if(entite)
         {
            entitesBound = entite.absoluteBounds;
            bubble = new ChatBubble(text);
            TooltipManager.show(bubble,entitesBound,UiModuleManager.getInstance().getModule("Ankama_Tooltips"),true,"entityBubble" + entityContextualId,LocationEnum.POINT_BOTTOMLEFT,LocationEnum.POINT_TOPRIGHT,0,true,null,null,null,null,false,StrataEnum.STRATA_WORLD);
         }
         if(displayInChat)
         {
            KernelEventsManager.getInstance().processCallback(ChatHookList.LivingObjectMessage,entityName,text,TimeManager.getInstance().getTimestamp());
         }
      }
   }
}

import com.ankamagames.dofus.datacenter.items.criterion.GroupItemCriterion;
import com.ankamagames.dofus.datacenter.monsters.Monster;
import com.ankamagames.dofus.datacenter.npcs.Npc;

class EntityTrigger
{
   
   public static const ENTITY_TYPE_NPC:uint = 0;
   
   public static const ENTITY_TYPE_MONSTER:uint = 1;
    
   
   public var criterions:GroupItemCriterion;
   
   public var probability:Number;
   
   public var text:String;
   
   public var displayInChat:Boolean = false;
   
   public var entityType:uint;
   
   public var entityId:uint;
   
   public var entityName:String;
   
   function EntityTrigger(entityType:uint, entityId:uint, criterions:String, probability:Number, text:String, displayInChat:Boolean = false)
   {
      super();
      this.entityType = entityType;
      this.entityId = entityId;
      this.criterions = new GroupItemCriterion(criterions);
      this.probability = probability;
      this.text = text;
      this.displayInChat = displayInChat;
      try
      {
         if(entityType == ENTITY_TYPE_NPC)
         {
            this.entityName = Npc.getNpcById(entityId).name;
         }
         else if(entityType == ENTITY_TYPE_MONSTER)
         {
            this.entityName = Monster.getMonsterById(entityId).name;
         }
         return;
      }
      catch(e:Error)
      {
         return;
      }
   }
}
