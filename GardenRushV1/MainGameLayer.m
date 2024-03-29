//
//  HelloWorldLayer.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 4/5/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "MainGameLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"
#import "NBLayerWithFlowerAtEnd.h"

#pragma mark - MainGameLayer


// HelloWorldLayer implementation
@implementation MainGameLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainGameLayer *layer = [MainGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if ((self=[super init]))
    {
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        [NBAudioManager sharedInstance];
		
        //Add Sky
        CCSprite* sky = [CCSprite spriteWithFile:@"NB_FlowerFrenzyMainMenu_640x1136.png"];
        //sky.scaleX = (size.width + 20) / sky.contentSize.width;
        //sky.scaleY = (size.height + 20) / sky.contentSize.height;
        sky.position = ccp(size.width / 2, size.height / 2);
        [self addChild:sky z:0];
        
        // create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Flower Frenzy" fontName:@"Papyrus" fontSize:36];
        label.position =  ccp(size.width / 2, size.height * 0.75);
		[self addChild:label z:2];
        
        CCLabelTTF* playGameLabel =[CCLabelTTF labelWithString:@"Play" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Papyrus" fontSize:24];
        CCMenuItemLabel* playGameMenu = [CCMenuItemLabel itemWithLabel:playGameLabel target:self selector:@selector(gotoTestScreen)];
        CCMenu* mainMenu = [CCMenu menuWithItems:playGameMenu, nil];
		mainMenu.position =  ccp(size.width / 2, (size.height / 2) - 40);
		//[self addChild:mainMenu];
		
		[CCMenuItemFont setFontSize:28];
        
        CCSprite* normalPlayButton = [CCSprite spriteWithSpriteFrameName:@"NB_FlowerFrenzyMainMenuStart_194x106.png"];
        CCSprite* selectedPlayButton = [CCSprite spriteWithSpriteFrameName:@"NB_FlowerFrenzyMainMenuStart_194x106.png"];
        CCMenuItemSprite* playButtonMenu = [CCMenuItemSprite itemWithNormalSprite:normalPlayButton selectedSprite:selectedPlayButton target:self selector:@selector(gotoTestScreen)];
        CCMenu* playMenu = [CCMenu menuWithItems:playButtonMenu, nil];
        playMenu.anchorPoint = ccp(0, 0);
        playMenu.position =  ccp(75, 230);
		[self addChild:playMenu];

        [self addStandardMenuString:@"Submit Dummy Score" withSelector:@selector(submitDummyScoreForTest)];
        [self addStandardMenuString:@"View Leaderboard" withSelector:@selector(openGameCenterLeaderBoard)];
        [self addStandardMenuString:@"Test add node" withSelector:@selector(addNode)];
        [self addStandardMenuString:@"Test remove node" withSelector:@selector(removeNode)];
        [self addStandardMenuString:@"Pre-game screen" withSelector:@selector(goToPreGameScreen)];
        [self addStandardMenuString:@"Particle screen" withSelector:@selector(goToParticleScreen)];
      
        self.testNodeCountLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:24];
        self.testNodeCountLabel.position = CGPointMake(20, self.layerSize.height - 20);
        [self addChild:self.testNodeCountLabel];
        
        self.layerNodeCountLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:24];
        self.layerNodeCountLabel.position = CGPointMake(20, self.layerSize.height - 50);
        [self addChild:self.layerNodeCountLabel];
        
        NBGameKitHelper* gkHelper = [NBGameKitHelper sharedGameKitHelper];
        gkHelper.delegate = self;
        [gkHelper authenticateLocalPlayer];

        [NBDataManager assignDifficulty:2];
        
        [self doPetalsFalling];
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

-(void)update:(ccTime)delta
{
    [self.testNodeCountLabel setString:[NSString stringWithFormat:@"%i", [NBTestNode getTestNodeCount]]];
    [self.layerNodeCountLabel setString:[NSString stringWithFormat:@"%i", [self children].count]];
}

-(void)gotoTestScreen
{
    [self changeToScene:TargetScenePreGame];
}

-(void)goToPreGameScreen
{
    [self changeToScene:TargetScenePreGame];
}

- (void)goToParticleScreen
{
    [self changeToScene:TargetSceneParticle];
}

-(void)submitDummyScoreForTest
{
    NBGameKitHelper* gkHelper = [NBGameKitHelper sharedGameKitHelper];
    [gkHelper submitScore:1234 category:@"com.nebulasoft.FlowerFun.HighScore1"];
}

-(void)addNode
{
    NBTestNode* testNode = [[NBTestNode alloc] init];
    [self addChild:testNode z:0 tag:[NBTestNode getTestNodeCount]];
}

-(void)removeNode
{
    NBTestNode* testNode = (NBTestNode*)[self getChildByTag:[NBTestNode getTestNodeCount]];
    [self removeChildByTag:[NBTestNode getTestNodeCount] cleanup:YES];
    [testNode release];
}

-(void)openGameCenterLeaderBoard
{
    NBGameKitHelper* gkHelper = [NBGameKitHelper sharedGameKitHelper];
    [gkHelper showLeaderboard];
}

-(void)onScoresSubmitted:(bool)success
{
    if (success)
    {
        NBGameKitHelper* gkHelper = [NBGameKitHelper sharedGameKitHelper];
        [gkHelper retrieveTopTenAllTimeGlobalScores];
    }
}

-(void)onScoresReceived:(NSArray*)scores
{
    for (GKScore* score in scores)
    {
        CCLOG(@"Score submitted with value %lli", score.value);
    }
}

- (void)doPetalsFalling {
  [self schedule:@selector(generatePetal) interval:0.5 repeat:NSNotFound delay:0];
}

- (void)generatePetal {
  NSInteger width = [[CCDirector sharedDirector] winSize].width;
  NBLayerWithFlowerAtEnd *layerWithFlowerAtEnd = [[NBLayerWithFlowerAtEnd alloc] initWithColor:ccc4(0, 0, 0, 0) width:50 height:300];
  layerWithFlowerAtEnd.position = CGPointMake(arc4random()%width, [[CCDirector sharedDirector] winSize].height);
  [self addChild:layerWithFlowerAtEnd z:1];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void)onLocalPlayerAuthenticationChanged
{
    GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
    if (localPlayer.authenticated)
    {
        NBGameKitHelper* gkHelper = [NBGameKitHelper sharedGameKitHelper];
        [gkHelper getLocalPlayerFriends];
    }
}

-(void)onFriendListReceived:(NSArray*)friends
{
    NBGameKitHelper* gkHelper = [NBGameKitHelper sharedGameKitHelper];
    [gkHelper getPlayerInfo:friends];
}

-(void)onPlayerInfoReceived:(NSArray*)players
{
    for (GKPlayer* gkPlayer in players)
    {
        CCLOG(@"PlayerID: %@, Alias: %@", gkPlayer.playerID, gkPlayer.alias);
    }
}

-(void)onLeaderboardViewDismissed
{
    CCLOG(@"Leaderboard dismissed");
}

-(void)onAchievementsViewDismissed
{
    CCLOG(@"Achievement dismissed");
}

@end
