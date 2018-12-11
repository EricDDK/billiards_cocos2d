player = { }

local playerData = nil
local roomInfo = { } -- 当前房间信息
local tableInfo = { } -- 当前桌子信息
local myTableID = -1 -- 我的桌子号
local mySeatID = -1 -- 我的座位号
local myTokenID = -1 -- 我的TokenID
local nSignInfo = { }
local personalInfo = { }
local gameResultInfo = { } --
local curGameType = -1 -- 当前游戏类型
local backPhone = nil -- 密码找回的手机
local backPwd = nil -- 密码找回的手机
local str = "" --比赛内的服务器局数消息
local isPromote = nil --是否绑定推荐人
local isBindPhone = nil --是否绑定手机
local disconnectCount = 0  --连续房间进不去次数
local vipInfo = nil  --判断用户所有的vip信息
local vipReward = nil  --每日vip领取情况
local isFirstLoginAndLaunchVipTip = false --判断用户是否是第一次登陆并且显示vip气泡
local bgUse = nil  --用户背景使用购买情况
local isShowQianDao = false --这个帐号是否弹出过签到
local playerHallRank = { } --大厅排名，3中每个3人
local playerRank = { }  --总排名，各种
local playerStartParam = nil  --win32启动透传参数

function player:init()
    playerData = { }
    playerData.UserID = 0
    playerData.Name = ""
    playerData.NickName = ""
    playerData.Male = 0
    -- 0,1是男，2是女
    playerData.Head = 0
    playerData.Score = 0
    playerData.Reputation = 0
    playerData.State = 0
    playerData.Role = 0
    playerData.MemberLevel = 0
    playerData.VScore = 0
    playerData.VPoint = 0
    playerData.WeekVip = 0
    playerData.MonthVip = 0
    backPhone = nil
    backPwd = nil
    str = ""
    isPromote = nil
    isBindPhone = nil
    disconnectCount = 0
    isReConnect = false
    vipInfo = nil
    vipReward = nil
    bgUse = nil
    isFirstLoginAndLaunchVipTip = false
    isShowQianDao = false
    playerHallRank = { }
    playerRank = { }
    playerStartParam = nil
end

function player:setNewPwd(newPwd)
    cc.UserDefault:getInstance():setStringForKey("lastPassword", newPwd)
end

function player:initPlayerData(data)
    if data then
        playerData = data
        --dump(playerData)
    end
end

-- 重置游戏信息
function player:resetPlayerInfo()
    roomInfo = { }
    tableInfo = { }
    mySeatID = -1
    myTokenID = -1
    myTableID = -1
end

function player:getPlayerData()
    return playerData
end

-- UID
function player:setPlayerUserID(uId)
    playerData.UserID = uId
end

function player:getPlayerUserID()
    return playerData.UserID
end

-- 名称
function player:setPlayerName(name)
    playerData.Name = name
end

function player:getPlayerName()
    return playerData.Name
end

-- 昵称
function player:setPlayerNickName(name)
    playerData.NickName = name
end

function player:getPlayerNickName()
    return playerData.NickName
end

-- 性别
function player:getPlayerSex()
    return playerData.Male
end

function player:setPlayerSex(sex)
    playerData.Male = sex
end

--
function player:setPlayerHead(head)
    playerData.Head = head
end

function player:getPlayerHead()
    return playerData.Head
end

-- 金币
function player:setPlayerVScore(score)
    playerData.VScore = score
end

function player:getPlayerVScore()
    return playerData.VScore
end

function player:modifyPlayerVScore(score)
    playerData.VScore = playerData.VScore + score
end

--
function player:getPlayerScore()
    return playerData.Score
end

function player:setPlayerScore(score)
    playerData.Score = score
end

function player:getPlayerVip()
    return playerData.WeekVip , playerData.MonthVip
end

function player:setPlayerVip(arg1,arg2)
    playerData.WeekVip = arg1
    playerData.MonthVip = arg2
