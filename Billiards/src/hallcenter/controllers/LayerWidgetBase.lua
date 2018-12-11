local LayerWidgetBase = class("LayerWidgetBase", function ()
	return cc.Layer:create()
end)

function LayerWidgetBase:initBackColor(deep)
    if not deep or deep < 0 or deep > 255 then
        deep = 100
    end
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, deep))
    if layer then
        self:addChild(layer)
    end
end

function LayerWidgetBase:registerTouchHandler()
    local function eventHandler(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(eventHandler)
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler( function() return true end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler( function() end, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler( function() end, cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function LayerWidgetBase:onEnter()
    print("LayerWidgetBase:onEnter()")
end

function LayerWidgetBase:onExit()
    print("LayerWidgetBase:onExit()")
end

local nTipsTag = 12345
function LayerWidgetBase:setLoadingTips(root)
    if root then
        local cacheImage = ccui.ImageView:create("login/loadingImage.png", UI_TEX_TYPE_LOCAL)
        local png = "login/loadingImage.png"
        local sprite = cc.Sprite:create(png)
        sprite:setTag(nTipsTag)
        sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(2, 300)))
        sprite:setPosition(cc.p(root:getContentSize().width / 2, root:getContentSize().height / 2))
        sprite:setGlobalZOrder(10000)
        sprite:runAction(cc.Sequence:create(
            cc.DelayTime:create(5),
            cc.CallFunc:create(function ()
                self:stopLoadingTips(root)
                tool.openTipsLayer("加载错误")
            end)
        ))
        root:addChild(sprite)
    end
end

function LayerWidgetBase:stopLoadingTips(root)
    if root then
        local tip = root:getChildByTag(nTipsTag)
        if tip and not tolua.isnull(tip) then
            tip:stopAllActions()
            tip:removeFromParent()
            tip = null
        end
    end
end

function LayerWidgetBase:createDefaultBack()
    local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 100))
    if layer then
        self:addChild(layer)
    end
end

function LayerWidgetBase:set3DCamera( ... )
    self:setCameraMask(cc.CameraFlag.USER3)
end

return LayerWidgetBase