local GRAVITY_CENTER = 1
local GRAVITY_LEFT = 2
local GRAVITY_RIGHT = 3
local Number_Score = "number_score"
local Number_Font = "font"
local Current_Score_Sprite_Tag = 10001

StatusLayer = class("StatusLayer", function ()
	return cc.Layer:create()
end)

function StatusLayer.create()
	local layer = StatusLayer.new()
	if nil ~= layer then
		--加载资源 字体1 number_score 0-9
		layer:loadNumber(Number_Score, "number_score_%02d")
		--加载资源 字体2 font_  用于游戏过程中分数显示
		layer:loadNumber(Number_Font,"font_0%02d",48)
		layer:showReadyStatus()
		layer:loadWhiteSprite()
	end
	return layer
end

function StatusLayer:ctor()
	self._bestScore = 0;
	self._currentScore = 0;
	self._isNewRecord = false;
	self._numberContainer = {}
end

function StatusLayer:showReadyStatus()
	--游戏过程中显示的分数，
	self._scoreSprite = self:convert(Number_Font, 0)
	self._scoreSprite:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height * 5 / 6)
	self:addChild(self._scoreSprite)

	--Get Ready 字样
	self._getreadySprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("text_ready"))
	self._getreadySprite:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height*2/3)
	self:addChild(self._getreadySprite)

	--操作说明图片
	self._tutorialSprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("tutorial"))
	self._tutorialSprite:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height*1/2)
	self:addChild(self._tutorialSprite)
end

function StatusLayer:onGameStart()
	--淡出
	self._tutorialSprite:runAction(cc.FadeOut:create(0.4))
	self._getreadySprite:runAction(cc.FadeOut:create(0.4))
end

function StatusLayer:onGamePlaying(score)
	--更新得分
	self:removeChild(self._scoreSprite)
	self._scoreSprite = self:convert(Number_Font, score)
	self._scoreSprite:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height * 5/6)
	self:addChild(self._scoreSprite)
end

function StatusLayer:onGameOver(curScore, bestScore)
	self._currentScore = curScore
	self._bestScore = bestScore
	if curScore > bestScore then
		self._bestScore = curScore
		self._isNewRecord = true
	else
		self._isNewRecord = false
	end
	self:removeChild(self._scoreSprite)
	self:blinkFullScreen()
end

function StatusLayer:blinkFullScreen()
	--白光一闪
	local function jump()
		self:fadeInGameOver()
	end

	local blinkAction = cc.Sequence:create(cc.FadeOut:create(0.1), cc.FadeIn:create(0.1))
	local actionDone = cc.CallFunc:create(jump)
	self._whiteSprite:stopAllActions()
	self._whiteSprite:runAction(cc.Sequence:create(blinkAction, actionDone))
end

function StatusLayer:fadeInGameOver()
	local function jump()
		self:jumpToScorePanel()
	end
	-- game over 字样
	local gameOverSprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("text_game_over"))
	gameOverSprite:setPosition(origin.x + visibleSize.width/2, origin.y + visibleSize.height* 2/3)
	self:addChild(gameOverSprite)
	local gameOverFadeIn = cc.FadeIn:create(0.5)

	--callback
	gameOverSprite:stopAllActions()
	gameOverSprite:runAction(cc.Sequence:create(gameOverFadeIn, cc.CallFunc:create(jump)))
end