end

--判断用户是否是第一次登陆并且显示vip气泡
function player:setIsFirstLoginAndLaunchVipTip()
    isFirstLoginAndLaunchVipTip = true
end

function player:getIsFirstLoginAndLaunchVipTip()
   return isFirstLoginAndLaunchVipTip 
end

--判断这个账户是否弹出过签到
function player:setIsShowQianDao()
    isShowQianDao = true
end

function player:getIsShowQianDao()
    return isShowQianDao
end

function player:modifyPlayerScore(score)
    playerData.Score = playerData.Score + score
end

-- s声望
function player:setPlayerReputation(rep)
    playerData.Reputation = rep
end

function player:getPlayerReputation()
    return playerData.Reputation
end

function player:getPlayerState()
    return playerData.State
end

function player:setPlayerState(state)
    playerData.State = state
end

--
function player:setPlayerRole(role)
    playerData.Role = role
end

function player:getPlayerRole()
    return playerData.Role
end

--vip
function player:getPlayerMemberLevel()
    return playerData.MemberLevel
end

function player:setPlayerMemberLevel(ml)
    playerData.MemberLevel = ml
end

function player:getPlayerVipInfo()
    return vipInfo
end

function player:setPlayerVipInfo(event)
    vipInfo = event
end

function player:getPlayerVipReward()
    return vipReward
end

function player:setPlayerVipReward(event)
    vipReward = event
end

--用户背景使用以及购买情况
function player:getPlayerBgUse()
    return bgUse
end

function player:setPlayerBgUse(event)
    bgUse = event
end

--
function player:setPlayerRole(role)
    playerData.Role = role
end

function player:getPlayerRole()
    return playerData.Role
end

-- 房间信息
function player:setRoomInfo(info)
    roomInfo = info
end

function player:getRoomInfo()
    return roomInfo
end

-- 桌子信息
function player:setTableInfo(info)
    tableInfo = info
end

function player:getTableInfo()
    return tableInfo
end

-- function player:setTableBet(nBet)
--     tableInfo.Bet = nBet
-- end

function player:setMySeatID(id)
    mySeatID = id
end

function player:getMySeatID()
    return mySeatID
end

function player:setMyTokenID(id)
    myTokenID = id
end

function player:getMyTokenID(id)
    return myTokenID
end

function player:setMyTableID(id)
    myTableID = id
end

function player:getMyTableID()
    return myTableID
end

function player:setCurGameType(gType)
    curGameType = gType
end

function player:getCurGameType()
    return curGameType
end

-------------------------签到信息----------------------
function player:setSignInfo(data)
    nSignInfo = data
end

function player:getIsCanSign()
    if nSignInfo and nSignInfo.msg == "您今天还没有签到" then
        return true
    end
    return false
end

function player:getSignInfo()
    return nSignInfo
end

function player:changeSignInfoByIndex(nIndex, statu)
    for i = 1, #nSignInfo.signInList do
        if i == nIndex then
            nSignInfo.signInList[i].state = statu
        end
    end
end

----------------------邮件信息
local mailList = { }
function player:setMailList(list)
    mailList = list
end

function player:getMailList(list)
    return mailList
end

function player:updateMailInfo(index)
    for i = 1, #mailList do
        if mailList[i].index == index then
            mailList[i].state = 5
        end
    end
end

local rewardMail = 0
function player:setRewardMailNum(num)
    rewardMail = num
end

function player:getRewardMailNum()
    return rewardMail
end

---------------------商城信息
local shopList = { }
local recordList = { }
local indianaList = { }
local indianaAddressList = { }
local cathecticList = { }   --投注记录
function player:getShopList()
    return shopList
end

function player:setShopList(list)
    shopList = list
end

function player:getRecordList()
    return recordList
end

function player:setRecordList(list)
    recordList = list
end

function player:getIndianaList()
    return indianaList
end

