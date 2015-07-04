--
-- Author: Your Name
-- Date: 2015-07-01 17:38:07
--

local Bubble = class("Bubble", function()
    return display.newSprite()
end)

function Bubble:ctor()
	self.ID  = 0
	self.posX = 0
	self.posY = 0
	self.RuleLayer={}
end

function Bubble:initBubble( ... )
	-- body
end

function Bubble:setData( ID)
	-- body
	self.ID= ID
	local frameName = string.format("Item%d.png", ID)
	--print("frameName",frameName)
    
    local frame = display.newSpriteFrame(frameName)
    self:setSpriteFrame(frame)

end

--[[移动到某个格子]]
function Bubble:moveToGrid(x , y)
	--目标的坐标
    
    --print(x,y)

	local tarX = self.RuleLayer.startPos.x + self.RuleLayer.bubbleLen* (y-1)
	local tarY = self.RuleLayer.startPos.y + self.RuleLayer.bubbleLen* (x-1)

	--print(tarX,tarY)

	-- 移动动作
	local moveAction= cc.MoveTo:create(0.3,cc.p(tarX,tarY))

	self:runAction(moveAction)

end

function  Bubble:expldeBubble( )
	-- body
end

return Bubble