local Cue = class("Cue", function() return cc.Sprite:create() end)

local m_RootBall

--杆子构造函数
--@_root 母球（这里是白球）
--构造函数传参，母球引用保留
function Cue:ctor(_root)
    m_RootBall = _root
    self:setTexture("gameBilliards/eightBall/eightBall_Cue.png")
    self:setAnchorPoint(1,0.5)
    self:setTag(g_EightBallData.g_Border_Tag.cue)
    local pos = _root:getContentSize().width/2
    self:setPosition(cc.p(pos,pos))
    _root:addChild(self)
    --标记点
    local spriteTag = cc.Sprite:create("gameBilliards/eightBall/eightBall_HighLowPole_RedPint.png")
    spriteTag:setTag(51)
    spriteTag:setAnchorPoint(cc.p(0.5,0.5))
    spriteTag:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    spriteTag:setVisible(false)
    self:addChild(spriteTag)
    --路径检测直线精灵
    local spriteLine = ccui.Scale9Sprite:create("gameBilliards/eightBall/eightBall_DrawLine.png")
    spriteLine:setAnchorPoint(cc.p(0,0.5))
    spriteLine:setCapInsets(cc.rect(1,1,spriteLine:getContentSize().width-2,spriteLine:getContentSize().height-2))
    spriteLine:setScale9Enabled(true)
    spriteLine:setContentSize(cc.size(1000,spriteLine:getContentSize().height))
    local pos = m_RootBall:getContentSize().width/2
    spriteLine:setPosition(pos,pos)
    spriteLine:setTag(g_EightBallData.g_Border_Tag.lineCheck)
    m_RootBall:addChild(spriteLine)

    local _borderWidth = 1136
    local _borderHeight = m_RootBall:getContentSize().width/2
    local cueCheckBorder = cc.DrawNode:create()
    cueCheckBorder:setTag(g_EightBallData.g_Border_Tag.cueCheck)
    cueCheckBorder:setAnchorPoint(cc.p(0.5,0.5))
    local _colorLine
    if g_EightBallData.isDebug then _colorLine = cc.c4f(0,0,0,0) else _colorLine = cc.c4f(0,0,0,0) end
    cueCheckBorder:drawRect(cc.p(-_borderWidth/2,-_borderHeight),cc.p(_borderWidth/2,_borderHeight),_colorLine)
    cueCheckBorder:setPosition(cc.p(_borderWidth/2,spriteLine:getContentSize().height/2))
    spriteLine:addChild(cueCheckBorder)

    local circleCheck = cc.Sprite:create("gameBilliards/eightBall/eightBall_DrawCircle.png")
    circleCheck:setTag(g_EightBallData.g_Border_Tag.circleCheck)
    circleCheck:setPosition(0,spriteLine:getContentSize().height/2)
    circleCheck:setVisible(false)
    spriteLine:addChild(circleCheck)

    local CircleShadow = cc.Sprite:create("gameBilliards/eightBall/eightBall_DrawCircle_Shadow.png")
    CircleShadow:setTag(g_EightBallData.g_Border_Tag.circleShadow)
    CircleShadow:setPosition(cc.p(pos,pos))
    circleCheck:addChild(CircleShadow)

    -------------------------------------------------------------
    self:setGlobalZOrder(1000)
    self:setCameraMask(cc.CameraFlag.USER2)
    --spriteLine:setGlobalZOrder(1000)  --测试用
    --spriteLine:setCameraMask(cc.CameraFlag.USER2)
    cueCheckBorder:setGlobalZOrder(1000)  --测试用
    cueCheckBorder:setCameraMask(cc.CameraFlag.USER2)
    circleCheck:setGlobalZOrder(1000)  --测试用
    circleCheck:setCameraMask(cc.CameraFlag.USER2)
    CircleShadow:setGlobalZOrder(1000)  --测试用
    CircleShadow:setCameraMask(cc.CameraFlag.USER2)
    -------------------------------------------------------------

    mCanSendSetCueMessage = true  --重置成员函数
end

