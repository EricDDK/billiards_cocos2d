local Ball3DRender = class("Ball3DRender")

function Ball3DRender.new(nTag, rootBall)
    local rbDes = { }
    rbDes.disableSleep = true
    rbDes.mass = 1.0
    rbDes.shape = cc.Physics3DShape:createSphere(0)
    Ball3DRender = cc.PhysicsSprite3D:create("gameBilliards/3d_ball/ball.c3b", rbDes)
    if Ball3DRender then
        local rigidBody = cc.Physics3DRigidBody:create(rbDes)
        local component = cc.Physics3DComponent:create(rigidBody)
        Ball3DRender:setTexture("gameBilliards/3d_ball/" .. nTag .. ".png")
        Ball3DRender:setTag(g_EightBallData.g_Border_Tag.texture3D)
        Ball3DRender:setScale((rootBall:getContentSize().width / 2) / g_EightBallData.radius_3D)
        Ball3DRender:setCameraMask(cc.CameraFlag.USER2)
        Ball3DRender:setGlobalZOrder(0 - nTag)
        -- 这里如果想要真实台球摆放位置，用random设置角度
        -- Ball3DRender:setRotation3D(cc.vec3(0.0,0.0,0.0))
        Ball3DRender:setRotation3D(cc.vec3(math.random(0, 180), math.random(0, 180), math.random(0, 180)))
        rigidBody:setAngularVelocity(cc.vec3(0.0, 0.0, 0.0))
    end
    return Ball3DRender
end

return Ball3DRender

--local rbDes = { }
--rbDes.disableSleep = true
--rbDes.mass = 1.0
--rbDes.shape = cc.Physics3DShape:createSphere(0)
--local Ball3DRender = class("Ball3DRender",
--function()
--    return cc.PhysicsSprite3D:create("gameBilliards/3d_ball/ball.c3b", rbDes)
--end )

----调整3D滚动效果
----@母体速度
----@母体角速度
--function Ball3DRender:adjust3DRolling(velocity,angularVelocity)
--    if self then
--        local rigidBody = self:getPhysicsObj()
--        if rigidBody then
--            rigidBody:setAngularVelocity(cc.vec3(- velocity.y / g_EightBallData.ballRollingRate, velocity.x / g_EightBallData.ballRollingRate, angularVelocity / g_EightBallData.ballRollingRate))
--        end
--    end
--end

---- 渲染3D
----@tag
----@母体球
--function Ball3DRender:ctor(nTag, rootBall)
--    local rigidBody = cc.Physics3DRigidBody:create(rbDes)
--    local component = cc.Physics3DComponent:create(rigidBody)
--    self:setTexture("gameBilliards/3d_ball/" .. nTag .. ".png")
--    self:setTag(g_EightBallData.g_Border_Tag.texture3D)
--    self:setScale((rootBall:getContentSize().width / 2) / g_EightBallData.radius_3D)
--    self:setCameraMask(cc.CameraFlag.USER2)
--    self:setGlobalZOrder(0-nTag)
--    --这里如果想要真实台球摆放位置，用random设置角度
--    --self:setRotation3D(cc.vec3(0.0,0.0,0.0))
--    self:setRotation3D(cc.vec3(math.random(0, 180), math.random(0, 180), math.random(0, 180)))
--    rigidBody:setAngularVelocity(cc.vec3(0.0, 0.0, 0.0))
--end

--return Ball3DRender