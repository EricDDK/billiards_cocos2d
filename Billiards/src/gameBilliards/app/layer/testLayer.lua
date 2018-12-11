local AGameBase = require("AGameCommon.AGameBase")
local testLayer = class("testLayer",AGameBase)

function testLayer:ctor()
    self:registerTouchHandler()
end

function testLayer:initView()
    self:setPhysicalView()
    
    --self.model:setGlobalZOrder(1)

    --self.layer3D:setCameraMask(2)
end

function testLayer:setPhysicalView()
    
    self.camera_Default = cc.Director:getInstance():getRunningScene():getDefaultCamera()
    local zeye = cc.Director:getInstance():getZEye()

    self.bg = ccui.ImageView:create("gameBilliards/image/billiards_Bg.png", UI_TEX_TYPE_LOCAL)
    self.bg:setPosition(cc.p(display.cx, display.cy))
    self:addChild(self.bg)

    self.desk = cc.Sprite:create("gameBilliards/image/table.png")
    self.desk:setAnchorPoint(cc.p(0.5,0.5))
    self.desk:setPosition(display.center)
    self.bg:addChild(self.desk)

    self._physicsScene = cc.Director:getInstance():getRunningScene()
    local winSize = cc.Director:getInstance():getWinSize()
    local physics3DWorld = self._physicsScene:getPhysics3DWorld()
    physics3DWorld:setDebugDrawEnable(true)
    physics3DWorld:setGravity(cc.vec3(0.0,0.0,0.0))

    --self._camera = cc.Camera:createPerspective(60, winSize.width/winSize.height, 10.0, zeye + winSize.height/2.0)
    self._camera = cc.Camera:createOrthographic(winSize.width, winSize.height, -100.0, 100.0)
    self._camera:setDepth(4.0)
    self._camera:setPosition3D(cc.vec3(0.0,0.0,0.0))
    --self._camera:lookAt(cc.vec3(winSize.width/2, winSize.height/2, 0.0), cc.vec3(0.0, 1.0, 0.0))
    self._camera:setCameraFlag(cc.CameraFlag.USER2)
    self:addChild(self._camera)

    local s3d = cc.Sprite3D:create("gameBilliards/3d_ball/ball.obj")
    local rbDes = {}
    rbDes.disableSleep = true
    rbDes.mass = 1.0
    --rbDes.shape = cc.Physics3DShape:createSphere(s3d:getContentSize().width/2/3)
    rbDes.shape = cc.Physics3DShape:createSphere(s3d:getContentSize().width/2/3)
    local rigidBody = cc.Physics3DRigidBody:create(rbDes)
    local component = cc.Physics3DComponent:create(rigidBody)
--    local component = cc.Physics3DComponent:create(rigidBody)
    self.model = cc.Sprite3D:create("gameBilliards/3d/ball.obj")
    self.model:setTexture("gameBilliards/3d_ball/11.png")
    --self.model:setPosition3D(cc.vec3(winSize.width/2, winSize.height/2, 0.0))
    self.model:setPosition(cc.p(1136/2,640/2))
    self.model:setScale(1)
    self.model:addComponent(component)
    self.model:setCameraMask(cc.CameraFlag.USER2)
    self:addChild(self.model)
    --component:syncNodeToPhysics()
    --component:setSyncFlag(cc.Physics3DComponent.PhysicsSyncFlag.PHYSICS_TO_NODE)
    rigidBody:setAngularVelocity(cc.vec3(0,0,0))
    --rigidBody:setLinearVelocity(cc.vec3(0,3,0))

    self:setActionView()   --测试效果

    self._physicsScene:setPhysics3DDebugCamera(self._camera)
end

function testLayer:setActionView()
--    local action1 = cc.RotateBy:create(1, cc.vec3(0, -360, 0))
--    self.model:runAction(cc.RepeatForever:create(action1))
    --self.model:setRotation3D(cc.vec3(100,100,0))

--    local rigidBody = self.model:getPhysicsObj()
--    rigidBody:setLinearFactor(cc.vec3(1.0, 1.0, 1.0))
--    rigidBody:setLinearVelocity(cc.vec3(100,100,0))
--    rigidBody:setAngularVelocity(cc.vec3(0.0,10.0,10.0))


    --self.model:syncNodeToPhysics()
    --self.model:setSyncFlag(cc.Physics3DComponent.PhysicsSyncFlag.PHYSICS_TO_NODE)
end

function testLayer:registerTouchHandler()
    local function eventHandler(eventType)
        if eventType == "enter" then
            self:onEnter()
        elseif eventType == "exit" then
            self:onExit()
        end
    end
    self:registerScriptHandler(eventHandler)
end

function testLayer:onEnter()
    self:initView()
end

function testLayer:onExit()
    
end

return testLayer