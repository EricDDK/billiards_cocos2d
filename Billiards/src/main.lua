print = release_print

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

package.path = package.path .. ";src/?.lua"
cc.FileUtils:getInstance():setPopupNotify(false)

cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

cc.FileUtils:getInstance():addSearchPath("res/gameBilliards", true)
cc.FileUtils:getInstance():addSearchPath("res/gameBilliards/test", true)
cc.FileUtils:getInstance():addSearchPath("res/gameBilliards/plist", true)

require("gameBilliards.app.define.EIGHTBALLProtoNetDefine")
require("gameBilliards.app.utils.Tools")
require("gameBilliards.app.utils.Help")
require("base.player")
require "config"

-- int 放在最后
require "cocos.init"

require("luasocket.socket")

function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")

    local message = errorMessage
    local errorMessage = debug.traceback(errorMessage, 3)
    buglyReportLuaException(tostring(message), debug.traceback())

    local ffi = require("ffi")
    if (ffi and ffi.os == "Windows") then
        ffi.cdef [[
                            int MessageBoxA(void *w, const char *txt, const char *cap, int type);
                        ]]
        ffi.C.MessageBoxA(nil, "found lua error. \napplication is stop.", "error", 0)
    end

    return errorMessage
end

require("gameBilliards.main")
