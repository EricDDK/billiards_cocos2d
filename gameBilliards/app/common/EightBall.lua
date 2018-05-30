local BallBase = require("gameBilliards.app.common.BallBase")
local EightBall = class("EightBall", BallBase)

-- 调整高光
function EightBall:adjustHighLight()
    local _highLight = self:getChildByTag(g_EightBallData.g_Border_Tag.heighLight)
    if _highLight then
        local _rot = self:getRotation()
            _highLight:setRotation(360 - _rot)
    end
end

-- 调整速度，刷新,3D动画的刷新以及速度的刷新
function EightBall:adjustBallSpeed()
    local velocity = self:getPhysicsBody():getVelocity()
    local v = math.pow(velocity.x, 2) + math.pow(velocity.y, 2)
    if v <= g_EightBallData.ballDampingValue then
        self:getPhysicsBody():setLinearDamping(g_EightBallData.ballLinearDamping * g_EightBallData.ballLinearIncreaseMultiple)
        if v <= g_EightBallData.ballDoubleDampingValue then
            self:getPhysicsBody():setLinearDamping(g_EightBallData.ballLinearDamping * g_EightBallData.ballLinearIncreaseDoubleMultiple)
        end
    end
    if v ~= 0 then
        local Texture = self:getChildByTag(8)
        if Texture then
            Texture:adjust3DRolling(velocity,self:getPhysicsBody():getAngularVelocity())
        end
    end
end

-- 检测球是否速度足够小可以停止转动
function EightBall:checkIsStop()
    local _velocity = self:getPhysicsBody():getVelocity()
    if math.abs(_velocity.x) >= g_EightBallData.ballVelocityLimit
        or math.abs(_velocity.y) >= g_EightBallData.ballVelocityLimit then
        return false
    elseif math.abs(_velocity.x) < g_EightBallData.ballVelocityLimit
        and math.abs(_velocity.y) < g_EightBallData.ballVelocityLimit then
        return true
    end
    return nil
end

-- 球停止运动
function EightBall:resetForceAndEffect()
    self:getPhysicsBody():setVelocity(cc.p(0, 0))
    self:getPhysicsBody():setAngularVelocity(0)
    self:clearWhiteBallContinuesForce()

    local sprite3D = self:getChildByTag(8)
    if sprite3D and sprite3D:getPhysicsObj() then
        sprite3D:getPhysicsObj():setAngularVelocity(cc.vec3(0.0, 0.0, 0.0))
    end
    if self:getTag() == g_EightBallData.g_Border_Tag.whiteBall then
        local cueRotate = mathMgr:changeAngleTo0to360(self:getRotation())
        self:setRotation(cueRotate)
    end
    if self:getBallState() ~= g_EightBallData.ballState.inHole then
        self:setBallState(g_EightBallData.ballState.stop)
    end
end

-- 球进洞
function EightBall:ballGoInHole(nTag)
    self:setBallState(g_EightBallData.ballState.inHole)
end

-- 重置球
function EightBall:resetBallState()
    self:setScale(g_EightBallData.radius/(self:getContentSize().width/2))
    self:setBallState(g_EightBallData.ballState.stop)
    self:setRotation(0)
    if self:getTag() == 0 then
        local cue = self:getChildByTag(g_EightBallData.g_Border_Tag.cue)
        if cue then
            cue:setCueLineCircleVisible(true)
            EBGameControl:setCueRotationOwn(cue,0)
            cue:setPercent(0)
        end
    end
end

-- 构造函数
function EightBall:ctor(nTag)
    self:setTexture("gameBilliards/eightBall/eightBall_TransparentBall.png")
    self:setScale(g_EightBallData.radius/(self:getContentSize().width/2))
    self:setTag(nTag)
    --self:setGlobalZOrder(1002+nTag)
    if nTag == g_EightBallData.g_Border_Tag.whiteBall then
        self:setPhysicsBody(cc.PhysicsBody:createCircle(self:getContentSize().width / 2, g_EightBallData.whilteBallPhysicsMaterial))
    else
        self:setPhysicsBody(cc.PhysicsBody:createCircle(self:getContentSize().width / 2, g_EightBallData.ballPhysicsMaterial))
    end
    self:getPhysicsBody():setLinearDamping(g_EightBallData.ballLinearDamping)
    self:getPhysicsBody():setAngularDamping(g_EightBallData.ballAngularDamping)
    self:getPhysicsBody():setCategoryBitmask(0x01)
    self:getPhysicsBody():setContactTestBitmask(0x01)
    self:getPhysicsBody():setCollisionBitmask(0x03)
    self:loadEffect()
    self:setBallState(g_EightBallData.ballState.stop)
    self:set3DRender(nTag)  --加载3D shader球面
    --self:setRotation(90)  --测试用
    if nTag == g_EightBallData.g_Border_Tag.whiteBall then
        self:loadOtherCompernent()
    end
