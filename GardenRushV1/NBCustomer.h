//
//  NBCustomer.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBBouquet.h"


@interface NBCustomer : CCLayer {
    CCSprite* faceImage;
    CCSprite* timerBarImage;
    
    float initialWaitingTime, currentWaitingTime;
    float timerSpeedRate;
    int selfIndex;
}

@property (nonatomic, retain) CCArray* request;
//@property (nonatomic, retain) NBBouquet* flowerRequest;
@property (nonatomic, retain) CCSprite* customerFrame;
@property (nonatomic, assign) int requestScore;

-(id)initWithIndex:(int)index requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime;
-(void)update:(ccTime)delta;
-(void)doCustomerLeave;
-(void)pauseWaitingTime;
-(void)resumeWaitingTime;
-(void)setTimerSpeedRate:(float)newRate;
-(void)fasterTimerSpeedRate;
-(void)slowerTimerSpeedRate;
-(void)resetTimerSpeedRate;
-(CCArray*)getRequestArray;

@end
