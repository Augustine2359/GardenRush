//
//  NBTestNode.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 20/5/13.
//
//

#import "NBTestNode.h"

static int nodeCount = 0;

@implementation NBTestNode

+(int)getTestNodeCount
{
    return nodeCount;
}

-(id)init
{
    if (self = [super init])
    {
        nodeCount++;
        
        self.testSprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];
        [self addChild:self.testSprite];
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
    nodeCount--;
}

@end
