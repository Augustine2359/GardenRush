//
//  NBGameKitHelper.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 19/5/13.
//
//

#import "NBGameKitHelper.h"
#import "AppDelegate.h"

static NBGameKitHelper* gameKitHelper = nil;

@implementation NBGameKitHelper

@synthesize delegate;
@synthesize isGameCenterAvailable;
@synthesize lastError;

+(NBGameKitHelper*)sharedGameKitHelper
{
    if (!gameKitHelper)
        return [[NBGameKitHelper alloc] init];
    else
        return gameKitHelper;
}

-(id)init
{
    if (!gameKitHelper)
    {
        if ((self = [super init]))
        {
            // Test for Game Center availability
            Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
            BOOL isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
            // Test if device is running iOS 4.1 or higher
            NSString* reqSysVer = @"4.1";
            NSString* currSysVer = [UIDevice currentDevice].systemVersion;
            BOOL isOSVer41 = ([currSysVer compare:reqSysVer
                                          options:NSNumericSearch] != NSOrderedAscending);
            isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
            NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");
            [self registerForLocalPlayerAuthChange];
            
            gameKitHelper = self;
        }
    }
    
    return self;
}

-(void)registerForLocalPlayerAuthChange
{
    if (isGameCenterAvailable == NO)
        return;
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(onLocalPlayerAuthenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

-(void)onLocalPlayerAuthenticationChanged
{
    if ([delegate respondsToSelector:@selector(onLocalPlayerAuthenticationChanged)])
    {
        [delegate onLocalPlayerAuthenticationChanged];
    }
}

-(void)authenticateLocalPlayer
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
    if (localPlayer.authenticated == NO)
    {
        [localPlayer authenticateWithCompletionHandler:^(NSError* error)
        {
            [self setLastError:error];
        }];
    }
}

-(void)setLastError:(NSError*)error
{
    lastError = error.copy;
    if (lastError != nil)
        NSLog(@"NBGameKitHelper ERROR: %@", [lastError userInfo].description);
}

-(void)getLocalPlayerFriends
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
    if (localPlayer.authenticated)
    {
        [localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
        {
            [self setLastError:error];
            if ([delegate respondsToSelector:@selector(onFriendListReceived:)])
            {
                [delegate onFriendListReceived:friends];
            }
        }];
    }
}

-(void)getPlayerInfo:(NSArray*)playerList
{
    if (playerList.count > 0)
    {
        // Get detailed information about a list of players
        [GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
        {
            [self setLastError:error];
            if ([delegate respondsToSelector:@selector(onPlayerInfoReceived:)])
            {
                [delegate onPlayerInfoReceived:players];
            }
        }];
    }
}

-(void)submitScore:(int64_t)score category:(NSString*)category
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKScore* gkScore = [[GKScore alloc] initWithCategory:category];
    gkScore.value = score;
    [gkScore reportScoreWithCompletionHandler:^(NSError* error)
    {
        [self setLastError:error];
        BOOL success = (error == nil);
        if ([delegate respondsToSelector:@selector(onScoresSubmitted:)])
        {
            [delegate onScoresSubmitted:success];
        }
    }];
}

-(void)retrieveTopTenAllTimeGlobalScores
{
    [self retrieveScoresForPlayers:nil category:nil range:NSMakeRange(1, 10) playerScope:GKLeaderboardPlayerScopeGlobal timeScope:GKLeaderboardTimeScopeAllTime];
}

-(void)retrieveScoresForPlayers:(NSArray*)players category:(NSString*)category range:(NSRange)range playerScope:(GKLeaderboardPlayerScope)playerScope timeScope:(GKLeaderboardTimeScope)timeScope
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKLeaderboard* leaderboard = nil;
    if (players.count > 0)
    {
        leaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:players];
    }
    else
    {
        leaderboard = [[GKLeaderboard alloc] init];
        leaderboard.playerScope = playerScope;
    }
    
    if (leaderboard != nil)
    {
        leaderboard.timeScope = timeScope;
        leaderboard.category = category;
        leaderboard.range = range;
        [leaderboard loadScoresWithCompletionHandler:^(NSArray* scores, NSError* error)
        {
            [self setLastError:error];
            if ([delegate respondsToSelector:@selector(onScoresReceived:)])
            {
                [delegate onScoresReceived:scores];
            }
        }];
    }
}

-(void)showLeaderboard
{
    if (isGameCenterAvailable == NO)
        return;
    
    GKLeaderboardViewController* leaderboardVC = [[GKLeaderboardViewController alloc] init];
    
    if (leaderboardVC != nil)
    {
        leaderboardVC.leaderboardDelegate = self;
        [self presentViewController:leaderboardVC];
    }
}

-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
    [self dismissModalViewController];
    if ([delegate respondsToSelector:@selector(onLeaderboardViewDismissed)])
    {
        [delegate onLeaderboardViewDismissed];
    }
}

-(void)achievementViewControllerDidFinish:(GKAchievementViewController*)viewControl
{
    [self dismissModalViewController];
    if ([delegate respondsToSelector:@selector(onAchievementsViewDismissed)])
    {
        [delegate onAchievementsViewDismissed];
    }
}

-(UINavigationController*)appNavigationController
{
    AppController* app = (AppController*)[UIApplication sharedApplication].delegate;
    return app.navController;
}

-(void)presentViewController:(UIViewController*)vc
{
    UINavigationController* navController = [self appNavigationController];
    [navController presentModalViewController:vc animated:YES];
}
-(void)dismissModalViewController
{
    UINavigationController* navController = [self appNavigationController];
    [navController dismissModalViewControllerAnimated:YES];
}

@end
