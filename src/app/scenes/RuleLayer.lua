--
-- Author: shenzhan
-- Date: 2015-07-01 17:38:18
--email:superzhan@yeah.net
--[[
    游戏规则控制层
    游戏的主要逻辑控制层
]]

local Bubble=require("app.scenes.Bubble")

local RuleLayer = class("RuleLayer", function()
    return display.newLayer()
end)

function RuleLayer:ctor()
	
	print("rule ctor")
  math.randomseed(os.time()) 

  --泡泡的行列个数
	self.RowCount = 9 
	self.ColCount = 7

  --泡泡的排列位置
	self.startPos=cc.p(45,100)
	self.bubbleLen = 65 
 
  --泡泡的列表容器  和 选择列表
	self.bubbleList={}
  self.explodeList={}


	self:initRule()

	self.preBubble = nil
	self.lastBubble = nil

  self.isCanTouch =false  -- 防止在动画播放过程中 ，进行游戏操作


  --score UI --------------------
  self.score =0
  local label = display.newTTFLabel({
    text = "score:",
    size = 64,
    x = 100,
    y = 750
  })
  self:addChild(label)

  local scoreLabel = display.newTTFLabel({
    text = "001",
    size = 64,
    x = 240,
    y = 750,
    align = cc.TEXT_ALIGNMENT_LEFT
  })
  self:addChild(scoreLabel)
  self.scoreLabel=scoreLabel
   --score UI --------------------
 
     --[[添加游戏的触摸实践 ]] 
    self:setTouchEnabled(true)
     -- 注册触摸事件
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	    -- event.name 是触摸事件的状态：began, moved, ended, cancelled
	    -- event.x, event.y 是触摸点当前位置
	    -- event.prevX, event.prevY 是触摸点之前的位置
	    -- printf("sprite: %s x,y: %0.2f, %0.2f",
	    --        event.name, event.x, event.y)

	    -- 在 began 状态时，如果要让 Node 继续接收该触摸事件的状态变化
	    -- 则必须返回 true
	    if event.name == "began" then
            
            if self.isCanTouch == false then
              return true
            end
            --记录第一个泡泡
            self.preBubble = self:getBubbleByPos(event.x, event.y)
            print("begin",self.preBubble.ID)
 
	        return true
	     elseif event.name == "ended" then
             if self.preBubble == nil then
             	return
             end
             
             self.lastBubble = self:getBubbleByPos(event.x, event.y)
             
              print("ended",self.lastBubble.ID)

             if self.lastBubble ~= nil then
             	--记录第二个泡泡 然后进行交换
             	self:swap(self.preBubble,self.lastBubble)

             end

             self.preBubble = nil
             self.lastBubble = nil

	    end
    end)


end

--[[根据点击的位置 来获取响应的泡泡]]
function  RuleLayer:getBubbleByPos( x ,y )
   local bubbleCount = #self.bubbleList
   for i=1,bubbleCount do
   	  local bubble = self.bubbleList[i]
      local bubbleX,bubbleY = bubble:getPosition()

      if   bubbleX - self.bubbleLen/2 <= x and x <=bubbleX + self.bubbleLen/2 and  bubbleY -self.bubbleLen/2 <= y and y<= bubbleY + self.bubbleLen/2 then
      	
      	return bubble
      end

   end
   return nil
end

--[[游戏出事化 
   创建和设置场景中的格子和泡泡
]]
function RuleLayer:initRule( )
	-- body
	  self.gridMap={}  -- 一个二维矩阵 表示场景中的泡泡矩阵


    for  row=1,self.RowCount do

      self.gridMap[row]={}
    	
    	for col=1,self.ColCount do
    		
    		local bubble = Bubble.new()
    		local ID = math.random(1,5)
			  bubble:setData(ID)
        bubble.RuleLayer = self 
        bubble.posX=row
        bubble.posY=col

  			local x=self.startPos.x + self.bubbleLen * (col-1)
  			local y=self.startPos.y + self.bubbleLen * (row-1)
  			bubble:pos(x, y)
  			self:addChild(bubble,4)
  			table.insert(self.bubbleList, bubble)

        local grid = display.newSprite( display.newSpriteFrame("ItemBack.png"),x,y )
                     :addTo(self,0)

        self.gridMap[row][col] = bubble

    	end

    end

    --初始化消除 上面初始化的结果可能产生 可以消除的情况 ，  
    local sequ = cc.Sequence:create(cc.DelayTime:create(0.3), 
                                    cc.CallFunc:create(
                                        function() 

                                          while self:checkAndExpode() do
                                          end
                                        end),
                                    cc.CallFunc:create(
                                        function() 
                                            self:FillNewItem()
                                        end)

                                    )
    --check
    self:runAction(sequ)

