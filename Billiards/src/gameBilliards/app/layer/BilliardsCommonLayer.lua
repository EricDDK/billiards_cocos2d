--
local LayerWidgetBase = require("hallcenter.controllers.LayerWidgetBase")
local BilliardsCommonLayer = class("BilliardsCommonLayer", LayerWidgetBase)

function BilliardsCommonLayer:ctor(callback,str)
    self.callback = callback
    self:registerTouchHandler()
    self:initView(str)
end

function BilliardsCommonLayer:initView(str)
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    if layer then
        self:addChild(layer)
    end
    local node = cc.CSLoader:createNode("gameBilliards/csb/BilliardsCommonLayer.csb")
    if node then
        node:setAnchorPoint(cc.p(0.5, 0.5))
        node:setPosition(cc.p(display.cx, display.cy))
        self:addChild(node)
        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        local rootBg = node:getChildByTag(1)
        if rootBg then
            self.text_Main = rootBg:getChildByTag(2)
            if str and str ~= "" then
                self.text_Main:setString(str)
            end
            for i = 3, 5 do
                local btn = rootBg:getChildByTag(i)
                if btn then
                    btn:addTouchEventListener(btnCallback)
                end
            end
        end
    end
end

function BilliardsCommonLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        sender:setScale(1.05)
    elseif eventType == TOUCH_EVENT_ENDED then
        sender:setScale(1.0)
        amgr.playEffect("hall_res/button.mp3")
        if nTag == 3 then
            if self.callback then
                self:callback()
            end
            self:removeFromParent()
        elseif nTag == 4 then
            self:removeFromParent()
        elseif nTag == 5 then
            self:removeFromParent()
        end
    elseif eventType == TOUCH_EVENT_MOVED then

    elseif eventType == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
end

function BilliardsCommonLayer:onEnter()
    self:set3DCamera()
end

function BilliardsCommonLayer:onExit()
    
end

return BilliardsCommonLayer