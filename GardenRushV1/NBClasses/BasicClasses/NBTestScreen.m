//
//  NBTestScreen.m
//  ElementArmy1.0
//
//  Created by Romy Irawaty on 19/1/13.
//
//

#import "NBTestScreen.h"

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
    
    //Display Title in the middle of the screen
    [self displayLayerTitle:@"Test Screen"];
    
    CGSize fieldSize = CGSizeMake(8, 8);
    self.fieldBackground = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];
    self.fieldBackground.scaleX = fieldSize.width * 30 / self.fieldBackground.contentSize.width;
    self.fieldBackground.scaleY = fieldSize.height * 30 / self.fieldBackground.contentSize.height;
    self.fieldBackground.position = ccp(self.layerSize.width / 2, self.layerSize.height / 2);
    self.fieldBackground.anchorPoint = ccp(0.5f, 0.5f);
    [self addChild:self.fieldBackground];
}
@end