function StatusLayer:jumpToScorePanel()
	-- score_panel
	local scorePanelSprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("score_panel"))
	scorePanelSprite:setPosition(origin.x + visibleSize.width/2, origin.y - scorePanelSprite:getContentSize().height)
	self:addChild(scorePanelSprite)
	-- best_Score
	local bestScoreSprite = self:convert(Number_Score, self._bestScore, GRAVITY_RIGHT)
	bestScoreSprite:setAnchorPoint(cc.p(1, 1))
	bestScoreSprite:setPosition(scorePanelSprite:getContentSize().width - 28 , 50)
	scorePanelSprite:addChild(bestScoreSprite)

	-- model
	local modelName = self:getModalsName(self._currentScore)
	if "" ~= modelName then
		local modelNameSprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName(modelName))
		modelNameSprite:setPosition(54, 58)
		modelNameSprite:addChild(self._blink)
		scorePanelSprite:addChild(modelNameSprite)
	end

	-- new 新纪录
	if self._isNewRecord then
		local newTagSprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("new"))
		newTagSprite:setPosition(-16, 12)
		bestScoreSprite:addChild(newTagSprite)
	end

	-- start next action
	local function jump()
		self:fadeInRestartBtn()
	end
	local scorePanelMoveTo = cc.MoveTo:create(0.8, cc.p(origin.x + visibleSize.width/2, origin.y + visibleSize.height/2 - 10))
	local sineIn = cc.EaseExponentialOut:create(scorePanelMoveTo)
	local actionDone = cc.CallFunc:create(jump)
	scorePanelSprite:stopAllActions()
	AudioEngine.playEffect(SFX_SWOOSHING)
	scorePanelSprite:runAction(cc.Sequence:create(sineIn, actionDone))
end

function StatusLayer:fadeInRestartBtn()
	local tempNode = cc.Node:create()
	-- create the restart menu
	local function menuRestartCallback()
		AudioEngine.playEffect(SFX_SWOOSHING)
		local scene = require("GameScene")
		runScene(cc.TransitionFade:create(1, scene.createScene()))
	end
	local restartBtn = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("button_play"))
	local restartBtnActive = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("button_play"))
	restartBtnActive:setPositionY(-4)
	local menuItem = cc.MenuItemSprite:create(restartBtn, restartBtnActive)
	menuItem:registerScriptTapHandler(menuRestartCallback)
	local menu = cc.Menu:create(menuItem)
	menu:setPosition(origin.x + visibleSize.width/2 - restartBtn:getContentSize().width/2, origin.y + visibleSize.height * 2/7 - 10)
	tempNode:addChild(menu)


	-- rate btn
	local rateBtn = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("button_score"))
	rateBtn:setPosition(origin.x + visibleSize.width/2 + rateBtn:getContentSize().width/2, origin.y + visibleSize.height * 2/7 - 10)
	tempNode:addChild(rateBtn)

	self:addChild(tempNode)

	-- fade in two button
	local function refreshScoreCallback()
		self:refreshScoreExecutor()
	end
	local fadeIn = cc.FadeIn:create(0.1)
	local actionDone = cc.CallFunc:create(refreshScoreCallback)
	tempNode:stopAllActions()
	tempNode:runAction(cc.Sequence:create(fadeIn, actionDone))
end

function StatusLayer:refreshScoreExecutor()
	self._tmpScore = 0
	local function caculScore()
		if self._tmpScore > self._currentScore then
			return
		end
		if self:getChildByTag(Current_Score_Sprite_Tag) then
			self:removeChildByTag(Current_Score_Sprite_Tag)
		end
		self._scoreSprite = self:convert(Number_Score, self._tmpScore, GRAVITY_RIGHT)
		self._scoreSprite:setAnchorPoint(cc.p(1, 0))
		self._scoreSprite:setPosition(origin.x + visibleSize.width * 3/4 + 20, origin.y + visibleSize.height * 1/2)
		self._scoreSprite:setTag(Current_Score_Sprite_Tag)
		self:addChild(self._scoreSprite, 1000)
		self._tmpScore = self._tmpScore + 1
	end
	schedule(self, caculScore, 0.1)
end


function StatusLayer:loadWhiteSprite()
	--this white sprite is used for blinking the screen for a short while
	self._whiteSprite = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("white"))
	self._whiteSprite:setScale(100)
	self._whiteSprite:setOpacity(0)
	self:addChild(self._whiteSprite)
end

function StatusLayer:getModalsName(score)
	self:setBlinkSprite()
	local modelName = ""	
	if score >=0 and score < 20 then
		modelName = "medals_0"
	elseif score >= 20 and score < 30 then
		modelName = "medals_1"
	elseif score >= 30 and score < 50 then
		modelName = "medals_2"
	elseif score >= 50 then
		modelName = "medals_3"
	end
	return modelName
