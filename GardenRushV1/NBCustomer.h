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
    CCArray* requests;
    
    float initialWaitingTime, currentWaitingTime;
    int selfIndex;
}

@property (nonatomic, retain) CCSprite* customerFrame;
@property (nonatomic, assign) int requestScore;

-(id)initWithIndex:(int)index requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime;
-(void)update:(ccTime)delta;
-(void)doCustomerLeave;

@end
