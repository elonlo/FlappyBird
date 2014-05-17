-- loading scene

local function createLoadingLayer()
	local loadLayer = cc.Layer:create()
	local bg = cc.Sprite:create("splash.png");
	bg:setPosition(origin.x + visibleSize.width/2, origin.y+visibleSize.height/2)
	loadLayer:addChild(bg)

	local function load_resource_call_back()
		local tex = cc.Director:getInstance():getTextureCache():addImage("atlas.png")
		AtlasLoader:getInstance():loadAtlas("atlas.txt", tex)
		AudioEngine.preloadEffect(SFX_DIE)
		AudioEngine.preloadEffect(SFX_HIT)
		AudioEngine.preloadEffect(SFX_POINT)
		AudioEngine.preloadEffect(SFX_SWOOSHING)
		AudioEngine.preloadEffect(SFX_WING)
 
		-- change the scene to welcomeScene after load all the things
		local wls  = require("WelcomeScene")	
		runScene(cc.TransitionFade:create(1, wls.createScene()))

	end

	performWithDelay(loadLayer, load_resource_call_back, 1)

	return loadLayer
end

local function createScene()
	local loadScene = cc.Scene:create()
	loadScene:addChild(createLoadingLayer())
	return loadScene
end

local loadingScene = {
	createScene = createScene,
}

return loadingScene
