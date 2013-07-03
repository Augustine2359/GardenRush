//
//  NBDifficultyTier.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 12/6/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBDifficultyTier.h"
#import "NBGameGUI.h"

static NBDifficultyTier* sharedDifficulty = nil;


@implementation NBDifficultyTier

+(NBDifficultyTier*) sharedDifficulty
{
    return sharedDifficulty;
}

-(id)init{
    if ([super init]) {
        sharedDifficulty = self;
        currDifficultyLevel = 1;
        [self setTier:currDifficultyLevel];
    }
    
    return self;
}

-(int)getTier{
    return currDifficultyLevel;
}

-(void)setTier:(int)nextTier{
    NBGameGUI* thatGUI = [NBGameGUI sharedGameGUI];
    
    switch (nextTier) {
        case 1:
            [thatGUI setSpawnInterval:14 max:21];
            [thatGUI setCustomerRequestAverageQuantity:1];
            [thatGUI setNextCustomerWaitingTime:60];
            break;
            
        case 2:
            [thatGUI setSpawnInterval:12 max:18];
            [thatGUI setCustomerRequestAverageQuantity:1];
            [thatGUI setNextCustomerWaitingTime:55];
            break;
            
        case 3:
            [thatGUI setSpawnInterval:10 max:15];
            [thatGUI setCustomerRequestAverageQuantity:2];
            [thatGUI setNextCustomerWaitingTime:50];
            break;
            
        case 4:
            [thatGUI setSpawnInterval:8 max:12];
            [thatGUI setCustomerRequestAverageQuantity:2];
            [thatGUI setNextCustomerWaitingTime:40];
            break;
            
        case 5:
            [thatGUI setSpawnInterval:6 max:9];
            [thatGUI setCustomerRequestAverageQuantity:3];
            [thatGUI setNextCustomerWaitingTime:30];
            break;
            
        case 6:
            [thatGUI setSpawnInterval:4 max:6];
            [thatGUI setCustomerRequestAverageQuantity:4];
            [thatGUI setNextCustomerWaitingTime:20];
            break;
            
        case 7:
            [thatGUI setSpawnInterval:2 max:3];
            [thatGUI setCustomerRequestAverageQuantity:5];
            [thatGUI setNextCustomerWaitingTime:10];
            break;
            
        default:
            CCLOG(@"Tier out of range");
            return;
    }
    
    currDifficultyLevel = nextTier;
    CCLOG(@"CHANGE TIER = %i", currDifficultyLevel);
}

-(void)checkTierUpdate:(int)currentScore{
    if (currentScore >= 12000) {
        [self setTier:7];
    }
    else if (currentScore >= 10000){
        [self setTier:6];
    }
    else if (currentScore >= 8000){
        [self setTier:5];
    }
    else if (currentScore >= 6000){
        [self setTier:4];
    }
    else if (currentScore >= 4000){
        [self setTier:3];
    }
    else if (currentScore >= 2000){
        [self setTier:2];
    }
    else{
        [self setTier:1];
    }
}

@end
