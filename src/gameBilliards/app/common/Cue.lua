local Cue = class("Cue", function() return cc.Sprite:createWithSpriteFrameName("eightBall_Cue.png") end)

local m_RootBall

--杆子构造函数
--@_root 母球（这里是白球）
--构造函数传参，母球引用保留
function Cue:ctor(_root)
    m_RootBall = _root
    self:setAnchorPoint(1,0.5)
    self:setTag(g_EightBallData.g_Border_Tag.cue)
    local pos = _root:getContentSize().width/2
    self:setPosition(cc.p(pos,pos))
    _root:addChild(self)
    --标记点
    local spriteTag = cc.Sprite:createWithSpriteFrameName("eightBall_HighLowPole_RedPint.png")
    spriteTag:setTag(51)
    spriteTag:setAnchorPoint(cc.p(0.5,0.5))
    spriteTag:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
    spriteTag:setVisible(false)
    self:addChild(spriteTag)
    --路径检测直线精灵
    self.spriteLine = ccui.Scale9Sprite:createWithSpriteFrameName("eightBall_DrawLine.png")
    self.spriteLine:setAnchorPoint(cc.p(0,0.5))
    self.spriteLine:setCapInsets(cc.rect(1,1,self.spriteLine:getContentSize().width-2,self.spriteLine:getContentSize().height-2))
    self.spriteLine:setScale9Enabled(true)
    self.spriteLine:setContentSize(cc.size(1000,self.spriteLine:getContentSize().height))
    local pos = m_RootBall:getContentSize().width/2
    self.spriteLine:setPosition(pos,pos)
    self.spriteLine:setTag(g_EightBallData.g_Border_Tag.lineCheck)
    m_RootBall:addChild(self.spriteLine)

    local _borderWidth = 1136
    local _borderHeight = m_RootBall:getContentSize().width/2
    local cueCheckBorder = cc.DrawNode:create()
    cueCheckBorder:setTag(g_EightBallData.g_Border_Tag.cueCheck)
    cueCheckBorder:setAnchorPoint(cc.p(0.5,0.5))
    local _colorLine
    if g_EightBallData.isDebug then _colorLine = cc.c4f(0,0,0,0) else _colorLine = cc.c4f(0,0,0,0) end
    cueCheckBorder:drawRect(cc.p(-_borderWidth/2,-_borderHeight),cc.p(_borderWidth/2,_borderHeight),_colorLine)
    cueCheckBorder:setPosition(cc.p(_borderWidth/2,self.spriteLine:getContentSize().height/2))
    self.spriteLine:addChild(cueCheckBorder)

    self.circleCheck = cc.Sprite:createWithSpriteFrameName("eightBall_DrawCircle.png")
    self.circleCheck:setTag(g_EightBallData.g_Border_Tag.circleCheck)
    self.circleCheck:setPosition(0,self.spriteLine:getContentSize().height/2)
    self.circleCheck:setVisible(false)
    self.spriteLine:addChild(self.circleCheck)

    self.CircleShadow = cc.Sprite:createWithSpriteFrameName("eightBall_DrawCircle_Shadow.png")
    self.CircleShadow:setTag(g_EightBallData.g_Border_Tag.circleShadow)
    self.CircleShadow:setPosition(cc.p(pos,pos))
    self.circleCheck:addChild(self.CircleShadow)

    self.whiteBallLine = ccui.Scale9Sprite:create("gameBilliards/eightBall/eightBall_ShortLine.png")
    self.whiteBallLine:setAnchorPoint(cc.p(0,0.5))
    self.whiteBallLine:setTag(g_EightBallData.g_Border_Tag.whiteBallLine)
    self.whiteBallLine:setPosition(self.spriteLine:getContentSize().width,self.spriteLine:getContentSize().height/2)
    self.spriteLine:addChild(self.whiteBallLine)

    self.colorBallLine = ccui.Scale9Sprite:create("gameBilliards/eightBall/eightBall_ShortLine.png")
    self.colorBallLine:setAnchorPoint(cc.p(0,0.5))
    self.colorBallLine:setTag(g_EightBallData.g_Border_Tag.colorBallLine)
    self.colorBallLine:setPosition(self.spriteLine:getContentSize().width,self.spriteLine:getContentSize().height/2)
    self.spriteLine:addChild(self.colorBallLine)

    -------------------------------------------------------------
    self:setGlobalZOrder(1000)
    self:setCameraMask(cc.CameraFlag.USER2)
    --self.spriteLine:setGlobalZOrder(1000)
    --self.spriteLine:setCameraMask(cc.CameraFlag.USER2)
    cueCheckBorder:setGlobalZOrder(1000)
    cueCheckBorder:setCameraMask(cc.CameraFlag.USER2)
    self.circleCheck:setGlobalZOrder(1000)
    self.circleCheck:setCameraMask(cc.CameraFlag.USER2)
    self.CircleShadow:setGlobalZOrder(1000)
    self.CircleShadow:setCameraMask(cc.CameraFlag.USER2)
    self.whiteBallLine:setGlobalZOrder(1000)
    self.whiteBallLine:setCameraMask(cc.CameraFlag.USER2)
    self.colorBallLine:setGlobalZOrder(1000)
    self.colorBallLine:setCameraMask(cc.CameraFlag.USER2)

    -------------------------------------------------------------

    mCanSendSetCueMessage = true  --重置成员函数
end