end


--[[交换两个泡泡]]
function RuleLayer:swap( bubbleA, bubbleB )
	-- body
	print("swap")
    

    --交换矩阵中的位置 修改位置属性
    local aPosX,aPosY = bubbleA.posX, bubbleA.posY
    local bPosX,bPosY = bubbleB.posX, bubbleB.posY

    --判断是否相邻
    if aPosX == bPosX and math.abs(aPosY - bPosY) == 1 then
        --continue
    elseif aPosY == bPosY and math.abs(aPosX - bPosX) == 1 then
        --continue
    else
      --不相邻
       return
    end

    

    -- 先进行位置交换
    self.gridMap[aPosX][aPosY] = bubbleB
    bubbleB.posX=aPosX
    bubbleB.posY=aPosY

    self.gridMap[bPosX][bPosY] = bubbleA
    bubbleA.posX=bPosX
    bubbleA.posY=bPosY

    --判断能否消除 ， 若不能消除 ，就恢复交换
    if self:checkAndExpode(true) == false  then
      --恢复
      self.gridMap[aPosX][aPosY] = bubbleA
      bubbleA.posX=aPosX
      bubbleA.posY=aPosY

      self.gridMap[bPosX][bPosY] = bubbleB
      bubbleB.posX=bPosX
      bubbleB.posY=bPosY

      --显示动画  A B  两个泡泡相互交互 然后又恢复交换的动画
      local sequA = cc.Sequence:create(cc.CallFunc:create(function() 
                                                             bubbleA:moveToGrid(bPosX, bPosY)
                                                          end
                                                          ),
                                       cc.DelayTime:create(0.3), 
                                       cc.CallFunc:create(function() 
                                                             bubbleA:moveToGrid(aPosX, aPosY)
                                                          end
                                                          )

                                      )
      bubbleA:runAction(sequA)

      local sequB = cc.Sequence:create(cc.CallFunc:create(function() 
                                                             bubbleB:moveToGrid(aPosX, aPosY)
                                                          end
                                                          ),
                                       cc.DelayTime:create(0.3), 
                                       cc.CallFunc:create(function() 
                                                             bubbleB:moveToGrid(bPosX, bPosY)
                                                          end
                                                          )

                                      )
      bubbleB:runAction(sequB)
      return
    end

    self.isCanTouch = false  -- 符合交换条件  设置标志位
    --移动 A B 两个泡泡 交换动画
    bubbleA:moveToGrid(bPosX, bPosY)
    bubbleB:moveToGrid(aPosX, aPosY)


    local sequ = cc.Sequence:create(cc.DelayTime:create(0.3), 
                                    cc.CallFunc:create(
                                        function() 

                                          while self:checkAndExpode() do
                                          end
                                        end),
                                    cc.CallFunc:create(
                                        function() 
                                            self:FillNewItem()
                                        end)

                                    )
    --check
    self:runAction(sequ)


end


