//
//  NBDataManager.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 5/5/13.
//
//

#import "NBDataManager.h"

static NBDataManager* sharedDataManager = nil;

@implementation NBDataManager

+(NBDataManager*)sharedDataManager
{
    return sharedDataManager;
}

@end
