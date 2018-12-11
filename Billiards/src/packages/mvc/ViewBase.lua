
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    self:enableNodeEvents()
    self.app_ = app
    self.name_ = name
    self._windows = {}

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResourceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResourceBinding(binding)
    end

    if res then
        self:createResourceBtnAni(self:getResourceNode())
    end

    if self.onCreate then xpcall(self.onCreate, __G__TRACKBACK__, self) end

    if self.async then
        self:setVisible(false)
        xpcall(self.async, __G__TRACKBACK__, self, function ( ... )
            self:setVisible(true)
        end)
    end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:createResoueceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:autoLayout(self.resourceNode_)
    self:addChild(self.resourceNode_)
end

function ViewBase:createResourceNode(resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    assert(self.resourceNode_, string.format("ViewBase:createResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:autoLayout(self.resourceNode_)
    self:addChild(self.resourceNode_)
end

function ViewBase:newResourceNode( resourceFilename )
    local node = cc.CSLoader:createNode(resourceFilename)
    self:createResourceBtnAni(node)
    assert(node, string.format("ViewBase:newResourceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:autoLayout(node)
    return node
end

function ViewBase:autoLayout( resouceNode )
    local ContentPanel = resouceNode:getChildByName("ContentPanel")
    if ContentPanel then
        resouceNode:setPosition(cc.p(0,0))
        ContentPanel:setPosition(cc.p(0,0))
        ContentPanel:setContentSize(cc.size(display.width, display.height))
        ccui.Helper:doLayout(ContentPanel) --cocos studio中的相对布局需要手动调该方法才有效
    end
end

function ViewBase:showPopAni(view , zorder, ...)
    local params = {...}
    local bg_layer
    if not view.__bg_layer then
        -- 底部遮罩
        bg_layer = ccui.Layout:create()
        bg_layer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        bg_layer:setBackGroundColorOpacity(190)
        bg_layer:setBackGroundColor(cc.c4b(0,0,0,0))
        bg_layer:setTouchEnabled(true)
        bg_layer:setContentSize(display.size)        
    else
        bg_layer = view.__bg_layer
        bg_layer:setTouchEnabled(true)
        bg_layer:setOpacity(190)
    end

    -- 重新设置属性
    local size = self:getResourceNode():getContentSize()
    view:setContentSize(display.size)
    view:setAnchorPoint(cc.p(0.5,0.5))
    view:setPosition(cc.p(display.width/2,display.height/2))
    view:setScaleX(0.68 * 0.85)
    view:setScaleY(0.55 * 0.85)
    view:setCascadeOpacityEnabled(true)
    view:setOpacity(0)

    -- 动画
    local timeScale = 1
    local function actOver()
        if view.onClose then
            bg_layer:onClick(handler(view, view.onClose))
        end
        if view.active then
            xpcall(view.active, __G__TRACKBACK__, view, unpack(params))
            -- view:active(unpack(params))
        end
    end
    local arr = {
        cc.Spawn:create(transition.newEasing(cc.ScaleTo:create(0.16 * timeScale,1), "CIRCLEOUT"), cc.FadeIn:create(0.16 * timeScale)),
        cc.CallFunc:create(actOver),
    }
    view:runAction( cc.Sequence:create(arr))

    -- FIXME 这里有点乱 待整理
    view.__bg_layer = bg_layer
    -- table.insert(self._windows, bg_layer)
    if not bg_layer:getParent() then
        view:registerScriptHandler(function ( state )
            if state == "enter" then
                view:onEnter_()
            elseif state == "exit" then
                view:unregisterScriptHandler()
                cc.scheduler.DelayRunFunc(function ( ... )
                    if not tolua.isnull(bg_layer) then
                        bg_layer:removeFromParent()
                    end
                end, 0)
                view:onExit_()
            elseif state == "enterTransitionFinish" then
                view:onEnterTransitionFinish_()
            elseif state == "exitTransitionStart" then
                view:onExitTransitionStart_()
            elseif state == "cleanup" then
                view:onCleanup_()
            end
        end)
        if zorder then
            self:addChild(bg_layer, zorder)
        else
            self:addChild(bg_layer)
        end
        
        bg_layer:addChild(view)
    else
        if zorder then
            view.__bg_layer:setLocalZOrder(zorder)
        end
        view.__bg_layer:setVisible(true)
    end

end

function ViewBase:openWindow( modname, ... )
--    local view = xy.windowsManager:getWindow(modname)
--    if tolua.isnull(view) then
--        view = self:getApp():createView(modname, ...)
--        xy.windowsManager:setWindow(modname, view)
--    end
--    xy.windowsManager:openWindow(self, {view}, ...)
--    return view
end

function ViewBase:openView( modname, ... )
    local view = self:getApp():createView(modname, ...)
    local params = {...}
    self:addChild(view)
    if view.active then
        xpcall(view.active, __G__TRACKBACK__, view, unpack(params))
    end
end

function ViewBase:closeView( ... )
    self:removeFromParent()
end

function ViewBase:active( ... )
    -- 当前页被激活时 调用
end

function ViewBase:unActive( ... )
    -- 当前页 不被激活/销毁 时调用
end

function ViewBase:afterCloseAni( ... )
    -- 关闭动画播放完的回调
    -- 可以在这里做移除自己等操作
end

-- 需要自己销毁或重写afterCloseAni！ 这里只负责动画！
function ViewBase:showCloseAni(...)
    local view, params = self, {...}
    local function removeView()
        if view.unActive then
            xpcall(view.unActive, __G__TRACKBACK__, view, unpack(params))
            -- view:unActive(unpack(params))
        end
        self:afterCloseAni()
    end
    local timeScale = 1.2
    local arr = {
        cc.Sequence:create(cc.ScaleTo:create(0.064 * timeScale,0.95), cc.Spawn:create(cc.ScaleTo:create(0.048 * timeScale,0.99), cc.FadeOut:create(0.048 * timeScale))),
        cc.CallFunc:create(removeView),
    }

    if view.__bg_layer then
        view.__bg_layer:onClick(function ( ... )
            print("界面正在关闭，无法响应事件.")
        end)
        view.__bg_layer:runAction(cc.Sequence:create(cc.FadeOut:create(0.064 * timeScale), cc.DelayTime:create(0.048 * timeScale), cc.CallFunc:create(function ( ... )
            view.__bg_layer:setVisible(false)
        end)))
    end
    view:setCascadeOpacityEnabled(true)
    view:setCascadeColorEnabled(true)
    view:runAction( cc.Sequence:create(arr))
end

function ViewBase:_onBtnTouch( event )
    -- dump(event)
    local node = event.target
    if event.name == "began" then
        local scaleAction1 = cc.ScaleTo:create(0.08,1.07)

        local seq = cc.Sequence:create(scaleAction1)
        node:runAction(seq)
    elseif event.name == "cancelled" or event.name == "ended" then
        -- addAction
        -- node:getNumberOfRunningActions()
        -- isDone
        node:stopAllActions()
        local scale1 = cc.ScaleTo:create(0.064, 0.97)
        local scale2 = cc.ScaleTo:create(0.064, 1.03)
        local scale3 = cc.ScaleTo:create(0.08, 1)
        local seq = cc.Sequence:create(scale1, scale2, scale3)
        node:runAction(seq)
    end
    if node.__TouchMethod then
        self[node.__TouchMethod](self, event)
    end
    if node.__ClickMethod and event.name == "ended" then
        self[node.__ClickMethod](self, event)

        local bDefault = true
        if self.class then
            local binding = rawget(self.class, "RESOURCE_BINDING")
            if binding and binding[node:getName()] and binding[node:getName()].sound then
                local sound = binding[node:getName()].sound
                amgr.playEffect(sound)
                bDefault = false
            end
        end
        if bDefault then
            -- 默认按钮音效
            amgr.playEffect("hall_res/button.mp3")
        end
    end
end

function ViewBase:createResourceBtnAni(node)
    local childrens = node:getChildren()
    for k,v in pairs(childrens) do
        if tolua.type(v) == "ccui.Button" then
            v:onTouch(handler(self, self._onBtnTouch))
        else
            if v.__TouchMethod then
                v:onTouch(handler(self, self[v.__TouchMethod]))
            end
            if v.__ClickMethod then
                v:onClick(handler(self, self[v.__ClickMethod]))
            end
            self:createResourceBtnAni(v)
        end
    end
end

function ViewBase:createResourceBinding(binding)
    assert(self.resourceNode_, "ViewBase:createResourceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        local node = ccui.Helper:seekNodeByName(self.resourceNode_, nodeName)
        -- local node = self.resourceNode_:getChildByName(nodeName)
        if tolua.type(node) == "ccui.TextField" then
            node = cc.utils.transition(node)
        end
        if not node then
            assert(false, tostring(self.name_ or "") .. " can't found child [ " .. tostring(nodeName) .. " ].")
        end
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                if not node.onTouch then
                    print(nodeName .. "(" .. tolua.type(node) .. ") can't find onTouch.")
                end
                node.__TouchMethod = event.method
            elseif event.event == "click" then
                if not node.onClick then
                    print(nodeName .. "(" .. tolua.type(node) .. ") can't find onClick.")
                end
                node.__ClickMethod = event.method
            end
        end
    end
end

function ViewBase:nodeFromPath(path, root)
    root = root or self:getResourceNode()
    assert(root, 'need root node')
    local nn = string.split(path, '.')

    local node = root
    for i = 1, #nn do
        node = node:getChildByName(nn[i])
    end
    return node
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    -- ZOOMFLIPANGULAR 翻转
    -- display.runScene(scene, transition or "FADE", time or 0.25, more)
    display.runScene(scene, transition, time, more)
    return self
end

function ViewBase:pushWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
   
    cc.Director:getInstance():pushScene(scene)
    return self
end

-- function ViewBase:onEnter( ... )
--     self:getParent():popView(self)
-- end

return ViewBase
