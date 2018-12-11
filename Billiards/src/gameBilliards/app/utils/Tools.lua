tool = {}

--获取时间
function tool.gettime()
    return os.time()
end 

--int 转bool
function tool.intTobool( value)
    if type(value) == "number" then
        if value == 1 then 
            return true
        end
    end
    return false
end

function tool.TranslateScore(score)
    if not score then
        return "0"
    end
    score = tonumber(score)
    local result, remainder, tempScore, showTxt
    if score == nil then
        return 
    end
    if score < 10000 then
        return score                  
    elseif score >= 10000 and score < 10000000 then
        result = score / 100
        remainder = score % 100
        if remainder >= 50 then
            tempScore = math.ceil(result)
        else
            tempScore = math.floor(result)
        end
        showTxt = tempScore / 100 .. "万"
    elseif  score >= 10000000  and score < 100000000  then
        result = score / 100000
        remainder = score % 100000
        if remainder >= 500000 then
            tempScore = math.ceil(result)
        else
            tempScore = math.floor(result)
        end
        showTxt = tempScore / 100 .. "千万"
    elseif score >= 100000000 then
         result = score / 100000
        remainder = score % 100000
        if remainder >= 50000000 then
            tempScore = math.ceil(result)
        else
            tempScore = math.floor(result)
        end
        showTxt = tempScore / 1000 .. "亿"
    end
    return showTxt
end

--根据选择底分区间开桌子返回
--@param rank是选择的底分区分，客户端本地数据
--@param mixBet是服务器的房间的底分
--@param isQuickStart是否是快速开始
--@return 随机的底分
function tool:setTableBetByPlayerScore(rank, mixBet,isQuickStart)
    local myScore = player:getPlayerScore()
    if rank and #rank == 2 and next(rank) ~= nil then
        if mixBet == 100 then
            if myScore < 4000 then
                return mixBet
            elseif myScore >= 10000 and myScore < 20000 then
                return 500
            elseif myScore >= 20000 then
                return 1000
            end
        elseif mixBet == 2000 then
            return 2000
        elseif mixBet == 5000 then
            return 5000
        elseif isQuickStart then
            return 20000
        elseif rank[1] == 20000 then
            if myScore < 450000 then
                return 20000
            else
                return 50000
            end
        elseif rank[1] == 100000 then
            if myScore < 1800000 then
                return 100000
            else
                return 200000
            end
        end
    else
        return mixBet
    end
end

--根据当前的秒数 换算成一个 字符串  2:00:00
function tool.getTimeStrBySecond(sec)
    return string.format("%02d:%02d:%02d", math.floor(sec/3600)%60, math.floor(sec/60)%60, sec%60)
end

--copy一个新的tab
function tool.tableCopy(tab)
    if tab ~= nil then
        local temp = {}
        for key,value in pairs(tab) do
            temp[key] = value
        end
        return temp
    end
    return nil
end

function string.subUTF8String(s, start, endl)    
    local dropping = string.byte(s, endl+1)    
    if not dropping then 
        return s 
    end    
    if dropping >= 128 and dropping < 192 then    
        return string.subUTF8String(s, start, endl-1)    
    end    
    return string.sub(s, start, endl)   
end 

