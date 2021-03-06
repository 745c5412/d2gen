package com.ankamagames.dofus.datacenter.items.criterion
{
   import com.ankamagames.dofus.datacenter.jobs.Job;
   import com.ankamagames.dofus.internalDatacenter.jobs.KnownJobWrapper;
   import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
   import com.ankamagames.jerakine.data.I18n;
   import com.ankamagames.jerakine.interfaces.IDataCenter;
   
   public class JobItemCriterion extends ItemCriterion implements IDataCenter
   {
       
      
      private var _jobId:uint;
      
      private var _jobLevel:int = -1;
      
      public function JobItemCriterion(pCriterion:String)
      {
         super(pCriterion);
         var arrayParams:Array = String(_criterionValueText).split(",");
         if(arrayParams && arrayParams.length > 0)
         {
            if(arrayParams.length <= 2)
            {
               this._jobId = uint(arrayParams[0]);
               this._jobLevel = int(arrayParams[1]);
            }
         }
         else
         {
            this._jobId = uint(_criterionValue);
            this._jobLevel = -1;
         }
      }
      
      override public function get isRespected() : Boolean
      {
         var knownJob:KnownJobWrapper = PlayedCharacterManager.getInstance().jobs[this._jobId];
         if(!knownJob)
         {
            return false;
         }
         if(this._jobLevel == -1)
         {
            return true;
         }
         if(knownJob.jobLevel > this._jobLevel)
         {
            return true;
         }
         return false;
      }
      
      override public function get text() : String
      {
         var readableCriterionRef:String = "";
         var readableCriterion:String = "";
         var job:Job = Job.getJobById(this._jobId);
         if(!job)
         {
            return readableCriterion;
         }
         var readableCriterionValue:String = job.name;
         var optionalJobLevel:String = "";
         if(this._jobLevel >= 0)
         {
            optionalJobLevel = " " + I18n.getUiText("ui.common.short.level") + " " + String(this._jobLevel);
         }
         switch(_operator.text)
         {
            case ItemCriterionOperator.EQUAL:
               readableCriterion = readableCriterionValue + optionalJobLevel;
               break;
            case ItemCriterionOperator.DIFFERENT:
               readableCriterion = I18n.getUiText("ui.common.dontBe") + readableCriterionValue + optionalJobLevel;
               break;
            case ItemCriterionOperator.SUPERIOR:
               readableCriterionRef = " >";
               readableCriterion = readableCriterionValue + readableCriterionRef + optionalJobLevel;
               break;
            case ItemCriterionOperator.INFERIOR:
               readableCriterionRef = " <";
               readableCriterion = readableCriterionValue + readableCriterionRef + optionalJobLevel;
         }
         return readableCriterion;
      }
      
      override public function clone() : IItemCriterion
      {
         var clonedCriterion:JobItemCriterion = new JobItemCriterion(this.basicText);
         return clonedCriterion;
      }
   }
}
