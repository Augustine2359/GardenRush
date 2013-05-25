//
//  NBCustomer.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBCustomer.h"


@implementation NBCustomer

-(id)initWithIndex:(int)index{
    if ([super init]) {
        CCLOG(@"creating cust");
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //Background frame
        CCSprite* customerFrame = [[CCSprite alloc] initWithFile:@"Default-Landscape~ipad.png"];
        CGSize frameSize = customerFrame.boundingBox.size;
        [customerFrame setScaleX:((screenSize.width/3)/frameSize.width)];
        [customerFrame setScaleY:(screenSize.height*0.2/frameSize.height)];
        frameSize = customerFrame.boundingBox.size;
        [customerFrame setPosition:ccp(screenSize.width/3 * index + frameSize.width*0.5, screenSize.height - frameSize.height)];
        [self addChild:customerFrame];
        
        //Sprite image
        faceImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
        [faceImage setScale:2.5];
        [faceImage setPosition:ccp(customerFrame.position.x - customerFrame.boundingBox.size.width*0.25,
                                   customerFrame.position.y + customerFrame.boundingBox.size.height*0.25)];
        [self addChild:faceImage];
        
        //Request images
        flowerRequest = [NBFlower randomFlower];
        CCSprite* requestImage = [flowerRequest flowerImage];
        [requestImage setPosition:ccp(customerFrame.position.x + customerFrame.boundingBox.size.width*0.25,
                                   customerFrame.position.y + customerFrame.boundingBox.size.height*0.25)];
//        [self addChild:requestImage];
        
        //TimerBar image
        timerBarImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
        [timerBarImage setScaleX:5];
        [timerBarImage setPosition:ccp(faceImage.position.x - faceImage.boundingBox.size.width*0.5, customerFrame.position.y - customerFrame.boundingBox.size.height*0.25)];
        [self addChild:timerBarImage];
        
        //Misc
        initialWaitingTime = 10;
        currentWaitingTime = initialWaitingTime;
        [timerBarImage setAnchorPoint:ccp(0, 0.5)];
        [self scheduleUpdate];
    }
    return self;
}

-(void)update:(ccTime)delta{
    currentWaitingTime -= delta;
    if (currentWaitingTime <= 0) {
        //CCLOG(@"Time up!");
        currentWaitingTime = 0;
        [self unscheduleUpdate];
        [self doCustomerLeave];
    }
    
    [timerBarImage setScaleX:(currentWaitingTime/initialWaitingTime * 5)];
}

-(void)doSpawnNewCustomer{
//    CGSize screenSize = [[CCDirector sharedDirector] winSize];
//    id action = [CCMoveTo actionWithDuration:3 position:ccp(self.position.x, screenSize.height + self.boundingBox.size.height)];
//    id actionEnd = [CCCallFunc actionWithTarget:self selector:@selector(deleteSelf)];
//    [self runAction:[CCSequence actions:action, actionEnd, nil]];
}

-(void)doCustomerLeave{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    id action = [CCMoveTo actionWithDuration:3 position:ccp(self.position.x, screenSize.height + self.boundingBox.size.height)];
    id actionEnd = [CCCallFunc actionWithTarget:self selector:@selector(deleteSelf)];
    [self runAction:[CCSequence actions:action, actionEnd, nil]];
}
                    
-(void)deleteSelf{
    [self removeFromParentAndCleanup:true];
}

@end