function Cue:setCircleByLegal(isLegal)
    if not isLegal then
        m_RootBall:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck):getChildByTag(g_EightBallData.g_Border_Tag.circleCheck)
        :getChildByTag(g_EightBallData.g_Border_Tag.circleShadow):setTexture("gameBilliards/eightBall/eightBall_DrawCircle_Red.png")
        return
    end
    m_RootBall:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck):getChildByTag(g_EightBallData.g_Border_Tag.circleCheck)
    :getChildByTag(g_EightBallData.g_Border_Tag.circleShadow):setTexture("gameBilliards/eightBall/eightBall_DrawCircle_Shadow.png")
end

--重置杆前后位置
function Cue:resetPos()
    self:setCircleByLegal(true)
    local pos = m_RootBall:getContentSize().width/2
    self:setPosition(cc.p(pos,pos))
end

--设置力量百分比，杆子变化
--@_percent 百分比，要除以100
function Cue:setPercent(_percent)
    local cueRotate = mathMgr:changeAngleTo0to360(self:getRotation())
    self:setRotation(cueRotate)
    local length = _percent
    local posX,posY = mathMgr:getCuePosByRotate(cueRotate,_percent)
    local radius = m_RootBall:getContentSize().width/2
    self:setPosition(radius+posX,radius+posY)
end

--发射球
--@ _forcePercent 力量百分比
--@ rootNode 桌子
--@ rotateX 左右塞
--@ rotateY 高低杆
--@ other 其他的力，待加,预留
function Cue:launchBall(_forcePercent, rootNode, rotateX, rotateY, otherX, otherY)
    self:setCueLineCircleVisible(false)
    self:resetPos()
    _forcePercent = _forcePercent / 100
    local spriteTag = self:getChildByTag(51)
    local x, y = spriteTag:getPosition()
    local cuePos = self:convertToWorldSpace(cc.p(spriteTag:getPosition()))
    local ballPos = rootNode:convertToWorldSpace(cc.p(m_RootBall:getPosition()))
    local diffX,diffY = (ballPos.x - cuePos.x),(ballPos.y - cuePos.y)
--    print("launchBall cuePos = ", cuePos.x, cuePos.y)
--    print("launchBall ballPos = ", ballPos.x, ballPos.y)
    
    --练习模式
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        m_RootBall:getPhysicsBody():setVelocity(
        cc.p(
        diffX * g_EightBallData.lineSpeedRatio * _forcePercent,
        diffY * g_EightBallData.lineSpeedRatio * _forcePercent)
        )

        m_RootBall:getPhysicsBody():setAngularVelocity(g_EightBallData.leftRightForceRatio * rotateX)

        m_RootBall:getPhysicsBody():applyForce(
        cc.p(
        (diffX * g_EightBallData.rotateForceRatio * _forcePercent * rotateY),
        (diffY * g_EightBallData.rotateForceRatio * _forcePercent * rotateY)
        ), 
        cc.p(0, 0)
        )
    --比赛中
    else
        local percent = _forcePercent*100
        local ballPosX = m_RootBall:getPositionX()
        local ballPosY = m_RootBall:getPositionY()
        local velocityX =diffX * g_EightBallData.lineSpeedRatio * _forcePercent
        local velocityY =diffY * g_EightBallData.lineSpeedRatio * _forcePercent
        local angularVelocity = g_EightBallData.leftRightForceRatio * rotateX
        local unevenX =diffX * g_EightBallData.rotateForceRatio * _forcePercent * rotateY
        local unevenY =diffY * g_EightBallData.rotateForceRatio * _forcePercent * rotateY
        local prickStrokeX = 0.0
        local prickStrokeY = 0.0
        Cue:sendHitWhiteBallMessage(percent, ballPosX, ballPosY, velocityX, velocityY, angularVelocity, unevenX, unevenY, prickStrokeX, prickStrokeY)
    end
end

