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
    currentMoney = 9999;
    
    CCSprite* moneyFrame = [[CCSprite alloc] initWithFile:@"Default-Landscape~ipad.png"];
    CGSize frameSize = moneyFrame.boundingBox.size;
    [moneyFrame setScaleX:(screenSize.width*0.5/frameSize.width)];
    [moneyFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
    frameSize = moneyFrame.boundingBox.size;
    [moneyFrame setPosition:ccp(screenSize.width*0.75, screenSize.height - frameSize.height*0.5)];
    [self addChild:moneyFrame];
    
    CCLabelTTF* moneyLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"$%i", currentMoney] fontName:@"Marker Felt" fontSize:32];
    [moneyLabel setPosition:ccp(screenSize.width*0.75, screenSize.height - moneyFrame.boundingBox.size.height*0.5)];
    [self addChild:moneyLabel];
}

-(void)initialiseCustomerGUI{
    for (int x = 0; x < 3; x++) {
        NBCustomer* thatCustomer = [[NBCustomer alloc] initWithIndex:x];
        [self addChild:thatCustomer];
    }
}

@end
