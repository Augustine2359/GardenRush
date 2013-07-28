//
//  NBTestScreen.m
//  ElementArmy1.0
//
//  Created by Romy Irawaty on 19/1/13.
//
//

#import "NBTestScreen.h"
#import "NBGameGUI.h"
#import "NBSpecialPowerButtonsContainer.h"

NBGameGUI* test = nil;

@interface NBTestScreen() <NBSpecialPowerButtonsContainerDelegate>

@end

@implementation NBTestScreen

// Helper class method that creates a Scene with the NBBattleLayer as the only child.
+(CCScene*)scene
{
    return [NBTestScreen sceneAndSetAsDefault:NO];
}

+(CCScene*)sceneAndSetAsDefault:(BOOL)makeDefault
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NBTestScreen *layer = [NBTestScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
    
    if (makeDefault)
        [NBBasicScreenLayer setDefaultScreen:scene];
	
	// return the scene
	return scene;
}

-(void) onEnter
{
	[super onEnter];
    
    UI_USER_INTERFACE_IDIOM();
    
    self.currentScene = (CCScene*)self.parent;
    
    //Display Title in the middle of the screen
    [self displayLayerTitle:@"Test Screen"];
  
    BOOL isFlowerFieldExpanded = [[[NSUserDefaults standardUserDefaults] objectForKey:IS_FLOWER_FIELD_EXPANDED] boolValue];
    self.flowerFieldGameGrid = [[NBFlowerFieldGameGrid alloc] initWithExpandedFlowerField:isFlowerFieldExpanded];
    [self addChild:self.flowerFieldGameGrid];
    
    //Temp test pls delete
    test = [NBGameGUI new];
    [self addChild:test];
    
    CGPoint scorePadPosition = [NBGameGUI getScorePosition];
    scorePadPosition = ccp(scorePadPosition.x, scorePadPosition.y - FIELD_POSITION_ADJUSTMENT);
    [NBBouquet setScorePadPosition:scorePadPosition];
    
    self.flowerCountLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:24];
    self.flowerCountLabel.position = CGPointMake(20, self.layerSize.height - 20);
    [self addChild:self.flowerCountLabel];
    
    self.flowerFieldChildCountLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:24];
    self.flowerFieldChildCountLabel.position = CGPointMake(20, self.layerSize.height - 50);
    [self addChild:self.flowerFieldChildCountLabel];
    
    self.isProcessingMoveLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:24];
    self.isProcessingMoveLabel.position = CGPointMake(20, self.layerSize.height - 80);
    [self addChild:self.isProcessingMoveLabel];
    
    self.isProcessingMatchLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Arial" fontSize:24];
    self.isProcessingMatchLabel.position = CGPointMake(20, self.layerSize.height - 110);
    [self addChild:self.isProcessingMatchLabel];
  
    //NBSpecialPowerButtonsContainer *specialPowerButton = [[NBSpecialPowerButtonsContainer alloc] init];
    //specialPowerButton.delegate = self;
    //[self.currentScene addChild:specialPowerButton];
}

-(void)update:(ccTime)delta
{
    [self.flowerCountLabel setString:[NSString stringWithFormat:@"%i", [NBFlower getFlowerCount]]];
    [self.flowerFieldChildCountLabel setString:[NSString stringWithFormat:@"%i", [self.flowerFieldGameGrid children].count]];
    [self.isProcessingMoveLabel setString:[NSString stringWithFormat:@"%i", (int)self.flowerFieldGameGrid.isProcessingMove]];
    [self.isProcessingMatchLabel setString:[NSString stringWithFormat:@"%i", (int)self.flowerFieldGameGrid.isProcessingMatching]];
}

#pragma mark - NBSpecialPowerButtonsContainerDelegate

- (void)onButtonPressed:(CCSprite *)buttonSprite {
  DLog(@"special power %d was used", buttonSprite.tag);
}

@end