function Cue:setCircleByLegal(isLegal)
    if not isLegal then
        self.CircleShadow:setSpriteFrame("eightBall_DrawCircle_Red.png")
        return
    end
    self.CircleShadow:setSpriteFrame("eightBall_DrawCircle_Shadow.png")
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
    m_RootBall:clearWhiteBallView()
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
        m_RootBall:setBallState(g_EightBallData.ballState.run)  --击球白球设置为run,放置定时器开跑白球就是stop导致直接结束
        m_RootBall:getPhysicsBody():applyImpulse(
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
        m_RootBall:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
            if m_RootBall and not tolua.isnull(m_RootBall) then
                m_RootBall:getPhysicsBody():resetForces()
            end
        end )))
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
        self:sendHitWhiteBallMessage(percent, ballPosX, ballPosY, velocityX, velocityY, angularVelocity, unevenX, unevenY, prickStrokeX, prickStrokeY)
    end
end

--接受到发射球消息
--@ event 服务器发来的力量数组
--@ callback 帧同步开始的回调函数,回到mainlayer开始帧同步发送与接受处理
function Cue:receiveLauchBall(event, callback)
    print("receiveLauchBall  ",event.fWhiteBallRotate,event.fCueRotate)
    local function _hitWhiteBall()
        if self and not tolua.isnull(self) and m_RootBall and not tolua.isnull(m_RootBall) then
            self:setCueLineCircleVisible(false)
            self:resetPos()
            EightBallGameManager:setCanRefreshBallAni(true)
            m_RootBall:setBallState(g_EightBallData.ballState.run)  --击球白球设置为run,放置定时器开跑白球就是stop导致直接结束
            m_RootBall:setPosition(cc.p(event.fPositionX, event.fPositionY))
            m_RootBall:getPhysicsBody():applyImpulse(cc.p(event.fVelocityX, event.fVelocityY))
            m_RootBall:getPhysicsBody():setAngularVelocity(event.fAngularVelocity)
            m_RootBall:getPhysicsBody():applyForce(cc.p(event.fUnevenBarsX, event.fUnevenBarsY), cc.p(0, 0))
            m_RootBall:setWhiteBallContinuesForce(cc.p(event.fUnevenBarsX, event.fUnevenBarsY))
            EightBallGameManager:playEffectByIndex(g_EightBallData.sound.cue)
            if callback then
                callback()-- 击球后就回调开始帧同步
            end
            m_RootBall:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create( function()
                if m_RootBall and not tolua.isnull(m_RootBall) then
                    m_RootBall:getPhysicsBody():resetForces()
                end
            end )))
        end
    end
    -- 是我自己开的球立刻击球
    if event.UserID == player:getPlayerUserID() then
        _hitWhiteBall()
   -- 是对手击的球就播放动画，延迟击打，同步
    else
        m_RootBall:setRotation(event.fWhiteBallRotate)
        self:setRotation(event.fCueRotate)
        self:stopAllActions()
        local cueRotate = mathMgr:changeAngleTo0to360(self:getRotation())
        self:setRotation(cueRotate)
        local posX, posY = mathMgr:getCuePosByRotate(cueRotate, event.Percent)
        local radius = m_RootBall:getContentSize().width / 2

        local func1 = cc.MoveTo:create(g_EightBallData.receiveHitWhiteBallInterval, cc.p(radius + posX, radius + posY))
        local func2 = cc.CallFunc:create( function()
            _hitWhiteBall()
        end )
        self:runAction(cc.Sequence:create(func1,func2))
    end
end

--接受消息，移动杆子的处理
function Cue:receriveSetCueInfo(rotate, rootNode)
    self:stopAllActions()

    if EightBallGameManager:getCurrentUserID() ~= player:getPlayerUserID() and EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
        self.spriteLine:setVisible(false)
        self.circleCheck:setVisible(false)
    else
        self.spriteLine:setVisible(true)
        self.circleCheck:setVisible(true)
    end

    self:runAction(cc.Sequence:create(
    cc.RotateTo:create(0.5, rotate),
    cc.CallFunc:create( function()
        self:setRotationOwn(rotate, rootNode)
    end )))
end

--设置角度
--@rotate 旋转的角度
function Cue:setRotationOwn(rotate,rootNode)
    if rotate == 0 then
        rotate = math.random(-5,5)/50
    end
    self:setRotation(rotate)
    if self.spriteLine then
        self.spriteLine:setRotation(rotate)
    end
    PhyControl:drawRouteDetection(rotate,self,m_RootBall,rootNode)
end

-- 设置瞄准线，杆，路径视图
-- 是否看得见瞄准线，圆球线，路径检测线
-- isVisible bool 是否看得见
function Cue:setCueLineCircleVisible(isVisible)
    --_print("set cue line circle visible = ",isVisible,debug.traceback())
    if self.spriteLine then
        self.spriteLine:setVisible(isVisible)
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
    if (mCanSendSetCueMessage or isEnded) and EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
        local requestData = {
            fAngle = tostring(angle),
            UserID = player:getPlayerUserID(),
            GameRound = EightBallGameManager:getGameRound(),
        }
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
        fWhiteBallRotate = tostring(m_RootBall:getRotation()),
        GameRound = EightBallGameManager:getGameRound(),
        fCueRotate = tostring(self:getRotation()),
    }
    print("round = ",requestData.GameRound,EightBallGameManager:getGameRound())
    dump(requestData)
    EBGameControl:requestEightBallCmd(g_EIGHTBALL_REG_HITWHITEBALL,requestData)
end

function Cue:onExit()
    if self and not tolua.isnull(self) then
        self:removeFromParent()
        self = nil
    end
    m_RootBall = nil
end

return Cue