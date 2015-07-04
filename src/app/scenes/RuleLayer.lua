--
-- Author: shenzhan
-- Date: 2015-07-01 17:38:18
--
--[[
    游戏规则控制层
]]

local Bubble=require("app.scenes.Bubble")

local RuleLayer = class("RuleLayer", function()
    return display.newLayer()
end)

function RuleLayer:ctor()
	
	print("rule ctor")
  math.randomseed(os.time()) 

	self.RowCount = 9 
	self.ColCount = 7

	self.startPos=cc.p(45,100)
	self.bubbleLen = 65 

	self.bubbleList={}
  self.explodeList={}


	self:initRule()

	self.preBubble = nil
	self.lastBubble = nil


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
             	
             	self:swap(self.preBubble,self.lastBubble)

             end

             self.preBubble = nil
             self.lastBubble = nil

	    end
    end)


end


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

function RuleLayer:initRule( )
	-- body
	  self.gridMap={}


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


     -- local map=self.gridMap
     -- while self:checkAndExpode(true) do
       
     --    for row=1,self.RowCount do
     --        for col=1, self.ColCount do
     --            local bubble=map[row][col]
     --             print("while ID",bubble.ID ,row, col)
     --             bubble:setData( math.random(1,5) )
     --        end
     --    end
     --    self.gridMap = map
     -- end

    
     
     -- while self:checkAndExpode() do
       
     -- end

     --self:checkAndExpode()
  

end



function RuleLayer:swap( bubbleA, bubbleB )
	-- body
	print("swap")

	-- local aX,aY =bubbleA:getPosition()
	-- local bX,bY = bubbleB:getPosition()
    
 --    local moveA = cc.MoveTo:create(0.3, cc.p(bX,bY))
 --    local moveB = cc.MoveTo:create(0.3, cc.p(aX,aY))

 --    bubbleA:runAction(moveA)
 --    bubbleB:runAction(moveB)

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

      --显示动画
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

    --移动
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

function RuleLayer:fillNext()


    local sequ = cc.Sequence:create(cc.DelayTime:create(0.4), 
                                    cc.CallFunc:create(
                                        function() 

                                          local haveLine=false
                                          while self:checkAndExpode() do
                                            haveLine = true
                                          end
                                          
                                          if haveLine ==false then
                                            return
                                          end

                                          self:FillNewItem()
                                        end)

                                    )
    --check
    self:runAction(sequ)


end

function RuleLayer:checkAndExpode(isCheck)
	 

  print("check and explode")

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

             if col == self.ColCount and counter >=3 then
                
                if isCheck ~= nil and isCheck == true then
                   return true
                end

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

function RuleLayer:FillNewItem( )
	  --[[根据空缺 把每列的 bubble 下移]]

    -- for col=1 , self.ColCount do
       
    --    --计算空缺个数
    --    local blockCount = 0
    --    local endIndex = 1
    --    for row=1, self.RowCount do
    --        if self.gridMap[row][col] == nil then
    --          blockCount = blockCount +1
    --          endIndex = row
    --        end
    --    end

    --    if blockCount >=1  then
    --       --向前填充
    --      for i=1,blockCount do
    --         local rowIndex = endIndex + i
    --         if rowIndex <= self.RowCount then
    --             local toRow = endIndex -blockCount +i
    --             self.gridMap[rowIndex][col]:moveToGrid(toRow,col)
    --             self.gridMap[rowIndex][col].posX = toRow
    --             self.gridMap[toRow][col] = self.gridMap[rowIndex][col]
    --             self.gridMap[rowIndex][col] =nil

    --         end

    --      end
    --    end

    -- end

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

  self:fillNext()

end

function RuleLayer:showScore()
	-- body
end

return RuleLayer