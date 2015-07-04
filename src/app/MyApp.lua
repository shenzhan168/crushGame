--
-- Author: shenzhan
-- Date: 2015-07-01 17:38:18
--email:superzhan@yeah.net
require("config")
require("cocos.init")
require("framework.init")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")

    display.addSpriteFrames("Item.plist", "Item.png")

    self:enterScene("MainScene")
end

return MyApp
