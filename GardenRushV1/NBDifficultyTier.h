//
//  NBDifficultyTier.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 12/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface NBDifficultyTier : CCNode {
    int currDifficultyLevel;
}

+(NBDifficultyTier*)sharedDifficulty;
-(int)getTier;
-(void)setTier:(int)nextTier;
-(void)checkTierUpdate:(int)currentScore;

@end
