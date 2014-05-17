
GAME_STATUS_READY = 1
GAME_STATUS_START = 2
GAME_STATUS_OVER = 3
UP_PIP = 21

DOWN_PIP = 12

PIP_PASS = 30

PIP_NEW = 31

--The radius of the bird
BIRD_RADIUS = 15

--The height of the pips
 PIP_HEIGHT = 320

--The width of the pips
PIP_WIDTH = 52

--Pip shift speed
PIP_SHIFT_SPEED = 80.0

--The distance between the down pip and up pip
PIP_DISTANCE = 100

--The distance between the pips vertical
PIP_INTERVAL = 180

--The number of pip pairs display in the screen in the same time
PIP_COUNT = 2

--The distance that the pip will display in the screen, for player to ready
WAIT_DISTANCE = 100

GameLayer = class("GameLayer")

GameLayer.__index = GameLayer

function GameLayer.extend(target)
	local t = tolua.getpeer(target)
	if not t then
	    	t = {}
	    	tolua.setpeer(target, t)
	end
	setmetatable(t, GameLayer)
	return target
end

function GameLayer:onEnter()
	self._pips = {}
	self:init()
end

function GameLayer:onExit()

end

function GameLayer.create()
	local layer = GameLayer.extend(cc.Layer:create())
	if nil ~= layer then
		-- layer:init()
		layer:createLand()
		layer:createBird()
		local function onNodeEvent(event)
			if "enter" == event then
				layer:onEnter()
			elseif "exit" == event then
            	layer:onExit()
			end
		end
		layer:registerScriptHandler(onNodeEvent)
	end
	return layer
end

function GameLayer:createBird()
	-- Add the bird
	self._bird = BirdSprite:getInstance()
	self._bird:createBird()
	local body = cc.PhysicsBody:create()
	body:addShape(cc.PhysicsShapeCircle:create(BIRD_RADIUS))
	body:setDynamic(true)
	body:setLinearDamping(0.0)
	body:setGravityEnable(false)
	body:setCategoryBitmask(1)
	body:setContactTestBitmask(-1)
	body:setCollisionBitmask(-1)
	self._bird:setPhysicsBody(body)
	self._bird:setPosition(origin.x + visibleSize.width*1/3-5, origin.y + visibleSize.height/2 + 5)
	self._bird:idle()
	self:addChild(self._bird)
end

function GameLayer:createLand()
	--Add the ground
	self._groundNode = cc.Node:create()
	local landHeight = self:getLandHeight()
	local groundBody = cc.PhysicsBody:create()
	groundBody:addShape(cc.PhysicsShapeBox:create(cc.size(288, landHeight)))
	groundBody:setDynamic(false)
	groundBody:setCategoryBitmask(1)
	groundBody:setContactTestBitmask(-1)
	groundBody:setCollisionBitmask(-1)
	groundBody:setLinearDamping(0.0)
	self._groundNode:setPhysicsBody(groundBody)
	self._groundNode:setPosition(144, landHeight/2)
	self:addChild(self._groundNode)

	-- Add the land
	local land1 = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("land"))
	land1:setAnchorPoint(cc.p(0, 0))
	land1:setPosition(0, 0)
	self:addChild(land1, 10)

	local land2 = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("land"))
	land2:setAnchorPoint(cc.p(0, 0))
	land2:setPosition(land1:getContentSize().width - 2, 0)
	self:addChild(land2, 10)

	local function scrollLand()
		if self._gameStatus == GAME_STATUS_OVER then
			return
		end
		-- move the land
		land1:setPositionX(land1:getPositionX() - 2.0)
		land2:setPositionX(land1:getPositionX() + land1:getContentSize().width - 2.0)
		if land2:getPositionX() == 0 then
			land1:setPositionX(0)
		end

		--move the pips
		for _, pip in ipairs(self._pips) do
			pip:setPositionX(pip:getPositionX() - 2.0)
			if pip:getPositionX() + PIP_WIDTH <= 0 then
				pip:setTag(PIP_NEW)
				pip:setPosition(visibleSize.width + PIP_WIDTH/2, self:getRandomHeight())
			end
		end
	end
	schedule(self, scrollLand, 0.01)
end

