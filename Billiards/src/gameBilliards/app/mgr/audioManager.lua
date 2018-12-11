
amgr = amgr or {}

local engine = ccexp.AudioEngine

function amgr.init()

    amgr.backMusicID = nil
    amgr.backMusicName = nil
    amgr.canViberate = nil

    local bPlayMusic = cc.UserDefault:getInstance():getStringForKey("playMusic","1")
    local bPlayEffect = cc.UserDefault:getInstance():getStringForKey("playEffect","1")
    local bViberate = cc.UserDefault:getInstance():getStringForKey("playViberate","1")
    amgr.nMusicVolume = cc.UserDefault:getInstance():getIntegerForKey("musicVolume",100)/100
    amgr.nEffectVolume = cc.UserDefault:getInstance():getIntegerForKey("effectVolume",100)/100

    amgr.nMusicVolume = amgr.nMusicVolume > 1 and 1 or amgr.nMusicVolume
    amgr.nEffectVolume = amgr.nEffectVolume > 1 and 1 or amgr.nEffectVolume

    print("[amgr.init] volume = ",amgr.nMusicVolume,amgr.nEffectVolume)

    if bPlayMusic == nil or bPlayMusic == "1" then
        amgr.canPlayeMusic = true
        if amgr.nMusicVolume == 0 then
            amgr.nMusicVolume = 50
        end
    else
        amgr.canPlayeMusic = false
        amgr.nMusicVolume = 0
    end
    if bPlayEffect == nil or bPlayEffect == "1" then
        amgr.canPlayeEffect = true
        if amgr.nEffectVolume == 0 then
            amgr.nEffectVolume = 50
        end
    else
        amgr.canPlayeEffect = false
        amgr.nEffectVolume = 0
    end
    if bViberate == nil or bViberate == "1" then
        amgr.canViberate = true
    else
        amgr.canViberate = false
    end
end

-- 背景音乐开关
function amgr.setMusicEnable(enable)
    enable = enable or false
    amgr.canPlayeMusic = enable
    local nFlag = enable and 1 or 0
    if enable == false then
        amgr.stopMusic(true)
        amgr.nMusicVolume = 0
    else
        if not amgr.backMusicID then
            amgr.playMusic(amgr.backMusicName,true)
        end
    end
    cc.UserDefault:getInstance():setStringForKey("playMusic", nFlag)
end

-- 音效开关
function amgr.setEffectEnable(enable)
    enable = enable or false
    local nFlag = enable and 1 or 0
    amgr.canPlayeEffect = enable
    if not enable then
        amgr.nEffectVolume = 0
    end
    cc.UserDefault:getInstance():setStringForKey("playEffect", nFlag)
end

--震动开关
function amgr.setViberateEnable(enable)
    enable = enable or false
    local nFlag = enable and 1 or 0
    print("[amgr.setViberateEnable]",enable,nFlag)
    amgr.canViberate = enable
    cc.UserDefault:getInstance():setStringForKey("playViberate", nFlag)
end

--获取音频状态
function amgr.getMusicAndEffectEnable()
    return amgr.canPlayeMusic,amgr.canPlayeEffect,amgr.canViberate
end

function amgr.getCanPlayMusic()
    return amgr.canPlayeMusic
end

function amgr.getCanPlayEffect()
    return amgr.canPlayeEffect
end

function amgr.getCanViberate()
    return amgr.canViberate
end

--震动
function amgr.playViberate(time)
    if amgr.canViberate then
        print("do viberate time = ", time)
        time =(time and time <= 1) and time or 0.5
        cc.Device:vibrate(time)
    end
end

local function getCorrectVolume(volume)
    if not volume then
        volume = 1
    else
        if volume > 100 or volume < 0 then
            volume = 1
        else
            volume = volume/100
        end
    end
    return volume
end

