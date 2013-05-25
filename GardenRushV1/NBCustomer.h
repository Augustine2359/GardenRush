//
//  NBCustomer.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NBBouquet.h"


@interface NBCustomer : CCLayer {
    CCSprite* faceImage;
    CCSprite* timerBarImage;
    NBBouquet* flowerRequest;
    
    float initialWaitingTime;
    float currentWaitingTime;
}

//Private
-(id)initWithIndex:(int)index;
-(void)update:(ccTime)delta;
-(void)doSpawnNewCustomer;
-(void)doCustomerLeave;
-(void)deleteSelf;
-(void)update:(ccTime)delta;

@end