function player:setIndianaList(list)
    indianaList = list
end

function player:deleteIndianaAddressList()
    if indianaAddressList and #indianaAddressList >= 1 and next(indianaAddressList) ~= nil then
        table.remove(indianaAddressList,1)
    end
end

function player:getIndianaAddressList()
    return indianaAddressList
end

function player:setIndianaAddressList(list)
    indianaAddressList = list
    if list and next(list) ~= nil then
        for i = 1, #indianaAddressList do
            indianaAddressList[i].ProductType = indianaAddressList[i].g_type
            indianaAddressList[i].ProductImage = indianaAddressList[i].g_img
            indianaAddressList[i].ProductName = indianaAddressList[i].g_name
            indianaAddressList[i].id = indianaAddressList[i].period
        end
    end
end

function player:getCathecticList()
    return cathecticList
end

function player:setCathecticList(list)
    cathecticList = list
end

function player:updateRecordList(data)
    if data then
        local date = os.date("*t", os.time())
        local curTime = date.year .. "-" .. date.month .. "-" .. date.day .. " " .. string.format("%2d", tonumber(date.hour)) .. ":" .. string.format("%2d", tonumber(date.min)) .. ":" .. string.format("%2d", tonumber(date.sec))
        local record = { ProductImage = data.ProductImage, ProductName = data.ProductName, ProductExchangeValue = data.ProductExchangeValue, time = curTime, status = "1" }
        table.insert(recordList, 1, record)
    end
    dump(recordList)
end

-------------------------------更新个人中心信息-------------------
function player:getPlayerPersonalUserType()
    return personalInfo.UserType
    -- 0 普通帐号1 游客 2 QQ 3 wechat
end

function player:setPlayerPersonalUserType(usertype)
    personalInfo.UserType = usertype
end

function player:setPlayerPersonIdCard(name, id)
    personalInfo.RealName = name
    personalInfo.IdCard = id
end

function player:setPlayerPersonPhone(phone)
    personalInfo.Mobile = phone
end

function player:getPlayerPersonalRealName()
    return personalInfo.RealName
end

function player:getPlayerPersonalIdCard()
    return personalInfo.IdCard
end

function player:setPlayerPersonalMobile(mobile)
    personalInfo.Mobile = mobile
end

function player:getPlayerPersonalMobile()
    return personalInfo.Mobile
end

function player:getPlayerGameResult()
    return gameResultInfo
end

function player:updatePlayerPersonalInfo(data)

    if data ~= nil then
        -- gamedata(战绩信息)
        if data.gamedata ~= nil then
            gameResultInfo = data.gamedata
        end

        -- userInfo（个人信息）
        if data.userInfo ~= nil then
            if data.userInfo.UserId ~= nil then
                playerData.UserID = tonumber(data.userInfo.UserId)
            end
            if data.userInfo.Name ~= nil then
                playerData.Name = data.userInfo.Name
            end
            if data.userInfo.Nickname ~= nil then
                playerData.NickName = data.userInfo.Nickname
            end
            if data.userInfo.Head ~= nil then
                playerData.Head = tonumber(data.userInfo.Head)
            end
            if data.userInfo.Score ~= nil then
                playerData.Score = tonumber(data.userInfo.Score)
            end
            if data.userInfo.VScore ~= nil then
                playerData.VScore = tonumber(data.userInfo.VScore)
            end
            if data.userInfo.type ~= nil then
                personalInfo.UserType = tonumber(data.userInfo.type)
            else
                personalInfo.UserType = nil
            end
            if data.userInfo.RealName ~= nil and data.userInfo.RealName ~= "" then
                personalInfo.RealName = data.userInfo.RealName
            else
                personalInfo.RealName = nil
            end
            if data.userInfo.IdCard ~= nil and data.userInfo.IdCard ~= "" then
                personalInfo.IdCard = data.userInfo.IdCard
            else
                personalInfo.IdCard = nil
            end
            if data.userInfo.mobile ~= nil and data.userInfo.mobile ~= "" then
                personalInfo.Mobile = data.userInfo.mobile

            else
                personalInfo.Mobile = nil

            end
        end
    end