-- 同步音量到本地
function amgr.syncVolume()
    local music = math.ceil(amgr.nMusicVolume*100)
    local effect = math.ceil(amgr.nEffectVolume*100)
    if music > 100 or music < 0 then
        music = 100
    end
    if effect > 100 or effect < 0 then
        effect = 100
    end
    cc.UserDefault:getInstance():setIntegerForKey("musicVolume",music)
    cc.UserDefault:getInstance():setIntegerForKey("effectVolume",effect)
    cc.UserDefault:getInstance():setStringForKey("playMusic", amgr.canPlayeMusic and 1 or 0)
    cc.UserDefault:getInstance():setStringForKey("playEffect", amgr.canPlayeEffect and 1 or 0)
end

function amgr.setMusicVolume(volume)
    if volume < 0.01 then
        amgr.canPlayeMusic = false
    else
        amgr.canPlayeMusic = true
    end
    amgr.nMusicVolume = volume
    if amgr.backMusicID then
        engine:setVolume(amgr.backMusicID,amgr.nMusicVolume)
    else
        amgr.backMusicID = engine:play2d(amgr.backMusicName,true,amgr.nMusicVolume)
    end
end

function amgr.getMusicVolume()
    return amgr.nMusicVolume
end

function amgr.setEffectVolume(volume)
    if volume < 0.01 then
        amgr.canPlayeEffect = false
    else
        amgr.canPlayeEffect = true
    end
    amgr.nEffectVolume = volume
end
function amgr.getEffectVolume()
    return amgr.nEffectVolume
end

-- 播放音效
function amgr.playEffect(effectFile, loop, forceStopAll,volume)
    --print("[amgr.playEffect]",effectFile)
    if volume == true then
        volume = amgr.nEffectVolume
    else
        volume = getCorrectVolume(volume) 
    end
    if amgr.getCanPlayEffect() then
        local isLoop = loop and true or false
        engine:play2d(effectFile,isLoop,volume)
    end
end

function amgr.playEffectByVolume(effectFile,volume)
    if amgr.getCanPlayEffect() then
        engine:play2d(effectFile,false,volume)
    end
end

-- 播放背景音乐
function amgr.playMusic(musicName, loop,volume)
    if volume == true then
        volume = amgr.nMusicVolume
    else
        volume = getCorrectVolume(volume) 
    end
    if (amgr.backMusicName ~= musicName or amgr.backMusicID == nil) and amgr.getCanPlayMusic() then
        amgr.stopAll()
        amgr.backMusicName = musicName
        --if amgr.getCanPlayMusic() then
            local isLoop = loop and true or false
            amgr.backMusicID = engine:play2d(musicName, isLoop,volume)
        --end
    else
        amgr.backMusicName = musicName
    end
end

-- 停止播放背景音乐
function amgr.stopMusic(isReleaseData)
    if amgr.backMusicID then
        engine:stop(amgr.backMusicID)
        amgr.backMusicID = nil
    end
end

--停止播放Music
function amgr:pauseMusic()
     amgr.stopMusic()
end

function amgr.isMusicPlaying()
    return amgr.backMusicID and true or false
end

function amgr:stopAll(args)
    engine:stopAll()
end

-- 停止音效
function amgr.stopEffect(effecthandle)
    
end

-- 停止所有音效
function amgr.stopAllEffect()
    local musicCurrentTime
    if amgr.backMusicID then
        musicCurrentTime = engine:getCurrentTime(amgr.backMusicID)
    end
    engine:stopAll()
    if musicCurrentTime then
        amgr.backMusicID = engine:play2d(amgr.backMusicName, true)
        engine:setCurrentTime(amgr.backMusicID, musicCurrentTime)
    end
end

--预加载
local preloadIndex = 1
function amgr.preloadEffect(effectArray)
    if effectArray and next(effectArray) ~= nil then
        --这里是异步的...
        for i = 1, #effectArray do
            engine:preload(effectArray[i])
        end
    end
end

amgr.init()
