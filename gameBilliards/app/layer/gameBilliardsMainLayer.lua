--local gameBilliardsMainLayer = class("gameBilliardsMainLayer", function() return cc.Scene:createWithPhysics() end)
local AGameBase = require("AGameCommon.AGameBase")
local gameBilliardsMainLayer = class("gameBilliardsMainLayer",AGameBase)

local nBall_white = 0
local nBall_1 = 1
local nBall_2 = 2
local nBall_3 = 3
local nBall_4 = 4
local nBall_5 = 5
local nBall_6 = 6
local nBall_7 = 7
local nBall_8 = 8
local nBall_9 = 9
local nBall_10 = 10
local nBall_11 = 11
local nBall_12 = 12
local nBall_13 = 13
local nBall_14 = 14
local nBall_15 = 15

local nImg_Cue = 50  --杆

local nImg_Desk = 100
local nBtn_Test = 101
local nBtn_Reset = 102
local nSlider_Force = 103
local nPanel_Ball = 110
local nPanel_Pull = 111  --加塞框
local nPanel_Slider = 112  --拖动条框
local nPanel_RedPoint = 308  --红点

local nImgBall_White = 1000

--------------------成员变量--------------------

local m_firstCollisionBall = -1

local m_ballOriginalPos = { }
local m_cueLength = 0
local m_rotateX = 0
local m_rotateY = 0
local m_ballMoveScheduler = nil  --定时器
local m_ballMoveSchedulerEntry = nil  --定时器

function gameBilliardsMainLayer:ctor()
--    for i=1,16 do
--        local _plist = "gameBilliards/plist/".."ball_"..(i-1).."_0.plist"
--        local _png = "gameBilliards/plist/".."ball_"..(i-1).."_0.png"
--        display.removeSpriteFrames(_plist,_png)
--        display.loadSpriteFrames(_plist,_png)
--    end
    self:registerTouchHandler()
    self:initView()
end

function gameBilliardsMainLayer:initView()
    self.bg = ccui.ImageView:create("gameBilliards/image/billiards_Bg.png", UI_TEX_TYPE_LOCAL)
    self.bg:setPosition(cc.p(display.cx, display.cy))
    if (display.width/display.height) <= 1136/640 then
        self.bg:setScale(display.height / self.bg:getContentSize().height)
    else
        self.bg:setScale(display.width / self.bg:getContentSize().width)
    end
    self:addChild(self.bg)
    self.node = cc.CSLoader:createNode("gameBilliards/csb/billardsMainLayer.csb")
    if self.node then
        self.node:setAnchorPoint(cc.p(0.5, 0.5))
        self.node:setPosition(display.center)
        self:addChild(self.node)

        local size = cc.Director:getInstance():getWinSize()
        size.width = size.width * 0.7
        size.height = size.height * 0.7

        local function btnCallback(sender, eventType)
            self:btnCallback(sender, eventType)
        end

        self.desk_main = self.node:getChildByTag(nImg_Desk)
        self.desk_main:loadTexture("gameBilliards/image/table.png",UI_TEX_TYPE_LOCAL)
        self.btn_test = self.node:getChildByTag(nBtn_Test)
        self.btn_reset = self.node:getChildByTag(nBtn_Reset)
        self.panel_slider = self.node:getChildByTag(nPanel_Slider)
        self.slider_force = self.panel_slider:getChildByTag(nSlider_Force)
        self.panel_ball = self.node:getChildByTag(nPanel_Ball)
        self.panel_pull = self.node:getChildByTag(nPanel_Pull)
        self.panel_redPoint = self.panel_pull:getChildByTag(nPanel_RedPoint)

        self.panel_pull:setTouchEnabled(true)
        self.panel_pull:addTouchEventListener(btnCallback)
        local function percentChangedEvent(sender, eventType)
            if eventType == ccui.SliderEventType.slideBallUp then
                print("beat white ball success ！！")
                self:giveBallAPower(sender:getPercent()/100)
                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function() sender:setPercent(0) end )))
            elseif eventType == ccui.SliderEventType.percentChanged then
                
            end
        end
        self.slider_force:addEventListener(percentChangedEvent)

        self.slicer_FineTurning = self.node:getChildByTag(130)
        self.panel_FineTurning = self.slicer_FineTurning:getChildByTag(131)
        self.panel_FineTurning:setSwallowTouches(false)
        self.fineTurning_1 = self.panel_FineTurning:getChildByTag(133)
        self.fineTurning_2 = self.panel_FineTurning:getChildByTag(132)

        --self:setCommonInfo()
        self.btn_test:addTouchEventListener(btnCallback)
        self.btn_reset:addTouchEventListener(btnCallback)
        self:initPhysicalView()
    end
end

local function createEffect(t,root,_self)
    cc.Director:getInstance():setDepthTest(false)

    local _posX,_posY = root:getPosition()
    local _Pos = _self.node:convertToWorldSpace(cc.p(_posX,_posY))
    return cc.Lens3D:create(1, cc.size(100,100), cc.p(_posX+100,_posY+100), 200)
end

function gameBilliardsMainLayer:setCommonInfo()
    local testBall = cc.Sprite:create("gameBilliards/c3b/ball_2.png")
    local pattern = cc.Sprite:create("gameBilliards/c3b/ball_3.png")

    testBall:setPosition(cc.p(500, 300))
    testBall:setAnchorPoint(cc.p(0.5,0.5))
    self.node:addChild(testBall)

    --tool.setSpriteBallRender(testBall)
    --local shader = cc.GLProgram:createWithFilenames("gameBilliards/shader/liquid.vert","gameBilliards/shader/liquid.frag")
    --local programState = cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgram:createWithFilenames("gameBilliards/shader/ball_3D_PositionTex.vert","gameBilliards/shader/ball_3D_PositionTex.frag"))
    local glProgram = cc.GLProgram:create("gameBilliards/shader/test.vsh","gameBilliards/shader/test.fsh")
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    glProgram:link()
    glProgram:updateUniforms()
    testBall:setGLProgram(glProgram)

    --local shader = cc.GLProgram:create("gameBilliards/shader/example_3D_PositionTex.vsh","gameBilliards/shader/example_3D_PositionTex.fsh")
--    shader:use()
--    shader:setUniformsForBuiltins()
    --testBall:setGLProgram(shader)

--    local msp = cc.Sprite:create()
--    msp:setAnchorPoint(cc.p(0.5,0.5))
--    msp:setPosition(cc.p(testBall:getContentSize().width/2,testBall:getContentSize().height/2))
--    local frames = display.newFrames("ball_4_0_%02d.png", 1, 60)
--    local animation = display.newAnimation(frames, 0.01)

--    local ani = cc.Animate:create(animation)
--    msp:runAction(cc.RepeatForever:create(ani))
--    msp:setScale(0.35)
--    self.action = msp
--    testBall:addChild(msp)

--    msp:runAction(cc.RepeatForever:create(cc.Sequence:create(ani,cc.CallFunc:create(function ()
--        msp:setRotation(msp:getRotation()+180)
--    end),ani:reverse(),cc.CallFunc:create(function ()
--        msp:setRotation(msp:getRotation()+180)
--    end))))

--    local sprite3d = cc.Sprite3D:create("gameBilliards/ballTest/ball.c3b", "gameBilliards/ballTest/ball_2.png")
--    -- sprite3d:setTexture("gameBilliards/ballTest/ball_2.png")
--    sprite3d:setPosition3D(cc.vec3(500.0, 300.0, -1.0))
--    sprite3d:setGlobalZOrder(1)
--    sprite3d:setTag(399)
--    sprite3d:setRotation3D(cc.vec3(0, 0, 0))
--    self.node:addChild(sprite3d)

