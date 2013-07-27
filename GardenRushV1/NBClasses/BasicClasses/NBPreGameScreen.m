//
//  NBPreGameScreen.m
//  GardenRushV1
//
//  Created by Augustine on 31/5/13.
//
//

#import "NBPreGameScreen.h"
#import "NBSpecialPowerButtonsContainer.h"

@interface NBPreGameScreen()<NBSpecialPowerButtonsContainerDelegate>

@property (nonatomic, strong) CCScene* currentScene;
@property (nonatomic, strong) NBSpecialPowerButtonsContainer *inGameItemsButtonsContainer;
@property (nonatomic, strong) CCLayerColor *dimmer;
@property (nonatomic, strong) NBSpecialPowerButtonsContainer *iapButtonsContainer;

@end

@implementation NBPreGameScreen

+(CCScene*)scene
{
  return [NBPreGameScreen sceneAndSetAsDefault:NO];
}

+(CCScene*)sceneAndSetAsDefault:(BOOL)makeDefault
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NBPreGameScreen *layer = [NBPreGameScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
  
  if (makeDefault)
    [NBBasicScreenLayer setDefaultScreen:scene];
	
	// return the scene
	return scene;
}

- (id)init {
  self = [super init];
  if (self) {
    [NBAudioManager sharedInstance];
  }

  return self;
}

- (void)onEnter {
  [super onEnter];
  
//  UI_USER_INTERFACE_IDIOM();
//
//  self.inGameItemsButtonsContainer = [[NBSpecialPowerButtonsContainer alloc] init];
//  self.inGameItemsButtonsContainer.delegate = self;
//  [self addChild:self.inGameItemsButtonsContainer];
//  
//  ccColor4B color = ccc4(0, 0, 0, 0);
//  self.dimmer = [CCLayerColor layerWithColor:color];
//  [self addChild:self.dimmer];
//  
//  self.iapButtonsContainer = [[NBSpecialPowerButtonsContainer alloc] init];
//  self.iapButtonsContainer.position = CGPointMake(self.iapButtonsContainer.position.x, self.iapButtonsContainer.position.y + 100);
//  self.iapButtonsContainer.delegate = self;
//  [self.iapButtonsContainer setShouldRespondToTouches:NO];
//  [self addChild:self.iapButtonsContainer];
    
    //Eric
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self setIsTouchEnabled:YES];
    
    //Energy
    CCSprite* energySprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    [energySprite setScale:3];
    [energySprite setPosition:ccp(screenSize.width*0.15, screenSize.height*0.9)];
    [self addChild:energySprite];
    
    int energyLevel = 5;
    CCLabelTTF* energyLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"X %i", energyLevel] fontName:@"Marker Felt" fontSize:30];
    [energyLabel setPosition:ccp(energySprite.position.x+energySprite.boundingBox.size.width, energySprite.position.y)];
    [self addChild:energyLabel];
    
    //3 Items
    CCSprite* item1Sprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    [item1Sprite setScale:4];
    [item1Sprite setPosition:ccp(screenSize.width*0.25, screenSize.height*0.6)];
    [self addChild:item1Sprite];
    
    CCSprite* item2Sprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    [item2Sprite setScale:4];
    [item2Sprite setPosition:ccp(screenSize.width*0.5, screenSize.height*0.6)];
    [self addChild:item2Sprite];
    
    CCSprite* item3Sprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    [item3Sprite setScale:4];
    [item3Sprite setPosition:ccp(screenSize.width*0.75, screenSize.height*0.6)];
    [self addChild:item3Sprite];
    
    //3 Buy Buttons
    CCSprite* buyItem1ButtonNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    CCSprite* buyItem1ButtonSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    CCMenuItemSprite* buyItem1Button = [CCMenuItemSprite itemWithNormalSprite:buyItem1ButtonNormal selectedSprite:buyItem1ButtonSelected target:self selector:@selector(goToAppStore)];
    
    [buyItem1Button setScaleX:4];
    [buyItem1Button setScaleY:3];
    [buyItem1Button setPosition:ccp(item1Sprite.position.x, item1Sprite.position.y-buyItem1Button.boundingBox.size.height*2)];
    [self addChild:buyItem1Button];

    CCSprite* buyItem2ButtonNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    CCSprite* buyItem2ButtonSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    CCMenuItemSprite* buyItem2Button = [CCMenuItemSprite itemWithNormalSprite:buyItem2ButtonNormal selectedSprite:buyItem2ButtonSelected target:self selector:@selector(goToAppStore)];
    
    [buyItem2Button setScaleX:4];
    [buyItem2Button setScaleY:3];
    [buyItem2Button setPosition:ccp(item2Sprite.position.x, item2Sprite.position.y-buyItem2Button.boundingBox.size.height*2)];
    [self addChild:buyItem2Button];
    
    CCSprite* buyItem3ButtonNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    CCSprite* buyItem3ButtonSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    CCMenuItemSprite* buyItem3Button = [CCMenuItemSprite itemWithNormalSprite:buyItem3ButtonNormal selectedSprite:buyItem3ButtonSelected target:self selector:@selector(goToAppStore)];
    
    [buyItem3Button setScaleX:4];
    [buyItem3Button setScaleY:3];
    [buyItem3Button setPosition:ccp(item3Sprite.position.x, item3Sprite.position.y-buyItem3Button.boundingBox.size.height*2)];
    [self addChild:buyItem3Button];

//    CCMenu* GUIMenu = [CCMenu menuWithItems:pauseButton, nil];
//    [self addChild:GUIMenu];
}

#pragma mark - NBSpecialPowerButtonsContainerDelegate

- (void)onButtonPressed:(CCSprite *)buttonSprite {  
  if ([self.inGameItemsButtonsContainer containsButton:buttonSprite]) {
    CCFadeTo *fadeIn = [[CCFadeTo alloc] initWithDuration:1 opacity:255];
    [self.dimmer runAction:fadeIn];

    [self.inGameItemsButtonsContainer setShouldRespondToTouches:NO];
    [self.iapButtonsContainer setShouldRespondToTouches:YES];

    [[NBAudioManager sharedInstance] playSoundEffect:@"hadouken.wav"];
  }
  else {
    CCFadeTo *fadeOut = [[CCFadeTo alloc] initWithDuration:1 opacity:0];
    [self.dimmer runAction:fadeOut];

    [self.iapButtonsContainer setShouldRespondToTouches:NO];
    [self.inGameItemsButtonsContainer setShouldRespondToTouches:YES];

    [[NBAudioManager sharedInstance] playSoundEffect:@"shoryuken.wav"];
  }
}

-(void)goToAppStore{
    CCLOG(@"Open App Store!");
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    CCSprite* imageSprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_green.png"];
    [imageSprite setScale:3];
    [imageSprite setPosition:ccp(screenSize.width*0.5, screenSize.height*0.5)];
    [self addChild:imageSprite z:-1];
    
    CCLabelTTF* messageLabel = [[CCLabelTTF alloc] initWithString:@"Loading app store..." fontName:@"Marker Felt" fontSize:20];
    [messageLabel setPosition:imageSprite.position];
    [self addChild:messageLabel z:-1];
}

@end
