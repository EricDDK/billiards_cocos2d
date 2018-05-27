EightBallGameManager = EightBallGameManager or {}

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

return EightBallGameManager