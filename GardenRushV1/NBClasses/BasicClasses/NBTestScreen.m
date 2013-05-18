//
//  NBTestScreen.m
//  ElementArmy1.0
//
//  Created by Romy Irawaty on 19/1/13.
//
//

#import "NBTestScreen.h"
#import "NBGameGUI.h"

NBGameGUI* test = nil;


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
    
    self.flowerFieldGameGrid = [[NBFlowerFieldGameGrid alloc] init];
    [self.currentScene addChild:self.flowerFieldGameGrid];
    
    //Temp test pls delete
    test = [NBGameGUI new];
    [self addChild:test];
}

-(void)update:(ccTime)delta
{
    [test updateCustomer:delta];
}
@end
