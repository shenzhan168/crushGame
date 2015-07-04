--
-- Author: shenzhan
-- Date: 2015-07-01 17:38:18
--email:superzhan@yeah.net
--[[
   游戏主场景

]]
local RuleLayer=require("app.scenes.RuleLayer")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local background = display.newSprite("GameBackground.png",display.cx,display.cy)
                       :addTo(self)

     -- local itemFrame=display.newSpriteFrame("Item1.png")
     -- local itemSprite=display.newSprite(itemFrame,display.cx,display.cy)
     --                  :addTo(self)

    -- 添加背景粒子特效
    local particle = cc.ParticleSystemQuad:create("gameBack.plist")
    self:addChild(particle)

     local ruleLayer=RuleLayer.new()
     self:addChild(ruleLayer)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
