local BallBase = require("gameBilliards.app.common.BallBase")
local EightBall = class("EightBall", BallBase)

-- 保存球状态
EightBall.mBallState = g_EightBallData.ballState.stop
-- 精确到小数第几位
local reservedDigits = "%.".. g_EightBallData.ReservedDigit .."f"

-- 调整高光
function EightBall:adjustHighLight()
    local _highLight = self:getChildByTag(g_EightBallData.g_Border_Tag.heighLight)
    if _highLight then
        local _rot = self:getRotation()
            _highLight:setRotation(360 - _rot)
    end
end

-- 调整速度，刷新,3D动画的刷新以及速度的刷新
--@nTime 这次击打的当前时间，也就是多少帧
function EightBall:adjustBallSpeed(nTime)
    local velocity = self:getPhysicsBody():getVelocity()
    local v = math.pow(velocity.x, 2) + math.pow(velocity.y, 2)
    if nTime and nTime > g_EightBallData.increaseVelocityTime then
        velocity = self:getPhysicsBody():getVelocity()
        v = math.pow(velocity.x, 2) + math.pow(velocity.y, 2)
        if v <= g_EightBallData.ballDampingValue then
            self:getPhysicsBody():setLinearDamping(g_EightBallData.ballLinearIncreaseMultiple)
            if v <= g_EightBallData.ballDoubleDampingValue then
                self:getPhysicsBody():setLinearDamping(g_EightBallData.ballLinearIncreaseDoubleMultiple)
            end
        end
    end
    if v ~= 0 then
        local Texture = self:getChildByTag(g_EightBallData.g_Border_Tag.texture3D)
        if Texture then
            --Texture:adjust3DRolling(velocity, self:getPhysicsBody():getAngularVelocity())
            local rigidBody = Texture:getPhysicsObj()
            if rigidBody then
                rigidBody:setAngularVelocity(cc.vec3(- velocity.y / g_EightBallData.ballRollingRate, velocity.x / g_EightBallData.ballRollingRate,
                self:getPhysicsBody():getAngularVelocity() / g_EightBallData.ballRollingRate))
            end
        end
    end
end

-- 检测球是否速度足够小可以停止转动
function EightBall:checkIsStop()
--    if self:getBallState() == g_EightBallData.ballState.stop then
--        return true
--    end
    local _velocity = self:getPhysicsBody():getVelocity()
    if math.abs(_velocity.x) >= g_EightBallData.ballVelocityLimit
        or math.abs(_velocity.y) >= g_EightBallData.ballVelocityLimit then
        return false
    elseif math.abs(_velocity.x) < g_EightBallData.ballVelocityLimit
        and math.abs(_velocity.y) < g_EightBallData.ballVelocityLimit then
        return true
    end
    return false
end

-- 球停止运动
function EightBall:resetForceAndEffect()
    self:getPhysicsBody():resetForces()
    self:getPhysicsBody():setVelocity(cc.p(0, 0))
    self:getPhysicsBody():setAngularVelocity(0)
    self:clearWhiteBallContinuesForce()

    local sprite3D = self:getChildByTag(g_EightBallData.g_Border_Tag.texture3D)
    if sprite3D and sprite3D:getPhysicsObj() then
        sprite3D:getPhysicsObj():setAngularVelocity(cc.vec3(0.0, 0.0, 0.0))
    end
    if self:getTag() == g_EightBallData.g_Border_Tag.whiteBall then
        local cueRotate = mathMgr:changeAngleTo0to360(self:getRotation())
        self:setRotationOwn(cueRotate)
    end
    self:setBallState(g_EightBallData.ballState.stop)
end

-- 处理白球上的指示符视图
--@ 放白球的手，禁止标志清除
function EightBall:clearWhiteBallView()
    local whiteShadow = self:getChildByTag(g_EightBallData.g_Border_Tag.whiteShadow)
    local moveHand = self:getChildByTag(g_EightBallData.g_Border_Tag.moveHand)
    local fobbiden = self:getChildByTag(g_EightBallData.g_Border_Tag.forbidden)
    if whiteShadow and moveHand and fobbiden then
        whiteShadow:setVisible(isVisible)
        moveHand:setVisible(isVisible)
        fobbiden:setVisible(isVisible)
    end
end