end

-- 加载其他组件(白球)
function EightBall:loadOtherCompernent()
    local radius = self:getContentSize().width/2
    local whiteShadow = cc.Sprite:create("gameBilliards/eightBall/eightBall_WhiteBall_BigCircle.png")
    whiteShadow:setTag(g_EightBallData.g_Border_Tag.whiteShadow)
    whiteShadow:setPosition(cc.p(radius,radius))
    whiteShadow:setVisible(false)
    self:addChild(whiteShadow)

    local whiteHand = cc.Sprite:create("gameBilliards/eightBall/eightBall_WhiteBall_Hand.png")
    whiteHand:setTag(g_EightBallData.g_Border_Tag.moveHand)
    whiteHand:setPosition(cc.p(radius,radius))
    whiteHand:setCameraMask(cc.CameraFlag.USER2)
    whiteHand:setGlobalZOrder(2001)
    whiteHand:setVisible(false)
    self:addChild(whiteHand)

    local forbidden = cc.Sprite:create("gameBilliards/eightBall/eightBall_ForbidSet_WhiteBall.png")
    forbidden:setTag(g_EightBallData.g_Border_Tag.forbidden)
    forbidden:setPosition(cc.p(radius,radius))
    forbidden:setCameraMask(cc.CameraFlag.USER2)
    forbidden:setVisible(false)
    forbidden:setGlobalZOrder(2000)
    self:addChild(forbidden)
end

-- 加载光影特效
function EightBall:loadEffect()
    local highLight = ccui.ImageView:create("gameBilliards/eightBall/eightBall_Ball_HighLight.png", UI_TEX_TYPE_LOCAL)
    highLight:setCascadeOpacityEnabled(false)
    highLight:setAnchorPoint(cc.p(0.5, 0.5))
    highLight:setScale(0.6)
    highLight:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    highLight:setCameraMask(cc.CameraFlag.USER2)
    highLight:setGlobalZOrder(2000)
    highLight:setTag(g_EightBallData.g_Border_Tag.heighLight)
    self:addChild(highLight)
    local shadow = ccui.ImageView:create("gameBilliards/eightBall/eightBall_Ball_Shadow.png", UI_TEX_TYPE_LOCAL)
    shadow:setCascadeOpacityEnabled(false)
    shadow:setScale(0.6)
    shadow:setAnchorPoint(cc.p(0.5, 0.5))
    shadow:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self:addChild(shadow)
end

-- 3D渲染球体
function EightBall:set3DRender(nTag)
    local effect = require("gameBilliards/app/common/Ball3DRender").new(nTag,self)
    effect:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
    self:addChild(effect)
end

-- 重置3D渲染位置
function EightBall:reset3DRender()
    
end

-- 白球触摸事件
-- ----------------------------------------------------------------------------
-- 
local oldWhiteBallPos = {}--保留初始白球位置,在放置错误位置时可以放置
--@ isReceive 是否是接受数据后调用的函数
--@ isLimitedPos 是否是开球的摆放球位置,限制开球区域
function EightBall:whiteBallTouchBegan(rootNode,posX,posY,isReceive,isLimitedPos)
    posX = GetPreciseDecimal(posX)
    posY = GetPreciseDecimal(posY)
    oldWhiteBallPos.x = posX
    oldWhiteBallPos.y = posY
    local cue = self:getChildByTag(g_EightBallData.g_Border_Tag.cue)
    local spriteLine = self:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    cue:setVisible(false)
    spriteLine:setVisible(false)
    self:getPhysicsBody():setCategoryBitmask(0x04)
    self:getPhysicsBody():setContactTestBitmask(0x04)
    self:getPhysicsBody():setCollisionBitmask(0x04)
