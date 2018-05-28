EightBallGameManager = EightBallGameManager or {}

local mCurrentUserID = -1 -- 当前可操作userid
--获取是不是我击球
function EightBallGameManager:returnIsMyOperate()
    --如果是练习模式，就是我
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise then
        return true
    end
    return mCurrentUserID == player:getPlayerUserID()
end

function EightBallGameManager:setCurrentUserID(args)
    mCurrentUserID = args 
end

function EightBallGameManager:getCurrentUserID()
    return mCurrentUserID 
end

--封装转换小数www
local function preciseDecimalBallsInfo(v)
    v.fPositionX = GetPreciseDecimal(v.fPositionX)
    v.fPositionY = GetPreciseDecimal(v.fPositionY)
    v.fVelocityX = GetPreciseDecimal(v.fVelocityX)
    v.fVelocityY = GetPreciseDecimal(v.fVelocityY)
    v.fAngularVelocity = GetPreciseDecimal(v.fAngularVelocity)
    v.fUnevenBarsForceX = GetPreciseDecimal(v.fUnevenBarsForceX)
    v.fUnevenBarsForceY = GetPreciseDecimal(v.fUnevenBarsForceY)
    v.fPrickStrokeForceX = GetPreciseDecimal(v.fPrickStrokeForceX)
    v.fPrickStrokeForceY = GetPreciseDecimal(v.fPrickStrokeForceY)
end

--帧同步数组
local syncBallArray = {}
function EightBallGameManager:insertSyncBallArray(value,index)
    if index <= 1 then
        EightBallGameManager:clearSyncBallArray()
    end
    --保留小数点后5位
    for k,v in pairs(value.BallInfoArray) do
        preciseDecimalBallsInfo(v)
    end
    syncBallArray[index] = value
end

function EightBallGameManager:setSyncBallArray(event)
    syncBallArray = event
end

function EightBallGameManager:getSyncBallArray()
    return syncBallArray
end

function EightBallGameManager:clearSyncBallArray()
    syncBallArray = {}
end


--存放这一次击打的所有消息的
--@ 碰撞信息，进球信息，单次碰撞信息
--@ collisionBorderCount 碰壁次数,所有球都算
--@ firstCollisionIndex 白球首次碰撞彩色球的索引
--@ firstInHoleBall 第一个进的球的索引
local hitBallsProcessArray = {
    collisionBorderCount = 0,
    firstCollisionIndex = 0,
    firstInHoleBall = -1,
}
--处理碰撞
function EightBallGameManager:dealCollision(tagA,tagB)
    if tagA and tagB then
        if tagA == g_EightBallData.g_Border_Tag.border or tagB == g_EightBallData.g_Border_Tag.border then
            hitBallsProcessArray.collisionBorderCount = hitBallsProcessArray.collisionBorderCount + 1
            return
        end
        if hitBallsProcessArray.firstCollisionIndex <= 0 and (tagA == g_EightBallData.g_Border_Tag.whiteBall or tagB == g_EightBallData.g_Border_Tag.whiteBall) then
            local anotherTag = (tagA == g_EightBallData.g_Border_Tag.whiteBall and tagB or tagA )
            if anotherTag <= 15 and anotherTag >= 1 then
                hitBallsProcessArray.firstCollisionIndex = anotherTag
                return
            end
        end
    end
    return
end

--处理进球
function EightBallGameManager:dealInHole(tag)
    if tag ~= g_EightBallData.g_Border_Tag.whiteBall and tag <= 15 and tag >= 1 then
        hitBallsProcessArray.firstInHoleBall = tag
    end
end

function EightBallGameManager:getHitBallsProcess()
    return hitBallsProcessArray
end

function EightBallGameManager:clearBallsProcess()
    hitBallsProcessArray = {
        collisionBorderCount = 0,
        firstCollisionIndex = 0,
        firstInHoleBall = - 1,
    }
end


--@ 保存服务器发送的击球统计结果
--@ 调整所有球的位置精度
local ballsResultArray = {}
local isCorrect = false
function EightBallGameManager:setBallsResultPos(event)
    ballsResultArray = event
    isCorrect = false
end

