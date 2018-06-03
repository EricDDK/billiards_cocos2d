local Camera3D = class("Camera3D")
Camera3D.__index = Camera3D

local function create2DCamera(depth, pos3D, flag)
    local camera
    local winSize = cc.Director:getInstance():getWinSize()
    camera = cc.Camera:createOrthographic(winSize.width, winSize.height, -100.0, 100.0)
    camera:setDepth(depth)
    camera:setPosition3D(pos3D)
    camera:setCameraFlag(flag)
    cc.Director:getInstance():getRunningScene():setPhysics3DDebugCamera(camera)
    return camera
end

local function create3DCamera(depth, pos3D, flag)
    local camera
    local winSize = cc.Director:getInstance():getWinSize()
    local camera = cc.Camera:createPerspective(60, visibleSize.width / visibleSize.height, 10, 1000)
    camera:setDepth(depth)
    camera:setPosition3D(pos3D)
    camera:setCameraFlag(flag)
    camera:lookAt(cc.vec3(0,0,0), cc.vec3(0, 1, 0))
    cc.Director:getInstance():getRunningScene():setPhysics3DDebugCamera(camera)
    return camera
end

--创建摄像机
--@ is3D 是否是3D摄像机
--@ depth 摄像机深度
--@ flag 摄像机flag，默认default,这里是user2
function Camera3D.new(is3D, depth, flag)
    local camera

    if is3D then
        
        camera = create3DCamera(depth, cc.vec3(0.0, 0.0, 0.0), flag)

    else
        
        camera = create2DCamera(depth, cc.vec3(0.0, 0.0, 0.0), flag)

    end

    return camera
end

return Camera3D