end

--@ isReceive 是否是接受到移动白球消息的移动
function EightBall:whiteBallTouchEnded(rootNode,pos,isReceive,isLimitedPos)
    pos.x = GetPreciseDecimal(pos.x)
    pos.y = GetPreciseDecimal(pos.y)
    local cue = self:getChildByTag(g_EightBallData.g_Border_Tag.cue)
    local spriteLine = self:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    cue:setVisible(true)
    spriteLine:setVisible(true)
    cue:setRotationOwn(0,rootNode)
    self:getPhysicsBody():setCategoryBitmask(0x01)
    self:getPhysicsBody():setContactTestBitmask(0x01)
    self:getPhysicsBody():setCollisionBitmask(0x03)

    local whiteShadow = self:getChildByTag(g_EightBallData.g_Border_Tag.whiteShadow)
    whiteShadow:setVisible(false)
    local moveHand = self:getChildByTag(g_EightBallData.g_Border_Tag.moveHand)
    moveHand:setVisible(false)
    local forbidden = self:getChildByTag(g_EightBallData.g_Border_Tag.forbidden)
    forbidden:setVisible(false)

    if mathMgr:checkBallLocationIsLegal(rootNode,pos,self) then
        if isReceive then
            self:setPosition(cc.p(pos.x,pos.y))
        end
        if not isReceive then
            self:sendSetWhiteBallMessage(pos.x,pos.y,rootNode,true)
        end
        
    else
        print("============whiteBallTouchEnded============")
        self:setPosition(cc.p(oldWhiteBallPos.x,oldWhiteBallPos.y))
    end
end

--@ isReceive 是否是接受到移动白球消息的移动
function EightBall:whiteBallTouchMoved(rootNode,pos,isReceive,isLimitedPos)
    pos.x = GetPreciseDecimal(pos.x)
    pos.y = GetPreciseDecimal(pos.y)
    local whiteShadow = self:getChildByTag(g_EightBallData.g_Border_Tag.whiteShadow)
    whiteShadow:setVisible(true)
    local moveHand = self:getChildByTag(g_EightBallData.g_Border_Tag.moveHand)
    moveHand:setVisible(true)
    local forbidden = self:getChildByTag(g_EightBallData.g_Border_Tag.forbidden)
    forbidden:setVisible(false)
    self:getPhysicsBody():setCategoryBitmask(0x04)
    self:getPhysicsBody():setContactTestBitmask(0x04)
    self:getPhysicsBody():setCollisionBitmask(0x04)

    if mathMgr:checkBallLocationIsLegal(rootNode,pos,self) then
        if isReceive then
            self:setPosition(cc.p(pos.x,pos.y))
        end
--        if not isReceive then  --移动时候发不发送数据呢
--            self:sendSetWhiteBallMessage(pos.x,pos.y,rootNode)
--        end
        forbidden:setVisible(false)
    else
        forbidden:setVisible(true)
    end
end
-- ----------------------------------------------------------------------------

local mCanSendSetWhiteBallMessage = true
--  发送移动杆子消息(定时器，多少秒内发)
--@ angle 杆子旋转的角度
--@ rootNode 游戏场景layer
--@ isEnded 如果是触摸停止事件必然发送
function EightBall:sendSetWhiteBallMessage(posX,posY, rootNode,isEnded)
    if not self:getTag() == 0 then
        return
    end
    if mCanSendSetWhiteBallMessage or isEnded then
        local requestData = {
            fPositionX = tostring(posX),
            fPositionY = tostring(posY),
            UserID = player:getPlayerUserID()
        }
        dump(requestData)
        EBGameControl:requestEightBallCmd(g_EIGHTBALL_REG_SETWHITEBALL,requestData)
        rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(g_EightBallData.sendSetWhiteBallInterval), cc.CallFunc:create( function()
            mCanSendSetWhiteBallMessage = true
        end )))
        mCanSendSetWhiteBallMessage = false
    end
end

