PhyControl = PhyControl or { }


-- 创建直线物理边界
local function createPhysicalBorderLine(pos1, pos2, root, tag, isBag)
    local border = cc.Node:create()
    border:setTag(tag)
    if not isBag then
        border:setPhysicsBody(cc.PhysicsBody:createEdgeSegment(pos1, pos2, g_EightBallData.borderPhysicsMaterial,1.0))
        border:getPhysicsBody():setCategoryBitmask(0x01)
        border:getPhysicsBody():setContactTestBitmask(0x01)
        border:getPhysicsBody():setCollisionBitmask(0x03)
    else
        border:setPhysicsBody(cc.PhysicsBody:createEdgeSegment(pos1, pos2, cc.PhysicsMaterial(1000000,0,1)))
        border:getPhysicsBody():setCategoryBitmask(0x01)
        border:getPhysicsBody():setContactTestBitmask(0x01)
        border:getPhysicsBody():setCollisionBitmask(0x03)
    end
    root:addChild(border)
end

-- 创建洞的物理边界
local function createPhysicalHole(pos1, pos2, radius, root, tag)
    local border = cc.Node:create()
    border:setTag(tag)
    border:setPhysicsBody(cc.PhysicsBody:createCircle(radius*1.2))
    border:setPosition(cc.p(pos1, pos2))
    border:getPhysicsBody():setCategoryBitmask(0x01)
    border:getPhysicsBody():setContactTestBitmask(0x01)
    border:getPhysicsBody():setCollisionBitmask(0x04)
    root:addChild(border)
end

-- 创建八球的物理边界
function PhyControl:initEightBallPhysicalBorder(_root)
    local desk = _root.desk
    PhyControl:createEightBallOutBorder(desk)
    PhyControl:createEightBallInnerBorder(desk)
    PhyControl:createEightBallHoleBorder(desk)
    PhyControl:createBagBorder(desk)
end

--创建所有的球
function PhyControl:initEightBallAllBalls(_root,isResume)
    local desk = _root.desk
    PhyControl:createWhiteBall(desk)
    PhyControl:createEightBallAllBalls(desk,isResume)
end

--创建杆子
function PhyControl:initCue(_rootBall)
    return require("gameBilliards/app/common/Cue").new(_rootBall)
end

-- 八球长方形外边界
function PhyControl:createEightBallOutBorder(desk)
    local deskWidth = desk:getContentSize().width
    local deskHeight = desk:getContentSize().height
    createPhysicalBorderLine(cc.p(0, 0), cc.p(deskWidth, 0), desk, g_EightBallData.g_Border_Tag.border)
    createPhysicalBorderLine(cc.p(0, 0), cc.p(0, deskHeight), desk, g_EightBallData.g_Border_Tag.border)
    createPhysicalBorderLine(cc.p(deskWidth, 0), cc.p(deskWidth, deskHeight), desk, g_EightBallData.g_Border_Tag.border)
    createPhysicalBorderLine(cc.p(0, deskHeight), cc.p(deskWidth, deskHeight), desk, g_EightBallData.g_Border_Tag.border)
end

-- 八球桌子内边界
function PhyControl:createEightBallInnerBorder(desk)
    local deskWidth = desk:getContentSize().width
    local deskHeight = desk:getContentSize().height
    local tag = g_EightBallData.g_Border_Tag.border
    createPhysicalBorderLine(cc.p(91, 59), cc.p(457, 59), desk, tag)
    createPhysicalBorderLine(cc.p(512, 59), cc.p(878, 59), desk, tag)
    createPhysicalBorderLine(cc.p(910, 92), cc.p(910, 455), desk, tag)
    createPhysicalBorderLine(cc.p(878, 488), cc.p(512, 488), desk, tag)
    createPhysicalBorderLine(cc.p(456, 488), cc.p(91, 488), desk, tag)
    createPhysicalBorderLine(cc.p(58, 456), cc.p(58, 91), desk, tag)

    -- createPhysicalBorderLine(cc.p(91, 59), cc.p(72.5, 41.7), desk, tag)
    -- createPhysicalBorderLine(cc.p(457, 59), cc.p(461.5, 41.7), desk, tag)
    -- createPhysicalBorderLine(cc.p(512, 59), cc.p(506.9, 41.7), desk, tag)
    -- createPhysicalBorderLine(cc.p(878, 59), cc.p(894.5, 41.7), desk, tag)
    -- createPhysicalBorderLine(cc.p(910, 92), cc.p(927.7, 75.1), desk, tag)
    -- createPhysicalBorderLine(cc.p(910, 455), cc.p(927.7, 473.1), desk, tag)
    -- createPhysicalBorderLine(cc.p(878, 488), cc.p(894.7, 506.1), desk, tag)
    -- createPhysicalBorderLine(cc.p(512, 488), cc.p(506.5, 506.1), desk, tag)
    -- createPhysicalBorderLine(cc.p(456, 488), cc.p(462, 506.1), desk, tag)
    -- createPhysicalBorderLine(cc.p(91, 488), cc.p(74.2, 506.1), desk, tag)
    -- createPhysicalBorderLine(cc.p(58, 456), cc.p(41.4, 473), desk, tag)
    -- createPhysicalBorderLine(cc.p(58, 91), cc.p(41.4, 74.2), desk, tag)
