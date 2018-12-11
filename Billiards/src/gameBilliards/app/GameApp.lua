local GameApp = class("GameApp", cc.load("mvc").AppBase)

gamename = "gameBilliards"

g_EightBallData = nil

function GameApp:ctor(...)
    GameApp.super.ctor(self, ...)

    g_EightBallData = require("gameBilliards.app.define.EightBallDefine")

    -- require("gameBilliards.app.mgr.ballManager")
    -- require("gameBilliards.app.define.GlobalDefine")  --测试Layer用
    
    require("gameBilliards.app.mgr.EightBallGameManager")
    require("gameBilliards.app.mgr.MathMgr")
    require("gameBilliards.app.mgr.BilliardsAnimationManager")
    require("gameBilliards.app.mgr.audioManager")
    require("gameBilliards.app.control.PhysicalControl")
    require("gameBilliards.app.control.EightBallGameControl")
end

function GameApp:run(isResume,isAudition)
    local pScene = cc.Scene:createWithPhysics()

    if G_GameIndex and G_GameIndex == G_GameIndex_Type.EIGHTBALL then
        DisplayDirectory:createGameLoadingLayer(G_Game_NumType.EIGHTBALL,nil,pScene)
    end

--    local loading = require(gamename .. "/app/layer/BilliardsLoadingLayer").new()
--    if loading then
--        pScene:addChild(loading)
--    end

    -- local layer = require(g_myGameName .. "/app/layer/testLayer").new()
    -- local layer = require(gamename .. "/app/layer/gameBilliardsMainLayer").new()
    local layer = require(gamename .. "/app/layer/EightBallLayer").new(isResume,isAudition)
    if layer then
        pScene:addChild(layer)
    end

    if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(pScene)
    else
        cc.Director:getInstance():runWithScene(pScene)
    end

    --if device.platform ~= "windows" then
        amgr.playMusic("gameBilliards/sound/Billiards_Bg_2.mp3", true)
    --end

    --ClientNetManager.getInstance():keepRoomAlive()
end

return GameApp