-- 处理白球进洞(显示白球白手放置图案)
function EightBall:dealWhiteBallInHole(rootNode)
    local whiteShadow = self:getChildByTag(g_EightBallData.g_Border_Tag.whiteShadow)
    -- local moveHand = self:getChildByTag(g_EightBallData.g_Border_Tag.moveHand)
    if whiteShadow then
        print("EightBall:dealWhiteBallInHole()   IsMyOperate = ",EightBallGameManager:returnIsMyOperate())
        if EightBallGameManager:returnIsMyOperate() then
            whiteShadow:setVisible(true)
        else
            whiteShadow:setVisible(false)
        end
    end
end

--处理白球进入袋子
--白球不走这流程
function EightBall:dealBallInBag()
    self:setScale(g_EightBallData.radius/(self:getContentSize().width/2))
    self:resetForceAndEffect()
    self:setBallState(g_EightBallData.ballState.inHole)
    self:setPosition(g_EightBallData.inBagPos)
    self:getPhysicsBody():applyForce(cc.p(-1000000, -1000000), cc.p(0, 0))
end

-- 重置球位置，状态，旋转角度归0
function EightBall:resetBallState()
    self:setScale(g_EightBallData.radius/(self:getContentSize().width/2))
    self:setRotationOwn(0)
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
    --self.mBallState = g_EightBallData.ballState.stop
    --self:setTexture("gameBilliards/eightBall/eightBall_TransparentBall.png")
    self:setScale(g_EightBallData.radius/(self:getContentSize().width/2))
    self:setTag(nTag)
    self:setVisible(false)
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
    self:setPosition(cc.p(nTag*40+1500,1500))
    self:setBallState(g_EightBallData.ballState.stop)
    self:set3DRender(nTag)  --加载3D shader球面
    self:setCameraMask(cc.CameraFlag.USER2)
    self:setGlobalZOrder(-1000)
    --self:setRotation(90)  --测试用
    if nTag == g_EightBallData.g_Border_Tag.whiteBall then
        self:loadOtherCompernent()
    else
        self:loadTipsEffect()
    end
end

-- 加载其他组件(白球)
function EightBall:loadOtherCompernent()
    local radius = self:getContentSize().width/2
    local whiteShadow = cc.Sprite:createWithSpriteFrameName("eightBall_WhiteBall_BigCircle.png")
    whiteShadow:setTag(g_EightBallData.g_Border_Tag.whiteShadow)
    whiteShadow:setPosition(cc.p(radius,radius))
    whiteShadow:setVisible(false)
    self:addChild(whiteShadow)

    local whiteHand = cc.Sprite:createWithSpriteFrameName("eightBall_WhiteBall_Hand.png")
    whiteHand:setTag(g_EightBallData.g_Border_Tag.moveHand)
    whiteHand:setPosition(cc.p(radius,radius))
    whiteHand:setCameraMask(cc.CameraFlag.USER2)
    whiteHand:setGlobalZOrder(2001)
    whiteHand:setVisible(false)
    self:addChild(whiteHand)

    local forbidden = cc.Sprite:createWithSpriteFrameName("eightBall_ForbidSet_WhiteBall.png")
    forbidden:setTag(g_EightBallData.g_Border_Tag.forbidden)
    forbidden:setPosition(cc.p(radius,radius))
    forbidden:setCameraMask(cc.CameraFlag.USER2)
    forbidden:setVisible(false)
    forbidden:setGlobalZOrder(2000)
    self:addChild(forbidden)
end

-- 加载光影特效
function EightBall:loadEffect()
    local highLight
    if self:getTag() == 0 then
        highLight = cc.Sprite:create("gameBilliards/eightBall/eightBall_WhiteBall_HighLight.png")
    else
        highLight = cc.Sprite:createWithSpriteFrameName("eightBall_Ball_HighLight.png")
    end
    if highLight then
        highLight:setCascadeOpacityEnabled(false)
        highLight:setAnchorPoint(cc.p(0.5, 0.5))
        highLight:setScale(0.6)
        highLight:setPosition(cc.p(self:getContentSize().width / 2, self:getContentSize().height / 2))
        highLight:setCameraMask(cc.CameraFlag.USER2)
        --highLight:setGlobalZOrder(0)
        highLight:setLocalZOrder(-100)
        highLight:setTag(g_EightBallData.g_Border_Tag.heighLight)
        self:addChild(highLight)
    end
    local shadow = ccui.ImageView:create("eightBall_Ball_Shadow.png", UI_TEX_TYPE_PLIST)
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