end

-- 八球洞边界
function PhyControl:createEightBallHoleBorder(desk)
    local radius = g_EightBallData.radius
    local tag = g_EightBallData.g_Border_Tag.hole
    createPhysicalHole(48, 48, radius, desk, tag)
    createPhysicalHole(48, 498.6, radius, desk, tag)
    createPhysicalHole(485, 30, radius, desk, tag)
    createPhysicalHole(485, 516, radius, desk, tag)
    createPhysicalHole(921, 498.6, radius, desk, tag)
    createPhysicalHole(921, 48, radius, desk, tag)
end

function PhyControl:createBagBorder(desk)
    local tag = g_EightBallData.g_Border_Tag.bagBorder
    createPhysicalBorderLine(cc.p( 3,470 ),cc.p( -11,470 ),desk,tag,true)
    createPhysicalBorderLine(cc.p( -11,470 ),cc.p( -21,463 ),desk,tag,true)
    createPhysicalBorderLine(cc.p( -21,463 ),cc.p( -21,35 ),desk,tag,true)
    createPhysicalBorderLine(cc.p( -21,35 ),cc.p( -54,35 ),desk,g_EightBallData.g_Border_Tag.bagBottom,true)  --袋子底部的tag是bagBottom 226
    createPhysicalBorderLine(cc.p( -54,35 ),cc.p( -54,492 ),desk,tag,true)
    createPhysicalBorderLine(cc.p( -54,492 ),cc.p( -45,505 ),desk,tag,true)
    createPhysicalBorderLine(cc.p( -45,505 ),cc.p( 5,505 ),desk,tag,true)
end

-- 初始化八球的白球
function PhyControl:createWhiteBall(desk)
    local whiteBall = require("gameBilliards/app/common/EightBall").new(0)
    if whiteBall then
        whiteBall:setPosition(270, desk:getContentSize().height / 2)
        desk:addChild(whiteBall)
    end
end

--袋中球碰撞
function PhyControl:dealInHoleBallCollision(ballA,ballB,desk)
    print("deal In Hole Bal lCollision ")
    if ballA and ballB and desk then
        if ballA:getPositionY() < 475 and ballA:getPositionX() < -30 and ballB:getPositionY() < 475 and ballB:getPositionX() < -30 then
            ballA:resetForceAndEffect()
            ballB:resetForceAndEffect()
        end
    end
    -- if EBGameControl:getIsBallAllStop() then
    --     EightBallGameManager:setCanRefreshBallAni(false)
    -- end
end

local ballPosIndex = {
    { index = 1 },
    { index = 2 },
    { index = 9 },
    { index = 10 },
    { index = 8 },
    { index = 3 },
    { index = 4 },
    { index = 11 },
    { index = 5 },
    { index = 12 },
    { index = 13 },
    { index = 6 },
    { index = 14 },
    { index = 15 },
    { index = 7 },
}

