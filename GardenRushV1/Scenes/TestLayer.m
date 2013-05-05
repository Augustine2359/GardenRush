//
//  TestLayer.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 5/5/13.
//
//

#import "TestLayer.h"

@implementation TestLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene*)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TestLayer *layer = [TestLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)onEnter
{
	[super onEnter];
    
	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
    
	CCLabelTTF* backgroundText;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
		backgroundText = [CCLabelTTF labelWithString:@"Test Layer" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
		backgroundText.rotation = 90;
	}
    else
    {
		backgroundText = [CCLabelTTF labelWithString:@"Test Layer" dimensions:CGSizeZero hAlignment:kCCTextAlignmentCenter fontName:@"Marker Felt" fontSize:12];
	}
    
	backgroundText.position = ccp(size.width / 2, size.height / 2);
    
	// add the label as a child to this Layer
	[self addChild:backgroundText];
}

@end
