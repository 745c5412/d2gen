package com.ankamagames.dofus.network.messages.game.context.roleplay.fight.arena
{
   import com.ankamagames.dofus.network.types.game.context.roleplay.fight.arena.LeagueFriendInformations;
   import com.ankamagames.jerakine.network.CustomDataWrapper;
   import com.ankamagames.jerakine.network.ICustomDataInput;
   import com.ankamagames.jerakine.network.ICustomDataOutput;
   import com.ankamagames.jerakine.network.INetworkMessage;
   import com.ankamagames.jerakine.network.NetworkMessage;
   import com.ankamagames.jerakine.network.utils.FuncTree;
   import flash.utils.ByteArray;
   
   [Trusted]
   public class GameRolePlayArenaInvitationCandidatesAnswer extends NetworkMessage implements INetworkMessage
   {
      
      public static const protocolId:uint = 6783;
       
      
      private var _isInitialized:Boolean = false;
      
      public var candidates:Vector.<LeagueFriendInformations>;
      
      private var _candidatestree:FuncTree;
      
      public function GameRolePlayArenaInvitationCandidatesAnswer()
      {
         this.candidates = new Vector.<LeagueFriendInformations>();
         super();
      }
      
      override public function get isInitialized() : Boolean
      {
         return this._isInitialized;
      }
      
      override public function getMessageId() : uint
      {
         return 6783;
      }
      
      public function initGameRolePlayArenaInvitationCandidatesAnswer(candidates:Vector.<LeagueFriendInformations> = null) : GameRolePlayArenaInvitationCandidatesAnswer
      {
         this.candidates = candidates;
         this._isInitialized = true;
         return this;
      }
      
      override public function reset() : void
      {
         this.candidates = new Vector.<LeagueFriendInformations>();
         this._isInitialized = false;
      }
      
      override public function pack(output:ICustomDataOutput) : void
      {
         var data:ByteArray = new ByteArray();
         this.serialize(new CustomDataWrapper(data));
         writePacket(output,this.getMessageId(),data);
      }
      
      override public function unpack(input:ICustomDataInput, length:uint) : void
      {
         this.deserialize(input);
      }
      
      override public function unpackAsync(input:ICustomDataInput, length:uint) : FuncTree
      {
         var tree:FuncTree = new FuncTree();
         tree.setRoot(input);
         this.deserializeAsync(tree);
         return tree;
      }
      
      public function serialize(output:ICustomDataOutput) : void
      {
         this.serializeAs_GameRolePlayArenaInvitationCandidatesAnswer(output);
      }
      
      public function serializeAs_GameRolePlayArenaInvitationCandidatesAnswer(output:ICustomDataOutput) : void
      {
         output.writeShort(this.candidates.length);
         for(var _i1:int = 0; _i1 < this.candidates.length; _i1++)
         {
            (this.candidates[_i1] as LeagueFriendInformations).serializeAs_LeagueFriendInformations(output);
         }
      }
      
      public function deserialize(input:ICustomDataInput) : void
      {
         this.deserializeAs_GameRolePlayArenaInvitationCandidatesAnswer(input);
      }
      
      public function deserializeAs_GameRolePlayArenaInvitationCandidatesAnswer(input:ICustomDataInput) : void
      {
         var _item1:* = null;
         var _candidatesLen:uint = input.readUnsignedShort();
         for(var _i1:int = 0; _i1 < _candidatesLen; _i1++)
         {
            _item1 = new LeagueFriendInformations();
            _item1.deserialize(input);
            this.candidates.push(_item1);
         }
      }
      
      public function deserializeAsync(tree:FuncTree) : void
      {
         this.deserializeAsyncAs_GameRolePlayArenaInvitationCandidatesAnswer(tree);
      }
      
      public function deserializeAsyncAs_GameRolePlayArenaInvitationCandidatesAnswer(tree:FuncTree) : void
      {
         this._candidatestree = tree.addChild(this._candidatestreeFunc);
      }
      
      private function _candidatestreeFunc(input:ICustomDataInput) : void
      {
         var length:uint = input.readUnsignedShort();
         for(var i:int = 0; i < length; i++)
         {
            this._candidatestree.addChild(this._candidatesFunc);
         }
      }
      
      private function _candidatesFunc(input:ICustomDataInput) : void
      {
         var _item:LeagueFriendInformations = new LeagueFriendInformations();
         _item.deserialize(input);
         this.candidates.push(_item);
      }
   }
}