end

function player:setMatchSTR(string)
    str = string
end

function player:getMatchSTR()
    return str
end


local banbenCode = "1.0.1"
function player:setBanbenInfo(info)
    banbenCode = info
end

function player:getBanbenCode()
    return banbenCode
end


-- 账号信息
local accountName = nil
local accountPass = nil

function player:setAccountName(name)
    accountName = name
end

function player:setAccountPassward(pass)
    accountPass = pass
end

function player:getAccountName(name)
    return accountName
end

function player:getAccountPassward()
    return accountPass
end

function player:getPlayerPromote()
    return isPromote
end

function player:setPlayerPromote(value)
    isPromote = value
end

function player:getBindPhone()
    return isBindPhone
end

function player:setBindPhone(value)
    isBindPhone = value
end

--连续连不进房间次数
function player:getDisconnectCount()
    return disconnectCount
end

function player:setDisconnectCount(count)
    disconnectCount = count
end

local myRoomInfo = { }
local isReConnect = false

-- 获取玩家房间信息
function player:getPlayerRoomInfo()
    if G_PlayerInfoList and #G_PlayerInfoList > 0 and next(G_PlayerInfoList) ~= nil then
        local playerInfo = G_PlayerInfoList:find(playerData.UserID)
        if playerInfo then
            return playerInfo
        end
    end
    return nil
end

-- 是否是重连
function player:setIsReConnect(state)
    isReConnect = true
end

function player:getIsReConnect()
    return isReConnect
end


local shopBuyList = { 1001 }

function player:checkIsBuy(id)
    for i = 1, #shopBuyList do
        if shopBuyList[i] == id then
            return true
        end
    end
    return false
end

function player:getShopBuyList()
    return shopBuyList
end

function player:updateShopBuyList(id)
    for i = 1, #shopBuyList do
        if shopBuyList[i] == id then
            return
        end
    end
    table.insert(shopBuyList, id)
end

-----------------------------------------暂时放这里-------------------------------

-- 账号是否存在
local function isAccountExit(userName)
    local totalAccountInfo = cc.UserDefault:getInstance():getStringForKey("totalAccountInfo", "")
    if totalAccountInfo ~= "" then
        local list = tool.splitStr(totalAccountInfo, ",")
        if #list > 0 then
            for i = 1, #list / 2 do
                print(list[2 * i - 1], userName)
                if list[2 * i - 1] == userName then
                    return true
                end
            end
        end
    end
    return false
end

-- 添加新账号
function player:addNewAccount(userName, password)
    if userName == "" or password == "" then return end
    if not isAccountExit(userName) then
        local totalAccountInfo = cc.UserDefault:getInstance():getStringForKey("totalAccountInfo", "")
        if totalAccountInfo then
            if totalAccountInfo ~= "" then
                totalAccountInfo = totalAccountInfo .. "," .. userName .. "," .. password
            else
                totalAccountInfo = userName .. "," .. password
            end
            cc.UserDefault:getInstance():setStringForKey("totalAccountInfo", totalAccountInfo)
        end
    end
end

function player:removeAccount(userName, password)
    local totalAccountInfo = cc.UserDefault:getInstance():getStringForKey("totalAccountInfo", "")
    if totalAccountInfo then
        if totalAccountInfo ~= "" then
            local list = tool.splitStr(totalAccountInfo, ",")
            for i = #list / 2, 1, -1 do
                if list[2 * i - 1] == userName then
                    table.remove(list, 2 * i)
                    table.remove(list, 2 * i - 1)
                    break
                end
            end

            local str = ""
            for i = 1, #list do
                if i == 1 then
                    str = str .. list[i]
                else
                    str = str .. "," .. list[i]
                end
            end
            cc.UserDefault:getInstance():setStringForKey("totalAccountInfo", str)
        end
    end
