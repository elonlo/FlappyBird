#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // initialize director
    auto director = Director::getInstance();
	auto glview = director->getOpenGLView();
	if(!glview) {
		glview = GLView::createWithRect("Flappy Bird", Rect(0,0,480, 800));
		director->setOpenGLView(glview);
	}

    // glview->setDesignResolutionSize(288,512, ResolutionPolicy::SHOW_ALL);
    glview->setDesignResolutionSize(288, 512, ResolutionPolicy::EXACT_FIT);

    // turn on display FPS
/*    director->setDisplayStats(true);*/

    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);


	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
	engine->executeScriptFile("src/main.lua");

    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
}