--    local orbit1 = cc.OrbitCamera:create(1, 1, 0, 0, 90, 0, 0)
--    local action1 = cc.RepeatForever:create(cc.Sequence:create(orbit1, orbit1:reverse()))
--    sprite3d:runAction(action1)

--        if testBall then
--            testBall:setPosition(cc.p(500, 300))
--            testBall:setAnchorPoint(cc.p(0.5, 0.5))
--            self.node:addChild(testBall)

----            pattern:setAnchorPoint(cc.p(0.5, 0.5))
----            pattern:setPosition(cc.p(testBall:getContentSize().width / 2, testBall:getContentSize().height / 2))
----            pattern:setScale(0.3)
--            --testBall:addChild(pattern)
--        end
--        local orbit1 = cc.OrbitCamera:create(2, -45, 0, 90, 180, 0, 0)
--        local action1 = cc.Sequence:create(orbit1, orbit1:reverse())
--        testBall:runAction(cc.RepeatForever:create(action1))


        --pattern:runAction(cc.RepeatForever:create(action1))

--            testBall:setPosition(cc.p(500,300))
--            testBall:setAnchorPoint(cc.p(0.5,0.5))
--            local gridNode = cc.NodeGrid:create()
--            self.node:addChild(gridNode)
--            gridNode:setAnchorPoint(cc.p(0.5,0.5))
--            gridNode:setPosition(cc.p(testBall:getContentSize().width/2,testBall:getContentSize().height/2))
--            local effect = createEffect(2,testBall,self)
--            gridNode:runAction(effect)
--            gridNode:addChild(testBall)
end

function gameBilliardsMainLayer:initPhysicalView()
    local top = cc.Node:create()
    local deskX = self.desk_main:getPositionX()
    local deskY = self.desk_main:getPositionY()
    local tableHeight = self.desk_main:getContentSize().width
    local tableWidth = self.desk_main:getContentSize().height
    local tableSize = self.desk_main:getBoundingBox()
    self:createPhysicalBorderLine(cc.p(208, 445), cc.p(208, 130))
    self:createPhysicalBorderLine(cc.p(240, 101), cc.p(537, 101))
    self:createPhysicalBorderLine(cc.p(600, 101), cc.p(897, 101))
    self:createPhysicalBorderLine(cc.p(930, 132), cc.p(930, 441))
    self:createPhysicalBorderLine(cc.p(894, 475), cc.p(600, 475))
    self:createPhysicalBorderLine(cc.p(538, 475), cc.p(243, 475))

    self:createPhysicalBorderLine(cc.p(208, 445), cc.p(208 - 500, 445 + 500))
    self:createPhysicalBorderLine(cc.p(208, 130), cc.p(208 - 500, 130 - 500))
    self:createPhysicalBorderLine(cc.p(240, 101), cc.p(240 - 500, 101 - 500))
    self:createPhysicalBorderLine(cc.p(537, 101), cc.p(546, 87))
    self:createPhysicalBorderLine(cc.p(600, 101), cc.p(591, 87))
    self:createPhysicalBorderLine(cc.p(897, 101), cc.p(897 + 500, 101 - 500))
    self:createPhysicalBorderLine(cc.p(930, 132), cc.p(930 + 500, 132 - 500))
    self:createPhysicalBorderLine(cc.p(930, 441), cc.p(930 + 500, 441 + 500))
    self:createPhysicalBorderLine(cc.p(894, 475), cc.p(894 + 500, 475 + 500))
    self:createPhysicalBorderLine(cc.p(600, 475), cc.p(591, 490))
    self:createPhysicalBorderLine(cc.p(538, 475), cc.p(546, 490))
    self:createPhysicalBorderLine(cc.p(243, 475), cc.p(243 - 500, 475 + 500))
    self:createPhysicalHole(205.9,478.7,15)
    self:createPhysicalHole(205.9,99.6,15)
    self:createPhysicalHole(931.9,478.7,15)
    self:createPhysicalHole(931.9,99.6,15)
    self:createPhysicalHole(569.50,492.42,15)
    self:createPhysicalHole(569.50,85.42,15)

    self:initWhiteBallPhysical()
    self:initOtherBallPhysical()
    self:initCueState()
    self:initPhysicalListenr()
end

--所有的监听事件在这里初始化
function gameBilliardsMainLayer:initPhysicalListenr()
    self:initCheckCollisionListener()
    self:setCueRotateCueListener()
end

-- 创建壁的物理边界
function gameBilliardsMainLayer:createPhysicalBorderLine(pos1, pos2)
    local border = cc.Node:create()
    border:setTag(100)
    border:setPhysicsBody(cc.PhysicsBody:createEdgeSegment(pos1, pos2, borderPhysicsMaterial))
    border:getPhysicsBody():setCategoryBitmask(0x01)
    border:getPhysicsBody():setContactTestBitmask(0x01)
    border:getPhysicsBody():setCollisionBitmask(0x03)
    self.node:addChild(border)
end

--创建洞的物理边界
function gameBilliardsMainLayer:createPhysicalHole(pos1,pos2,radius)
    local border = cc.Node:create()
    border:setTag(200)
    border:setPhysicsBody(cc.PhysicsBody:createCircle(radius))
    border:setPosition(cc.p(pos1,pos2))
    border:getPhysicsBody():setCategoryBitmask(0x01)
    border:getPhysicsBody():setContactTestBitmask(0x01)
    border:getPhysicsBody():setCollisionBitmask(0x04)
    self.node:addChild(border)
end

--加载白球的刚体
function gameBilliardsMainLayer:initWhiteBallPhysical()
    self.whiteBall = cc.Sprite:createWithSpriteFrame(self.node:getChildByTag(nImgBall_White):getSpriteFrame())
    self.whiteBall:setPosition(whiteBallOriginalPos)
    self.whiteBall:setScale(ballScale)
    self.whiteBall:setTag(nBall_white)
    self.whiteBall:setPhysicsBody(cc.PhysicsBody:createCircle(self.whiteBall:getContentSize().width / 2, whilteBallPhysicsMaterial))
    self.whiteBall:getPhysicsBody():setLinearDamping(ballLinearDamping)
    self.whiteBall:getPhysicsBody():setAngularDamping(ballAngularDamping)
    self.whiteBall:getPhysicsBody():setCategoryBitmask(0x01)
    self.whiteBall:getPhysicsBody():setContactTestBitmask(0x01)
    self.whiteBall:getPhysicsBody():setCollisionBitmask(0x03)
    self.node:addChild(self.whiteBall)
    local highLight = ccui.ImageView:create("gameBilliards/image/ball_HighLight.png", UI_TEX_TYPE_LOCAL)
    highLight:setCascadeOpacityEnabled(false)
    highLight:setAnchorPoint(cc.p(0.5, 0.5))
    highLight:setPosition(cc.p(self.whiteBall:getContentSize().width / 2, self.whiteBall:getContentSize().height / 2))
    highLight:setScale(2.8)
    highLight:setCameraMask(4)
    highLight:setTag(1000)
    self.whiteBall:addChild(highLight)
    local shadow = ccui.ImageView:create("gameBilliards/image/ball_Shadow.png", UI_TEX_TYPE_LOCAL)
    shadow:setCascadeOpacityEnabled(false)
    shadow:setAnchorPoint(cc.p(0.5, 0.5))
    shadow:setPosition(cc.p(self.whiteBall:getContentSize().width / 2, self.whiteBall:getContentSize().height / 2))
    shadow:setScale(2.8)
    self.whiteBall:addChild(shadow)
end

