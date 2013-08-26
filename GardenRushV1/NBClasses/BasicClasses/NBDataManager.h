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
+(CCArray*)getItemList;

-(NSDate*)getFirstTimeEnergyReduced;
-(void)setFirstTimeEnergyReduced:(NSDate*)newTime;
-(int)getItem0Quantity;
-(int)getItem1Quantity;
-(int)getItem2Quantity;
-(void)setItem0Quantity:(int)quantity;
-(void)setItem1Quantity:(int)quantity;
-(void)setItem2Quantity:(int)quantity;

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