--tips事件，球体最下层的指示框，提醒玩家该不该打这个球
function EightBall:loadTipsEffect()
    if self:getBallState() ~= g_EightBallData.g_Border_Tag.inHole then
        local radius = self:getContentSize().width / 2
        local tips = cc.Sprite:createWithSpriteFrameName("eightBall_Tips.png")
        if tips then
            tips:setTag(g_EightBallData.g_Border_Tag.tips)
            tips:setPosition(cc.p(radius, radius))
            tips:setCascadeOpacityEnabled(true)
            tips:setOpacity(100)
            tips:setScale(0.5)
            self:addChild(tips)
        end
    end
end

function EightBall:startTipsEffect()
    if self.mBallState == g_EightBallData.ballState.inHole then
        return
    end
    local action1 = cc.ScaleTo:create(1, 1.2)
    local action2 = cc.ScaleTo:create(1, 0.6)
    local action = cc.RepeatForever:create(cc.Sequence:create(action1, action2))
    local tips = self:getChildByTag(g_EightBallData.g_Border_Tag.tips)
    if tips and not tolua.isnull(tips) then
        tips:runAction(action)
        tips:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.CallFunc:create(function ()
            if self and not tolua.isnull(self) then
                self:stopTipsEffect()
            end
        end)))
    end
end

function EightBall:stopTipsEffect()
    local tips = self:getChildByTag(g_EightBallData.g_Border_Tag.tips)
    if tips and not tolua.isnull(tips) then
        tips:stopAllActions()
        tips:setScale(0.5)
    end
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

    --这里复杂，如果不违法放置白球，发送当前合法位置消息
    --如果违法放置白球，检测是否是边界外，
    --边界外的停止在边界上
    --边界内的就是和其他球重合，立刻放回原位，再发送消息
    if mathMgr:checkBallLocationIsLegal(rootNode,pos,self) then
        if isReceive then
            self:setPosition(cc.p(pos.x,pos.y))
        end
        if not isReceive then
            print("=============")
            self:sendSetWhiteBallMessage(pos.x,pos.y,rootNode,true)
        end
    else
        self:sendSetWhiteBallMessage(self:getPositionX(),self:getPositionY(),rootNode,true)
        -- if mathMgr:checkBallLocationIsOut(rootNode, pos, self) then
        --     self:sendSetWhiteBallMessage(self:getPositionX(),self:getPositionY(),rootNode,true)
        -- else
        --     self:setPosition(cc.p(oldWhiteBallPos.x,oldWhiteBallPos.y))
        --     self:sendSetWhiteBallMessage(self:getPositionX(),self:getPositionY(),rootNode,true)
        -- end
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
    if not self:getTag() == 0 or EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        return
    end
    if EBGameControl:getGameState() == g_EightBallData.gameState.waiting and posX > g_EightBallData.whiteBallOriginalPos.x then
        posX = g_EightBallData.whiteBallOriginalPos.x
    end
    if mCanSendSetWhiteBallMessage or isEnded then
        local requestData = {
            fPositionX = tostring(posX),
            fPositionY = tostring(posY),
            UserID = player:getPlayerUserID(),
            GameRound = EightBallGameManager:getGameRound(),
        }
        --dump(requestData)
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
--    if event.fPositionX <= g_EightBallData.inBagPos.x then
--        return
--    end
    --解决球会从洞里同步出来
    if self:getBallState() == g_EightBallData.ballState.inHole and event.fPositionX > 0 then
        self:getPhysicsBody():resetForces()
    end
    self:setPosition(cc.p(event.fPositionX,event.fPositionY))
    self:getPhysicsBody():setVelocity(cc.p(event.fVelocityX,event.fVelocityY))
end

-- 获取球帧同步信息
function EightBall:getBallSyncState(syncArray)
    local _velocity = self:getPhysicsBody():getVelocity()
    local _positionX, _positionY = self:getPosition()

    -- if _velocity.x == 0 and _velocity.y == 0 then
    --     return
    -- end
    
