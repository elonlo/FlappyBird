-- game scene
require("GameLayer")
require("StatusLayer")

local function backgroundLayer()
	local bgLayer = cc.Layer:create()
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
	return bgLayer
end

local function createScene()
	local scene = cc.Scene:createWithPhysics()
	-- scene:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL)
	scene:getPhysicsWorld():setGravity(cc.p(0, -900))

	scene:addChild(backgroundLayer())
	local statusLayer = StatusLayer.create()
	local gameLayer = GameLayer.create()
	gameLayer:setDelegator(statusLayer)

	scene:addChild(gameLayer)
	scene:addChild(statusLayer)

	return scene
end

local GameScene = {
	createScene = createScene,
}

return GameScene