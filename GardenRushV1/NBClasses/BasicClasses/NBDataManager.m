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
    if (sharedDataManager)
        return sharedDataManager;
    else
        return [[NBDataManager alloc] init];
}

+(void)assignDifficulty:(int)difficultyIndex
{
    sharedDataManager.currentDifficultyTier = difficultyIndex;
}

+(int)getDifficultyValueOnKey:(NSString*)keyString
{
    for (NSDictionary* difficultyTier in sharedDataManager.difficultyTierArray)
    {
        int tier = [[difficultyTier objectForKey:@"tier"] intValue];
        
        if (tier == sharedDataManager.currentDifficultyTier)
        {
            return [[difficultyTier objectForKey:keyString] intValue];
        }
    }
    
    return 0;
}

+(void)saveState
{
    if (!sharedDataManager)
        sharedDataManager = [[NBDataManager alloc] init];
    
    NSMutableDictionary* gameStateCollection = [sharedDataManager.currentDataDictionary objectForKey:@"GameState"];
    
    //Update below if any new key for the Game State settings
    //*******************************************************
    [gameStateCollection setObject:[NSNumber numberWithLong:sharedDataManager.availableCoins] forKey:@"availableCoins"];
    [gameStateCollection setObject:[NSNumber numberWithLong:sharedDataManager.availableItem1] forKey:@"availableItem1"];
    //*******************************************************
    
    [sharedDataManager.currentDataDictionary setObject:gameStateCollection forKey:@"GameState"];
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:sharedDataManager.currentDataDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
    
    //save the changes to the app documents directory
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [rootPath stringByAppendingPathComponent:@"SaveGame.plist"];
    
    if (plistData)
        [plistData writeToFile:path atomically:YES];
}

-(id)init
{
    if (self = [super init])
    {
        sharedDataManager = self;
        
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *plistPath = [rootPath stringByAppendingPathComponent:@"SaveGame.plist"];
        self.currentDataDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        
        self.currentDataDictionary = nil;
        
        //If doesnt exist create one
        if (self.currentDataDictionary == NULL)
        {
            DLog(@"Creating player data");
            plistPath = [[NSBundle mainBundle] pathForResource:@"GameSettings" ofType:@"plist"];
            self.currentDataDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
            
            NSString* initialCoin = @"0";
            NSString* initialItem1Amount = @"0";
            self.availableCoins = 0;
            
            [self.currentDataDictionary setObject:initialCoin forKey:@"availableCoins"];
            [self.currentDataDictionary setObject:initialItem1Amount forKey:@"AvailableItem1"];
            
            //Save data
            NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:self.currentDataDictionary format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
            
            //Save path
            NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [rootPath stringByAppendingPathComponent:@"SaveGame.plist"];
            
            if (plistData)
                [plistData writeToFile:path atomically:YES];
        }

        DLog(@"Loading player data");
        NSDictionary* gameStateDictionary = [self.currentDataDictionary objectForKey:@"GameState"];
        self.currentDifficultyTier = [[gameStateDictionary objectForKey:@"currentDifficultyTier"] intValue];
        self.availableCoins = [[gameStateDictionary objectForKey:@"availableCoins"] intValue];
        self.availableItem1 = [[gameStateDictionary objectForKey:@"AvailableItem1"] intValue];
        
        NSDictionary* userProfileDictionary = [self.currentDataDictionary objectForKey:@"UserProfile"];
        self.currentGameScore = [[userProfileDictionary objectForKey:@"currentGameScore"] longValue];
        self.lastGameScore = [[userProfileDictionary objectForKey:@"lastGameScore"] longValue];
        self.highestGameScoreToday = [[userProfileDictionary objectForKey:@"highestGameScoreToday"] longValue];
        self.highestGameScoreThisWeek = [[userProfileDictionary objectForKey:@"highestGameScoreThisWeek"] longValue];
        self.highestGameScoreAllTime = [[userProfileDictionary objectForKey:@"highestGameScoreAllTime"] longValue];
        
        NSArray* tierArray = [self.currentDataDictionary objectForKey:@"Difficulty"];
        self.difficultyTierArray = [[NSArray alloc] initWithArray:tierArray];
        
        for (NSDictionary* difficultyTier in self.difficultyTierArray)
        {
            DLog(@"tier = %i", [[difficultyTier objectForKey:@"tier"] intValue]);
            DLog(@"flowerTypeLevel = %i", [[difficultyTier objectForKey:@"flowerTypeLevel"] intValue]);
            DLog(@"customerPatience = %i", [[difficultyTier objectForKey:@"customerPatience"] intValue]);
            DLog(@"customerRequirementType = %i", [[difficultyTier objectForKey:@"customerRequirementType"] intValue]);
            DLog(@"customerRequirementCount = %i", [[difficultyTier objectForKey:@"customerRequirementCount"] intValue]);
        }
    }
    
    return self;
}

-(NSDate*)getFirstTimeEnergyReduced{
    NSDate *energyRefillStartTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"energyRefillStartTime"];
    return energyRefillStartTime;
}

-(void)setFirstTimeEnergyReduced:(NSDate *)newTime{
    [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"energyRefillStartTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