-- 加载其他15颗彩色球的刚体和物理边界
function gameBilliardsMainLayer:initOtherBallPhysical()
    for i = nBall_1, nBall_15 do
        local ball = cc.Sprite:createWithSpriteFrame(self.panel_ball:getChildByTag(i):getSpriteFrame())
        if ball then
            ball:setScale(ballScale)
            ball:setTag(i)
            ball:setAnchorPoint(cc.p(0.5, 0.5))
            ball:setPosition(self.panel_ball:convertToWorldSpace(cc.p(self.panel_ball:getChildByTag(i):getPositionX() + 1136, self.panel_ball:getChildByTag(i):getPositionY())))
            ball:setPhysicsBody(cc.PhysicsBody:createCircle(ball:getContentSize().width / 2, ballPhysicsMaterial))
            ball:getPhysicsBody():setLinearDamping(ballLinearDamping)
            ball:getPhysicsBody():setCategoryBitmask(0x01)
            ball:getPhysicsBody():setContactTestBitmask(0x01)
            ball:getPhysicsBody():setCollisionBitmask(0x03)
            ball:getPhysicsBody():setAngularDamping(ballAngularDamping)
            table.insert(m_ballOriginalPos, cc.p(ball:getPositionX(), ball:getPositionY()))
            self.node:addChild(ball)
            local highLight = ccui.ImageView:create("gameBilliards/image/ball_HighLight.png", UI_TEX_TYPE_LOCAL)
            highLight:setCascadeOpacityEnabled(false)
            highLight:setAnchorPoint(cc.p(0.5,0.5))
            highLight:setPosition(cc.p(ball:getContentSize().width/2,ball:getContentSize().height/2))
            highLight:setScale(2.8)
            highLight:setCameraMask(4)
            ball:addChild(highLight)
            local shadow = ccui.ImageView:create("gameBilliards/image/ball_Shadow.png", UI_TEX_TYPE_LOCAL)
            shadow:setCascadeOpacityEnabled(false)
            shadow:setAnchorPoint(cc.p(0.5,0.5))
            shadow:setPosition(cc.p(ball:getContentSize().width/2,ball:getContentSize().height/2))
            shadow:setScale(2.8)
            ball:addChild(shadow)
        end
    end
end

--
local speedCount = 0
function gameBilliardsMainLayer:refreshBallAni(isCollision)
    if self.whiteBall and not tolua.isnull(self.whiteBall) and self.whiteBall.getChildByTag then
        local _highLight = self.whiteBall:getChildByTag(1000)
        if _highLight then
            local _rot = self.whiteBall:getRotation()
            _highLight:setRotation(360 - _rot)
        end
    end
    speedCount = speedCount + 1
    if speedCount >= 6 then
        speedCount = 0
        return
    end
    local s3d_Width = cc.Sprite3D:create("gameBilliards/3d_ball/ball.obj"):getContentSize().width / 2
    for i = 0, nBall_15 do
        local ball = self.node:getChildByTag(i)
        if ball then
            local Texture3D = ball:getChildByTag(8)
            if not Texture3D then
                local rbDes = { }
                rbDes.disableSleep = true
                rbDes.mass = 1.0
                rbDes.shape = cc.Physics3DShape:createSphere(ball:getContentSize().width / 2 / 100)
                local rigidBody = cc.Physics3DRigidBody:create(rbDes)
                local component = cc.Physics3DComponent:create(rigidBody)
                Texture3D = cc.PhysicsSprite3D:create("gameBilliards/3d_ball/ball.c3b", rbDes)
                Texture3D:setTexture("gameBilliards/3d_ball/" .. i .. ".png")
                Texture3D:setPosition(cc.p(ball:getContentSize().width / 2, ball:getContentSize().height / 2))
                Texture3D:setTag(8)
                Texture3D:setScale(s3d_Width * 2 /(ball:getContentSize().width / 2))
                Texture3D:setCameraMask(cc.CameraFlag.USER2)
                ball:addChild(Texture3D)
                Texture3D:setRotation3D(cc.vec3(math.random(0,180),math.random(0,180),math.random(0,180)))
                rigidBody:setAngularVelocity(cc.vec3(0.0, 0.0, 0.0))
            end
            local velocity = ball:getPhysicsBody():getVelocity()
            local v = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
            if v <= ballDampingValue then
                ball:getPhysicsBody():setLinearDamping(ballLinearDamping * ballLinearIncreaseMultiple)
                if v <= 100 then
                     ball:getPhysicsBody():setLinearDamping(ballLinearDamping * 3)
                end
            end
            if v ~= 0 then
                local rigidBody = Texture3D:getPhysicsObj()
                if rigidBody then
                    local angularVelocity = ball:getPhysicsBody():getAngularVelocity()
                    rigidBody:setAngularVelocity(cc.vec3(- velocity.y / ballRollingRate, velocity.x / ballRollingRate, angularVelocity / ballRollingRate))
                end
            end
        end
    end
end

--local speedCount = 0
---- 球体动画效果
--function gameBilliardsMainLayer:refreshBallAni(isCollision)
--    -- 白球旋转位置改动
--    if self.whiteBall then
--        local _highLight = self.whiteBall:getChildByTag(1000)
--        if _highLight then
--            local _rot = self.whiteBall:getRotation()
--            _highLight:setRotation(360 - _rot)
--        end
--    end
--    speedCount = speedCount + 1
--    if speedCount >= 6 then
--        speedCount = 0
--        return
--    end
--    for i = 0, nBall_15 do
--        local ball = self.node:getChildByTag(i)
--        if ball then
--            --            if i >= 2 then
--            --                ball:removeFromParent()
--            --                return
--            --            end
--            local msp = ball:getChildByTag(8)
--            if not msp then
--                msp = cc.CSLoader:createNode("gameBilliards/test/Ball_11.csb")
--                msp:setAnchorPoint(cc.p(0.5, 0.5))
--                msp:setPosition(cc.p(ball:getContentSize().width / 2, ball:getContentSize().height / 2))
--                msp:setScale(0.55 * 5)
--                ball:addChild(msp)
--                msp:setTag(8)
--                local action = cc.CSLoader:createTimeline("gameBilliards/test/Ball_11.csb")
--                msp:runAction(action)
--                action:gotoFrameAndPlay(0, 179, 0, true)
--                action:setTimeSpeed(0)
--                action:setTag(5)
--            end
--            local _action = msp:getActionByTag(5)
--            if _action then
--                local velocity = ball:getPhysicsBody():getVelocity()
--                local v = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
--                if velocity.x ~= 0 or velocity.y ~= 0 then
--                    _action:resume()
--                    _action:setTimeSpeed(v / 22)
--                    local rotate
--                    if velocity.x >= 0 and velocity.y >= 0 then
--                        rotate = math.atan(velocity.x / velocity.y) * 180 / math.pi
--                    elseif velocity.x >= 0 and velocity.y <= 0 then
--                        rotate = 90 + math.atan(- velocity.y / velocity.x) * 180 / math.pi
--                    elseif velocity.x <= 0 and velocity.y >= 0 then
--                        rotate = 360 - math.atan(- velocity.x / velocity.y) * 180 / math.pi
--                    elseif velocity.x <= 0 and velocity.y <= 0 then
--                        rotate = 180 + math.atan(velocity.x / velocity.y) * 180 / math.pi
--                    end
--                    if v <= ballDampingValue then
--                        -- ball:getPhysicsBody():setLinearDamping(ballLinearDamping * 2)
--                        --                        if v <= 100 then
--                        --                            ball:getPhysicsBody():setLinearDamping(ballLinearDamping * 3)
--                        --                        end
--                    end
--                    local _multiple, t2 = math.modf(rotate / 30)
--                    if rotate < 180 then
--                        _multiple = _multiple + 1
--                    end
--                    --print("===== multiple rotate = ",rotate,_multiple)
--                    local _frame = _action:getCurrentFrame() % 180 + _multiple * 180
--                    if isCollision then
--                        local _frame = _action:getCurrentFrame() % 180 + _multiple * 180
--                        _action:gotoFrameAndPlay(_multiple * 180, _multiple * 180 + 179, _frame, true)
----                        if i == 0 then
----                            print(i .. " num ball multiple and frame is", _multiple, _frame, rotate)
----                        end
--                    end
--                    msp:setRotation(rotate)
--                else
--                    _action:pause()
--                    _action:setTimeSpeed(0)
--                end
--            end
--        end
--    end
--end

