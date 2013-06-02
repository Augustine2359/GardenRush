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
        self.availableCoins = [[self.currentDataDictionary objectForKey:@"availableCoins"] intValue];
        self.availableItem1 = [[self.currentDataDictionary objectForKey:@"AvailableItem1"] intValue];
        self.currentGameScore = [[self.currentDataDictionary objectForKey:@"currentGameScore"] longValue];
        self.lastGameScore = [[self.currentDataDictionary objectForKey:@"lastGameScore"] longValue];
        self.highestGameScoreToday = [[self.currentDataDictionary objectForKey:@"highestGameScoreToday"] longValue];
        self.highestGameScoreThisWeek = [[self.currentDataDictionary objectForKey:@"highestGameScoreThisWeek"] longValue];
        self.highestGameScoreAllTime = [[self.currentDataDictionary objectForKey:@"highestGameScoreAllTime"] longValue];
    }
    
    return self;
}

@end
