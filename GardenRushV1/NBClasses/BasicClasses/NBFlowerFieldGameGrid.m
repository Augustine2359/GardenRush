//
//  NBFlowerFieldGameGrid.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 9/5/13.
//
//

#import "NBFlowerFieldGameGrid.h"

@implementation NBFlowerFieldGameGrid

-(id)init
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if (self = [super init])
    {
        CGSize fieldSize = CGSizeMake(10, 10);
        self.fieldBackground = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];
        self.fieldBackground.scaleX = fieldSize.width * 30 / self.fieldBackground.contentSize.width;
        self.fieldBackground.scaleY = fieldSize.height * 30 / self.fieldBackground.contentSize.height;
        self.fieldBackground.position = ccp(winSize.width / 2, 10 + (fieldSize.height * 30 / 2));
        self.fieldBackground.anchorPoint = ccp(0.5f, 0.5f);
        self.fieldBackground.color = ccc3(139, 119, 101);
        [self addChild:self.fieldBackground];
    }
    
    return self;
}

@end