end

-- @param 1-密码修改  2-密码找回
function player:changeAccountPwd(password, updateType)
    local userName
    if updateType == 1 then
        userName = player:getLastAccountInfo()[1]
    elseif updateType == 2 then
        userName = player:getBackPhone()
    end

    if isAccountExit(userName) then
        local totalAccountInfo = cc.UserDefault:getInstance():getStringForKey("totalAccountInfo", "")
        print("==============:" .. totalAccountInfo .. "==userNAme:" .. userName .. "====pwd:" .. password)
        if totalAccountInfo and totalAccountInfo ~= "" then
            local list = tool.splitStr(totalAccountInfo, ",")
            for i = 1, #list do
                if list[i] == userName then
                    list[i + 1] = password
                    break
                end
            end
            local str = ""
            for i = 1, #list do
                if i == 1 then
                    str = str .. list[i]
                else
                    str = str .. "," .. list[i]
                end
            end
            cc.UserDefault:getInstance():setStringForKey("totalAccountInfo", str)
        end
    end
end

-- 找回用到的手机号
function player:setBackPhone(phone)
    backPhone = phone
end

function player:getBackPhone()
    return backPhone
end

-- 找回后的密码
function player:setBackPwd(pwd)
    backPwd = pwd
end

function player:getBackPwd()
    return backPwd
end

function player:getLastAccountInfo()
    local userName = cc.UserDefault:getInstance():getStringForKey("lastUserName", "")
    local password = cc.UserDefault:getInstance():getStringForKey("lastPassword", "")
    local userType = cc.UserDefault:getInstance():getStringForKey("lastUserType", "")
    if userType == 0 then
        return { "", "", userType }
    else
        return { userName, password, userType }
    end
end

function player:setLastAccountInfo(userName, password, userType)
    cc.UserDefault:getInstance():setStringForKey("lastUserName", userName)
    cc.UserDefault:getInstance():setStringForKey("lastPassword", password)
    cc.UserDefault:getInstance():setStringForKey("lastUserType", userType)
    player:addNewAccount(userName, password)
end

-- 获取房间玩家人数
function player:getRoomUserCountByGameType(gameType)
    local count = 0
    for i = 1, #G_RoomInfoList do
        if G_RoomInfoList[i].GameType == gameType then
            count = count + G_RoomInfoList[i].UserCount
        end
    end
    if count == 0 then
        return count
    end
    if gameType == G_GameType.SRDDZ then
        count = count * 5 + math.random(1, 3)
    else
        count = count * 3 + math.random(1, 3)
    end
    return count
end

local isLoading = false
function player:setIsLoading(state)
    isLoading = state
end

function player:getIsLoading()
    return isLoading
end


----------------------------验证码倒计时
-- 验证码倒计时
-- 找回密码倒计时           1
-- 注册倒计时               2


local codeTime = { 0, 0 }
local codeTimeEntry = { nil, nil }
function player:openTimeCountDown(cType, totalTime)
    if not codeTimeEntry[cType] then
        codeTime[cType] = totalTime
        local function update(dt)
            print(codeTime[cType])
            codeTime[cType] = codeTime[cType] -1
            if codeTime[cType] <= 0 then
                player:closeTimeCountDown(cType)
            end
        end
        codeTimeEntry[cType] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
    end
end

function player:closeTimeCountDown(cType)
    if codeTimeEntry[cType] then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(codeTimeEntry[cType])
        codeTimeEntry[cType] = nil
    end
end

function player:setCodeTime(cType, time)
    codeTime[cType] = time
end

function player:getCodeTime(cType)
    return codeTime[cType]
end

local rUserName = ""
local rUserPassword = ""
function player:setRegisterInfo(userName, userpassword)
    rUserName = userName
    rUserPassword = userpassword
