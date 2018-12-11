--
local LayerWidgetBase = require("hallcenter.controllers.LayerWidgetBase")
local BilliardsLoadingLayer = class("BilliardsLoadingLayer", LayerWidgetBase)

function BilliardsLoadingLayer:ctor()
    self:registerTouchHandler()
    self:initView()
end

function BilliardsLoadingLayer:initView()
    self.bg = ccui.ImageView:create("gameBilliards/eightBall/eightBall_Background_Main.png", UI_TEX_TYPE_LOCAL)
    self.bg:setPosition(cc.p(display.cx, display.cy))
    if (display.width / display.height) <= 1136 / 640 then
        self.bg:setScale(display.height / self.bg:getContentSize().height)
    else
        self.bg:setScale(display.width / self.bg:getContentSize().width)
    end
    self:addChild(self.bg)
    self:setTag(g_EightBallData.g_Layer_Tag.commonLayer)
    local node = cc.CSLoader:createNode("gameBilliards/csb/BilliardsLoadingLayer.csb")
    if node then
        self.node = node
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(cc.p(display.cx, display.cy))
        self:addChild(node)

        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        for i = 1, 2 do
            local btn = node:getChildByTag(i)
            if btn then
                btn:addTouchEventListener(btnCallback)
            end
        end

        self:createAni(node)
        --self:loadPlistRes()
    end
end

--创建动画
function BilliardsLoadingLayer:createAni(node)
    local png = "gameBilliards/eightBall/eightBall_Loading_RotateImage.png"
    self._sprite = cc.Sprite:create(png)
    self._sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 360)))
    self._sprite:setPosition(cc.p(node:getContentSize().width / 2, node:getContentSize().height / 2 + 20))
    node:addChild(self._sprite)
end

local mPercent = 0
function BilliardsLoadingLayer:loadPlistRes()
    local resData = gameFty:getResDataByGame(G_Game_NumType.EIGHTBALL)
    local callBack = function(data)
        if data <= 100 then
            
        else
            local layer = require(gamename .. "/app/layer/EightBallLayer").new(isResume)
            if layer then
                display.getRunningScene():addChild(layer)
            end
        end
    end
    tool:loadCacheResByType(resData, callBack)
    --    local res = G_ResInfo[G_LoadResType.EIGHTBALL]

    --    local _plist = "gameBilliards/plist/BilliardsFrameEffet.plist"
    --    local _png = "gameBilliards/plist/BilliardsFrameEffet.png"
    --    display.removeSpriteFrames(_plist, _png)
    --    display.loadSpriteFrames(_plist, _png)

    --    _plist = "gameBilliards/plist/BilliardsCommon.plist"
    --    _png = "gameBilliards/plist/BilliardsCommon.png"
    --    display.removeSpriteFrames(_plist, _png)
    --    display.loadSpriteFrames(_plist, _png)

    --    _plist = "gameBilliards/plist/EightBall.plist"
    --    _png = "gameBilliards/plist/EightBall.png"
    --    display.removeSpriteFrames(_plist, _png)
    --    display.loadSpriteFrames(_plist, _png)
end

function BilliardsLoadingLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        sender:setScale(1.05)
    elseif eventType == TOUCH_EVENT_ENDED then
        sender:setScale(1.0)
        amgr.playEffect("hall_res/button.mp3")
        if nTag == 1 then
            self:removeFromParent()
        elseif nTag == 2 then
            EBGameControl:leaveGame()
            --AppBaseInstanse.Mobile_APP:enterScene("GameHallScene", "FADE", 0.2)
        end
    elseif eventType == TOUCH_EVENT_MOVED then

    elseif eventType == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
end

function BilliardsLoadingLayer:onEnter()
    self:set3DCamera()
end

function BilliardsLoadingLayer:onExit()
    mPercent = 0
end

return BilliardsLoadingLayer