--[[
  泡泡消除检测
  先进行行检测 然后再进行列检测
  isCheck == true  表示检测模式 不消除
  isCheck == nil or false  检测 并 消除可以消除的泡泡
]]
function RuleLayer:checkAndExpode(isCheck)
	 

  print("check and explode")
   
  -- 获取格子的ID
   function getGridID(x,y)
      if self.gridMap[x][y] == nil then
         return 0
      else
        return self.gridMap[x][y].ID
      end
   end

   local counter=1
   local bMark=0
   local starIndex=1



   --[[检测行]]
   for row=1 ,self.RowCount do
      bMark =  getGridID(row,1)
      starIndex=1
      counter=1

      for col=2,self.ColCount do
         


         if getGridID(row,col)>0 and getGridID(row,col) == bMark then
             counter = counter + 1
              
              --检测完了一行
             if col == self.ColCount and counter >=3 then  
                
                --检查模式 不消除
                if isCheck ~= nil and isCheck == true then
                   return true
                end
                
                --标记可消除的泡泡
                for m = starIndex,starIndex+counter-1 do
                  table.insert(self.explodeList, self.gridMap[row][m] )
                  self.gridMap[row][m] = nil
                end
                
                self:explodeBubble()
                --FillNewItem()
                return true
              end
         else
              if counter >=3 then

                if isCheck ~= nil and isCheck == true then
                   return true
                end
                
                --标记可消除的泡泡
                for m = starIndex,starIndex+counter-1 do
                  table.insert(self.explodeList, self.gridMap[row][m] )
                  self.gridMap[row][m] = nil
                end
                
                self:explodeBubble()
                --FillNewItem()
                return true
              else
                bMark = getGridID(row,col)
                counter = 1
                starIndex=col
              end
         end

      end
   end


   --[[检测列====================]]
    local counter=1
    local bMark=0
    local starIndex=1

   for col=1 ,self.ColCount do
      bMark =  getGridID(1,col)
      starIndex=1
      counter=1

      for row=2,self.RowCount do

        
         
         if getGridID(row,col) >0 and getGridID(row,col) == bMark then
             counter = counter + 1

             if row == self.RowCount and counter >=3 then

                if isCheck ~= nil and isCheck == true then
                   return true
                end

                for k = starIndex,(starIndex+counter-1) do
                  table.insert(self.explodeList, self.gridMap[k][col] )
                  self.gridMap[k][col]= nil
                end
                
                self:explodeBubble()
                --FillNewItem()
                return true
               end


         else
             if counter >=3 then

                if isCheck ~= nil and isCheck == true then
                   return true
                end
               
                for k = starIndex,(starIndex+counter-1) do
                  table.insert(self.explodeList, self.gridMap[k][col] )
                  self.gridMap[k][col]= nil
                end
                
                self:explodeBubble()
                --FillNewItem()
                return true
              else
                bMark = getGridID(row,col)
                counter = 1
                starIndex= row
              end
         end

      end
   end

  return false
  
end


--[[
   把标记的泡泡进行消除
]]
function  RuleLayer:explodeBubble()
  
  if  #self.explodeList <1 then
    return
  end

  self.score = self.score + #self.explodeList
  self.scoreLabel:setString(self.score)

  for i=1,#self.explodeList do
      
    
    local explodePati=cc.ParticleSystemQuad:create("bubbleExplode.plist")
    local posX ,posY = self.explodeList[i]:getPosition()
     explodePati:pos(posX, posY)
     explodePati:setAutoRemoveOnFinish(true)
     self:addChild(explodePati,6)

     local x, y =self.explodeList[i].posX , self.explodeList[i].posY
      self.gridMap[x][y] = nil
      self.explodeList[i]:pos(1, 3000)

  end

end

--[[填充消除后的空缺的泡泡
    在每一列中 把上边的泡泡向下移动

]]
function RuleLayer:FillNewItem( )
	  

    local useIndex=1

    for col=1,self.ColCount do
      
      for row=1,self.RowCount do
           if self.gridMap[row][col] == nil then
               
               local fit = false
               for index=row+1,self.RowCount do
                   local bubble = self.gridMap[index][col]
                   if bubble ~= nil then
                       -- move to 
                       self.gridMap[index][col] = nil
                       bubble:moveToGrid(row,col)
                       bubble.posX=row
                       bubble.posY=col
                       self.gridMap[row][col]=bubble
                        
                       fit = true
                       break
                   end
               end

               if fit == false then
                 
                 local bubble = self.explodeList[useIndex]
                 useIndex = useIndex +1
                 
                 local srcX = self.startPos.x + self.bubbleLen * (col -1)
                 local srcY = self.startPos.y + self.bubbleLen * (self.RowCount+3)

                 bubble:pos(srcX, srcY)
                 bubble:setData(math.random(1,5))

                 bubble:moveToGrid(row, col)
                 bubble.posX=row
                 bubble.posY = col 
                 self.gridMap[row][col] = bubble

               end

           end
      end

    end

  self.explodeList={}

  self:fillNext()  -- 进行递归消除

end

--[[
   填充完后 再进行检测 
   如果又可以消除 这再次进行 消除 和 填充

   函数  checkAndExplode()  FillNewItem()  fillNext()  构成了一个递归调用
         递归入口 是 FillNewItem 递归出口在fillNext() 中的  if haveLine ==false then return
]]
function RuleLayer:fillNext()


    local sequ = cc.Sequence:create(cc.DelayTime:create(0.4), 
                                    cc.CallFunc:create(
                                        function() 

                                          local haveLine=false
                                          while self:checkAndExpode() do
                                            haveLine = true
                                          end
                                          
                                          if haveLine ==false then
                                            
                                            self.isCanTouch =true

                                            return
                                          end

                                          self:FillNewItem()
                                        end)

                                    )
    --check
    self:runAction(sequ)


end



return RuleLayer