end

function player:getRegisterInfo()
    return rUserName, rUserPassword
end

function player:resetRegisterInfo()
    rUserName = ""
    rUserPassword = ""
end

-- 聊天语音
local chatcodeTimeEntry
local chatTime = 0

function player:setchatTime(time)
    if chatTime <= 0 then
        chatTime = time
    end
end

function player:chatopenTimeCountDown()
    local function update(dt)
        chatTime = chatTime - 1
        print("-------------------------------------------chat:", chatTime)
        if chatTime <= 0 then
            player:chatcloseTimeCountDown()
        end
    end
    if chatcodeTimeEntry == nil then
        chatcodeTimeEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 1, false)
    end
end

function player:chatcloseTimeCountDown()
    if chatcodeTimeEntry then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(chatcodeTimeEntry)
        chatcodeTimeEntry = nil
    end
end

function player:getchatTime()
    return chatTime
end

--win32启动透传参数
function player:getPlayerStartParam()
    return playerStartParam
end

function player:setPlayerStartParam(event)
    playerStartParam = event
end

--是否是透传启动
function player:getIsPassthroughParamStart()
    dump(playerStartParam)
    if playerStartParam and next(playerStartParam) ~= nil and device.platform == "windows" then
        return true
    else
        return false
    end
end

-------------------------------排行榜工厂----------------------------

--大厅前三
function player:getPlayerHallRank()
    return playerHallRank
end

function player:setPlayerHallRank(event)
    if event and event.ytdWeightRankList and event.ytdScoreRankList and event.ytdFreegameRankList then
        playerHallRank = { { }, { }, { } }
        playerHallRank[1] = event.ytdWeightRankList
        playerHallRank[2] = event.ytdScoreRankList
        playerHallRank[3] = event.ytdFreegameRankList
    else
        playerHallRank = event
    end
end

--总排名
function player:getPlayerRank()
    return playerRank
end

function player:setPlayerRank(event)
    playerRank.landlordKingRank = event.phoneWeightRankList
    playerRank.winnerKingRank = event.phoneScoreRankList
    playerRank.dayMatchRank = event.phoneGamefreeRankList

    playerRank.myLandlordKingRank = event.phoneMyWeightRankList
    playerRank.myWinnerKingRank = event.phoneMyScoreRankList
    playerRank.myDayMatchRank = event.phoneMyGamefreeRankList

    playerRank.phoneYesterdayWeightRankList = event.phoneYesterdayWeightRankList
    playerRank.phoneYesterdayScoreRankList = event.phoneYesterdayScoreRankList
    playerRank.phoneYesterdayGamefreeRankList = event.phoneYesterdayGamefreeRankList
end

--@setRank的时候存在处理本地客户端逻辑，如果服务器数据有误，就自动修改自己的名次
--@其他人的是不会变的
--地主王排行
function player:getPlayerLandlordKingRank()
    return playerRank.landlordKingRank
end

function player:setPlayerLandlordKingRank(event)
    playerRank.landlordKingRank = event
