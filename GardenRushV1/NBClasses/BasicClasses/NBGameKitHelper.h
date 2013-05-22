//
//  NBGameKitHelper.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 19/5/13.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol NBGameKitHelperProtocol <NSObject>
@optional
-(void)onLocalPlayerAuthenticationChanged;
-(void)onFriendListReceived:(NSArray*)friends;
-(void)onPlayerInfoReceived:(NSArray*)players;
-(void)onScoresSubmitted:(bool)success;
-(void)onScoresReceived:(NSArray*)scores;
-(void)onLeaderboardViewDismissed;
-(void)onAchievementsViewDismissed;
@end

@interface NBGameKitHelper : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
{
    id <NBGameKitHelperProtocol> delegate;
    BOOL isGameCenterAvailable;
    NSError* lastError;
}

+(NBGameKitHelper*)sharedGameKitHelper;
-(void)authenticateLocalPlayer;
-(void)getLocalPlayerFriends;
-(void)getPlayerInfo:(NSArray*)players;
-(void)submitScore:(int64_t)score category:(NSString*)category;
-(void)retrieveScoresForPlayers:(NSArray*)players category:(NSString*)category range:(NSRange)range playerScope:(GKLeaderboardPlayerScope)playerScope timeScope:(GKLeaderboardTimeScope)timeScope;
-(void)retrieveTopTenAllTimeGlobalScores;
-(void)showLeaderboard;

@property (nonatomic, retain) id<NBGameKitHelperProtocol> delegate;
@property (nonatomic, readonly) BOOL isGameCenterAvailable;
@property (nonatomic, readonly) NSError* lastError;

@end
