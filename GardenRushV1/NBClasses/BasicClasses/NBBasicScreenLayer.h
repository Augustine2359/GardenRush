//
//  NBBasicScreenLayer.h
//  ElementArmy1.0
//
//  Created by Romy Irawaty on 21/11/12.
//
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#import "NBDataManager.h"

typedef enum
{
    TargetSceneINVALID = 0,
    TargetSceneMain,
    TargetSceneFirst,
    TargetSceneSecond,
    TargetScenePreGame,
    TargetSceneParticle,
    TargetSceneMAX,
} TargetSceneTypes;

@interface NBBasicScreenLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>

// returns a CCScene that contains the HelloWorldLayer as the only child
+(TargetSceneTypes)getCurrentScreenType;
+(CCScene*)scene;
+(CCScene*)sceneAndSetAsDefault:(BOOL)makeDefault;
+(CCScene*)loadCurrentScene;
+(void)setDefaultScreen:(CCScene*)scene;
+(void)setCurrentScreen:(CCScene*)scene;
+(void)resetMenuIndex;

-(void)setLayerColor:(ccColor4B)color;
-(void)displayLayerTitle:(NSString*)title;
-(void)changeToScene:(TargetSceneTypes)sceneType;
-(void)changeToScene:(TargetSceneTypes)sceneType transitionWithDuration:(float)duration;
-(void)addStandardMenuString:(NSString*)menuTitle withSelector:(SEL)selectedMethod;
-(void)setCurrentBackgroundWithFileName:(NSString*)fileName stretchToScreen:(BOOL)stretch;

@property (nonatomic, retain) NSString* layerName;
@property (nonatomic, retain) CCLabelTTF* layerTitle;
@property (nonatomic, assign) CGSize layerSize;
@property (nonatomic, assign) CGSize layerSizeInPixels;
@property (nonatomic, retain) CCMenu *menu;
@property (nonatomic, retain) CCSpriteBatchNode* currentSpritesBatchNode;
@property (nonatomic, retain) CCSpriteFrameCache* currentFrameCache;
@property (nonatomic, retain) NSString* nextScene;
@property (nonatomic, retain) CCSprite* background;
@property (nonatomic, retain) NBDataManager* dataManager;

@end
