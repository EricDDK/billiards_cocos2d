local GameApp = class("GameApp", cc.load("mvc").AppBase)

local gamename = "gameBilliards"

g_EightBallData = require("gameBilliards.app.define.EightBallDefine")

-- require("gameBilliards.app.define.GlobalDefine")  --测试Layer用
require("gameBilliards.app.mgr.EightBallGameManager")
require("gameBilliards.app.mgr.ballManager")
require("gameBilliards.app.mgr.MathMgr")
require("gameBilliards.app.control.PhysicalControl")
require("gameBilliards.app.control.EightBallGameControl")

function GameApp:ctor(...)
    GameApp.super.ctor(self, ...)
end

function GameApp:run()
    local pScene = cc.Scene:createWithPhysics()
    -- local layer = require(g_myGameName .. "/app/layer/testLayer").new()
    -- local layer = require(gamename .. "/app/layer/gameBilliardsMainLayer").new()
    local layer = require(gamename .. "/app/layer/EightBallLayer").new()
    if layer then
        pScene:addChild(layer)
    end

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(pScene)
    else
        cc.Director:getInstance():runWithScene(pScene)
    end

    if device.platform ~= "windows" then
        amgr.playMusic("gameBilliards/sound/Billiards_Bg_2.mp3", true)
    end

end

return GameApp