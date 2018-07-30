local LayerWidgetBase = require("hallcenter.controllers.LayerWidgetBase")
local gamebilliardsWhiteBallLayer = class("gamebilliardsWhiteBallLayer", LayerWidgetBase)
gamebilliardsWhiteBallLayer.__index = gamebilliardsWhiteBallLayer

local m_posX = 0
local m_posY = 0

local m_posXDiff = 0
local m_posYDiff = 0
local m_variance = 0

function gamebilliardsWhiteBallLayer:ctor(mainLayer,posX,posY)
    m_posX = (posX ~= 0 and posX) and posX or 0
    m_posY = (posY ~= 0 and posY) and posY or 0
    self:initView()
    self:registerTouchHandler()
    self.mainLayer = mainLayer
end

function gamebilliardsWhiteBallLayer:initView()
    -- self:setGlobalZOrder(10000)
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    if layer then
        self:addChild(layer)
    end
    self.node = cc.CSLoader:createNode("gameBilliards/csb/billiardsWhiteBallLayer.csb")
    self:setTag(g_EightBallData.g_Layer_Tag.whiteBallLayer)
    -- self.node:setGlobalZOrder(10000)
    if self.node then
        m_posXDiff =(display.width - self.node:getContentSize().width) / 2
        m_posYDiff =(display.height - self.node:getContentSize().height) / 2
        m_variance = math.sqrt(math.pow(m_posXDiff, 2) + math.pow(m_posYDiff, 2))
        print("====== white ball layer display param = ",m_posXDiff,m_posYDiff,m_variance)
        self.node:setAnchorPoint(cc.p(0.5, 0.5))
        self.node:setPosition(display.center)
        self:addChild(self.node)

        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        self.ball_white = self.node:getChildByTag(1)
        -- self.ball_white:setGlobalZOrder(10000)
        self.redPoint = self.ball_white:getChildByTag(2)
        -- self.redPoint:setGlobalZOrder(10000)
        local _value =(self.ball_white:getContentSize().width / 2 - 30)
        self.redPoint:setPosition(cc.p((_value * m_posX + _value + 35),(_value * m_posY + _value + 35)))
        self.backGround = self.node:getChildByTag(3)
    end
    self.node:setPositionY(0 -(display.height - self.node:getContentSize().height))
    self.node:runAction(cc.MoveTo:create(0.3, cc.p(display.cx, display.cy)))
end

function gamebilliardsWhiteBallLayer:registerTouchHandler()
    print("-------registerTouchHandler in gamebilliardsWhiteBallLayer------")
    local function eventHandler(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(eventHandler)

    local onBegan = function(touch, event) return self:onTouchBegan(touch, event) end
    local onMoved = function(touch, event) self:onTouchMoved(touch, event) end
    local onEnded = function(touch, event) self:onTouchEnded(touch, event) end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onEnded, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--当前选择的控件
local chooseCompenent
function gamebilliardsWhiteBallLayer:onTouchBegan(touch)
    local curPos = self.node:convertToNodeSpace(touch:getLocation())
    local circleX,circleY = self.ball_white:getPosition()
    if math.sqrt((curPos.x-circleX)*(curPos.x-circleX)+(curPos.y-circleY)*(curPos.y-circleY)) < self.ball_white:getContentSize().width/2-30 then
        --self.redPoint:setPosition(self.ball_white:convertToNodeSpace(curPos))
        chooseCompenent = self.redPoint:getTag()
        self:onTouchMoved(touch)
    else
        chooseCompenent = self.backGround:getTag()
        --self:removeSelf()
    end
    return true
end

function gamebilliardsWhiteBallLayer:onTouchEnded(touch)
    if chooseCompenent == 3 then
        tool.closeLayerAni(self.node,self)
    elseif chooseCompenent == 2 then
        local _posX = (self.redPoint:getPositionX()-(self.ball_white:getContentSize().width / 2))/(self.ball_white:getContentSize().width / 2-35)
        local _posY = (self.redPoint:getPositionY()-(self.ball_white:getContentSize().width / 2))/(self.ball_white:getContentSize().width / 2-35)
        if self.mainLayer.setPullNum then
            self.mainLayer:setPullNum(_posX,_posY)
        end
    end
end

function gamebilliardsWhiteBallLayer:onTouchMoved(touch)
    if chooseCompenent == 2 then
        local curPos = self.node:convertToNodeSpace(touch:getLocation())
        local circleX, circleY = self.ball_white:getPosition()
        if math.sqrt((curPos.x - circleX) *(curPos.x - circleX) +(curPos.y - circleY) *(curPos.y - circleY)) > (self.ball_white:getContentSize().width / 2-30) then
        else
            self.redPoint:setPosition(self.ball_white:convertToNodeSpace(touch:getLocation()))
        end
    end
end

function gamebilliardsWhiteBallLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        if nTag == 1 or nTag == 2 then
            
        end
    elseif eventType == TOUCH_EVENT_ENDED then
        if nTag == 3 then
            tool.closeLayerAni(self.node,self)
            --self:removeSelf()
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        
    elseif eventType == TOUCH_EVENT_CANCELED then
        
    end
end

function gamebilliardsWhiteBallLayer:onEnter()
    self:set3DCamera()
end

function gamebilliardsWhiteBallLayer:onExit()
    if self._camera then
        self._camera = nil
    end
    m_posX = 0
    m_posY = 0
end

return gamebilliardsWhiteBallLayer