function EightBallGameManager:getBallsResultPos()
    return ballsResultArray
end

--击球结果同步数组
local switch = {
    [g_EightBallData.gameRound.none] = function()
        print("result is none")
        EBGameControl:setGameState(g_EightBallData.gameState.none)
    end,
    [g_EightBallData.gameRound.foul] = function()
        print("result is foul")
        EBGameControl:setGameState(g_EightBallData.gameState.setWhite)
    end,
    [g_EightBallData.gameRound.keep] = function()
        print("result is keep")
        EBGameControl:setGameState(g_EightBallData.gameState.hitBall)
    end,
    [g_EightBallData.gameRound.change] = function()
        print("result is change")
        EBGameControl:setGameState(g_EightBallData.gameState.hitBall)
    end,
    [g_EightBallData.gameRound.gameOver] = function()
        print("result is gameOver")
        EBGameControl:setGameState(g_EightBallData.gameState.gameOver)
    end,
    [g_EightBallData.gameRound.restart] = function()
        print("result is restart")
        EBGameControl:setGameState(g_EightBallData.gameState.waiting)
    end,
}
--同步一下结果，所有球位置修正
function EightBallGameManager:syncHitResult(rootNode)
    if EBGameControl:getGameState() == g_EightBallData.gameState.practise then return end
    
    EightBallGameManager:setCurrentUserID(ballsResultArray.UserID)
    if ballsResultArray.UserID == player:getPlayerUserID() then
        --我的回合
        rootNode.slider_PowerBar:setTouchEnabled(true)
    else
        --对方回合，我等
        rootNode.slider_PowerBar:setTouchEnabled(false)
    end
    --设置我的击球颜色
    EightBallGameManager:setColorUserID(ballsResultArray.FullColorUserID,ballsResultArray.HalfColorUserID)
    local func = switch[ballsResultArray.Result]
    if func then
        func()
    end
    -- 结束同步最后同步一下结果函数
    if not isCorrect and #ballsResultArray > 0 then
        local ballsArray = ballsResultArray.BallInfoArray
        for i = 0, 15 do
            local ball = rootNode.desk:getChildByTag(i)
            if ball then
                ball:setBallsResultState(ballsArray[i + 1])
            end
        end
        isCorrect = true
        ballsResultArray = { }
    end
    if rootNode.whiteBall:getIsInHole() then
        EBGameControl:dealWhiteBallInHole()
    end
end


--击打白球结果数组,暂时存放结果数据用，被同步端结束击打会自动调用
--@ event.fAngularVelocity 这里是白球的当前rotation，不是角速度了！！！
local hitWhiteBallResult = nil
function EightBallGameManager:setHitWhiteResult(event)
    for k,v in pairs(event.BallInfoArray) do
        preciseDecimalBallsInfo(v)
    end
    hitWhiteBallResult = event
end

function EightBallGameManager:getHitWhiteResult()
    return hitWhiteBallResult
end

function EightBallGameManager:init()
    
end


local mFullColorUserID = -1 -- 击打全色球的userid
local mHalfColorUserID = -1 -- 击打半色球的userid
--是否打全色球
function EightBallGameManager:setColorUserID(fullColorUserID,halfColorUserID)
    mFullColorUserID = fullColorUserID
    mHalfColorUserID = halfColorUserID
end

function EightBallGameManager:getColorUserID()
    return mFullColorUserID,mHalfColorUserID
end

function EightBallGameManager:getMyColor()
    --还没判断好谁打全色球谁打半色球,或者不是我的轮次，自动白色圈圈
    if mFullColorUserID == -1 or mHalfColorUserID == -1 or mCurrentUserID ~= player:getPlayerUserID() then
        return -1
    end
    if player:getPlayerUserID() == mFullColorUserID then
        return 1
    elseif player:getPlayerUserID() == mHalfColorUserID then
        return 2
    end
    return 0
end

--初始化函数
function EightBallGameManager:initialize()
    mCurrentUserID = -1
    syncBallArray = {}
    ballsResultArray = {}
    isCorrect = false
    hitWhiteBallResult = nil
    mFullColorUserID = -1
    mHalfColorUserID = -1
end

return EightBallGameManager