function GameLayer:init()
	self._gameStatus = GAME_STATUS_READY
	self._score = 0

	local function update(dt)
		if self._gameStatus == GAME_STATUS_START then
			self:rotateBird()
			self:checkHit()
		end
	end
    self:scheduleUpdateWithPriorityLua(update,0)

	local function onContactBegin(contact)
		cclog("contact")
 		self:gameOver()
 		return true
 	end
    local contactListener = cc.EventListenerPhysicsContact:create();
  	contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN);
  	local eventDispatcher = self:getEventDispatcher()
  	eventDispatcher:addEventListenerWithSceneGraphPriority(contactListener, self);

  	-- touch 
  	self:setTouchEnabled(true)
	-- handling touch events   
	local function onTouchEnded(touch, event)
		if self._gameStatus == GAME_STATUS_OVER then
			return
		end
		AudioEngine.playEffect(SFX_WING)
		if self._gameStatus == GAME_STATUS_READY then
			self._delegator:onGameStart()
			self._bird:fly()
			self._bird:getPhysicsBody():setVelocity(cc.p(0, 26))
			self._gameStatus = GAME_STATUS_START
			self:createPips()
		elseif self._gameStatus == GAME_STATUS_START then
			self._bird:getPhysicsBody():setVelocity(cc.p(0, 260))
		end
    end
	local function onTouchBegan(touch, event)
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)

	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)
end

function GameLayer:getLandHeight()
	return cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("land")):getContentSize().height
end

function GameLayer:gameOver()
	cclog("game over")
	if self._gameStatus == GAME_STATUS_OVER then
		return
	end
	AudioEngine.playEffect(SFX_HIT)
	--保存数据
	local bestScore = cc.UserDefault:getInstance():getIntegerForKey("best_score")
	if self._score > bestScore then
		cc.UserDefault:getInstance():setIntegerForKey("best_score", self._score)
	end
	--控制显示gameOver
	self._delegator:onGameOver(self._score, bestScore)

	AudioEngine.playEffect(SFX_DIE)
	self._bird:die()
	self._bird:setRotation(-90)
	self:birdSpriteFadeOut()
	self._gameStatus = GAME_STATUS_OVER
end

function GameLayer:setDelegator(_delegator)
	self._delegator = _delegator
end

function GameLayer:rotateBird()
	local verticalSpeed = self._bird:getPhysicsBody():getVelocity().y
	--setRotation(angle) 其中angle为角度不是弧度。正数为顺时针旋转，负数为逆时针旋转。
	self._bird:setRotation((-1)*math.min(math.max(-90, (verticalSpeed*0.2 + 60)), 30))
end

function GameLayer:checkHit()
	for _, pip in ipairs(self._pips) do
		if pip:getTag() == PIP_NEW then
			if pip:getPositionX() < self._bird:getPositionX() then
				AudioEngine.playEffect(SFX_POINT)
				self._score = self._score + 1
				self._delegator:onGamePlaying(self._score)
				pip:setTag(PIP_PASS)
			end
		end
	end
end

function GameLayer:createPips()
	--实际只有创建两根水管
	for i = 0, PIP_COUNT-1 do
		local pipUp = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("pipe_up"))
		local pipDown = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("pipe_down"))
		local singlePip = cc.Node:create()

		pipDown:setPosition(0, PIP_HEIGHT + PIP_DISTANCE)
		singlePip:addChild(pipDown, 0, DOWN_PIP)
		singlePip:addChild(pipUp, 0, UP_PIP)
		singlePip:setPosition(visibleSize.width + i*PIP_INTERVAL + WAIT_DISTANCE, self:getRandomHeight())

		local body = cc.PhysicsBody:create()
		local shapeDown = cc.PhysicsShapeBox:create(pipDown:getContentSize(), cc.PHYSICSSHAPE_MATERIAL_DEFAULT, cc.p(0, PIP_HEIGHT + PIP_DISTANCE))
		body:addShape(shapeDown)
		local shapeUp = cc.PhysicsShapeBox:create(pipUp:getContentSize())
		body:addShape(shapeUp)
		body:setCategoryBitmask(0x01)
		body:setContactTestBitmask(-1)
		body:setCollisionBitmask(-1)
		body:setDynamic(false)

		singlePip:setPhysicsBody(body)
		singlePip:setTag(PIP_NEW)
		self:addChild(singlePip)
		table.insert(self._pips, singlePip)
	end
end

function GameLayer:getRandomHeight()
	return math.random(0, 2*PIP_HEIGHT + PIP_DISTANCE - visibleSize.height)
end

function GameLayer:birdSpriteFadeOut()
	local function birdSpriteRemove()
		self._bird:setRotation(0)
		self._bird:cleanBird()
	end

	local animationDone = cc.CallFunc:create(birdSpriteRemove)
	local sequence = cc.Sequence:create(cc.FadeOut:create(1.5), animationDone)
	self._bird:stopAllActions()
	self._bird:runAction(sequence)
end
