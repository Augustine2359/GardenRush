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
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
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
        int random = arc4random() % (int)btFiveOfAKind;
        flowerRequest = [NBBouquet createBouquet:random show:YES];
        [flowerRequest setPosition:ccp(self.customerFrame.position.x + self.customerFrame.boundingBox.size.width*0.25,
                                    self.customerFrame.position.y + self.customerFrame.boundingBox.size.height*0.25)];
        [self addChild:flowerRequest];

        
        //TimerBar image
        timerBarImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
        [timerBarImage setScaleX:5];
        [timerBarImage setPosition:ccp(faceImage.position.x - faceImage.boundingBox.size.width*0.5, self.customerFrame.position.y - self.customerFrame.boundingBox.size.height*0.25)];
        [self addChild:timerBarImage];
        
        //Misc
        initialWaitingTime = 10;
        currentWaitingTime = initialWaitingTime;
        [timerBarImage setAnchorPoint:ccp(0, 0.5)];
        self.requestScore = 100;
        
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
