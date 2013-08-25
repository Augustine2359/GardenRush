//
//  NBDataManager.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 5/5/13.
//
//

#import <Foundation/Foundation.h>

@interface NBDataManager : NSObject{
    int energyLevel, energyMaxLevel;
}

+(NBDataManager*)sharedDataManager;
+(void)assignDifficulty:(int)difficultyIndex;
+(int)getDifficultyValueOnKey:(NSString*)keyString;

-(NSDate*)getFirstTimeEnergyReduced;
-(void)setFirstTimeEnergyReduced:(NSDate*)newTime;

@property (nonatomic, retain) NSMutableDictionary* currentDataDictionary;

@property (nonatomic, assign) long currentGameScore;
@property (nonatomic, assign) long lastGameScore;
@property (nonatomic, assign) long highestGameScoreToday;
@property (nonatomic, assign) long highestGameScoreThisWeek;
@property (nonatomic, assign) long highestGameScoreAllTime;

@property (nonatomic, assign) int availableCoins;

@property (nonatomic, assign) int currentDifficultyTier;
@property (nonatomic, assign) int flowerTypeLevel;
@property (nonatomic, assign) int customerPatience;
@property (nonatomic, assign) int customerRequirementType;
@property (nonatomic, assign) int customerRequirementCount;

@property (nonatomic, assign) NSArray* difficultyTierArray;


@end
