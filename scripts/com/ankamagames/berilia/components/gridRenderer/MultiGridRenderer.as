package com.ankamagames.berilia.components.gridRenderer
{
   import com.ankamagames.berilia.UIComponent;
   import com.ankamagames.berilia.components.Grid;
   import com.ankamagames.berilia.interfaces.IGridRenderer;
   import com.ankamagames.berilia.managers.SecureCenter;
   import com.ankamagames.berilia.types.graphic.GraphicContainer;
   import com.ankamagames.berilia.types.graphic.UiRootContainer;
   import com.ankamagames.berilia.types.uiDefinition.BasicElement;
   import com.ankamagames.berilia.types.uiDefinition.ButtonElement;
   import com.ankamagames.berilia.types.uiDefinition.ContainerElement;
   import com.ankamagames.berilia.types.uiDefinition.StateContainerElement;
   import com.ankamagames.berilia.uiRender.UiRenderer;
   import com.ankamagames.berilia.utils.errors.BeriliaError;
   import com.ankamagames.jerakine.messages.Message;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class MultiGridRenderer implements IGridRenderer
   {
       
      
      protected var _grid:Grid;
      
      protected var _cptNameReferences:Dictionary;
      
      protected var _componentReferences:Dictionary;
      
      protected var _componentReferencesByInstance:Dictionary;
      
      protected var _elemID:uint;
      
      protected var _containerCache:Dictionary;
      
      protected var _uiRenderer:UiRenderer;
      
      protected var _containerDefinition:Dictionary;
      
      protected var _bgColor1:ColorTransform;
      
      protected var _bgColor2:ColorTransform;
      
      protected var _updateFunctionName:String;
      
      protected var _getLineTypeFunctionName:String;
      
      protected var _defaultLineType:String;
      
      protected var _getDataLengthFunctionName:String;
      
      public function MultiGridRenderer(args:String)
      {
         var params:* = null;
         super();
         if(args)
         {
            params = args.split(",");
            this._updateFunctionName = params[0];
            this._getLineTypeFunctionName = params[1];
            this._getDataLengthFunctionName = params[2];
            if(params[3])
            {
               this._bgColor1 = new ColorTransform();
               this._bgColor1.color = parseInt(params[3],16) & 16777215;
               if(params[3].length > 8)
               {
                  this._bgColor1.alphaMultiplier = ((parseInt(params[3],16) & 4278190080) >> 24) / 255;
               }
            }
            if(params[4])
            {
               this._bgColor2 = new ColorTransform();
               this._bgColor2.color = parseInt(params[4],16) & 16777215;
               if(params[4].length > 8)
               {
                  this._bgColor2.alphaMultiplier = ((parseInt(params[4],16) & 4278190080) >> 24) / 255;
               }
            }
            if(params[5])
            {
               this._bgColor1.alphaMultiplier = parseFloat(params[5]);
               this._bgColor2.alphaMultiplier = parseFloat(params[5]);
            }
         }
         this._cptNameReferences = new Dictionary();
         this._componentReferences = new Dictionary();
         this._containerDefinition = new Dictionary();
         this._componentReferencesByInstance = new Dictionary(true);
         this._uiRenderer = new UiRenderer();
         this._containerCache = new Dictionary();
      }
      
      public function set grid(g:Grid) : void
      {
         if(!this._grid)
         {
            this._grid = g;
         }
         g.mouseEnabled = true;
         var ui:UiRootContainer = this._grid.getUi();
         this._uiRenderer.postInit(ui);
      }
      
      public function render(data:*, index:uint, selected:Boolean, subIndex:uint = 0) : DisplayObject
      {
         var container:GraphicContainer = new GraphicContainer();
         container.setUi(this._grid.getUi(),SecureCenter.ACCESS_KEY);
         this.update(data,index,container,selected,subIndex);
         return container;
      }
      
      public function update(data:*, index:uint, target:DisplayObject, selected:Boolean, subIndex:uint = 0) : void
      {
         var s:* = null;
         var ui:UiRootContainer = this._grid.getUi();
         if(!ui.uiClass.hasOwnProperty(this._getLineTypeFunctionName) && !this._defaultLineType || !ui.uiClass.hasOwnProperty(this._updateFunctionName))
         {
            throw new BeriliaError("GetLineType function or update function is not define.");
         }
         var containerName:String = !!this._defaultLineType?this._defaultLineType:ui.uiClass[this._getLineTypeFunctionName](data,subIndex);
         if(target.name != containerName)
         {
            this.buildLine(target as Sprite,containerName);
         }
         if(target is Sprite)
         {
            s = target as Sprite;
            if(index % 2 == 0)
            {
               s.graphics.clear();
               if(this._bgColor1)
               {
                  s.graphics.beginFill(this._bgColor1.color,this._bgColor1.alphaMultiplier);
                  s.graphics.drawRect(0,0,this._grid.slotWidth,this._grid.slotHeight);
                  s.graphics.endFill();
               }
            }
            if(index % 2 == 1)
            {
               s.graphics.clear();
               if(this._bgColor2)
               {
                  s.graphics.beginFill(this._bgColor2.color,this._bgColor2.alphaMultiplier);
                  s.graphics.drawRect(0,0,this._grid.slotWidth,this._grid.slotHeight);
                  s.graphics.endFill();
               }
            }
         }
         this.uiUpdate(ui,target,data,selected,subIndex);
      }
      
      protected function uiUpdate(ui:UiRootContainer, target:DisplayObject, data:*, selected:Boolean, subIndex:uint) : void
      {
         if(DisplayObjectContainer(target).numChildren)
         {
            ui.uiClass[this._updateFunctionName](data,this._cptNameReferences[DisplayObjectContainer(target).getChildAt(0)],selected,subIndex);
         }
      }
      
      public function remove(dispObj:DisplayObject) : void
      {
         dispObj.visible = false;
      }
      
      public function destroy() : void
      {
         var o:* = null;
         var o2:* = null;
         var o3:* = null;
         for each(o in this._componentReferences)
         {
            o2 = o;
            for each(o3 in o2)
            {
               if(o3 is GraphicContainer)
               {
                  o3.remove();
               }
            }
         }
         this._componentReferences = null;
         this._componentReferencesByInstance = null;
         this._grid = null;
      }
      
      public function getDataLength(data:*, selected:Boolean) : uint
      {
         var ui:UiRootContainer = this._grid.getUi();
         if(ui.uiClass.hasOwnProperty(this._getDataLengthFunctionName))
         {
            return ui.uiClass[this._getDataLengthFunctionName](data,selected);
         }
         return 1;
      }
      
      public function renderModificator(childs:Array) : Array
      {
         var container:* = null;
         for each(container in childs)
         {
            this._containerDefinition[container.name] = container;
         }
         return [];
      }
      
      public function eventModificator(msg:Message, functionName:String, args:Array, target:UIComponent) : String
      {
         return functionName;
      }
      
      public function getItemIndex(target:*) : int
      {
         var elemContainer:* = undefined;
         var component:* = null;
         if(this._grid)
         {
            for(elemContainer in this._cptNameReferences)
            {
               for each(component in this._cptNameReferences[elemContainer])
               {
                  if(component === target)
                  {
                     return this._grid.getItemIndex(elemContainer);
                  }
               }
            }
         }
         return -1;
      }
      
      protected function buildLine(container:Sprite, name:String) : void
      {
         var ui:* = null;
         var elemContainer:* = null;
         var key:* = null;
         var multiGridMarkerIndex:int = 0;
         var realElemName:* = null;
         if(container.name == name)
         {
            return;
         }
         if(!this._containerCache[name])
         {
            this._containerCache[name] = [];
         }
         if(this._containerDefinition[container.name])
         {
            if(!this._containerCache[container.name])
            {
               this._containerCache[container.name] = [];
            }
            if(container.numChildren)
            {
               this._containerCache[container.name].push(container.getChildAt(0));
               container.removeChildAt(0);
            }
         }
         container.name = !!name?name:"#########EMPTY";
         if(!name)
         {
            return;
         }
         if(this._containerCache[name].length)
         {
            container.addChild(this._containerCache[name].pop());
            return;
         }
         ui = this._grid.getUi();
         elemContainer = new GraphicContainer();
         elemContainer.setUi(ui,SecureCenter.ACCESS_KEY);
         elemContainer.mouseEnabled = false;
         container.addChild(elemContainer);
         var cptNames:* = [];
         this._uiRenderer.makeChilds([this.copyElement(this._containerDefinition[name],cptNames)],elemContainer,true);
         ui.render();
         var components:* = {};
         for(key in cptNames)
         {
            multiGridMarkerIndex = key.indexOf("_m_");
            realElemName = key;
            if(multiGridMarkerIndex != -1)
            {
               realElemName = realElemName.substr(0,multiGridMarkerIndex);
            }
            components[realElemName] = ui.getElement(cptNames[key]);
         }
         this._cptNameReferences[elemContainer] = components;
         this._elemID++;
      }
      
      protected function copyElement(basicElement:BasicElement, names:Object) : BasicElement
      {
         var childs:* = null;
         var elem:* = null;
         var nsce:* = null;
         var sce:* = null;
         var stateChangingProperties:* = null;
         var state:* = 0;
         var stateStr:* = null;
         var elemName:* = null;
         var newElement:BasicElement = new (getDefinitionByName(getQualifiedClassName(basicElement)) as Class)();
         basicElement.copy(newElement);
         newElement.properties["isInstance"] = true;
         if(newElement.name)
         {
            newElement.setName(newElement.name + "_m_" + this._grid.name + "_" + this._elemID);
            names[basicElement.name] = newElement.name;
         }
         else
         {
            newElement.setName("elem_m_" + this._grid.name + "_" + BasicElement.ID++);
         }
         if(newElement is ContainerElement)
         {
            childs = new Array();
            for each(elem in ContainerElement(basicElement).childs)
            {
               childs.push(this.copyElement(elem,names));
            }
            ContainerElement(newElement).childs = childs;
         }
         if(newElement is StateContainerElement)
         {
            nsce = newElement as StateContainerElement;
            sce = basicElement as StateContainerElement;
            stateChangingProperties = new Array();
            for(stateStr in sce.stateChangingProperties)
            {
               state = uint(parseInt(stateStr));
               for(elemName in sce.stateChangingProperties[state])
               {
                  if(!stateChangingProperties[state])
                  {
                     stateChangingProperties[state] = [];
                  }
                  stateChangingProperties[state][elemName + "_m_" + this._grid.name + "_" + this._elemID] = sce.stateChangingProperties[state][elemName];
               }
            }
            nsce.stateChangingProperties = stateChangingProperties;
         }
         if(newElement is ButtonElement)
         {
            if(newElement.properties["linkedTo"])
            {
               newElement.properties["linkedTo"] = newElement.properties["linkedTo"] + "_m_" + this._grid.name + "_" + this._elemID;
            }
         }
         return newElement;
      }
   }
}
