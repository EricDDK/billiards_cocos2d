cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/",true)
cc.FileUtils:getInstance():addSearchPath("res/",true)

print("main.lua load Billiards alone")

require("gameBilliards.app.utils.Tools")
require("gameBilliards.app.utils.Help")

g_myGameName = "gameBilliards"

local function main()
    require("gameBilliards.app.GameApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
