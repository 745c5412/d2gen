package com.ankamagames.dofus.scripts
{
   import com.ankamagames.jerakine.types.positions.MapPoint;
   
   public class ScriptsUtil
   {
       
      
      public function ScriptsUtil()
      {
         super();
      }
      
      public static function getMapPoint(pArgs:Array) : MapPoint
      {
         var mp:* = null;
         var se:* = null;
         if(pArgs)
         {
            switch(pArgs.length)
            {
               case 1:
                  if(pArgs[0] is ScriptEntity)
                  {
                     se = pArgs[0] as ScriptEntity;
                     mp = MapPoint.fromCoords(se.x,se.y);
                     break;
                  }
                  mp = MapPoint.fromCellId(pArgs[0]);
                  break;
               case 2:
                  mp = MapPoint.fromCoords(pArgs[0],pArgs[1]);
            }
         }
         return mp;
      }
   }
}