--接受到发射球消息
--@ event 服务器发来的力量数组
--@ callback 帧同步开始的回调函数,回到mainlayer开始帧同步发送与接受处理
function Cue:receiveLauchBall(event, callback)
    local function _hitWhiteBall()
        if self and not tolua.isnull(self) and m_RootBall and not tolua.isnull(m_RootBall) then
            self:setCueLineCircleVisible(false)
            self:resetPos()
            m_RootBall:setPosition(cc.p(event.fPositionX, event.fPositionY))
            m_RootBall:getPhysicsBody():setVelocity(cc.p(event.fVelocityX, event.fVelocityY))
            m_RootBall:getPhysicsBody():setAngularVelocity(event.fAngularVelocity)
            m_RootBall:getPhysicsBody():applyForce(cc.p(event.fUnevenBarsX, event.fUnevenBarsY), cc.p(0, 0))
            m_RootBall:setWhiteBallContinuesForce(cc.p(event.fUnevenBarsX, event.fUnevenBarsY))
            EightBallGameManager:playEffect(g_EightBallData.effect.cue)
            if callback then
                callback()-- 击球后就回调开始帧同步
            end
        end
    end
    -- 是我自己开的球立刻击球
    if event.UserID == player:getPlayerUserID() then
        _hitWhiteBall()
   -- 是对手击的球就播放动画，延迟击打，同步
    else
        self:stopAllActions()
        local cueRotate = mathMgr:changeAngleTo0to360(self:getRotation())
        self:setRotation(cueRotate)
        local posX, posY = mathMgr:getCuePosByRotate(cueRotate, event.Percent)
        local radius = m_RootBall:getContentSize().width / 2

        local func1 = cc.MoveTo:create(1, cc.p(radius + posX, radius + posY))
        local func2 = cc.CallFunc:create( function()
            _hitWhiteBall()
        end )
        self:runAction(cc.Sequence:create(func1, func2))
    end
end

--设置角度
--@rotate 旋转的角度
function Cue:setRotationOwn(rotate,rootNode)
    self:setRotation(rotate)
    local lineCheck = m_RootBall:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    if lineCheck then
        lineCheck:setRotation(rotate)
    end
    PhyControl:drawRouteDetection(rotate,self,m_RootBall,rootNode)
end

-- 设置瞄准线，杆，路径视图
-- 是否看得见瞄准线，圆球线，路径检测线
-- isVisible bool 是否看得见
function Cue:setCueLineCircleVisible(isVisible)
    local lineCheck = m_RootBall:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    if lineCheck then
        lineCheck:setVisible(isVisible)
    end
    self:setVisible(isVisible)
    self:setCircleByLegal(true)
end

local mCanSendSetCueMessage = true
--发送移动杆子消息(定时器，多少秒内发)
--@ angle 杆子旋转的角度
--@ rootNode 游戏场景layer
--@ isEnded 如果是触摸停止事件必然发送
function Cue:sendSetCueMessage(angle, rootNode,isEnded)
    if mCanSendSetCueMessage or isEnded then
        local requestData = {
            fAngle = tostring(angle),
            UserID = player:getPlayerUserID()
        }
        dump(requestData)
        EBGameControl:requestEightBallCmd(g_EIGHTBALL_REG_SETCUEINFO,requestData)
        rootNode:runAction(cc.Sequence:create(cc.DelayTime:create(g_EightBallData.sendSetCueInterval), cc.CallFunc:create( function()
            mCanSendSetCueMessage = true
        end )))
        mCanSendSetCueMessage = false
    end
end

--发送击球
--@ percent 力量百分比
--@ velocity 初速度
--@ angularVelocity 角速度
--@ uneven 高低杆，左右赛
--@ prickStroke 扎杆
function Cue:sendHitWhiteBallMessage(percent,ballPosX,ballPosY,velocityX,velocityY,angularVelocity,unevenX,unevenY,prickStrokeX,prickStrokeY)
    local requestData = {
        UserID = player:getPlayerUserID(),
        SeatID = dmgr:getPlayerSeatIDByUserID(UserID),
        Percent = percent,
        fPositionX = tostring(ballPosX),
        fPositionY = tostring(ballPosY),
        fVelocityX = tostring(velocityX),
        fVelocityY = tostring(velocityY),
        fUnevenBarsX = tostring(unevenX),
        fUnevenBarsY = tostring(unevenY),
        fPrickStrokeX = tostring(prickStrokeX),
        fPrickStrokeY = tostring(prickStrokeY),
        fAngularVelocity = tostring(angularVelocity),
    }
    EBGameControl:requestEightBallCmd(g_EIGHTBALL_REG_HITWHITEBALL,requestData)
end

return Cue