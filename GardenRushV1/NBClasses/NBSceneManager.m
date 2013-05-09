//
//  NBSceneManager.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 5/5/13.
//
//

#import "NBSceneManager.h"
#import "MainGameLayer.h"
#import "TestLayer.h"

@implementation NBSceneManager

+(id) sceneWithTargetScene:(TargetSceneTypes)sceneType;
{
    return [[self alloc] initWithTargetScene:sceneType];
}
-(id) initWithTargetScene:(TargetSceneTypes)sceneType
{
    if ((self = [super init]))
    {
        targetScene = sceneType;
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Loading ..." fontName:@"Marker Felt" fontSize:64];
        CGSize size = [CCDirector sharedDirector].winSize;
        label.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:label];
        
        // Must wait one frame before loading the target scene!
        [self scheduleOnce:@selector(loadScene:) delay:0.0f];
    }
    
    return self;
}

-(void)loadScene:(ccTime)delta
{
    // Decide which scene to load based on the TargetScenes enum.
    switch (targetScene)
    {
        case TargetSceneTest:
            [[CCDirector sharedDirector] replaceScene:[TestLayer scene]];
            break;
        case TargetSceneMainGameLayer:
            [[CCDirector sharedDirector] replaceScene:[MainGameLayer scene]];
            break;
        default:
            // Always warn if an unspecified enum value was used
            NSAssert2(nil, @"%@: unsupported TargetScene %i", NSStringFromSelector(_cmd), targetScene);
            break;
    }
}

@end