--local animationTable = {}
--local speedCount = 0
----球体动画效果
--function gameBilliardsMainLayer:refreshBallAni(isCollision)
--    -- 白球旋转位置改动
--    if self.whiteBall then
--        local _highLight = self.whiteBall:getChildByTag(1000)
--        if _highLight then
--            local _rot = self.whiteBall:getRotation()
--            _highLight:setRotation(360 - _rot)
--        end
--    end
--    speedCount = speedCount + 1
--    if speedCount >= 10 then
--        speedCount = 0
--        return
--    end
--    for i = 0, nBall_15 do
--        local ball = self.node:getChildByTag(i)
--        if ball then
--            local msp = ball:getChildByTag(8)
--            if not msp then
--                msp = cc.Sprite:create()
--                msp:setTag(8)
--                msp:setAnchorPoint(cc.p(0.5, 0.5))
--                msp:setPosition(cc.p(ball:getContentSize().width / 2, ball:getContentSize().height / 2))
--                msp:setScale(0.55 * 5)
--                local frames = display.newFrames("ball_"..i.."_0_%03d.png", 1, 180)
--                local animation = display.newAnimation(frames, 0.01)
--                local ani = cc.Animate:create(animation)
--                local rollAni = cc.Speed:create(cc.RepeatForever:create(ani), 3)
--                msp:runAction(rollAni)
--                rollAni:setTag(5)
--                ball:addChild(msp)
--            end
--            local velocity = ball:getPhysicsBody():getVelocity()
--            local v = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
--            if velocity.x ~= 0 or velocity.y ~= 0 then
--                msp:resume()
--                local _ani = msp:getActionByTag(5)
--                if _ani then
--                    _ani:setSpeed(v / 45)
--                end
--                local rotate
--                if velocity.x >= 0 and velocity.y >= 0 then
--                    rotate = math.atan(velocity.x / velocity.y) * 180 / math.pi
--                elseif velocity.x >= 0 and velocity.y <= 0 then
--                    rotate = 90 + math.atan(- velocity.y / velocity.x) * 180 / math.pi
--                elseif velocity.x <= 0 and velocity.y >= 0 then
--                    rotate = 360 - math.atan(- velocity.x / velocity.y) * 180 / math.pi
--                elseif velocity.x <= 0 and velocity.y <= 0 then
--                    rotate = 180 + math.atan(velocity.x / velocity.y) * 180 / math.pi
--                end
--                if v <= ballDampingValue then
--                    ball:getPhysicsBody():setLinearDamping(ballLinearDamping*2)
--                    if v <= 100 then
--                        ball:getPhysicsBody():setLinearDamping(ballLinearDamping*3)
--                    end
--                end
--                if v > 30 then
--                    msp:setRotation(rotate)
--                end
--            else
--                msp:pause()
--            end
--        end
--    end
--end

--加载杆的属性
function gameBilliardsMainLayer:initCueState()
    self.cue = self.node:getChildByTag(nImg_Cue)
    self.cue:setAnchorPoint(cc.p(1, 0.5))
    self.cue:setLocalZOrder(cueZOrder)
    self.cue:setPosition(cc.p(self.whiteBall:getPosition()))
    m_cueLength = self.cue:getContentSize().width + self.whiteBall:getContentSize().width * ballScale
    self.line = cc.DrawNode:create()
    self.line:setTag(g_Border_Tag.lineCheck)
    self.line:setLocalZOrder(lineZOrder)
    self.line:drawLine(cc.p(self.cue:convertToNodeSpace(cc.p(self.cue:getPosition()))),
    cc.p(self.cue:convertToNodeSpace(cc.p(self.cue:getPositionX() + self.desk_main:getContentSize().width, self.cue:getPositionY()))), cc.c4f(1.0, 1.0, 1.0, 1.0))
    self.cue:addChild(self.line)

    --画圈圈
    local circleCheck = cc.DrawNode:create()
    circleCheck:setTag(g_Border_Tag.circleCheck)
    circleCheck:setGlobalZOrder(circleZOrder)
    circleCheck:drawCircle(cc.p(-999,5),self.whiteBall:getContentSize().width/2 * ballScale,math.pi/2,50,false,1.0,1.0,cc.c4f(1.0, 1.0, 1.0, 1.0))
    self.line:addChild(circleCheck)

    --彩球检测线
    local ballCollisionLine = cc.DrawNode:create()
    ballCollisionLine:setTag(g_Border_Tag.ballCollisionLine)
    ballCollisionLine:setGlobalZOrder(ballCollisionLineOrder)
    self.line:addChild(ballCollisionLine)

    --白球检测线
    local whiteCollisionLine = cc.DrawNode:create()
    whiteCollisionLine:setTag(g_Border_Tag.whiteCollisionLine)
    whiteCollisionLine:setGlobalZOrder(whiteCollisionLineOrder)
    self.line:addChild(whiteCollisionLine)

    local _borderWidth = self.desk_main:getContentSize().width
    local _borderHeight = self.whiteBall:getContentSize().width * ballScale*2
    self.cueCheckBorder = cc.DrawNode:create()
    self.cueCheckBorder:setTag(g_Border_Tag.cueCheck)
    self.cueCheckBorder:setAnchorPoint(cc.p(0.5,0.5))
    local _colorLine
    if isDebug then _colorLine = cc.c4f(1,0,1,1) else _colorLine = cc.c4f(0,0,0,0) end
    self.cueCheckBorder:drawRect(cc.p(-_borderWidth/2,-_borderHeight/2),cc.p(_borderWidth/2,_borderHeight/2),_colorLine)
    self.cueCheckBorder:setPosition(cc.p(self.desk_main:getContentSize().width+3.5,5))
    self.cue:addChild(self.cueCheckBorder)

    --OpenGL绘制无锯齿直线
--    self.line = gl.glNodeCreate()
--    self.line:setTag(g_Border_Tag.lineCheck)
--    self.line:setLocalZOrder(lineZOrder)
--    local function primitivesDraw(transform, transformUpdated)
--        kmGLPushMatrix()
--        kmGLLoadMatrix(transform)
--        cc.DrawPrimitives.drawColor4B(255,255,255,255)
--        cc.DrawPrimitives.drawLine(cc.p(self.cue:convertToNodeSpace(cc.p(self.cue:getPosition()))),cc.p(self.cue:convertToNodeSpace(cc.p(self.cue:getPositionX() + self.desk_main:getContentSize().width, self.cue:getPositionY()))))
--        kmGLPopMatrix()
--    end
--    self.line:registerScriptDrawHandler(primitivesDraw)
--    self.cue:addChild(self.line)

--    local _borderWidth = self.desk_main:getContentSize().width
--    local _borderHeight = self.whiteBall:getContentSize().width * ballScale*2
--    local cueCheckBorder = cc.Node:create()
--    cueCheckBorder:setTag(g_Border_Tag.cueCheck)
--    cueCheckBorder:setAnchorPoint(cc.p(0,0.5))
--    cueCheckBorder:setPhysicsBody(cc.PhysicsBody:createEdgeBox(cc.size(_borderWidth, _borderHeight)))
--    cueCheckBorder:setPosition(cc.p(self.desk_main:getContentSize().width+3,5))
--    cueCheckBorder:getPhysicsBody():setCategoryBitmask(0x01)
--    cueCheckBorder:getPhysicsBody():setContactTestBitmask(0x01)
--    cueCheckBorder:getPhysicsBody():setCollisionBitmask(0x04)
--    self.cue:addChild(cueCheckBorder)
end