--    if _positionX < g_EightBallData.inBagPos.x then
--        return
--    end

    -- local _angularVelocity = self:getPhysicsBody():getAngularVelocity()
    -- local _unevenBarsForce = self:getWhiteBallContinuesForce()
    -- local _prickStrokeForce = cc.p(0.0, 0.0)
    -- 保留小数点后5位
    table.insert(syncArray,{
        Tag = self:getTag(),
        fPositionX = string.format(reservedDigits, _positionX),
        fPositionY = string.format(reservedDigits, _positionY),
        fVelocityX = string.format(reservedDigits, _velocity.x),
        fVelocityY = string.format(reservedDigits, _velocity.y),
        -- fAngularVelocity = string.format("%.5f", _angularVelocity),
        -- fUnevenBarsForceX = string.format("%.5f", _unevenBarsForce.x),
        -- fUnevenBarsForceY = string.format("%.5f", _unevenBarsForce.y),
        -- fPrickStrokeForceX = string.format("%.5f", _prickStrokeForce.x),
        -- fPrickStrokeForceY = string.format("%.5f", _prickStrokeForce.y),
    })
end

-- 收到服务器同步的结果消息，同步球的所有位置
function EightBall:setBallsResultState(event,rootNode)
    local posX = GetPreciseDecimal(event.fPositionX)
    local posY = GetPreciseDecimal(event.fPositionY)
    if self:getTag() == 0 then
        local rotate = GetPreciseDecimal(event.fAngularVelocity)
        self:setRotationOwn(rotate)
    end
    self:setPosition(cc.p(posX,posY))
    self:getPhysicsBody():resetForces()
    self:getPhysicsBody():setVelocity(cc.p(0, 0))
end

--  获取球停止后的信息，在获取击球结果时使用
--@ fAngularVelocity 不是角速度
--@ 只有白球的fAngularVelocity，是当前白球的rotation角度，其他球还是0的角速度
function EightBall:getBallsResultState()
    local _positionX, _positionY = self:getPosition()
    local angularVelocity = 0
    if self:getTag() == g_EightBallData.g_Border_Tag.whiteBall then
        if self:getBallState() == g_EightBallData.ballState.inHole then
            _positionX = 1500
            _positionY = 1500
        end
        angularVelocity = self:getRotation()
    end
    --保留小数点后5位
    return {
        fPositionX = string.format(reservedDigits, _positionX),
        fPositionY = string.format(reservedDigits, _positionY),
        fVelocityX = string.format(reservedDigits, 0),
        fVelocityY = string.format(reservedDigits, 0),
        fAngularVelocity = string.format(reservedDigits, angularVelocity),
        fUnevenBarsForceX = string.format(reservedDigits, 0),
        fUnevenBarsForceY = string.format(reservedDigits, 0),
        fPrickStrokeForceX = string.format(reservedDigits, 0),
        fPrickStrokeForceY = string.format(reservedDigits, 0),
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

--持续力保存
function EightBall:getWhiteBallContinuesForce()
    return whiteBallContinuesForce
end

function EightBall:clearWhiteBallContinuesForce()
    whiteBallContinuesForce = cc.p(0,0)
end

-- 保存球状态
function EightBall:setBallState(args,m_MainLayer)
    self.mBallState = args
end

function EightBall:getBallState()
    return self.mBallState
end

-- 获取此球是否进洞
function EightBall:getIsInHole()
    if self:getPositionX() < 70 or self:getPositionX() > 910 or self:getPositionY() > 475 or self:getPositionY() < 70  then
        return true
    end
    return self:getBallState() == g_EightBallData.ballState.inHole
    and (self:getPositionX() < 70 or self:getPositionX() > 910 or self:getPositionY() > 475 or self:getPositionY() < 70 )
end

--通过位置判断是否进洞
function EightBall:setIsInHoleByPos(posX,posY)
    if posX < 70 or posY < 70 or posX > 910 or posY > 475 then
        self:setBallState(g_EightBallData.ballState.inHole)
    end
end

--封装一个
function EightBall:setRotationOwn(rotate)
    if not rotate then
        return
    end
    if rotate == 0 then
        rotate = 0.1
    end
    if self:getTag() == g_EightBallData.g_Border_Tag.whiteBall then
        self:setRotation(rotate)
        local whiteShadow = self:getChildByTag(g_EightBallData.g_Border_Tag.whiteShadow)
        local moveHand = self:getChildByTag(g_EightBallData.g_Border_Tag.moveHand)
        local forbidden = self:getChildByTag(g_EightBallData.g_Border_Tag.forbidden)
        if whiteShadow then
            whiteShadow:setRotation(360 - rotate)
        end
        if moveHand then
            moveHand:setRotation(360 - rotate)
        end
        if forbidden then
            forbidden:setRotation(360 - rotate)
        end
    else
        self:setRotation(rotate)
    end
end

return EightBall