--
-- 球的基类，可拓展,将来公用函数可以移到这
-- 二次封装,易错函数
-- author ding
--
local BallBase = class("BallBase", function() return cc.Sprite:createWithSpriteFrameName("eightBall_TransparentBall.png") end)

function BallBase:init()

end

--
-- 封装一些易错函数
--
function BallBase:setVelocity(...)
    self:getPhysicsBody():setVelocity(...)
end

function BallBase:getVelocity()
    return self:getPhysicsBody():getVelocity()
end

function BallBase:setAngularVelocity(...)
    self:getPhysicsBody():setAngularVelocity(...)
end

function BallBase:getAngularVelocity()
    return self:getPhysicsBody():getAngularVelocity()
end

function BallBase:resetForces()
    self:getPhysicsBody():resetForces()
end

function BallBase:setCategoryBitmask(...)
    self:getPhysicsBody():setCategoryBitmask(...)
end

function BallBase:setContactTestBitmask(...)
    self:getPhysicsBody():setContactTestBitmask(...)
end

function BallBase:setCollisionBitmask(...)
    self:getPhysicsBody():setCollisionBitmask(...)
end

function BallBase:setLinearDamping(...)
    self:getPhysicsBody():setLinearDamping(...)
end

function BallBase:setAngularDamping(...)
    self:getPhysicsBody():setAngularDamping(...)
end

return BallBase