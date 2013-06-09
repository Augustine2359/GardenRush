//
//  NBBasicScreenLayer.m
//  ElementArmy1.0
//
//  Created by Romy Irawaty on 21/11/12.
//
//

#import "NBBasicScreenLayer.h"
#import "NBDataManager.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - NBBattleLayer

static int menuIndex = 0;
static CCScene* currentScreen = nil;
static CCScene* defaultScreen = nil;
static TargetSceneTypes currentLayerType = TargetSceneINVALID;

// NBBattleLayer implementation
@implementation NBBasicScreenLayer
+(TargetSceneTypes)getCurrentScreenType
{
    return currentLayerType;
}

// Helper class method that creates a Scene with the NBBattleLayer as the only child.
+(CCScene*)scene
{
    return [NBBasicScreenLayer sceneAndSetAsDefault:NO];
}

+(CCScene*)sceneAndSetAsDefault:(BOOL)makeDefault
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NBBasicScreenLayer *layer = [NBBasicScreenLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    if (makeDefault)
        defaultScreen = scene;
	
	// return the scene
	return scene;
}

+(CCScene*)loadCurrentScene
{
    if (!currentScreen)
    {
        DLog(@"No default screen has been initialized!");
    }
    
    return currentScreen;
}

+(void)setDefaultScreen:(CCScene*)scene
{
    defaultScreen = scene;
}

+(void)setCurrentScreen:(CCScene*)scene
{
    currentScreen = scene;
}

+(void)resetMenuIndex
{
    // Reset Menu Index
    menuIndex = 0;
}

// on "init" you need to initialize your instance
-(id)init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if ((self = [super init]))
    {
        //if (!self.dataManager)
        //    self.dataManager = [NBDataManager sharedDataManager];
        [NBDataManager sharedDataManager];
        
        self.currentFrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [self.currentFrameCache addSpriteFramesWithFile:@"GardenRushSpriteSheet1.plist"];
        self.currentSpritesBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"GardenRushSpriteSheet1.png"];
        [self addChild:self.currentSpritesBatchNode z:0 tag:0];
        
        self.layerSize = [[CCDirector sharedDirector] winSize];
        self.layerSizeInPixels = [[CCDirector sharedDirector] winSizeInPixels];
        DLog(@"Entering %@...window size: width (%f) height (%f)", NSStringFromClass([self class]), self.layerSizeInPixels.width, self.layerSizeInPixels.height);
        [self scheduleUpdate];
        
        self.isTouchEnabled = YES;
    }

	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

-(void)onEnter
{
	[super onEnter];
}

-(void)onExit
{
    //[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
    
    [super onExit];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)addStandardMenuString:(NSString*)menuTitle withSelector:(SEL)selectedMethod
{
    // Default font size will be 28 points.
    [CCMenuItemFont setFontSize:10];
    [CCMenuItemFont setFontName:@"Zapfino"];
    
    // create and initialize a Label
    CCLabelTTF* label = [CCLabelTTF labelWithString:menuTitle dimensions:CGSizeMake(120, 24) hAlignment:NSTextAlignmentLeft fontName:@"Zapfino" fontSize:10];
    CCMenuItem *startGameButtonMenu = [CCMenuItemFont itemWithLabel:label target:self selector:selectedMethod];
    self.menu = [CCMenu menuWithItems:startGameButtonMenu, nil];
    [self.menu setColor:ccWHITE];
    
    //[self.menu alignItemsHorizontally];
    [self.menu setPosition:ccp(60, (20 + ((label.contentSize.height - 4) * menuIndex)))];
    
    // Add the menu to the layer
    [self addChild:self.menu];
    
    menuIndex++;
}

-(void)setLayerColor:(ccColor4B)color
{
    CCLayerColor *backgroundColor = [CCLayerColor layerWithColor:color];
    [self addChild:backgroundColor];
}

-(void)displayLayerTitle:(NSString*)title
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    self.layerTitle = [CCLabelTTF labelWithString:title fontName:@"Zapfino" fontSize:32];
    self.layerTitle.position = CGPointMake(size.width / 2, size.height / 2);
    [self addChild:self.layerTitle];
}

-(void)changeToScene:(TargetSceneTypes)sceneType
{
    [self changeToScene:sceneType transitionWithDuration:1.0];
}

-(void)changeToScene:(TargetSceneTypes)sceneType transitionWithDuration:(float)duration
{
    [NBBasicScreenLayer resetMenuIndex];
    currentLayerType = sceneType;
    
    switch (sceneType)
    {
        case TargetSceneFirst:
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration scene:[NSClassFromString(@"NBTestScreen") scene] withColor:ccWHITE]];
            break;
      case TargetScenePreGame:
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration scene:[NSClassFromString(@"NBPreGameScreen") scene] withColor:ccWHITE]];
      case TargetSceneParticle:
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:duration scene:[NSClassFromString(@"NBParticleScreen") scene] withColor:ccBLUE]];
        default:
            break;
    }
}

-(void)setCurrentBackgroundWithFileName:(NSString*)fileName stretchToScreen:(BOOL)stretch
{
    CGSize size = [[CCDirector sharedDirector] winSize];

    self.background = [CCSprite spriteWithSpriteFrameName:fileName];
    
    if (stretch)
    {
        self.background.scaleX = size.width / self.background.contentSize.width;
        self.background.scaleY = size.height / self.background.contentSize.height;
    }

    self.background.position = ccp(size.width / 2, size.height / 2);

    // add the label as a child to this Layer
    [self addChild:self.background];
}

-(void)update:(ccTime)delta
{
}

@end
