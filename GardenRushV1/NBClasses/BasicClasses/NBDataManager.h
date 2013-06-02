//
//  NBDataManager.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 5/5/13.
//
//

#import <Foundation/Foundation.h>

@interface NBDataManager : NSObject

+(NBDataManager*)sharedDataManager;

@property (nonatomic, retain) NSMutableDictionary* currentDataDictionary;

@property (nonatomic, assign) long currentGameScore;
@property (nonatomic, assign) long lastGameScore;
@property (nonatomic, assign) long highestGameScoreToday;
@property (nonatomic, assign) long highestGameScoreThisWeek;
@property (nonatomic, assign) long highestGameScoreAllTime;

@property (nonatomic, assign) int availableCoins;
@property (nonatomic, assign) int availableItem1;


@end
