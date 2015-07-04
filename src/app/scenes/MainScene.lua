
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

     local ruleLayer=RuleLayer.new()
     self:addChild(ruleLayer)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
