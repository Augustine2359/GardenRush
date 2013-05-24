//
//  NBCustomer.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface NBCustomer : CCLayer {
    CCSprite* faceImage;
    CCSprite* timerBarImage;
    CCArray* requests;
    
    float initialWaitingTime;
    float currentWaitingTime;
}

-(id)initWithIndex:(int)index;
-(void)updateTimer:(ccTime)deltaTime;
-(void)doSpawnNewCustomer;
-(void)doCustomerLeave;
-(void)deleteSelf;
-(void)update:(ccTime)delta;

@end