--每个字单独导出在table
function string.utf8StringInTable( str )
    local len  = #str
    local left = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local t = {}
    local start = 1
    local wordLen = 0
    while len ~= left do
        local tmp = string.byte(str, start)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                break
            end
            i = i - 1
        end
        wordLen = i + wordLen
        local tmpString = string.sub(str, start, wordLen)
        start = start + i
        left = left + i
        t[#t + 1] = tmpString
    end
    return t
end

--utf字符串长度
function string.utfstrlen(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
    while left ~= 0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then 
                left=left-i
                break
            end
            i=i-1
        end
        cnt=cnt+1
    end
    return cnt
end

function table.print(tbl, prev)
    local function tprint(tbl, prev)
        if prev == nil then prev = "" end
        local str = prev.."{\n"
        for k, v in pairs(tbl) do
            local s
            if type(v) == "table" then
                s = prev.."\t"..k.."=\n"..tprint(v, prev.."\t")..",\n"
            else
                s = prev.."\t"..k.."="..tostring(v)..",\n"
            end

            str = str..s
        end

        str = str..prev.."}"
        return str
    end
    if not tbl then print(" table is nil ")  return end
    print(
        "\n*************************START***************************\n",
        tprint(tbl, prev),
        "\n**************************END****************************\n")
end

function table.inter(tb1, tb2)
    local cln = table.copy(tb2)
    local insr={}
    for _, v1 in pairs(tb1) do
        for k, v in pairs(cln)do
            if v1 == v then
                table.insert(insr, v)
                table.remove(cln, k)
                break
            end
        end
    end
    return insr
end

--表中是否包含某个值 适用 number string -元table
function table.isInTable(tab,value)
    for k,v in pairs(tab) do
        if v == value then
            return true
        end
    end
    return false 

end

--clone函数
function table.clone(object)
    local lookup_table = {}--新建table用于记录
    local function _copy(object)--_copy(object)函数用于实现复制
        if type(object) ~= "table" then
            return object   ---如果内容不是table 直接返回object(例如如果是数字\字符串直接返回该数字\该字符串)
        elseif lookup_table[object] then
            return lookup_table[object]--这里是用于递归滴时候的,如果这个table已经复制过了,就直接返回
        end
        local new_table = {}
        lookup_table[object] = new_table--新建new_table记录需要复制的二级子表,并放到lookup_table[object]中.
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)--遍历object和递归_copy(value)把每一个表中的数据都复制出来
        end
        return setmetatable(new_table, getmetatable(object))--每一次完成遍历后,就对指定table设置metatable键值
    end
    return _copy(object)
end

function table.empty(t)
    if type(t) ~= 'table' then
        return false
    end

    for k, v in pairs(t) do
        return false
    end
    return true
end

function table.hasValue(t, value)
    for k, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function table.removeOfValue(t, value)
    local rms = {}
    for k, v in pairs(t) do
        if v == value then
            rms[#rms+1] = k
        end
    end

    for i=#rms,1 do
         table.remove(t, rms[i])
    end
end

local isTipsRunning = false

function tool:resetTipsRunning()
    isTipsRunning = false
end

function tool.openTipsLayer(str,fontSize)
    if str == nil or str == "" then
        str = ""
        return
    end
    str = tostring(str)
    if isTipsRunning then
        return
    end
    local tipsBg = ccui.ImageView:create("common_tips.png",UI_TEX_TYPE_PLIST)
    if tipsBg then
        local label = cc.Label:createWithTTF(str,"fonts/FZY4JW.TTF",fontSize and fontSize or 30)
        if label then
            label:setPosition(cc.p(tipsBg:getContentSize().width/2,tipsBg:getContentSize().height/2))
            label:setColor(cc.c3b(255,210,2))
            tipsBg:addChild(label)
        end
        cc.Director:getInstance():getRunningScene():addChild(tipsBg)
        local func1 = cc.CallFunc:create(function() isTipsRunning = true end)
        local func2 = cc.DelayTime:create(1)
        local func3 = cc.CallFunc:create(function()
            if not tolua.isnull(tipsBg) and tipsBg ~= nil then tipsBg:removeFromParent() tipsBg = nil end
            isTipsRunning = false
        end)
        tipsBg:setPosition(cc.p(display.cx,display.cy))
        tipsBg:runAction(cc.Sequence:create(func1,func2,func3))
    end
end

function tool.openTipsLayerLongtime(str,fontSize)
    if isTipsRunning then return end
    local tipsBg = ccui.ImageView:create("common_tips.png",UI_TEX_TYPE_PLIST)
    if tipsBg then
        local label = cc.Label:createWithTTF(str,"fonts/FZY4JW.TTF",fontSize and fontSize or 30)
        if label then
            label:setPosition(cc.p(tipsBg:getContentSize().width/2,tipsBg:getContentSize().height/2))
            label:setColor(cc.c3b(255,210,2))
            tipsBg:addChild(label)
        end
        cc.Director:getInstance():getRunningScene():addChild(tipsBg)
        local func1 = cc.CallFunc:create(function() isTipsRunning = true end)
        local func2 = cc.DelayTime:create(10)
        local func3 = cc.CallFunc:create(function() 
            isTipsRunning = false
            if not tolua.isnull(tipsBg) and tipsBg ~= nil then tipsBg:removeFromParent() end
        end)
        tipsBg:setPosition(cc.p(display.cx,display.cy))
        tipsBg:runAction(cc.Sequence:create(func1,func2,func3))
    end
end

function tool.openNetTips(str,fontSize)
    if str == nil or str == "" then
        str = ""
        return
    end
    str = tostring(str)
    local tipsBg = ccui.Scale9Sprite:create("NewFrameWork/NewFram_BlackBack.png")
    tipsBg:setContentSize(display.width,tipsBg:getContentSize().height-10)
    tipsBg:setAnchorPoint(cc.p(0.5,1))
    if tipsBg then
        local label = cc.Label:createWithTTF(str,"fonts/FZY4JW.TTF",fontSize and fontSize or 35)
        if label then
            label:setPosition(cc.p(tipsBg:getContentSize().width/2,tipsBg:getContentSize().height/2))
            label:setColor(cc.c3b(255,255,255))
            tipsBg:addChild(label)
            tipsBg:setScaleY(0)
        end
        cc.Director:getInstance():getRunningScene():addChild(tipsBg)
        local func1 = cc.ScaleTo:create(0.1,1.0)
        local func2 = cc.DelayTime:create(2)
        local func3 = cc.ScaleTo:create(0.1,1,0)
        local func4 = cc.CallFunc:create(function() 
            if not tolua.isnull(tipsBg) and tipsBg ~= nil then tipsBg:stopAllActions() tipsBg:removeFromParent() tipsBg = nil end
        end)
        tipsBg:setPosition(cc.p(display.cx,display.height))
        tipsBg:runAction(cc.Sequence:create(func1,func2,func3,func4))
    end
end

function tool.playLayerAni(layer)
    if layer then
        layer:setScale(0.4)
        layer:setAnchorPoint(cc.p(0.5, 0.5))
        layer:setPosition(cc.p(display.cx, display.cy))
        local func1 = cc.ScaleTo:create(0.15, 1.05)
        local func2 = cc.ScaleTo:create(0.1, 0.98)
        local func3 = cc.ScaleTo:create(0.02, 1)
        layer:runAction(cc.Sequence:create(func1, func2, func3))
    else
        print("[tool.playLayerAni] => layer param is nullptr")
    end
end

--关闭Layer的动画
function tool.closeLayerAni(layer,this)
    layer:setAnchorPoint(cc.p(0.5,0.5))
    layer:setPosition(cc.p(display.cx,display.cy))
    local func1 = cc.ScaleTo:create(0.1, 1.15)
    local func2 = cc.ScaleTo:create(0.2, 0.3)
    local func3 = cc.CallFunc:create( function() if not tolua.isnull(this) and this ~= nil then this:removeFromParent() end end)
    layer:runAction(cc.Sequence:create(func1,func2,func3))
end

function tool.shakeLayer(layer)
    layer:setPosition(cc.p(display.cx,display.cy))
    local xx = display.cx
    local yy = display.cy
    for i=1,1 do
        local x = math.random(-10,10)
        local y = math.random(-10,10)
        local func1 = cc.MoveTo:create(0.5,ccp(display.cx+xx,display.cy+yy))
        local func2 = cc.MoveTo:create(0.5,ccp(display.cx+x,display.cy+y))
        layer:runAction(cc.Sequence:create(func1,func2))
        x = xx
        y = yy
    end
    layer:setPosition(cc.p(display.cx,display.cy))
end

--在重新加载场景的时候重置的状态
function tool:resetStateInReplaceScene()
    isTipsRunning = false
end

local function setSpriteGray(sp,state)
    local vertShaderByteArray = "\n"..  
        "attribute vec4 a_position; \n" ..  
        "attribute vec2 a_texCoord; \n" ..  
        "attribute vec4 a_color; \n"..  
        "#ifdef GL_ES  \n"..  
        "varying lowp vec4 v_fragmentColor;\n"..  
        "varying mediump vec2 v_texCoord;\n"..  
        "#else                      \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord;  \n"..  
        "#endif    \n"..  
        "void main() \n"..  
        "{\n" ..  
        "gl_Position = CC_PMatrix * a_position; \n"..  
        "v_fragmentColor = a_color;\n"..  
        "v_texCoord = a_texCoord;\n"..  
        "}"  
	
	--置灰
    local flagShaderByteArray = "#ifdef GL_ES \n" ..  
        "precision mediump float; \n" ..  
        "#endif \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord; \n" ..  
        "void main(void) \n" ..  
        "{ \n" ..  
        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..  
        "gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..  
        "gl_FragColor.w = c.w; \n"..  
        "}"  
		
	--还原
	local flagShaderByteArray2 = "#ifdef GL_ES \n" ..  
        "precision mediump float; \n" ..  
        "#endif \n" ..  
        "varying vec4 v_fragmentColor; \n" ..  
        "varying vec2 v_texCoord; \n" ..  
        "void main(void) \n" ..  
        "{ \n" ..  
        "vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..  
        "gl_FragColor.xyz = c.rgb; \n"..  
        "gl_FragColor.w = c.w; \n"..  
        "}" 
	local glProgram 
	if state then
		glProgram = cc.GLProgram:createWithByteArrays(vertShaderByteArray,flagShaderByteArray) 
	else
		glProgram = cc.GLProgram:createWithByteArrays(vertShaderByteArray,flagShaderByteArray2) 
	end 
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    glProgram:link()  
    glProgram:updateUniforms()  
    sp:setGLProgram( glProgram )
end 

local function setSpriteBallRender(sp)
    local vertShaderByteArray = "\n" ..
    "#version 130 \n" ..
    "in vec4 vVertex;  \n" ..
    "in vec3 vNormal;  \n" ..
    "uniform mat4   mvpMatrix;  \n" ..
    "uniform mat4   mvMatrix;  \n" ..
    "uniform mat3   normalMatrix;  \n" ..
    "smooth out vec2 vVaryingTexCoord;    \n" ..
    "vec2 sphereMap(in vec3 normal, in vec3 ecPosition3)  \n" ..
    "{\n" ..
    "float m;  \n" ..
    "vec3 r, u;  \n" ..
    "u = normalize(ecPosition3);  \n" ..
    "r = reflect(u, normal);  \n" ..
    "m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1.0) * (r.z + 1.0));  \n" ..
    "return vec2 (r.x / m + 0.5, r.y / m + 0.5);  \n" ..
    "} \n" ..
    "void main(void)   \n" ..
    "{  \n" ..
    "vec3 vEyeNormal = normalMatrix * vNormal;  \n" ..
    "vec4 vVert4 = mvMatrix * vVertex;  \n" ..
    "vec3 vEyeVertex = vVert4.xyz / vVert4.w;  \n" ..
    "vVaryingTexCoord = sphereMap(vEyeNormal, vEyeVertex);  \n" ..
    "gl_Position = mvpMatrix * vVertex;  \n" ..
    "}"
    local flagShaderByteArray = "#version 130  \n" ..
    "out vec4 vFragColor;  \n" ..
    "uniform sampler2D  sphereMap;  \n" ..
    "smooth in vec2 vVaryingTexCoord;  \n" ..
    "void main(void)  \n" ..
    "{   \n" ..
    "vFragColor = texture(sphereMap, vVaryingTexCoord);  \n" ..
    "}"
    local vSource = cc.FileUtils:getInstance():getStringFromFile("gameBilliards/shader/ball_3D_PositionTex.vsh")
    local fSource = cc.FileUtils:getInstance():getStringFromFile("gameBilliards/shader/ball_3D_PositionTex.fsh")
    local glProgram = cc.GLProgram:createWithByteArrays(vSource,fSource)
    --local glProgram = cc.GLProgram:createWithByteArrays(vertShaderByteArray,flagShaderByteArray)
    glProgram:link()  
    glProgram:updateUniforms()  
    sp:setGLProgram( glProgram )  
end

function tool.setSpriteGray(sp,isRec)
    setSpriteGray(sp,isRec)
end

function tool.setSpriteBallRender(sp)
    setSpriteBallRender(sp)
end

--------------------------
--选取满足底分区间的房间(下限 上限 我的积分 游戏类型)
function tool.getRoomInfoByScore(minScore,maxScore,myScore,gameType)

    local roomList = {}
    local room,canEnterMinScore 
    for i = 1,#G_RoomInfoList do
        room = G_RoomInfoList[i]
        canEnterMinScore = myScore/room.MinBetRate
        if gameType == room.GameType and room.MinBet <= canEnterMinScore and room.MinBet<= maxScore  then
            table.insert(roomList,room)
        end
    end

    if #roomList >= 2 then
        table.sort(roomList,function(obj1,obj2)
            return obj1.MinBet > obj2.MinBet
        end)
    end
    --dump(roomList[1])
    return roomList[1]
end

--选取最合适的桌子
function tool.getTableByScore(myScore)
    local deskList = { }
    local desk,canEnterMinScore
    for i = 1, #G_TableInfoList do
        desk = G_TableInfoList[i]
        canEnterMinScore = myScore/desk.MinBetRate
        if desk.Bet <= canEnterMinScore and (desk.State == 0 or desk.State == 2) and desk.EmptySeat > 0 then
            table.insert(deskList, desk)
        end
    end
    if #deskList >= 2 then
        table.sort(deskList,function(obj1,obj2)
            if obj1.FixedBet == obj2.FixedBet then
                return obj1.EmptySeat < obj2.EmptySeat
            else
                return obj1.FixedBet > obj2.FixedBet
            end
        end)
    end

    --dump(deskList[1])
    return deskList[1]
end

--获取指定桌子信息
function tool.getTableInfoByID(tableID)
    local deskInfo = G_TableInfoList[tableID+1]
    if not deskInfo then
        deskInfo = {}
    end
    return deskInfo
end

--设置桌子底分
function tool.setBetOnTable(tableID,Bet)
    if tableID and tableID >= 0 and G_TableInfoList and (tableID + 1) <= #G_TableInfoList then
        G_TableInfoList[tableID+1].Bet = Bet
    end
end

--分配座位(测试用随机)
function tool.getSeatIDByTableID(tableID)
    local allSeat = {0,1,2,3}
    local function removeSeat(seat)
        for i = #allSeat,1,-1 do
            if seat == allSeat[i] then
                table.remove(allSeat,i)
            end
        end
    end
    if G_PlayerInfoList and #G_PlayerInfoList > 0 then
        local playerInfo
        for i = 1,#G_PlayerInfoList do
            playerInfo = G_PlayerInfoList[i]
            if playerInfo.TableID == tableID then
                removeSeat(playerInfo.SeatID)
            end
        end
    end

    math.randomseed(tostring(os.time()):reverse():sub(1, 6))

    return allSeat[math.random(#allSeat)]
end

--@playerData tableID,seatID
function tool.resetPlayerInfo(playerData)
    if G_PlayerInfoList and #G_PlayerInfoList > 0 and playerData then
        local _key = G_PlayerInfoList:keyFind(playerData.userID)
        if _key then
            G_PlayerInfoList[_key].TableID = -1
            G_PlayerInfoList[_key].SeatID = -1
        end
    end
end

--更新玩家信息(找到则替换，找不到则添加)
function tool.updatePlayerInfo(newPlayerInfo)
    if G_PlayerInfoList and #G_PlayerInfoList > 0 then
        local _key = G_PlayerInfoList:keyFind(newPlayerInfo.User.UserInfo.UserID)
        if _key then
            G_PlayerInfoList[_key] = newPlayerInfo
        else
            G_PlayerInfoList:insert(newPlayerInfo)
        end
    end
    dmgr:updatePlayerInfo(newPlayerInfo)
end

function tool.getPlayerInfo(uID)
    local playerInfo
    return G_PlayerInfoList:find(uID)
end

--弃用
function tool.setTableEmptySeat()
    if G_TableInfoList ~= nil and #G_TableInfoList > 0 then
        for i = 1, #G_TableInfoList do
            local table = G_TableInfoList[i].TableID
            local seat = G_TableInfoList[i].SeatCount
            if G_PlayerInfoList ~= nil and #G_PlayerInfoList > 0 then
                for j = 1, #G_PlayerInfoList do
                    if G_PlayerInfoList[j].TableID == table then
                        seat = seat - 1
                    end
                end
            end
            G_TableInfoList[i].EmptySeat = seat
        end
    end
end

function tool.splitStr(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = { }
    while true do
        local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
        if not nFindLastIndex then
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
            break
        end
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
        nFindStartIndex = nFindLastIndex + string.len(szSeparator)
        nSplitIndex = nSplitIndex + 1
    end
    return nSplitArray
end

--修改头像唯一入口
function tool.getHeadImgById(nId,isPath)
    local img = "roleHeadImg/head_101.png"
    nId = tonumber(nId)
    if nId > 100 and nId <= 106 or (nId >= 111 and nId <= 119) then
        img = "roleHeadImg/head_" .. nId ..".png"
    end
    if isPath then return img end
    return ccui.ImageView:create(img, UI_TEX_TYPE_LOCAL)
end

--添加头像
function tool.addHeadImgOnRoot(curHead,scale,rootBg)
    local headImg = tool.getHeadImgById(curHead)
    headImg:setScale(scale)
    headImg:setAnchorPoint(cc.p(0.5, 0.5))
    headImg:setPosition(cc.p(rootBg:getContentSize().width / 2, rootBg:getContentSize().height / 2))
    rootBg:addChild(headImg)
end

function tool.getSexByHeadID(nId)
    if nId and nId > 100 and nId <= 106 then
        if nId <= 103 then
            return 0 --男
        else
            return 1 --女
        end
    else
        return 0
    end
end

--[[--

http请求的入口，链接配置在公共部分GlobalData
@by dingdekai 2017-12-17
@param requestCallBack是回调函数
@param isGet是get还是post
@param api是请求头，？前的那个参数
@param url是请求正文，
@return 

]]
function tool.requesHttp(requestCallBack, url, paras,isGet,api)
    local xhr = cc.XMLHttpRequest:new() --创建一个请求  
    local _value = "api"
    if api ~= nil then
        _value = api
    end
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON --设置返回数据格式为字符串  
    --local req = "http://www.XXX"        --请求地址  
    local urlStr = ""
    local urlTable = {{},{},{},{},{}}
    urlTable[1] = g_requestURL
    urlTable[2] = _value
    urlTable[3] = "/"
    urlTable[4] = url
    urlTable[5] = "?"
    if isGet then
        urlTable[6] = paras
        urlStr = table.concat(urlTable)
        xhr:open("GET", urlStr)
    else
        urlStr = table.concat(urlTable)
        xhr:open("POST", urlStr)
    end
    _print(urlStr)
    local function onReadyStateChange()  --请求响应函数  
        if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then  --请求状态已完并且请求已成功  
            local statusString = "Http Status Code:"..xhr.statusText
            --_print("请求返回状态码"..statusString)  
            local s = xhr.response --获得返回的内容  
            --_print("返回的数据")
            requestCallBack(s)
        end  
    end  
    xhr:registerScriptHandler(onReadyStateChange) --注册请求响应函数  
    if isGet then
        xhr:send() --最后发送请求
    else
        xhr:send(paras) --最后发送请求
    end
end

--手机号检测
function tool.CheckIsMobile(str)
    return string.match(str,"[1][3,4,5,7,8]%d%d%d%d%d%d%d%d%d") == str;
end

function tool.CheckChinese(s) 
    local ret = {};
    local f = '[%z\1-\127\194-\244][\128-\191]*';
    local line, lastLine, isBreak = '', false, false;
    for v in s:gfind(f) do
        table.insert(ret, {c=v,isChinese=(#v~=1)});
    end
    return ret;
end

--实名认证姓名检测  只能是中文
function tool.checkIsCN(str)
    local table = tool.CheckChinese(str)
    for k,v in pairs(table) do
        if v.isChinese == false then
            return false
        end
    end
    return true
end

--实名认证身份证格式本地校验
function tool.checkIdCard(str)
    if #str ~= 18 then
        return false
    else
        for i = 1, #str do
            local curByte = string.byte(str, i)
            if i <= 17 then
                if curByte < 48 or curByte > 57 then
                    return false
                end
            else
                if (curByte < 48 or curByte > 57) and curByte ~= 88 then
                    return false
                end
            end
        end
    end
    return true
end

--用户账号检测 （4-12个字符，不允许中文）
function tool.checkNameString(str)
    if #str < 4 or #str > 15 then
        return false
    end
    local table = tool.CheckChinese(str)
    for k,v in pairs(table) do
        if v.isChinese then
            return false
        end
    end
    return true
end

--昵称检测 （4-12个字符，不允许纯数字）
function tool.checkNickName(str)
    print("========" .. #str)
    if #str < 4 or #str > 15 then
        return false
    end
    -- return string.match(str,"%d+") == str
    return true
end

--密码检测 (6-18个字符，只支持英文和数字)
function tool.checkPwd(str)
    if #str < 6 or #str > 18 then
        return false
    end
    local table = tool.CheckChinese(str)
    for k,v in pairs(table) do
        if v.isChinese then
            return false
        end
    end
    return true
end

function tool.registerBtnHandler(sender, callback)
    local function btnCallback(sender, eventType)
        local nTag = sender:getTag()
        if eventType == TOUCH_EVENT_BEGAN then
            sender:setScale(1.05)
        elseif eventType == TOUCH_EVENT_ENDED then
            amgr.playEffect("hall_res/button.mp3")
            sender:setScale(1.0)
            callback()
        elseif eventType == TOUCH_EVENT_MOVED then
            sender:setScale(1.0)
        end
    end
    sender:setTouchEnabled(true)
    sender:addTouchEventListener(btnCallback)
end

function tool.selectHead(head_img)
    if  head_img then
        local nId = player:getPlayerHead()
        local img = tool.getHeadImgById(nId,true)
        head_img:loadTexture(img,UI_TEX_TYPE_LOCAL)
        else
        head_img = tool.getHeadImgById(player:getPlayerHead())
        head_img:setTag(11)
        self.frameScene.imgUserFace:addChild(head_img)
        head_img:setPosition(cc.p(self.frameScene.imgUserFace:getContentSize().width/2,self.frameScene.imgUserFace:getContentSize().height/2))
        head_img:setScale(0.5)
    end
end

function tool.getChatSoundPath(content,talkContent)
     print("++++++++++++++++++++++++++++++++++getChatSoundPath")
     print(#talkContent)
        for i = 1,#talkContent do
            if content == talkContent[i].content then
                return talkContent[i].sound
            end
        end
    return nil
end

function tool.createDdzPlayerHead(nPlayerHead,nMemberLevel)
    print("==================", nPlayerHead)
    local headBg = ccui.ImageView:create("common_touxiangkuang1.png", UI_TEX_TYPE_PLIST)
    if headBg then
        headBg:setCascadeOpacityEnabled(false)
        local img = tool.getHeadImgById(nPlayerHead)
        if img then
            headBg:addChild(img)
            img:setPosition(cc.p(48,48))
            img:setScale(0.6)
            if nMemberLevel and nMemberLevel >= 2 then
                headBg:setOpacity(0)
            end
        end
    end
    return headBg
end

function tool.updateTimeoutTimes(userID,isReset)
    -- 多开情况下这里会闪退
    if debugMgr:getIsDebug() then
        return
    end
    local curTimeoutTimes
    if isReset then
        curTimeoutTimes = 0
    else
        curTimeoutTimes = cc.UserDefault:getInstance():getIntegerForKey("timeoutTimes",0)
        curTimeoutTimes = curTimeoutTimes + 1
    end
    cc.UserDefault:getInstance():setIntegerForKey("timeoutTimes",curTimeoutTimes)
    return curTimeoutTimes
end

function tool.shakeScreen()
    stage:setPosition(-10, -10)
   GTween.new(stage, 0.25, {x = 0,y = 0}, {delay = 0, ease = easing.outBounce })
end

function tool:setPercentByNum(num)
    if num > 100 then
        return 100
    else
        return num
    end
end

--[[--

这是获取设备唯一标识的函数
@by dingdekai 2017-12-17
@param 安卓是IMEI IOS是IDFA广告码
@IOS审核需要允许获取IDFA，不然会被终身封禁
@param table
@return string 设备号

]]
function tool.getDeviceID()
    local sn = ""
    if device.platform == "android" then
        local args = { }
        local sign = "()Ljava/lang/String;"
        local isSuc, id = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", "getIMEI", args, sign)
        if isSuc then
            sn = id
            cc.UserDefault:getInstance():setStringForKey("DeviceID", sn)
        end
        if sn == nil or sn == "" then
            print("渠道获取IMEI值为空")
            return "wangxiangqian"
        end
    elseif device.platform == "ios" then
        local getIDFABack = function(code)
            print("iphone 设备号获取成功返回！！！")
            sn = code
            cc.UserDefault:getInstance():setStringForKey("DeviceID", sn)
            if sn == nil or sn == "" then
                print("渠道获取IDFS值为空")
                return "wangxiangqian"
            end
        end
        local luaoc = require("cocos.cocos2d.luaoc")
        local className = "AppSDKManager_ios"
        -- 调用oc中的类名
        local methodName = "getiosIDFA"
        -- oc中的 方法名
        local args = { callBack = getIDFABack }
        local ok = luaoc.callStaticMethod(className, methodName, args)
    elseif device.platform == "windows" then
        print("是windows系统")
        sn = "windows"
    end
    return sn
end

--[[--

之后游戏内的动画需要用到的函数(系列)
@by dingdekai 2017-12-17
@param self自己 
@param table or type
@return nil

]]

function tool:PlayAniInLayer(_self)
    local msp = cc.Sprite:createWithSpriteFrameName("fanqie.png")
    if msp then
        local frames = display.newFrames("fanqie_%d.png",1,12)
        local animation = display.newAnimation(frames,0.1)
        msp:setPosition(cc.p(1050,360))
        msp:runAction(cc.Sequence:create(cc.Animate:create(animation),cc.FadeOut:create(0.15)))
        _self:addChild(msp,1)
    end
end

--[[--

以下都是vip需要使用到的公共函数
@by dingdekai 2017-12-17
@param string 
@param table or type
@return 自己看
]]

--设置玩家的头像框,这是vip的实时到帐
function tool:setHeadByVipInfo(head, level)
    if level then
        if player:getPlayerMemberLevel() < level then
            player:setPlayerMemberLevel(level)
            if head and not tolua.isnull(head) then
                head:loadTexture("roleHeadImg/headFrame" .. tostring(level) .. ".png", UI_TEX_TYPE_LOCAL)
            end
        end
    end
end

--设置玩家vip标识
function tool:refreshVipPos(head, img, scale, level)
    if img and not tolua.isnull(img) then
        img:setCascadeOpacityEnabled(false)
        if level >= 2 then
            head = ccui.ImageView:create("roleHeadImg/headFrame" .. tostring(level) .. ".png", UI_TEX_TYPE_LOCAL)
            head:setAnchorPoint(cc.p(0.5, 0.5))
            head:setScale(scale)
            head:setPosition(cc.p(img:getContentSize().width / 2, img:getContentSize().height / 2))
            if head and not tolua.isnull(head) then
                img:addChild(head)
                img:setOpacity(0)
            end
        end
    end
end

--设置金银卡的头像右边的标识
function tool:refreshGoldAndSilveryPos(img_silvery,img_gold)
    local myVipInfo = player:getPlayerVipInfo()
    if myVipInfo and myVipInfo[1].leftdays and myVipInfo[1].leftdays >= 0 then
        img_silvery:loadTexture("vip/hall_silvery_yes.png", UI_TEX_TYPE_LOCAL)
    end
    if myVipInfo and myVipInfo[2].leftdays and myVipInfo[2].leftdays >= 0 then
        img_gold:loadTexture("vip/hall_gole_yes.png", UI_TEX_TYPE_LOCAL)
    end
end

--playerInfo界面的周卡月卡剩余时间
function tool:getVipInfoString(info)
    local str = ""
    if info and info[1].leftdays and info[1].leftdays >= 0 then
        str = "银卡:"..tostring(info[1].leftdays).."天 "
    else
        str = "银卡:无 "
    end

    if info and info[2].leftdays and info[2].leftdays >= 0 then
        str = str .. "金卡:"..tostring(info[2].leftdays).."天"
    else
        str = str .. "金卡:无"
    end
    return str
end

--vip气泡
function tool:showVipTip(root)
    if root and not tolua.isnull(root) then
        local tip = ccui.ImageView:create("vip/hall_vip_tip.png", UI_TEX_TYPE_LOCAL)
        tip:setPosition(cc.p(root:getContentSize().width * 0.4, - tip:getContentSize().height * 1.0))
        tip:setScale(2.0)
        root:addChild(tip)
        -- 文字内容
        local txt = "即将到期"
        local label = cc.Label:createWithTTF(txt, "fonts/FZY4JW.TTF", 22)
        if label and not tolua.isnull(label) then
            label:setPosition(cc.p(root:getContentSize().width * 0.4, - tip:getContentSize().height * 1.2))
            label:setColor(cc.c3b(255, 255, 255))
            root:addChild(label)
        end
        -- 5秒移除
        local function removeTip()
            if tip and not tolua.isnull(tip) then
                tip:removeFromParent()
                tip = nil
            end
            if label and not tolua.isnull(label) then
                label:removeFromParent()
                label = nil
            end
        end
        tip:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(removeTip)))
        tip:setTouchEnabled(true)
        tip:addTouchEventListener(removeTip)
    end
end

--增加名字在头像框架
function tool:addPlayerName(bg, name)
    print("addPlayerName   增加名字  = ",name)
    if name == nil then
        name = "未知"
    end
    name = GetMaxLenString(name,10)
    if bg and not tolua.isnull(bg) then
        local _image = ccui.ImageView:create("roleHeadImg/game_name_Bg.png",UI_TEX_TYPE_LOCAL)
        if _image then
            _image:setAnchorPoint(cc.p(0.5, 0.5))
            _image:setPosition(cc.p(50,-15))
            bg:addChild(_image)
        end
        local label = cc.Label:createWithTTF(name, "fonts/FZY4JW.TTF", 20)
        if label ~= nil then
            label:setAnchorPoint(cc.p(0.5, 0.5))
            label:setPosition(cc.p(50,-15))
            bg:addChild(label)
        end
    end
end

--获得用户是否是安卓渠道用户
function tool:getIsChannel()
    if device.platform == "android" then
        if ChannelID == "HuaWei" or ChannelID == "XiaoMi" or ChannelID == "Oppo" or ChannelID == "Vivo" or ChannelID == "360"
        or ChannelID == "Tencent" or ChannelID == "Baidu" or ChannelID == "Alibaba" or ChannelID == "Today" then
            return true
        end
    end
    return false
end

function tool:reloadDdzRes()
    local resData = G_ResInfo[G_LoadResType.Ddz]
    for i=1,#G_ResInfo[G_LoadResType.Ddz] do
        local strPngPath = string.gsub(resData[i], ".plist", ".png")
        display.removeSpriteFrames(resData[i], strPngPath)
        display.loadSpriteFrames(resData[i], strPngPath, false)
    end
end

function tool:reloadMjRes()
    local resData = G_ResInfo[G_LoadResType.Hall_Mj]
    for i=1,#G_ResInfo[G_LoadResType.Hall_Mj] do
        local strPngPath = string.gsub(resData[i], ".plist", ".png")
        display.removeSpriteFrames(resData[i], strPngPath)
        display.loadSpriteFrames(resData[i], strPngPath, false)
    end
end

--@ _list 是成功支付的订单
--@ _order是整个totalIOSOrder
--从内存中的IOS订单中删除已经购买成功的
function tool:removeIosPruchaseFromOrder(_list,_keyName)
    local _order = cc.UserDefault:getInstance():getStringForKey(_keyName, "")
    if _order and _order ~= "" then
        local list = tool.splitStr(_order, ",")
        for i = 1, #list do
            if _list == list[i] then
                table.remove(list, i)
                break
            end
        end
        if #list > 0 then
            local str = ""
            for i = 1, #list do
                if i == 1 then
                    str = str .. list[i]
                else
                    str = str .. "," .. list[i]
                end
            end
            cc.UserDefault:getInstance():setStringForKey(_keyName, str)
        else
            cc.UserDefault:getInstance():deleteValueForKey(_keyName)
        end
    end
end

--新增一张支付成功的ios订单
function tool:addIosPruchaseFromOrder(_list,_keyName)
    if _list and _list ~= "" then
        local _order = cc.UserDefault:getInstance():getStringForKey(_keyName, "")
        if _order ~= "" and _order ~= nil then
            _order = _order .. "," .. _list
        else
            _order = _list
        end
        cc.UserDefault:getInstance():setStringForKey(_keyName, _order)
    end
end

--添加网络图片下载精灵在子节点上
function tool:addOnlineSp(_img_good, img_good,imgPath)
    if _img_good and img_good and not tolua.isnull(img_good) then
        local onlineSp
        if imgPath then
            onlineSp = cc.OnlineImageSprite:create(imgPath, _img_good)
        else
            onlineSp = cc.OnlineImageSprite:create("shop_res/defaultImage.png", _img_good)
        end
        if onlineSp ~= nil and not tolua.isnull(onlineSp) then
            onlineSp = tolua.cast(onlineSp, "cc.Sprite")
            if onlineSp ~= nil and not tolua.isnull(onlineSp) then
                onlineSp:setScaleX(img_good:getContentSize().width / onlineSp:getContentSize().width)
                onlineSp:setScaleY(img_good:getContentSize().height / onlineSp:getContentSize().height)
            end
            onlineSp:setPosition(cc.p(img_good:getContentSize().width / 2, img_good:getContentSize().height / 2))
            img_good:addChild(onlineSp)
        end
    end
end

function tool:getStrByState(state)
    if state == 1 then
        return "未配送"
    elseif state == 2 then
        return "配送中"
    elseif state == 3 then
        return "已签收"
    elseif state == 4 then
        return "已作废"
    end
    return ""
end

function tool:getStrByIndianaState(state)
    if state == "1" then
        return "进行中"
    elseif state == "2" then
        return "正在开奖"
    elseif state == "3" then
        return "已结束"
    else
        return "已结束"
    end
    return ""
end

--排序夺宝投注记录
--@listNoAddress 未填写地址
--@listOther 其他状态
--@listFinish 完成填写状态，放最后
function tool:sortCathecticList(_list)
    local listNoAddress = { }
    local listOther = { }
    local listFinish = { }
    for k, v in pairs(_list) do
        if v.status == "未填写" then
            table.insert(listNoAddress, _list[k])
        elseif v.status == "未中奖" or v.status == "流拍" then
            table.insert(listFinish, _list[k])
        else
            table.insert(listOther, _list[k])
        end
    end
    table.sort(listNoAddress, function(a, b) return a.kj_strtotime > b.kj_strtotime end)
    table.sort(listOther, function(a, b) return a.kj_strtotime > b.kj_strtotime end)
    table.sort(listFinish, function(a, b) return a.kj_strtotime > b.kj_strtotime end)
    local _returnList = listNoAddress
    if next(listOther) ~= nil and #listOther > 0 then
        for i = 1, #listOther do
            table.insert(_returnList, listOther[i])
        end
    end
    if next(listFinish) ~= nil and #listFinish > 0 then
        for i = 1, #listFinish do
            table.insert(_returnList, listFinish[i])
        end
    end
    return _returnList
end
------------------------------------------------------------------------------------------------------------------------------------

--每次启动游戏增加一次，10次之后就开出限制
function tool:setLoginCountToLimitRoom()
    
end

-------------------------------------------------     排行榜功能     ----------------------------------------------------

--@rootBg是pic的父节点,是个panel添加在滚动容器中
--@page是传入的信息数字，存着对应的数据
--@num是第几个排名，地主网1，得分王2，日赛排行3
--在大厅滚动图片中添加对应的排名名字和背景图片
function tool.addNameInfoInPageViewRankBack(rootBg, page, num, position)
    local pic = ccui.ImageView:create(page.imagePath, page.plistType)
    local _picRankTitle = ccui.ImageView:create(page.rankWord, page.plistType)
    _picRankTitle:setAnchorPoint(cc.p(0.5, 0.5))
    _picRankTitle:setPosition(position)
    local rankList = player:getPlayerHallRank()
    if #rankList ~= 0 and next(rankList) ~= nil then
        for i = 1, #rankList do
            if next(rankList) ~= nil and num <= #rankList and rankList[num] and rankList[num][i] and rankList[num][i].nickname then
                local _headBg = ccui.ImageView:create("common_touxiangkuang.png",UI_TEX_TYPE_PLIST)
                if _headBg then
                    _headBg:setScale(0.8)
                    _headBg:setPosition(cc.p(105,pic:getContentSize().height-29-i*(_headBg:getContentSize().height+12)))
                    pic:addChild(_headBg)
                    local _headNum
                    if i == 1 then
                        tool.addHeadImgOnRoot(113+1-num,0.5,_headBg)
                    else
                        tool.addHeadImgOnRoot(rankList[num][i].head,0.5,_headBg) 
                    end
                end
                local label = cc.Label:createWithTTF(GetMaxLenString(rankList[num][i].nickname, 12), "fonts/FZY4JW.TTF", 26)
                if label and not tolua.isnull(label) then
                    label:setAnchorPoint(0, 0.5)
                    label:setColor(cc.c3b(168, 38, 1))
                    label:setPosition(cc.p(135, 365 - i * 88))
                    pic:addChild(label)
                end
            end
        end
    end
    if _picRankTitle and not tolua.isnull(_picRankTitle) then
        pic:addChild(_picRankTitle)
    end
    pic:setPosition(cc.p(rootBg:getContentSize().width / 2, rootBg:getContentSize().height / 2))
    rootBg:addChild(pic)
end

--@_cur 1是上海地主王，2是上海得分王，3是五星大师赛日赛
function tool:getMyRankInfo(_cur)
    local myLandlordKingRank, myWinnerKingRank, myDayMatachRank = player:getMyRankInfo()
    if _cur == 1 then
        if myLandlordKingRank == nil or next(myLandlordKingRank) == nil or not myLandlordKingRank.ranking then
            return "未上榜", "0"
        end
        for k, v in ipairs(player:getPlayerLandlordKingRank()) do
            if tonumber(v.uid) == player:getPlayerUserID() then
                return tostring(k), tool.TranslateScore(myLandlordKingRank.weight)
            end
        end
        return myLandlordKingRank.ranking, tool.TranslateScore(myLandlordKingRank.weight)
    elseif _cur == 2 then
        if myWinnerKingRank == nil or next(myWinnerKingRank) == nil or not myWinnerKingRank.ranking then
            return "未上榜", "0"
        end
        for k, v in ipairs(player:getPlayerWinnerKingRank()) do
            if tonumber(v.uid) == player:getPlayerUserID() then
                return tostring(k), tool.TranslateScore(myWinnerKingRank.winScore)
            end
        end
        return myWinnerKingRank.ranking, tool.TranslateScore(myWinnerKingRank.winScore)
    else
        if myDayMatachRank == nil or next(myDayMatachRank) == nil or not myDayMatachRank.ranking then
            return "未上榜", "0"
        end
        for k, v in ipairs(player:getPlayerDayMatchRank()) do
            if tonumber(v.uid) == player:getPlayerUserID() then
                return tostring(k), tool.TranslateScore(myDayMatachRank.winScore)
            end
        end
        return myDayMatachRank.ranking, tool.TranslateScore(myDayMatachRank.winScore)
    end
end

function tool:setYesterdayRankInfoView(_cur)
    local _rankInfo = player:getPlayerRank()
    if _cur == 1 then
        if _rankInfo.phoneYesterdayWeightRankList[1] and _rankInfo.phoneYesterdayWeightRankList[2] and _rankInfo.phoneYesterdayWeightRankList[3] then
            return GetMaxLenString(_rankInfo.phoneYesterdayWeightRankList[1].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayWeightRankList[1].weight),
            GetMaxLenString(_rankInfo.phoneYesterdayWeightRankList[2].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayWeightRankList[2].weight),
            GetMaxLenString(_rankInfo.phoneYesterdayWeightRankList[3].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayWeightRankList[3].weight)
        end
        return nil, nil, nil
    elseif _cur == 2 then
        if _rankInfo.phoneYesterdayScoreRankList[1] and _rankInfo.phoneYesterdayScoreRankList[2] and _rankInfo.phoneYesterdayScoreRankList[3] then
            return GetMaxLenString(_rankInfo.phoneYesterdayScoreRankList[1].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayScoreRankList[1].winScore),
            GetMaxLenString(_rankInfo.phoneYesterdayScoreRankList[2].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayScoreRankList[2].winScore),
            GetMaxLenString(_rankInfo.phoneYesterdayScoreRankList[3].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayScoreRankList[3].winScore)
        end
        return nil, nil, nil
    else
        if _rankInfo.phoneYesterdayGamefreeRankList[1] and _rankInfo.phoneYesterdayGamefreeRankList[2] and _rankInfo.phoneYesterdayGamefreeRankList[3] then
            return GetMaxLenString(_rankInfo.phoneYesterdayGamefreeRankList[1].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayGamefreeRankList[1].winScore),
            GetMaxLenString(_rankInfo.phoneYesterdayGamefreeRankList[2].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayGamefreeRankList[2].winScore),
            GetMaxLenString(_rankInfo.phoneYesterdayGamefreeRankList[3].nickname, 12) .. "\n" .. "积分:" .. tool.TranslateScore(_rankInfo.phoneYesterdayGamefreeRankList[3].winScore)
        end
        return nil, nil, nil
    end
end

--获取昨天前三名的头像信息 --@_cur: 1地主王 2得分王 3日赛
function tool:setYesterdayThirdHeadInfo(_cur,_num)
    local _rankInfo = player:getPlayerRank()
    if _cur == 1 then
        if _rankInfo.phoneYesterdayWeightRankList[1] and _rankInfo.phoneYesterdayWeightRankList[2] and _rankInfo.phoneYesterdayWeightRankList[3] then
            return tonumber(_rankInfo.phoneYesterdayWeightRankList[_num].head)
        end
    elseif _cur == 2 then
        if _rankInfo.phoneYesterdayScoreRankList[1] and _rankInfo.phoneYesterdayScoreRankList[2] and _rankInfo.phoneYesterdayScoreRankList[3] then
            return tonumber(_rankInfo.phoneYesterdayScoreRankList[_num].head)
        end
    elseif _cur == 3 then
        if _rankInfo.phoneYesterdayGamefreeRankList[1] and _rankInfo.phoneYesterdayGamefreeRankList[2] and _rankInfo.phoneYesterdayGamefreeRankList[3] then
            return tonumber(_rankInfo.phoneYesterdayGamefreeRankList[_num].head)
        end
    end
    return 0
end

--观察者中取得rankLayer再设置其中的邮件红点是否存在
function tool:checkRankLayerMailRePoint(isLightUp)
    if DisplayObserver.getInstance():getDisplayByName("RankMainLayer") then
        DisplayObserver.getInstance():getDisplayByName("RankMainLayer").redPoint_main:setVisible(isLightUp)
    end
end