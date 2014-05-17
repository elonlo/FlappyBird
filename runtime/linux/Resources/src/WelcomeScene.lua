-- Welcome scene

local function createBgLayer()
	local bgLayer = cc.Layer:create()
	--get the current time, the background image will selected by current time day or night: bg_day or bg_night
	local time = os.date("*t", os.time())
	local background = nil
	if time.hour >= 6 and time.hour <= 17 then
		background = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("bg_day"))
	else
		background = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("bg_night"))
	end
	background:setAnchorPoint(cc.p(0, 0))
	background:setPosition(0, 0)
	bgLayer:addChild(background)

	-- add the word game-title to the current scene
	local title = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("title"))
	title:setPosition(origin.x+visibleSize.width/2, (visibleSize.height * 5) / 7)
	bgLayer:addChild(title)

	-- create a bird and set the position in the center of the screen
	local bird = BirdSprite:getInstance()
	bird:createBird()
	bird:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height*3/5-10)
	bird:idle()
	bgLayer:addChild(bird)

	-- Add the land
	local land1 = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("land"))
	land1:setAnchorPoint(cc.p(0, 0))
	land1:setPosition(0, 0)
	bgLayer:addChild(land1)

	local land2 = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("land"))
	land2:setAnchorPoint(cc.p(0, 0))
	land2:setPosition(land1:getContentSize().width - 2, 0)
	bgLayer:addChild(land2)

	local function scrollLand()
		land1:setPositionX(land1:getPositionX() - 2.0)
		land2:setPositionX(land1:getPositionX() + land1:getContentSize().width - 2.0)
		if land2:getPositionX() == 0 then
			land1:setPositionX(0)
		end
	end
	schedule(bgLayer, scrollLand, 0.01)

	local function menuStartCallback()
		AudioEngine.playEffect(SFX_SWOOSHING)
		bgLayer:removeChildByTag(BIRD_SPRITE_TAG)
		local scene = require("GameScene")
		runScene(cc.TransitionFade:create(1, scene.createScene()))
	end
	-- add the start-menu to the current scene
	local startButton = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("button_play"))
	local activeStartButton = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("button_play"))
	activeStartButton:setPositionY(5)
	local menuItem = cc.MenuItemSprite:create(startButton, activeStartButton)
	menuItem:registerScriptTapHandler(menuStartCallback)
	menuItem:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height*2/5)
	local menu = cc.Menu:create(menuItem)
	menu:setPosition(origin.x, origin.y)
	bgLayer:addChild(menu, 1)

	-- add the copyright-text to the current scne
	local copyright = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("brand_copyright"))
	copyright:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height/6)
	bgLayer:addChild(copyright, 10)

	return bgLayer
end

local function createMenuLayer()
	local menuLayer = cc.Layer:create()
	return menuLayer
end

local function createScene()
	local wlScene = cc.Scene:create()
	wlScene:addChild(createBgLayer())
	wlScene:addChild(createMenuLayer())
	return wlScene
end

local welcomeScene = {
	createScene = createScene,
}

return welcomeScene