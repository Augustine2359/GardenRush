//
//  NBSceneManager.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 5/5/13.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    TargetSceneINVALID = 0,
    TargetSceneTest,
    TargetSceneMainGameLayer,
    TargetSceneMAX,
} TargetSceneTypes;

@interface NBSceneManager : CCScene
{
    TargetSceneTypes targetScene;
}

+(id) sceneWithTargetScene:(TargetSceneTypes)sceneType;
-(id) initWithTargetScene:(TargetSceneTypes)sceneType;

@end
