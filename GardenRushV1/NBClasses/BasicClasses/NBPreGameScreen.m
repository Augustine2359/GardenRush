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

- (void)onEnter {
  [super onEnter];
  
  UI_USER_INTERFACE_IDIOM();

  self.inGameItemsButtonsContainer = [[NBSpecialPowerButtonsContainer alloc] init];
  self.inGameItemsButtonsContainer.delegate = self;
  [self addChild:self.inGameItemsButtonsContainer];
  
  ccColor4B color = ccc4(0, 0, 0, 0);
  self.dimmer = [CCLayerColor layerWithColor:color];
  [self addChild:self.dimmer];
  
  self.iapButtonsContainer = [[NBSpecialPowerButtonsContainer alloc] init];
  self.iapButtonsContainer.position = CGPointMake(self.iapButtonsContainer.position.x, self.iapButtonsContainer.position.y + 100);
  self.iapButtonsContainer.delegate = self;
  [self.iapButtonsContainer setShouldRespondToTouches:NO];
  [self addChild:self.iapButtonsContainer];
}

#pragma mark - NBSpecialPowerButtonsContainerDelegate

- (void)onButtonPressed:(CCSprite *)buttonSprite {  
  if ([self.inGameItemsButtonsContainer containsButton:buttonSprite]) {
    CCFadeTo *fadeIn = [[CCFadeTo alloc] initWithDuration:1 opacity:255];
    [self.dimmer runAction:fadeIn];

    [self.inGameItemsButtonsContainer setShouldRespondToTouches:NO];
    [self.iapButtonsContainer setShouldRespondToTouches:YES];
  }
  else {
    CCFadeTo *fadeOut = [[CCFadeTo alloc] initWithDuration:1 opacity:0];
    [self.dimmer runAction:fadeOut];

    [self.iapButtonsContainer setShouldRespondToTouches:NO];
    [self.inGameItemsButtonsContainer setShouldRespondToTouches:YES];
  }
}

@end