-- 八球初始化所有的彩色球
function PhyControl:createEightBallAllBalls(desk,isResume)
    local dir = cc.p(650,desk:getContentSize().height / 2)
    local diameter = g_EightBallData.radius*2+2
    local ballPos = dir
    local curNumber = 1
    local curColY = 0
    for i=1,5 do
        ballPos.x = ballPos.x + diameter-3
        ballPos.y = ballPos.y - (diameter)
        curColY = ballPos.y
        for j=1,i do
            ballPos.y = ballPos.y + diameter
            local ball = require("gameBilliards/app/common/EightBall").new(ballPosIndex[curNumber].index)
            if isResume then
                ball:setPosition(cc.p(curNumber*40 + 100,1500))
            else
                ball:setPosition(ballPos)
            end
            desk:addChild(ball)
            curNumber = curNumber + 1
            if j == i then
                ballPos.y = curColY+ (diameter)/2  --末尾放置
            end
        end
    end
end

--重置所有球的位置
function PhyControl:resetAllBallsPos(rootNode)
    local desk = rootNode.desk
    print("desk size = ",desk:getContentSize().width,desk:getContentSize().height)
    for i=0,15 do
        local ball = desk:getChildByTag(i)
        if ball then
            ball:resetForceAndEffect()
            ball:resetBallState()
            ball:setVisible(true)
            ball:setBallState(g_EightBallData.ballState.stop)
        end
    end
    if desk:getChildByTag(0) then
        desk:getChildByTag(0):setPosition(270, desk:getContentSize().height / 2)
        desk:getChildByTag(0):getChildByTag(g_EightBallData.g_Border_Tag.cue):setRotationOwn(0,rootNode)
    end
    local dir = cc.p(650,desk:getContentSize().height / 2)
    local diameter = g_EightBallData.radius*2+2
    local ballPos = dir
    local curNumber = 1
    local curColY = 0
    for i=1,5 do
        ballPos.x = ballPos.x + diameter- 3
        ballPos.y = ballPos.y - (diameter)
        curColY = ballPos.y
        for j=1,i do
            ballPos.y = ballPos.y + diameter
            local ball = desk:getChildByTag(ballPosIndex[curNumber].index)
            ball:setPosition(ballPos)
            ball:setRotationOwn(0)
            ball:setBallState(g_EightBallData.ballState.stop)
            curNumber = curNumber + 1
            if j == i then
                ballPos.y = curColY+ (diameter)/2  --末尾放置
            end
        end
    end

    for i=0,15 do
        local ball = desk:getChildByTag(i)
        print(i.." num ball pos is ",ball:getPositionX(),ball:getPositionY())
    end
    
end

----------------------------------------------------------------Route Detection-------------------------------------------------------------------------
-------------------------------------------------------------------路经检测-----------------------------------------------------------------------------

--路径检测画线
--@ rotate 杆子旋转角度
--@ cue 杆子节点
--@ whiteBall 母球节点
--@ mainLayer 游戏图层传递
--// 这里需要微调，_rectTmp那一行，末尾的+ _line:getContentSize().height+2微调碰撞模型
--// 这里还有白圈判定，这里很乱，待整理
function PhyControl:drawRouteDetection(rotate, cue, whiteBall, mainLayer)
    local _line = whiteBall:getChildByTag(g_EightBallData.g_Border_Tag.lineCheck)
    local _circle = _line:getChildByTag(g_EightBallData.g_Border_Tag.circleCheck)
    local _whiteBallLine = _line:getChildByTag(g_EightBallData.g_Border_Tag.whiteBallLine)
    local _colorBallLine = _line:getChildByTag(g_EightBallData.g_Border_Tag.colorBallLine)

    if EightBallGameManager:getCurrentUserID() ~= player:getPlayerUserID() and EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
        _line:setVisible(false)
        _circle:setVisible(false)
        _whiteBallLine:setVisible(false)
        _colorBallLine:setVisible(false)
        return
    -- else
    --     _line:setVisible(true)
    --     _circle:setVisible(true)
    --     _whiteBallLine:setVisible(true)
    --     _colorBallLine:setVisible(true)
    end

    rotate = mathMgr:changeAngleTo0to360(360 - rotate - whiteBall:getRotation())
    local _rect = _line:getChildByTag(g_EightBallData.g_Border_Tag.cueCheck)
    local _rectTmp = _line:convertToWorldSpace(cc.p(_rect:getPositionX(), _rect:getPositionY()))
    local _rectPos = mainLayer.desk:convertToNodeSpace(cc.p(_rectTmp.x, _rectTmp.y))
    local _whitePosX, _whitePosY = whiteBall:getPosition()
    local _whitePos = cc.p(_whitePosX, _whitePosY)
    local _tmpCollisionBall = { }
    _line:setVisible(true)
    _circle:setVisible(true)
    _whiteBallLine:setVisible(true)
    _colorBallLine:setVisible(true)
    local _ball
    for i = 1, 15 do
        _ball = mainLayer.desk:getChildByTag(i)
        if _ball then
            local ballPosX, ballPosY = _ball:getPosition()
            local json = mathMgr.getNewRx_Ry(_rectPos.x, _rectPos.y, ballPosX, ballPosY, rotate)
            if mathMgr.computeCollision(1136,_ball:getContentSize().width,_ball:getContentSize().width/2,json.newRx,json.newRy) then
                local _ballDistance = mathMgr.twoDistance(_whitePos.x,_whitePos.y,ballPosX,ballPosY)
                if ballPosX > 0 then
                    table.insert(_tmpCollisionBall, { tag = i, distance = _ballDistance })
                end
            end
        end
    end
    ------------------------------------------------------------
