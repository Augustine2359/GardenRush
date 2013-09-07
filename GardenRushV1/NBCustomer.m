//
//  NBCustomer.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBCustomer.h"
#import "NBGameGUI.h"


@implementation NBCustomer

-(id)initWithIndex:(int)index requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime{
    if ([super init]) {
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        selfIndex = index;
        
        //Background frame
        self.customerFrame = [[CCSprite alloc] initWithFile:@"Default-Landscape~ipad.png"];
        CGSize frameSize = self.customerFrame.boundingBox.size;
        [self.customerFrame setScaleX:((screenSize.width/3)/frameSize.width)];
        [self.customerFrame setScaleY:(screenSize.height*0.2/frameSize.height)];
        frameSize = self.customerFrame.boundingBox.size;
        [self.customerFrame setPosition:ccp(screenSize.width/3 * index + frameSize.width*0.5, screenSize.height - frameSize.height)];
        [self addChild:self.customerFrame];
        
        //Sprite image
        faceImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
        [faceImage setScale:2.5];
        [faceImage setPosition:ccp(self.customerFrame.position.x - self.customerFrame.boundingBox.size.width*0.25,
                                   self.customerFrame.position.y + self.customerFrame.boundingBox.size.height*0.25)];
        [self addChild:faceImage];
        
        //Request images
        self.request = [[CCArray alloc] initWithCapacity:5];
        int random = (arc4random() % (int)btFourOfAKind) + btThreeOfAKind;
        for (int x = 0; x < requestQuantity; x++) {
            NBBouquet* flowerRequest = [NBBouquet createBouquet:random show:YES];
            [flowerRequest setPosition:ccp(self.customerFrame.position.x + self.customerFrame.boundingBox.size.width*0.375 - self.customerFrame.boundingBox.size.width*0.05f*x,
                                           self.customerFrame.position.y + self.customerFrame.boundingBox.size.height*0.25)];
            [self addChild:flowerRequest];
            [self.request addObject:flowerRequest];
        }
        
        //TimerBar image
        timerBarImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
        [timerBarImage setScaleX:5];
        [timerBarImage setPosition:ccp(faceImage.position.x - faceImage.boundingBox.size.width*0.5, self.customerFrame.position.y - self.customerFrame.boundingBox.size.height*0.25)];
        [self addChild:timerBarImage];
        
        //Misc
        initialWaitingTime = waitingTime;
        currentWaitingTime = initialWaitingTime;
        [timerBarImage setAnchorPoint:ccp(0, 0.5)];
        self.requestScore = 100 * requestQuantity;
        [self resetTimerSpeedRate];
        
        //Transit to position
        self.position = ccp(self.position.x, self.position.y+screenSize.height*0.5);
        id action = [CCMoveBy actionWithDuration:3 position:ccp(0, -screenSize.height*0.5)];
        [self runAction:[CCSequence actions:action, nil]];
        
        [self scheduleUpdate];
    }
    return self;
}

-(void)update:(ccTime)delta{
    currentWaitingTime -= delta * timerSpeedRate;
    
    if (currentWaitingTime <= 0) {
        CCLOG(@"You pissed off a customer!");
        currentWaitingTime = 0;
        [self unscheduleUpdate];
        [self doCustomerLeave];
    }
    
    [timerBarImage setScaleX:(currentWaitingTime/initialWaitingTime * 5)];
}

-(void)doCustomerLeave{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    id action = [CCMoveBy actionWithDuration:3 position:ccp(0, screenSize.height)];
    id actionEnd = [CCCallFunc actionWithTarget:self selector:@selector(deleteSelf)];
    [self runAction:[CCSequence actions:action, actionEnd, nil]];
}
                    
-(void)deleteSelf{
    [[NBGameGUI sharedGameGUI] doDeleteCustomer:[NSNumber numberWithInt:selfIndex]];
    [self removeFromParentAndCleanup:true];
}

-(CCArray*)getRequestArray{
    return self.request;
}

-(void)pauseWaitingTime{
    [self pauseSchedulerAndActions];
}

-(void)resumeWaitingTime{
    [self resumeSchedulerAndActions];
}

-(void)setTimerSpeedRate:(float)newRate{
    timerSpeedRate = newRate;
}

-(void)fasterTimerSpeedRate{
    timerSpeedRate++;
}

-(void)slowerTimerSpeedRate{
    timerSpeedRate--;
}

-(void)resetTimerSpeedRate{
    timerSpeedRate = 1;
}

@end