--根据触摸来设置杆的位置
function gameBilliardsMainLayer:setCuePosByTouch(pos,isBegan,isEnd,angular)
    if angular then
        if math.abs(angular) > 0.3 then
            return
        end
        local rotate = self.cue:getRotation()+angular
        self.cue:setRotation(rotate)
        self:drawRouteDetection(360-rotate)
        return
    end
    if not self.whiteBall then
        self.cue:setVisible(false)
        self.cue:getChildByTag(g_Border_Tag.cueCheck):setPosition(cc.p(9999,9999))
        self.slider_force:setTouchEnabled(false)
        return
    end
    local ballX,ballY
    if self and self.whiteBall and not tolua.isnull(self.whiteBall) and self.whiteBall.getPosition then
        ballX,ballY = self.whiteBall:getPosition()
    else
        return
    end
    local touchX = pos.x
    local touchY = pos.y
    --print("touch Moved pos = ",pos.x,pos.y)
    local rotateX = -(pos.x-ballX)
    local rotateY = -(pos.y-ballY)
    local rotate = math.atan(rotateY/rotateX)*180/math.pi
    if rotateX >= 0 and rotateY >= 0 then
        rotate = 180 - rotate
    elseif rotateX <= 0 and rotateY <= 0 then
        rotate = 360-rotate
    elseif rotateX <= 0 and rotateY >= 0 then
        rotate = math.abs(rotate)
    elseif rotateX >= 0 and rotateY <= 0 then
        rotate = 180+math.abs(rotate)
    end
    self.cue:setAnchorPoint(cc.p(1,0.5))
    self.cue:setRotation(rotate)

    if isBegan then
        self.cue:setPosition(cc.p(self.whiteBall:getPosition()))
    end
    self:drawRouteDetection(360-rotate)  --路径检测并画线 
end

--路径检测
function gameBilliardsMainLayer:drawRouteDetection(rotate)
    local _rect = self.cue:getChildByTag(g_Border_Tag.cueCheck)
    local _rectWorld = _rect:convertToWorldSpace(cc.p(_rect:getPositionX() - self.desk_main:getContentSize().width - 3.5, _rect:getPositionY() - 5))
    local _rectPos = self.node:convertToNodeSpace(cc.p(_rectWorld.x, _rectWorld.y))
    local _whitePos = self.node:convertToNodeSpace(cc.p(self.whiteBall:getPosition()))
    local _tmpCollisionBall = {}
    for i = 2, 16 do
        local _ball = self.node:getChildByTag(i - 1)
        if _ball then
            local _ballPosWorld = self.node:convertToNodeSpace(cc.p(_ball:getPosition()))
            local json = help.getNewRx_Ry(_rectPos.x,_rectPos.y,_ballPosWorld.x,_ballPosWorld.y,rotate)
            if help.computeCollision(self.desk_main:getContentSize().width,self.whiteBall:getContentSize().width * ballScale,_ball:getContentSize().width/2*ballScale,json.newRx, json.newRy) then
                --print("Route detection that white ball is collided with", i - 1, "num ball")
                local _ballDistance = help.twoDistance(_whitePos.x,_whitePos.y,_ballPosWorld.x,_ballPosWorld.y)
                table.insert(_tmpCollisionBall,{tag=i-1,distance=_ballDistance})
            end
        end
    end
    local _circle = self.line:getChildByTag(g_Border_Tag.circleCheck)
    local _ballCollisionLine = self.line:getChildByTag(g_Border_Tag.ballCollisionLine)  --彩球的碰撞线
    local _whiteCollisionLine = self.line:getChildByTag(g_Border_Tag.whiteCollisionLine)  --白球的线
    local _radius = self.whiteBall:getContentSize().width/2*ballScale  --白球半径
    _circle:clear()
    _ballCollisionLine:clear()
    _whiteCollisionLine:clear()
    if #_tmpCollisionBall > 0 and next(_tmpCollisionBall) ~= nil and _tmpCollisionBall[1].tag then
        table.sort(_tmpCollisionBall,function(a, b) return (a.distance) < (b.distance) end)
        --print("Route detection that white ball collided with", _tmpCollisionBall[1].tag, "num ball")
        local _ballPos = self.node:convertToNodeSpace(cc.p(self.node:getChildByTag(_tmpCollisionBall[1].tag):getPosition()))
        local _value = help.getShortestDistanceBetweenPointAndLine(rotate,_ballPos,_whitePos,_radius)
        _circle:drawCircle(cc.p(self.desk_main:getContentSize().width/2+3.5+_tmpCollisionBall[1].distance-_value,5),
        self.whiteBall:getContentSize().width/2 * ballScale,math.pi/2,50,false,1.0,1.0,cc.c4f(1.0, 1.0, 1.0, 1.0))
        local _whiteCollisionPoint = self.node:convertToNodeSpace(cc.p(self.desk_main:getContentSize().width/2+3.5+_tmpCollisionBall[1].distance-_value,5))
        local _ballCollisionPoint = self.line:convertToNodeSpace(cc.p(self.node:getChildByTag(_tmpCollisionBall[1].tag):getPosition()))
        local _whiteCollisionPointNew
        if _ballCollisionPoint.y >= _whiteCollisionPoint.y then
            _whiteCollisionPointNew = self.node:convertToNodeSpace(cc.p((1.5*_ballCollisionPoint.x-0.5*_whiteCollisionPoint.x),
            (_whiteCollisionPoint.y+1.5*(math.sqrt(4*_radius*_radius-math.pow(_ballCollisionPoint.x-_whiteCollisionPoint.x,2))))))
        else
            _whiteCollisionPointNew = self.node:convertToNodeSpace(cc.p((1.5*_ballCollisionPoint.x-0.5*_whiteCollisionPoint.x),
            (1.5*(math.sqrt(4*_radius*_radius-math.pow(_ballCollisionPoint.x-_whiteCollisionPoint.x,2)))-_whiteCollisionPoint.y)))
        end
        local _ballCollisionPointNew = self.node:convertToNodeSpace(cc.p(_ballCollisionPoint.x*3-_whiteCollisionPoint.x*2,_ballCollisionPoint.y*3-_whiteCollisionPoint.y*2))
        _ballCollisionLine:drawLine(_whiteCollisionPoint,_ballCollisionPointNew,cc.c4f(1.0, 1.0, 1.0, 1.0))
        --白球瞄准线的截取
        self.line:clear()
        self.line:drawLine(cc.p(self.cue:convertToNodeSpace(cc.p(self.cue:getPosition()))),
        cc.p(self.desk_main:getContentSize().width/2+3.5+_tmpCollisionBall[1].distance-_value-_radius,5),cc.c4f(1.0, 1.0, 1.0, 1.0))
    else
        --print("Route Detection result is collided with wall")
        local _value,isWidth = help.checkCollisionPointBetweenLines(rotate,_whitePos,_radius)
        _circle:drawCircle(cc.p(self.desk_main:getContentSize().width/2+3.5+_value,5),
        self.whiteBall:getContentSize().width/2 * ballScale,math.pi/2,50,false,1.0,1.0,cc.c4f(1.0, 1.0, 1.0, 1.0))
        self.line:clear()
        self.line:drawSegment(cc.p(self.cue:convertToNodeSpace(cc.p(self.cue:getPosition()))),
        cc.p(self.desk_main:getContentSize().width/2+3.5+_value-_radius,5),1,cc.c4f(1.0, 1.0, 1.0, 1.0))
    end
end

