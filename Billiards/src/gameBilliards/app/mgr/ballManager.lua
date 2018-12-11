ballMgr = ballMgr or {}

local ballState = {}  --实时状态，结束击球会清除保存下一杆的
local ballProcess = {}  --过程数组

function ballMgr:insertBallState(value)
    table.insert(ballState,value)
end

function ballMgr:setBallState(event)
    ballState = event
end

function ballMgr:getBallState()
    return ballState
end

function ballMgr:setBallProcess(event)
    ballProcess = event
end

function ballMgr:getBallProcess()
    return ballProcess
end

return ballMgr