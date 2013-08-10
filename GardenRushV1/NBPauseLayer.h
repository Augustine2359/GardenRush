//
//  NBPauseLayer.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 10/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface NBPauseLayer : CCLayer {
    
    CCMenu* pauseMenu;
}

-(void)doPauseGame;
-(void)doResumeGame;
-(void)doQuitGame;


@end