-- 击打白球
function gameBilliardsMainLayer:giveBallAPower(_forcePercent)
    -- print("cvdsvjsodvjmds=",self.cue:getChildByTag(51):getPositionX(),self.cue:getChildByTag(51):getPositionY())
    local cuePos = self.cue:convertToWorldSpace(cc.p(self.cue:getChildByTag(51):getPositionX(), self.cue:getChildByTag(51):getPositionY()))
    local ballPosX, ballPosY = self.whiteBall:getPosition()
    print("x,y = ", ballPosX - cuePos.x, ballPosY - cuePos.y)
    self.whiteBall:getPhysicsBody():setVelocity(cc.p((ballPosX - cuePos.x) * lineSpeedRatio * _forcePercent,(ballPosY - cuePos.y) * lineSpeedRatio * _forcePercent))

    -- self.whiteBall:getPhysicsBody():applyImpulse(cc.p((ballPosX - cuePos.x) * lineForceRatio,(ballPosY - cuePos.y) * lineForceRatio), cc.p(0, 0))
    print("rotateY = ",m_rotateX,m_rotateY)
    self.whiteBall:getPhysicsBody():applyForce(cc.p(((ballPosX-cuePos.x) * rotateForceRatio * _forcePercent*m_rotateY),
    ((ballPosY-cuePos.y) * rotateForceRatio * _forcePercent*m_rotateY)), cc.p(0, 0))
    self.whiteBall:getPhysicsBody():setAngularVelocity(leftRightForceRatio*m_rotateX)
    -- self.whiteBall:getPhysicsBody():applyForce(cc.p(300000, 0), cc.p(0, 0))
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create( function()
        if self.whiteBall and not tolua.isnull(self.whiteBall) and self.whiteBall.getPhysicsBody then
            self.whiteBall:getPhysicsBody():resetForces()
        end
    end )))
    m_rotateX = 0 m_rotateY = 0
    self.cue:setVisible(false)
    self.cue:getChildByTag(g_Border_Tag.cueCheck):setPosition(cc.p(9999,9999))
    self.slider_force:setTouchEnabled(false)
    self:openTimeEntry()
    --这里注释暂停本地同步测试
    --self:openSynchronizeTimeEntry()
end

--球进了，移除进的球
--@nTag 球的tag
--@nNode 壁的tag
function gameBilliardsMainLayer:removeGoalBall(nTag, nNode)
    local _ball
    _ball = self.node:getChildByTag(nTag)
    if nNode and _ball then
        local ballPosX, ballPosY = _ball:getPosition()
        local nodePosX, nodePosY = nNode:getPosition()
        print("ball pos and border pos are ",ballPosX,ballPosY,nodePosX,nodePosY)
        _ball:runAction(cc.Sequence:create(cc.DelayTime:create(0), cc.CallFunc:create( function()
            _ball:getPhysicsBody():resetForces()
            _ball:getPhysicsBody():setVelocity(cc.p(0, 0))
            _ball:getPhysicsBody():setAngularVelocity(0)
            local sprite3d = _ball:getChildByTag(8)
            if sprite3D and sprite3D:getPhysicsObj() then
                sprite3D:getPhysicsObj():setAngularVelocity(cc.vec3(0.0, 0.0, 0.0))
            end

            _ball:runAction(cc.Spawn:create(cc.MoveTo:create(0.5, cc.p(nodePosX, nodePosY)),cc.ScaleTo:create(0.5,0.15), cc.CallFunc:create( function()
                if sprite3D and sprite3D:getPhysicsObj() then
                    sprite3D:getPhysicsObj():setAngularVelocity(cc.vec3(-(nodePosY - ballPosY)/ballRollingRate/10,(nodePosX - ballPosX)/ballRollingRate/10, 0.0))
                end
            end )))

            _ball:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
                if _ball and not tolua.isnull(_ball) then
                    if _ball:getTag() == 0 then
                        tool.openNetTips("白球进洞了傻逼")
                    elseif _ball:getTag() == 8 then
                        tool.openNetTips("黑八进啦，比赛结束了傻逼")
                    end
                    _ball:removeFromParent()
                    _ball = nil
                end
            end )))
        end )))
    end
    --    local _ball
    --    _ball = self.node:getChildByTag(nTag)
    --    if _ball and not tolua.isnull(_ball) then
    --        _ball:removeFromParent()
    --        _ball = nil
    --    end
    --    if nTag == nBall_white then
    --        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create( function() self:resetBall()
    --        self.cue:setPosition(cc.p(self.whiteBall:getPosition())) end)))
    --        tool.openNetTips("白球进洞了傻逼")
    --        return
    --    elseif nTag == nBall_8 then
    --        self:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create( function() self:resetBall()
    --        self.cue:setPosition(cc.p(self.whiteBall:getPosition())) end)))
    --        tool.openNetTips("黑八进啦，比赛结束了傻逼")
    --        return
    --    end
end

-- 所有球体置回原位
function gameBilliardsMainLayer:resetBall()
    for i=nBall_white,nBall_15 do
        local _ball = self.node:getChildByTag(i)
        if _ball then
            print(i)
            _ball:removeFromParent()
            _ball = nil
        end
    end
    m_firstCollisionBall = -1
    self:initWhiteBallPhysical()
    self:initOtherBallPhysical()
    self:closeTimeEntry()
    self:closeSynchronizeTimeEntry()
    --ballMgr:setBallProcess({})
    ballMgr:setBallState({})
    self.cue:setVisible(true)
    self.cue:getChildByTag(g_Border_Tag.cueCheck):setPosition((self.cue:convertToNodeSpace(cc.p(self.cue:getPosition()))))
    self.cue:getChildByTag(g_Border_Tag.cueCheck):setPositionX(self.cue:getChildByTag(g_Border_Tag.cueCheck):getPositionX()+self.desk_main:getContentSize().width/2)
    self.cue:setRotation(0)
    self.cue:setPosition(cc.p(self.whiteBall:getPosition()))
    self.slider_force:setTouchEnabled(true)
end

--测试按钮
function gameBilliardsMainLayer:testButton()
    --self:giveBallAPower(0.5)

--    local _multiple = math.random(0,11)
--    for i=0,nBall_15 do
--        local ball = self.node:getChildByTag(i)
--        if ball then
--            local msp = ball:getChildByTag(8)
--            if msp then
--                local _action = msp:getActionByTag(5)
--                if _action then
--                    print("=-==============",_multiple*180,_action:getCurrentFrame()%180)
--                    _action:gotoFrameAndPlay(_multiple*180, _multiple*180+179, _action:getCurrentFrame()%180+_multiple*180, true)
--                end
--            end
--        end
--    end
    
    self.whiteBall:getPhysicsBody():setVelocity(cc.p(-150,100))
end

--打开加塞界面
function gameBilliardsMainLayer:openPullBallLayer()
    display.getRunningScene():addChild(require("gameBilliards.app.layer.gamebilliardsWhiteBallLayer").new(self))
end

--充值刚体组件的状态
function gameBilliardsMainLayer:resetPhysicalState(rigidBody)
    rigidBody:getPhysicsBody():resetForces()
    rigidBody:getPhysicsBody():setVelocity(cc.p(0,0))
    rigidBody:getPhysicsBody():setAngularVelocity(0)
end

--设置加塞的状态
function gameBilliardsMainLayer:setPullNum(_x,_y)
    print("setPullNum",_x,_y)
    m_rotateX = _x
    m_rotateY = _y
end

--------------------------------------------------------   ↓   下面全是监听事件   ↓    --------------------------------------------------------

function gameBilliardsMainLayer:btnCallback(sender, eventType)
    local nTag = sender:getTag()
    if eventType == TOUCH_EVENT_BEGAN then
        print("eventType == TOUCH_EVENT_BEGAN")
    elseif eventType == TOUCH_EVENT_ENDED then
        print("eventType == TOUCH_EVENT_ENDED")
        if nTag == nBtn_Test then
            print("this is a test button click",m_rotateX,m_rotateY)
            self:testButton()
        elseif nTag == nBtn_Reset then
            self:resetBall()
        elseif nTag == nPanel_Pull then
            self:openPullBallLayer()
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        print("eventType == TOUCH_EVENT_MOVED")
    elseif eventType == TOUCH_EVENT_CANCELED then
        print("eventType == TOUCH_EVENT_CANCELED")
    end
