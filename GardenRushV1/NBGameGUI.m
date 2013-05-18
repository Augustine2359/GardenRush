//
//  NBGameGUI.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 8/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBGameGUI.h"


@implementation NBGameGUI

-(id)init{
    if ([super init]) {
        [self initialiseLivesGUI];
        [self initialiseMoneyGUI];
        [self initialiseCustomerGUI];
    }
    return self;
}

-(void)initialiseLivesGUI{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    //Read from plist when available
    int currentLives = 3;
    
    CCSprite* lifeFrame = [[CCSprite alloc] initWithFile:@"Default-Landscape~ipad.png"];
    CGSize frameSize = lifeFrame.boundingBox.size;
    [lifeFrame setScaleX:(screenSize.width*0.5/frameSize.width)];
    [lifeFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
    frameSize = lifeFrame.boundingBox.size;
    [lifeFrame setPosition:ccp(screenSize.width*0.25, screenSize.height - frameSize.height*0.5)];
    [self addChild:lifeFrame];
    
    for (int x = 0; x < currentLives; x++) {
        CCSprite* lifeSprite = [[CCSprite alloc] initWithFile:@"Icon.png"];
        CGSize spriteSize = lifeSprite.boundingBox.size;
        [lifeSprite setScaleX:(frameSize.width*0.2/spriteSize.width)];
        [lifeSprite setScaleY:(frameSize.height*0.8/spriteSize.height)];
        spriteSize = lifeSprite.boundingBox.size;
        float liveOffsetFromLeft = frameSize.width*0.1 + spriteSize.width*0.5;
        [lifeSprite setPosition:ccp(liveOffsetFromLeft + (spriteSize.width + frameSize.width*0.1)*x, screenSize.height - frameSize.height*0.5)];
        [self addChild:lifeSprite];
        [livesArray addObject:lifeSprite];
    }
}

-(void)initialiseMoneyGUI{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    //Read from plist when available
    actualMoney = 0;
    tempMoney = actualMoney;
    
    CCSprite* moneyFrame = [[CCSprite alloc] initWithSpriteFrameName:@"staticbox_green.png"];
    CGSize frameSize = moneyFrame.boundingBox.size;
    [moneyFrame setScaleX:(screenSize.width*0.5/frameSize.width)];
    [moneyFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
    frameSize = moneyFrame.boundingBox.size;
    [moneyFrame setPosition:ccp(screenSize.width*0.75, screenSize.height - frameSize.height*0.5)];
    [self addChild:moneyFrame];
    
    moneyLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"$%i", tempMoney] fontName:@"Marker Felt" fontSize:32];
    [moneyLabel setPosition:ccp(screenSize.width*0.75, screenSize.height - moneyFrame.boundingBox.size.height*0.5)];
    [self addChild:moneyLabel];
    
//    id delay = [CCDelayTime actionWithDuration:2];
//    id asd = [CCCallFunc actionWithTarget:self selector:@selector(doAddMoney:)];
//    [self runAction:[CCSequence actions:delay, asd, nil]];
}

-(void)initialiseCustomerGUI{
    customersArray = [CCArray new];
    
    for (int x = 0; x < 3; x++) {
        NBCustomer* thatCustomer = [[NBCustomer alloc] initWithIndex:x];
        [self addChild:thatCustomer];
        [customersArray addObject:thatCustomer];
    }
}

-(void)updateCustomer:(ccTime)deltaTime{
    for (int x = 0; x < [customersArray count]; x++) {
        [(NBCustomer*)[customersArray objectAtIndex:x] updateTimer:deltaTime];
    }
}

-(void)updateMoney{
    if (tempMoney >= actualMoney) {
        tempMoney = actualMoney;
        [self unschedule:@selector(updateMoney)];
        return;
    }
    
    tempMoney += 5;
    [moneyLabel setString:[NSString stringWithFormat:@"$%i", tempMoney]];
}

-(void)doAddMoney:(int)amount{
    actualMoney += amount;
    [self schedule:@selector(updateMoney) interval:1.0f/60.0f];
}

@end
