--
local LayerWidgetBase = require("hallcenter.controllers.LayerWidgetBase")
local EightBallSettingLayer = class("EightBallSettingLayer", LayerWidgetBase)

function EightBallSettingLayer:ctor()
    self:registerTouchHandler()
    self:initView()
end

function EightBallSettingLayer:initView()
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    if layer then
        self:addChild(layer)
    end
    local node = cc.CSLoader:createNode("gameBilliards/csb/EightBallSettingLayer.csb")
    if node then
        tool.playLayerAni(node)
        self:addChild(node)

        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        local rootBg = node:getChildByTag(1)
        if rootBg then
            self.btn_Close = rootBg:getChildByTag(2)
            self.btn_Viberate = rootBg:getChildByTag(3)
            self.btn_Music = rootBg:getChildByTag(4)
            self.btn_Effect = rootBg:getChildByTag(5)

            self.btn_Close:addTouchEventListener(btnCallback)

            self.btn_Viberate:setTouchEnabled(true)
            self.btn_Music:setTouchEnabled(true)
            self.btn_Effect:setTouchEnabled(true)

            self.btn_Viberate:addTouchEventListener(btnCallback)
            self.btn_Music:addTouchEventListener(btnCallback)
            self.btn_Effect:addTouchEventListener(btnCallback)

            self.canMusic,self.canEffect,self.canViberate = amgr.getMusicAndEffectEnable()
            if self.canMusic then
                self.btn_Music:getChildByTag(10):setPositionX(95)
            else
                self.btn_Music:getChildByTag(10):setPositionX(28)
            end
            if self.canEffect then
                self.btn_Effect:getChildByTag(10):setPositionX(95)
            else
                self.btn_Effect:getChildByTag(10):setPositionX(28)
            end
            if self.canViberate then
                self.btn_Viberate:getChildByTag(10):setPositionX(95)
            else
                self.btn_Viberate:getChildByTag(10):setPositionX(28)
            end
        end
    end
end

function EightBallSettingLayer:setViberate()
    if self.canViberate then
        amgr.setViberateEnable(false)
        self.btn_Viberate:getChildByTag(10):setPositionX(28)
        self.canViberate = false
    else
        amgr.setViberateEnable(true)
        self.btn_Viberate:getChildByTag(10):setPositionX(95)
        self.canViberate = true
    end
end

function EightBallSettingLayer:setMusic()
    if self.canMusic then
        amgr.setMusicEnable(false)
        self.btn_Music:getChildByTag(10):setPositionX(28)
        self.canMusic = false
    else
        amgr.setMusicEnable(true)
        self.btn_Music:getChildByTag(10):setPositionX(95)
        self.canMusic = true
    end
end

function EightBallSettingLayer:setEffect()
    if self.canEffect then
        amgr.setEffectEnable(false)
        self.btn_Effect:getChildByTag(10):setPositionX(28)
        self.canEffect = false
    else
        amgr.setEffectEnable(true)
        self.btn_Effect:getChildByTag(10):setPositionX(95)
        self.canEffect = true
    end
end

function EightBallSettingLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        sender:setScale(1.05)
    elseif eventType == TOUCH_EVENT_ENDED then
        sender:setScale(1.0)
        amgr.playEffect("hall_res/button.mp3")
        if nTag == 2 then
            self:removeFromParent()
        elseif nTag == 3 then
            self:setViberate()
        elseif nTag == 4 then
            self:setMusic()
        elseif nTag == 5 then
            self:setEffect()
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        
    elseif eventType == TOUCH_EVENT_CANCELED then
        sender:setScale(1.0)
    end
end

function EightBallSettingLayer:onEnter()
    self:set3DCamera()
end

function EightBallSettingLayer:onExit()
    
end

return EightBallSettingLayer