end

--碰撞检测的监听事件设置
function gameBilliardsMainLayer:initCheckCollisionListener()
local function onContactBegin(contact)
    -- print("collision listener result that 2 tag are = ", contact:getShapeA():getBody():getNode():getTag(), contact:getShapeB():getBody():getNode():getTag())
    local tagA = contact:getShapeA():getBody():getNode():getTag()
    local tagB = contact:getShapeB():getBody():getNode():getTag()

    if tagA == 0 or tagB == 0 then
        print("a white ball is collided")
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create( function()
            if self.whiteBall and not tolua.isnull(self.whiteBall) then
                self.whiteBall:getPhysicsBody():resetForces()
            end
        end )))
    end
    if tagA == 200 and tagB <= 15 then
        print("a ball is goaled that tag = : ", tagB)
        self:removeGoalBall(tagB,contact:getShapeA():getBody():getNode())
    elseif tagB == 200 and tagA <= 15 then
        print("a ball is goaled that tag = : ", tagA)
        self:removeGoalBall(tagA,contact:getShapeB():getBody():getNode())
    end
    return true
end
    local function onContactEnd(contact)
        self:refreshBallAni(true)
    end
    local contactListener = cc.EventListenerPhysicsContact:create()
    contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    contactListener:registerScriptHandler(onContactEnd, cc.Handler.EVENT_PHYSICS_CONTACT_SEPARATE)
    local eventDispatcher = self.node:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self.node)
end