--    --先检测是否有自己在排行榜内，有就修改实时数据再排序
--    for k,v in pairs(playerRank.landlordKingRank) do
--        if tonumber(v.uid) == player:getPlayerUserID() then
--            if playerRank.myLandlordKingRank and playerRank.myLandlordKingRank.weight then
--                v.weight = tonumber(playerRank.myLandlordKingRank.weight)
--            end
--            table.sort(playerRank.landlordKingRank,function(a, b) return (a.weight) > (b.weight) end)
--            return
--        end
--    end
--    --如果排行榜内没有我的名字但是我的分数应该在排行榜内
--    if playerRank.landlordKingRank and #playerRank.landlordKingRank >= 10 then
--        if playerRank.myLandlordKingRank and playerRank.myLandlordKingRank.weight and tonumber(playerRank.myLandlordKingRank.weight) > playerRank.landlordKingRank[10].weight then
--            for i=1,#playerRank.landlordKingRank do
--                if playerRank.landlordKingRank[i].weight <= tonumber(playerRank.myLandlordKingRank.weight)  then
--                    table.insert(playerRank.landlordKingRank,i,playerRank.myLandlordKingRank)
--                    table.remove(playerRank.landlordKingRank,#playerRank.landlordKingRank)
--                    return
--                end
--            end
--        end
--    end
end

--得分王排行
function player:getPlayerWinnerKingRank()
    return playerRank.winnerKingRank
end

function player:setPlayerWinnerKingRank(event)
    playerRank.winnerKingRank = event
--    --先检测是否有自己在排行榜内，有就修改实时数据再排序
--    for k,v in pairs(playerRank.winnerKingRank) do
--        if tonumber(v.uid) == player:getPlayerUserID() then
--            if playerRank.myWinnerKingRank and playerRank.myWinnerKingRank.winScore then
--                v.winScore = tonumber(playerRank.myWinnerKingRank.winScore)
--            end
--            table.sort(playerRank.winnerKingRank,function(a, b) return (a.winScore) > (b.winScore) end)
--            return
--        end
--    end
--    --如果排行榜内没有我的名字但是我的分数应该在排行榜内
--    if playerRank.winnerKingRank and #playerRank.winnerKingRank >= 10 then
--        if playerRank.myWinnerKingRank and playerRank.myWinnerKingRank.winScore and tonumber(playerRank.myWinnerKingRank.winScore) > playerRank.winnerKingRank[10].winScore then
--            for i=1,#playerRank.winnerKingRank do
--                if playerRank.winnerKingRank[i].winScore <= tonumber(playerRank.myWinnerKingRank.winScore) then
--                    table.insert(playerRank.winnerKingRank,i,playerRank.myWinnerKingRank)
--                    table.remove(playerRank.winnerKingRank,#playerRank.winnerKingRank)
--                    return
--                end
--            end
--        end
--    end
end

--日赛排行
function player:getPlayerDayMatchRank()
    return playerRank.dayMatchRank
end

function player:setPlayerDayMatchRank(event)
    playerRank.dayMatchRank = event
end

--获取自己的
function player:getMyRankInfo()
    return playerRank.myLandlordKingRank , playerRank.myWinnerKingRank , playerRank.myDayMatchRank
end

function player:setMyRankInfo(event)
    playerRank.myLandlordKingRank = event.phoneMyWeightRankList
    playerRank.myWinnerKingRank = event.phoneMyScoreRankList
    playerRank.myDayMatchRank = event.phoneMyGamefreeRankList

    playerRank.myLandlordKingRank.userid = player:getPlayerUserID()
    playerRank.myLandlordKingRank.userid = player:getPlayerUserID()
    playerRank.myLandlordKingRank.userid = player:getPlayerUserID()

    playerRank.myLandlordKingRank.head = player:getPlayerHead()
    playerRank.myLandlordKingRank.head = player:getPlayerHead()
    playerRank.myLandlordKingRank.head = player:getPlayerHead()
end

-----------------------------------------暂时放这里-------------------------------





-----------------------------------
function player:release()
    playerData = nil
    roomInfo = { }
    tableInfo = { }
    mySeatID = -1
    nSignInfo = { }
    personalInfo = { }
    gameResultInfo = { }

    codeTime = { 0, 0 }
    codeTimeEntry = { nil, nil }

    shopList = { }
    recordList = { }
    --indianaList = { }
    indianaAddressList = { }
    cathecticList = { }

    mailList = { }
    str = ""
    G_SignInfo = { }
    isPromote = nil
    isBindPhone = nil
    disconnectCount = 0
    isReConnect = false
    vipInfo = nil
    vipReward = nil
    bgUse = nil
    isFirstLoginAndLaunchVipTip = false
    isShowQianDao = false
end

player:init()

return player
