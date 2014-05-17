-- Bird Sprite

BIRD_SPRITE_TAG = 10003
local ACTION_STATE_IDLE = 0
local ACTION_STATE_FLY = 1
local ACTION_STATE_DIE = 2

--Bird Sprite class
BirdSprite = class("BirdSprite", function (spriteframe)
	return cc.Sprite:createWithSpriteFrame(spriteframe)
end)

BirdSprite.__index = BirdSprite
BirdSprite._shareBirdSprite = nil
BirdSprite._isFirstTime = 3


function BirdSprite:ctor()
	self._isFirstTime = 3
end

function BirdSprite:getInstance()
	if BirdSprite._shareBirdSprite == nil then
		BirdSprite._shareBirdSprite = BirdSprite.new(AtlasLoader:getInstance():getSpriteFrameByName("bird0_0"))
		BirdSprite._shareBirdSprite:retain()
	end
	return BirdSprite._shareBirdSprite
end

function BirdSprite:cleanBird()
	self:removeFromParent()
	self:release()
	BirdSprite._shareBirdSprite = nil
end

-- create && init the bird
function BirdSprite:createBird()
	self:createBirdNameByRandom()
	self:setSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName(self._birdName))
	self:setTag(BIRD_SPRITE_TAG)
	if self then
		-- create the bird animation
		local animation = self:createAnimation(self._birdNameFormat, 3, 10)
		local animate = cc.Animate:create(animation)
		self._idleAction = cc.RepeatForever:create(animate)

		--create the swing action
		local up = cc.MoveBy:create(0.4, cc.p(0, 8))
		local upBack = up:reverse()
		self._swingAction = cc.RepeatForever:create(cc.Sequence:create(up, upBack))
	end
end

function BirdSprite:changeState(_state)
	self._currentState = _state
end

function BirdSprite:idle()
	self:changeState(ACTION_STATE_IDLE)
	self:runAction(self._idleAction)
	self:runAction(self._swingAction)
end

function BirdSprite:fly()
	self:changeState(ACTION_STATE_FLY)
	self:stopAction(self._swingAction)
	self:getPhysicsBody():setGravityEnable(true)
end

function BirdSprite:die()
	self:changeState(ACTION_STATE_DIE)
	self:stopAllActions()
end

-- This method change current status. called by fly and idle etc.
function BirdSprite:createAnimation(format, count , fps)
	local animation = cc.Animation:create()
	animation:setDelayPerUnit(1/fps)
	for i = 0, count-1 do
		local filename = string.format(format, i)
		local frame = AtlasLoader:getInstance():getSpriteFrameByName(filename)
		animation:addSpriteFrame(frame)
	end
	return animation
end

--Since this game has three different types of bird
-- this method is just used for choosing which type of bird by random
function BirdSprite:createBirdNameByRandom()
	math.randomseed(os.time())
	local birdType = math.random(1, 3)
	if birdType == 1 then
		self._birdName = "bird0_0"
		self._birdNameFormat = "bird0_%d"
	elseif birdType == 2 then
		self._birdName = "bird1_0"
		self._birdNameFormat = "bird1_%d"
	else
		self._birdName = "bird2_0"
		self._birdNameFormat = "bird2_%d"
	end
	-- if(this->isFirstTime & 1){
	-- 	this->isFirstTime &= 2;
	-- }else if(this->isFirstTime & 2){
	-- 	this->isFirstTime &= 1;
	-- 	return ;
	-- }
end

