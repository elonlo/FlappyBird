
-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end

-- run a scene
function runScene(_scene)
     if cc.Director:getInstance():getRunningScene() then
        cc.Director:getInstance():replaceScene(_scene)
    else
        cc.Director:getInstance():runWithScene(_scene)
    end
end

-- static var
visibleSize = cc.Director:getInstance():getVisibleSize()
origin = cc.Director:getInstance():getVisibleOrigin()

local function loadCocosLib()
    require "Cocos2d"
    require "Cocos2dConstants"
    require "Resource"
    require("AudioEngine")
    require("extern")
    require("AtlasLoader")
    require("BirdSprite")
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()

    if targetPlatform == cc.PLATFORM_OS_WINDOWS then
        cc.FileUtils:getInstance():addSearchResolutionsOrder("res/sounds/wav")
        EFFECT_FORMAT = ".wav"
    else
        cc.FileUtils:getInstance():addSearchResolutionsOrder("res/sounds/ogg")
    end
    cc.FileUtils:getInstance():addSearchResolutionsOrder("src")
    cc.FileUtils:getInstance():addSearchResolutionsOrder("res/fonts")
    cc.FileUtils:getInstance():addSearchResolutionsOrder("res/image")
    

    loadCocosLib()

    local ls = require("LoadingScene")
    runScene(ls.createScene())
end


xpcall(main, __G__TRACKBACK__)