end

function StatusLayer:setBlinkSprite()
	self._blink = cc.Sprite:createWithSpriteFrame(AtlasLoader:getInstance():getSpriteFrameByName("blink_00"))

	local animation = cc.Animation:create()
	animation:setDelayPerUnit(0.1)
	for i = 0, 2 do
		local filename = string.format("blink_%02d", i)
		local frame = AtlasLoader:getInstance():getSpriteFrameByName(filename)
		animation:addSpriteFrame(frame)
	end
	for i = 2, 0, -1 do
		local filename = string.format("blink_%02d", i)
		local frame = AtlasLoader:getInstance():getSpriteFrameByName(filename)
		animation:addSpriteFrame(frame)
	end
	local animate = cc.Animate:create(animation)

	local function blinkAction()
		if self._blink and self._blink:getParent() then
			local activeSize = self._blink:getParent():getContentSize()
			self._blink:setPosition(math.random(0, activeSize.width), math.random(0, activeSize.height))
		end
	end
	local actionDone = cc.CallFunc:create(blinkAction)
	self._blink:runAction(cc.RepeatForever:create(cc.Sequence:create(animate, actionDone)))
end

function StatusLayer:loadNumber(name, fmt, base)
	base = base == nil and 0 or base
	local numberSeries = {}
	for i = base, 9+base do
		local filename = string.format(fmt, i)
		local frame = AtlasLoader:getInstance():getSpriteFrameByName(filename)
		-- numberSeries[i] = frame
		table.insert(numberSeries, frame)
	end
	self._numberContainer[name] = numberSeries
	-- table.insert(self._numberContainer, numberSeries)
end

function StatusLayer:convert(name, number, gravity)
	gravity = gravity == nil and GRAVITY_CENTER or gravity
	local numbers = self._numberContainer[name]
	if 0 == number then
		cclog("=====number: " .. tostring(numbers[1]))
		local numberZero = cc.Sprite:createWithSpriteFrame(numbers[1])
		numberZero:setAnchorPoint(0.5, 0)
		return numberZero
	end
	local numberNode = cc.Node:create()
	local totalWidth = 0
	while number ~= 0 do
		local temp = math.fmod(number, 10)
		number = math.floor(number/10)
		local sprite = cc.Sprite:createWithSpriteFrame(numbers[temp+1])
		totalWidth = totalWidth + sprite:getContentSize().width
		numberNode:addChild(sprite)
	end
	local numberZero = cc.Sprite:createWithSpriteFrame(numbers[1])
	numberNode:setContentSize(cc.size(totalWidth, numberZero:getContentSize().height))

    local pChildren = numberNode:getChildren()

	if gravity == GRAVITY_CENTER then
		local singleWidth = totalWidth / numberNode:getChildrenCount()
		local index = numberNode:getChildrenCount() / 2
		for i = 1, numberNode:getChildrenCount() do
			local child = pChildren[i]
			child:setAnchorPoint(cc.p(0.5, 0))
			local offLength = singleWidth * index
			index = index - 1
			child:setPositionX(offLength)
		end
	elseif gravity == GRAVITY_LEFT then
		local singleWidth = totalWidth / numberNode:getChildrenCount()
		local index = 0
		for i = 1, numberNode:getChildrenCount() do
			local child = pChildren[i]
			child:setAnchorPoint(cc.p(0, 0))
			local offLength = singleWidth * index
			index = index + 1
			child:setPositionX(offLength)
		end
	elseif gravity == GRAVITY_RIGHT then
		local singleWidth = totalWidth / numberNode:getChildrenCount()
		local index = numberNode:getChildrenCount()
		for i = 1, numberNode:getChildrenCount() do
			local child = pChildren[i]
			child:setAnchorPoint(cc.p(1, 0))
			local offLength = singleWidth * index
			index = index - 1
			child:setPositionX(offLength)
		end
	end

	return numberNode
end
