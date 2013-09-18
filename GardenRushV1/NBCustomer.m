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
        self.customerFrame = [CCSprite spriteWithSpriteFrameName:@"NB_UI_customerBoard_204x148-hd.png"];
        CGSize frameSize = self.customerFrame.boundingBox.size;
        frameSize = self.customerFrame.boundingBox.size;
        [self.customerFrame setPosition:ccp((screenSize.width/3 * index + frameSize.width*0.5) + 3, (screenSize.height * 0.9) - (frameSize.height / 2) + 1)];
        [self addChild:self.customerFrame];
        
        //Sprite image
        faceImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
        [faceImage setScale:3];
        [faceImage setPosition:ccp(self.customerFrame.position.x - self.customerFrame.boundingBox.size.width*0.175,
                                   self.customerFrame.position.y + self.customerFrame.boundingBox.size.height*0.1)];
        [self addChild:faceImage];
        
        //Request images
//        self.request = [[CCArray alloc] initWithCapacity:5];
        int random = (arc4random() % (int)btFourOfAKind) + btThreeOfAKind;
        self.flowerRequest = [NBBouquet createBouquet:random show:YES];
        [self.flowerRequest setPosition:ccp(self.customerFrame.position.x + self.customerFrame.boundingBox.size.width*0.375 - self.customerFrame.boundingBox.size.width*0.05, self.customerFrame.position.y + self.customerFrame.boundingBox.size.height*0.25)];
        [self addChild:self.flowerRequest];
//        [self.request addObject:flowerRequest];
        
        //Request quantity label
        quantityLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"x %i", (int)requestQuantity] fontName:@"Marker Felt" fontSize:15];
        [quantityLabel setPosition:ccp(self.customerFrame.position.x + self.customerFrame.boundingBox.size.width*0.3, self.customerFrame.position.y)];
        [self addChild:quantityLabel];
        
        //TimerBar image
        timerBarImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
        [timerBarImage setScaleX:5];
        [timerBarImage setScaleY:0.5f];
        [timerBarImage setPosition:ccp(faceImage.position.x - faceImage.boundingBox.size.width*0.5, self.customerFrame.position.y - self.customerFrame.boundingBox.size.height*0.4)];
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
        [[NBGameGUI sharedGameGUI] doAngerCustomer:selfIndex];
        [[NBGameGUI sharedGameGUI] doMinusOneLife];
        [self unscheduleUpdate];
        [self doCustomerLeave];
    }
    else if(currentWaitingTime <= initialWaitingTime*0.2 && !isBlinking){
        isBlinking = YES;
        CCBlink* blink = [CCBlink actionWithDuration:initialWaitingTime*0.2 blinks:initialWaitingTime*0.2];
        [faceImage runAction:blink];
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

//-(CCArray*)getRequestArray{
//    return self.request;
//}

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

-(void)updateRequestLabel{
    if (self.requestQuantity < 0) {
        self.requestQuantity = 0;
    }
    
    [quantityLabel setString:[NSString stringWithFormat:@"x %i", self.requestQuantity]];
}

@end