--  同步球信息(帧同步)
--@ event 球信息
--@ isResume 是否是断线重连
function EightBall:syncBallState(event,isResume)
    self:setPosition(cc.p(event.fPositionX,event.fPositionY))
    self:getPhysicsBody():setVelocity(cc.p(event.fVelocityX,event.fVelocityY))
    self:getPhysicsBody():setAngularVelocity(event.fAngularVelocity)
    if isResume then
        self:getPhysicsBody():applyForce(cc.p(event.fUnevenBarsForceX,event.fUnevenBarsForceY),cc.p(0,0))
    end
end

-- 获取球帧同步信息
function EightBall:getBallSyncState()
    local _positionX, _positionY = self:getPosition()
    local _velocity = self:getPhysicsBody():getVelocity()
    local _angularVelocity = self:getPhysicsBody():getAngularVelocity()
    local _unevenBarsForce = self:getWhiteBallContinuesForce()
    local _prickStrokeForce = cc.p(0.0, 0.0)
    -- 保留小数点后5位
    return {
        fPositionX = string.format("%.5f", _positionX),
        fPositionY = string.format("%.5f", _positionY),
        fVelocityX = string.format("%.5f", _velocity.x),
        fVelocityY = string.format("%.5f", _velocity.y),
        fAngularVelocity = string.format("%.5f", _angularVelocity),
        fUnevenBarsForceX = string.format("%.5f", _unevenBarsForce.x),
        fUnevenBarsForceY = string.format("%.5f", _unevenBarsForce.y),
        fPrickStrokeForceX = string.format("%.5f", _prickStrokeForce.x),
        fPrickStrokeForceY = string.format("%.5f", _prickStrokeForce.y),
    }
end

-- 收到服务器同步的结果消息，同步球的所有位置
function EightBall:setBallsResultState(event,rootNode)
    local posX = GetPreciseDecimal(event.fPositionX)
    local posY = GetPreciseDecimal(event.fPositionY)
    if self:getTag() == 0 then
        local rotate = GetPreciseDecimal(event.fAngularVelocity)
        self:setRotation(rotate)
        print("EightBall setBallsResultState  whiteBall rotation = ",rotate)
    end
    self:setPosition(cc.p(posX,posY))
end

--  获取球停止后的信息，在获取击球结果时使用
--@ fAngularVelocity 不是角速度
--@ 只有白球的fAngularVelocity，是当前白球的rotation角度，其他球还是0的角速度
function EightBall:getBallsResultState()
    local _positionX, _positionY = self:getPosition()
    local angularVelocity = 0
    if self:getTag() == 0 then
        angularVelocity = self:getRotation()
        print("EightBall:getBallsResultState() white ball rotation = ",angularVelocity)
    end
    --保留小数点后5位
    return {
        fPositionX = string.format("%.5f", _positionX),
        fPositionY = string.format("%.5f", _positionY),
        fVelocityX = string.format("%.5f", 0),
        fVelocityY = string.format("%.5f", 0),
        fAngularVelocity = string.format("%.5f", angularVelocity),
        fUnevenBarsForceX = string.format("%.5f", 0),
        fUnevenBarsForceY = string.format("%.5f", 0),
        fPrickStrokeForceX = string.format("%.5f", 0),
        fPrickStrokeForceY = string.format("%.5f", 0),
    }
end

-- 施加在白球上的持续的力
local whiteBallContinuesForce = cc.p(0,0)
function EightBall:setWhiteBallContinuesForce(event)
    if self:getTag() ~= 0 then
        return
    end
    whiteBallContinuesForce = event
end

function EightBall:getWhiteBallContinuesForce()
    return whiteBallContinuesForce
end

function EightBall:clearWhiteBallContinuesForce()
    whiteBallContinuesForce = cc.p(0,0)
end

-- 保存球状态
local ballState = g_EightBallData.ballState.stop
function EightBall:setBallState(args)
    ballState = args
end

function EightBall:getBallState()
    return ballState
end

-- 获取此球是否进洞
function EightBall:getIsInHole()
    return ballState == g_EightBallData.ballState.inHole
    or self:getPositionX() < 0 or self:getPositionX() > 968 
    or self:getPositionY() < 0 or self:getPositionY() > 547
end

return EightBall