--    --输出测试数据
--    local str = ""
--    local i = 1
--    while i<= #_tmpCollisionBall  do
--        str = str.._tmpCollisionBall[i].tag.."|"
--        i = i + 1
--    end
--    _print(str)
    ------------------------------------------------------------
    local _radius = whiteBall:getContentSize().width / 2
    if #_tmpCollisionBall > 0 and next(_tmpCollisionBall) ~= nil and _tmpCollisionBall[1].tag then
        table.sort(_tmpCollisionBall, function(a, b) return(a.distance) <(b.distance) end)
        local _ballPos = { }
        _ballPos.x, _ballPos.y = mainLayer.desk:getChildByTag(_tmpCollisionBall[1].tag):getPosition()
        local _value,_isUpOrDown = mathMgr.getShortestDistanceBetweenPointAndLine(rotate, _ballPos, _whitePos, _radius)
        _line:setContentSize(cc.size(_tmpCollisionBall[1].distance - _value - _radius, _line:getContentSize().height))
        _circle:setPosition(cc.p((_tmpCollisionBall[1].distance - _value), _line:getContentSize().height/2))

        local angle = math.asin(_value/_radius/2)*180/math.pi
        _whiteBallLine:setPosition(cc.p(_tmpCollisionBall[1].distance - _value, _line:getContentSize().height/2))
        _whiteBallLine:setRotation( _isUpOrDown * angle)
        _whiteBallLine:setContentSize(cc.size(90-angle+_radius,_whiteBallLine:getContentSize().height))
        _colorBallLine:setPosition(cc.p(_tmpCollisionBall[1].distance - _value, _line:getContentSize().height/2))
        _colorBallLine:setRotation(_isUpOrDown * angle - _isUpOrDown * 90)
        _colorBallLine:setContentSize(cc.size(angle+_radius,_whiteBallLine:getContentSize().height))

        -- 1是默认值，白圈判定
        if EBGameControl:getGameState() ~= g_EightBallData.gameState.practise then
            local myColor = EightBallGameManager:getMyColor()
            if myColor == g_EightBallData.HitColor.black then
                if _tmpCollisionBall[1].tag == 8 then
                    cue:setCircleByLegal(true)
                else
                    cue:setCircleByLegal(false)
                    _whiteBallLine:setVisible(false)
                    _colorBallLine:setVisible(false)
                end
            elseif ( _tmpCollisionBall[1].tag >= 8 and myColor == g_EightBallData.HitColor.full) 
            or (_tmpCollisionBall[1].tag <= 8 and myColor == g_EightBallData.HitColor.half) then
                cue:setCircleByLegal(false)
                _whiteBallLine:setVisible(false)
                _colorBallLine:setVisible(false)
            else
                cue:setCircleByLegal(true)
            end
        end
    else
        local _value = mathMgr:getLineLengthBetweenPointAndLine(rotate, _whitePos, _radius)
        _circle:setPosition(cc.p(_value, _line:getContentSize().height/2))
        _line:setContentSize(cc.size(_value - _radius, _line:getContentSize().height))
        cue:setCircleByLegal(true)
        _whiteBallLine:setVisible(false)
        _colorBallLine:setVisible(false)
    end
end

return PhyControl