--杆子的旋转监听事件
function gameBilliardsMainLayer:setCueRotateCueListener()
    local onBegan = function(touch, event) return self:onTouchBegan(touch, event) end
    local onMoved = function(touch, event) self:onTouchMoved(touch, event) end
    local onEnded = function(touch, event) self:onTouchEnded(touch, event) end

    self.listenerCueRotate = cc.EventListenerTouchOneByOne:create()
    self.listenerCueRotate:registerScriptHandler(onBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.listenerCueRotate:registerScriptHandler(onMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.listenerCueRotate:registerScriptHandler(onEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.eventDispatcher = self:getEventDispatcher()
    self.eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerCueRotate, self)
end

local curBatPosY = 0
function gameBilliardsMainLayer:onTouchBegan(touch,event)
    local rect = self.slicer_FineTurning:getBoundingBox()
    local curPos = self.node:convertToNodeSpace(touch:getLocation())
    if cc.rectContainsPoint(rect, cc.p(curPos.x, curPos.y)) then
        curBatPosY = self.panel_FineTurning:convertToNodeSpace(curPos).y
        return true
    end
    self:setCuePosByTouch(touch:getLocation(),true)
    return true
end

function gameBilliardsMainLayer:onTouchEnded(touch,event)
    local rect = self.slicer_FineTurning:getBoundingBox()
    local curPos = self.node:convertToNodeSpace(touch:getLocation())
    if cc.rectContainsPoint(rect, cc.p(curPos.x, curPos.y)) then
        return true
    end
    if curBatPosY == 0 then
        self:setCuePosByTouch(touch:getLocation(),false,true)
    end
    curBatPosY = 0
end

function gameBilliardsMainLayer:onTouchMoved(touch, event)
    local rect = self.slicer_FineTurning:getBoundingBox()
    local curPos = self.node:convertToNodeSpace(touch:getLocation())
    if cc.rectContainsPoint(rect, cc.p(curPos.x, curPos.y)) then
        local _pos = self.panel_FineTurning:convertToNodeSpace(curPos)
        self.fineTurning_1:setPositionY(self.fineTurning_1:getPositionY()-curBatPosY+_pos.y)
        self.fineTurning_2:setPositionY(self.fineTurning_2:getPositionY()-curBatPosY+_pos.y)
        self:setCuePosByTouch(nil,false,false,(curBatPosY-_pos.y)/200)
        curBatPosY = ((self.fineTurning_1:getPositionY() > self.fineTurning_2:getPositionY()) and 
        {self.fineTurning_1:getPositionY()} or {self.fineTurning_2:getPositionY()})[1]
        return true
    end
    self:setCuePosByTouch(touch:getLocation())
end

--移除杆子旋转的监听事件
function gameBilliardsMainLayer:removeCueRotateCueListener()
    if self.eventDispatcher and self.listenerCueRotate then
        self.eventDispatcher:removeEventListener(self.listenerCueRotate)
        self.eventDispatcher = nil
    end
end

--移动白球sprite的监听事件设置
function gameBilliardsMainLayer:setMoveWhiteBallListener()
    local function onTouchWhiteBallBegan(touch, event)
        -- 不要忘了return true  否则你懂的（事件不能响应）
        print("onTouchBegan")
        return true
    end
    local function onTouchWhiteBallEnded(touch, event)
        print("onTouchEnded")
    end
    local function onTouchWhiteBallMoved(touch, event)
        print("onTouchMoved")
        local target = event:getCurrentTarget()
        local locationInNode = target:convertToNodeSpace(touch:getLocation())
        local s = target:getContentSize()
        local rect = cc.rect(-s.width*3, -s.height*3, s.width*6, s.height*6)
        if cc.rectContainsPoint(rect, locationInNode) then
            local target = event:getCurrentTarget()
            -- 获取当前的控件
            --print("onTouchMoved : getCurrentTarget = ", target:getTag())
            local posX, posY = target:getPosition()
            -- 获取当前的位置
            local delta = touch:getDelta()
            -- 获取滑动的距离
            target:setPosition(cc.p(posX + delta.x, posY + delta.y))
            -- 给精灵重新设置位置
        end
    end
    self.listenerWhiteBallMove = cc.EventListenerTouchOneByOne:create()
    -- 创建一个单点事件监听
    self.listenerWhiteBallMove:setSwallowTouches(true)
    -- 是否向下传递
    self.listenerWhiteBallMove:registerScriptHandler(onTouchWhiteBallBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    self.listenerWhiteBallMove:registerScriptHandler(onTouchWhiteBallMoved, cc.Handler.EVENT_TOUCH_MOVED)
    self.listenerWhiteBallMove:registerScriptHandler(onTouchWhiteBallEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.eventDispatcher = self:getEventDispatcher()
    self.eventDispatcher:addEventListenerWithSceneGraphPriority(self.listenerWhiteBallMove, self.whiteBall)
    -- 分发监听事件
end

-- 移除白球精灵移动事件
function gameBilliardsMainLayer:removMoveeWhiteBallListener()
    if self.eventDispatcher then
        self.eventDispatcher:removeEventListener(self.listenerWhiteBallMove)
        self.eventDispatcher = nil
    end
end

function gameBilliardsMainLayer:registerTouchHandler()
    local function eventHandler(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(eventHandler)
--    local listener = cc.EventListenerTouchOneByOne:create()
--    listener:setSwallowTouches(true)
--    listener:registerScriptHandler( function() return true end, cc.Handler.EVENT_TOUCH_BEGAN)
--    listener:registerScriptHandler( function() end, cc.Handler.EVENT_TOUCH_MOVED)
--    listener:registerScriptHandler( function() end, cc.Handler.EVENT_TOUCH_ENDED)
--    local eventDispatcher = self:getEventDispatcher()
--    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

--帧同步定时器，加入数组
function gameBilliardsMainLayer:openSynchronizeTimeEntry()
    local function synchronizeUpdate(dt)
        local _ballProcessArray = ballMgr:getBallProcess()
        if #_ballProcessArray == 0 or next(_ballProcessArray) == nil then
            local _ballState = { { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, { }, }
            for i = 1, 16 do
                local _ball = self.node:getChildByTag(i - 1)
                if _ball then
                    local _velocity = _ball:getPhysicsBody():getVelocity()
                    local _positionX, _positionY = _ball:getPosition()
                    local _angularVelocity = _ball:getPhysicsBody():getAngularVelocity()
                    _ballState[i].tag = i - 1
                    _ballState[i].velocityX = _velocity.x
                    _ballState[i].velocityY = _velocity.y
                    _ballState[i].positionX = _positionX
                    _ballState[i].positionY = _positionY
                    _ballState[i].angularVelocity  = _angularVelocity
                end
            end
            ballMgr:insertBallState(_ballState)
        else
            for i = 1, 16 do
                local _ball = self.node:getChildByTag(i - 1)
                if _ball then
                    _ball:setPosition(cc.p(_ballProcessArray[1][i].positionX, _ballProcessArray[1][i].positionY))
                    _ball:getPhysicsBody():setVelocity(cc.p(_ballProcessArray[1][i].velocityX, _ballProcessArray[1][i].velocityY))
                    _ball:getPhysicsBody():setAngularVelocity(_ballProcessArray[1][i].angularVelocity)
                end
            end
            table.remove(_ballProcessArray, 1)
            if #_ballProcessArray == 0 or next(_ballProcessArray) == nil then
                self:closeSynchronizeTimeEntry()
            end
        end
    end
    self.synchronizeEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(synchronizeUpdate, g_NetSynchronization_Rate, false)
end

--关闭帧同步定时器
function gameBilliardsMainLayer:closeSynchronizeTimeEntry()
    if self.synchronizeEntry then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.synchronizeEntry)
        self.synchronizeEntry = nil
    end
end

-- 开启定时器(检测球是否已停止运动)
function gameBilliardsMainLayer:openTimeEntry()
    -- 检测16个球是否都停止运动了
    local function checkCueVisibleState(dt)
        local isCueVisible = false  --杆子是否显示
        for i = nBall_white, nBall_15 do
            local _ball = self.node:getChildByTag(i)
            if _ball then
                --print("the state of ball is = ",_ball:getPhysicsBody():getVelocity().x,_ball:getPhysicsBody():getVelocity().y,i)
                if math.abs(_ball:getPhysicsBody():getVelocity().x) > g_Velocity_Limit and math.abs(_ball:getPhysicsBody():getVelocity().y) > g_Velocity_Limit then
                    isCueVisible = true
                elseif math.abs(_ball:getPhysicsBody():getVelocity().x) <= g_Velocity_Limit and math.abs(_ball:getPhysicsBody():getVelocity().y) <= g_Velocity_Limit then
                    --print("stop the ball because of low speed",_ball:getPhysicsBody():getVelocity().x,_ball:getPhysicsBody():getVelocity().y,_ball:getTag())
                    _ball:getPhysicsBody():setVelocity(cc.p(0, 0))
                    _ball:getPhysicsBody():setAngularVelocity(0)
                    local sprite3D = _ball:getChildByTag(8)
                    if sprite3D and sprite3D:getPhysicsObj() then
                        sprite3D:getPhysicsObj():setAngularVelocity(cc.vec3(0.0,0.0,0.0))
                    end
                end
            end
        end
        if not isCueVisible then
            print("all of the balls are stopped")
            ballMgr:setBallProcess(ballMgr:getBallState())
            ballMgr:setBallState({})

            --输出数组测试
            --dump(ballMgr:getBallProcess())

            for i = nBall_white, nBall_15 do
                local _ball = self.node:getChildByTag(i)
                if _ball then
                    _ball:getPhysicsBody():setVelocity(cc.p(0, 0))
                    _ball:getPhysicsBody():setAngularVelocity(0)
                    _ball:setRotation(_ball:getRotation())
                end
            end
            local ball
            while true do
                --选择下一个合适的球打
                local _ball = self.node:getChildByTag(math.random(1,15))
                if _ball then
                    ball = _ball
                    break
                end
            end
            self:closeTimeEntry()  --关闭检测球停止定时器

            --关闭帧同步定时器
            self:closeSynchronizeTimeEntry()

            --print("the choosen ball's tag is ",ball:getTag(),ball:getPositionX(),ball:getPositionY())
            self:setCuePosByTouch(cc.p(ball:getPosition()),true)
            self.cue:setVisible(true)
            self.cue:getChildByTag(g_Border_Tag.cueCheck):setPosition((self.cue:convertToNodeSpace(cc.p(self.cue:getPosition()))))
            self.cue:getChildByTag(g_Border_Tag.cueCheck):setPositionX(self.cue:getChildByTag(g_Border_Tag.cueCheck):getPositionX()+self.desk_main:getContentSize().width/2)
            self.slider_force:setTouchEnabled(true)
        end
    end
    m_ballMoveScheduler = CCDirector:getInstance():getScheduler()
    m_ballMoveSchedulerEntry = m_ballMoveScheduler:scheduleScriptFunc(checkCueVisibleState, 0.3, false)
end

-- 关闭计时器
function gameBilliardsMainLayer:closeTimeEntry()
    if m_ballMoveScheduler or m_ballMoveSchedulerEntry then
        m_ballMoveScheduler:unscheduleScriptEntry(m_ballMoveSchedulerEntry)
        m_ballMoveScheduler = nil
        m_ballMoveSchedulerEntry = nil
    end
end

function gameBilliardsMainLayer:setPhysical3DView()
    --self.camera_Default = cc.Director:getInstance():getRunningScene():getDefaultCamera()
    local zeye = cc.Director:getInstance():getZEye()
    self._physicsScene = cc.Director:getInstance():getRunningScene()
    local winSize = cc.Director:getInstance():getWinSize()
    local physics3DWorld = self._physicsScene:getPhysics3DWorld()
    physics3DWorld:setDebugDrawEnable(isDebug)
    physics3DWorld:setGravity(cc.vec3(0.0,0.0,0.0))
    --self._camera = cc.Camera:createPerspective(60, winSize.width/winSize.height, 10.0, zeye + winSize.height/2.0)
    self._camera = cc.Camera:createOrthographic(winSize.width, winSize.height, -100.0, 100.0)
    self._camera:setDepth(4.0)
    self._camera:setPosition3D(cc.vec3(0.0,0.0,0.0))
    --self._camera:lookAt(cc.vec3(winSize.width/2, winSize.height/2, 0.0), cc.vec3(0.0, 1.0, 0.0))
    self._camera:setCameraFlag(cc.CameraFlag.USER2)
    self:addChild(self._camera)
    self._physicsScene:setPhysics3DDebugCamera(self._camera)
end

local m_time = 0  --记录一下时间
local m_count = 0  --这一秒跑了多少次
function gameBilliardsMainLayer:onEnter()
    self:setPhysical3DView()
    -- 物理设置
    if isDebug then cc.Director:getInstance():getRunningScene():getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL) end
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setGravity(cc.p(0, 0))
    --self:setCameraMask(2)
    -- 解决刚体穿透问题
    local function physicsFixedUpdate(delta)
        for i = 1, freshCount do
            cc.Director:getInstance():getRunningScene():getPhysicsWorld():step(1 / screenRefreshRate)
        end
        self:refreshBallAni()
    end
    cc.Director:getInstance():getRunningScene():getPhysicsWorld():setAutoStep(false)
    self.node:scheduleUpdateWithPriorityLua(physicsFixedUpdate, 0)
    print("gameBilliardsMainLayer:onEnter()")
end

function gameBilliardsMainLayer:onExit()
    print("gameBilliardsMainLayer:onExit()")
end

return gameBilliardsMainLayer