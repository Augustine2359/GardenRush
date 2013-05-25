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
        [self initialiseScoreGUI];
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

-(void)initialiseScoreGUI{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    additionalScoreLabels = [CCArray new];
    [additionalScoreLabels retain];
    //Read from plist when available
    actualScore = 0;
    tempScore = actualScore;
    
    CCSprite* scoreFrame = [[CCSprite alloc] initWithSpriteFrameName:@"staticbox_green.png"];
    CGSize frameSize = scoreFrame.boundingBox.size;
    [scoreFrame setScaleX:(screenSize.width*0.5/frameSize.width)];
    [scoreFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
    frameSize = scoreFrame.boundingBox.size;
    [scoreFrame setPosition:ccp(screenSize.width*0.75, screenSize.height - frameSize.height*0.5)];
    [self addChild:scoreFrame];
    
    scoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"$%i", tempScore] fontName:@"Marker Felt" fontSize:32];
    [scoreLabel setPosition:ccp(screenSize.width*0.75, screenSize.height - scoreFrame.boundingBox.size.height*0.5)];
    [self addChild:scoreLabel];
    
    //Testing only 
//    id delay = [CCDelayTime actionWithDuration:3];
//    id asd = [CCCallFunc actionWithTarget:self selector:@selector(doFulfillCustomer)];
//    [self runAction:[CCSequence actions:delay, asd, nil]];
}

-(void)initialiseCustomerGUI{
    customersArray = [CCArray new];
    
    for (int x = 0; x < 3; x++) {
        NBCustomer* thatCustomer = [[NBCustomer alloc] initWithIndex:x];
        [self addChild:thatCustomer z:-2];
        [customersArray addObject:thatCustomer];
    }
    
    //Testing
//    [self doFulfillCustomer:1 flowerScore:100];
}

-(void)updateScore{
    if (tempScore >= actualScore) {
        tempScore = actualScore;
        [self unschedule:@selector(updateScore)];
        isScoreUpdating = NO;
        return;
    }
    
    tempScore += 5;
    [scoreLabel setString:[NSString stringWithFormat:@"$%i", tempScore]];
}

-(void)doAddScore:(int)amount index:(int)customerIndex{
    actualScore += amount;
    
//    NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:customerIndex];
    
    CCLabelTTF* additionalScoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%i", amount] fontName:@"Marker Felt" fontSize:30];
    additionalScoreLabel.position = scoreLabel.position;
    [self addChild:additionalScoreLabel];
    [additionalScoreLabels addObject:additionalScoreLabel];
    id move = [CCMoveBy actionWithDuration:2 position:ccp(0, -50)];
    id delete = [CCCallFunc actionWithTarget:self selector:@selector(deleteAdditionalScoreLabel)];
    [additionalScoreLabel runAction:[CCSequence actions:move, delete, nil]];
    
    if (!isScoreUpdating) {
        [self schedule:@selector(updateScore) interval:1.0f/60.0f];
        isScoreUpdating = YES;
    }
}

-(void)deleteAdditionalScoreLabel{
    [[additionalScoreLabels objectAtIndex:0] removeFromParentAndCleanup:YES];
    [additionalScoreLabels removeObjectAtIndex:0];
}

-(void)doFulfillCustomer:(int)index flowerScore:(int)flowerScore{
    NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:index];
    int requestScore = 200;
    int totalScore = flowerScore + requestScore;
    [self doAddScore:totalScore index:index];
    [thatCustomer doCustomerLeave];
}

@end
