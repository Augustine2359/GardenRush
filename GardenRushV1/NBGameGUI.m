//
//  NBGameGUI.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 8/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBGameGUI.h"

static NBGameGUI* sharedGameGUI = nil;
static CGPoint scorePosition = {0, 0};

@implementation NBGameGUI

+(NBGameGUI*)sharedGameGUI
{
    return sharedGameGUI;
}

+(CGPoint)getScorePosition
{
    return scorePosition;
}

-(id)init{
    if ([super init]) {
        [self initialiseLivesGUI];
        [self initialiseScoreGUI];
        [self initialiseCustomerGUI];
        
        sharedGameGUI = self;
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
    
    scoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"$%i", tempScore] fontName:@"Marker Felt" fontSize:24];
    scorePosition = ccp(screenSize.width*0.75, screenSize.height - scoreFrame.boundingBox.size.height*0.5);
    [scoreLabel setPosition:scorePosition];
    [self addChild:scoreLabel];
    
    [self scheduleUpdate];
    
    //Testing only 
//    id delay = [CCDelayTime actionWithDuration:3];
//    id asd = [CCCallFunc actionWithTarget:self selector:@selector(doFulfillCustomer)];
//    [self runAction:[CCSequence actions:delay, asd, nil]];
}

-(void)initialiseCustomerGUI{
    self.customersArray = [[CCArray alloc] initWithCapacity:3];
    missingCustomerIndex = [CCArray new];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:2]];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:1]];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:0]];
    
//    for (int x = 0; x < 3; x++) {
//        NBCustomer* thatCustomer = [[NBCustomer alloc] initWithIndex:x];
//        [self addChild:thatCustomer z:-2];
//        [customersArray addObject:thatCustomer];
//    }
    
    //Testing
//    [self doFulfillCustomer:1 flowerScore:100];
//    [self doSpawnNewCustomer];
}

-(void)update:(ccTime)delta{
    
    //Update score
    if (isScoreUpdating) {
        tempScore += 5;
        [scoreLabel setString:[NSString stringWithFormat:@"$%i", tempScore]];
        
        if (tempScore >= actualScore) {
            tempScore = actualScore;
            isScoreUpdating = NO;
        }
    }
    
    //Spawn customer
    if ([missingCustomerIndex count] > 0 && !isSpawningCustomer) {
        isSpawningCustomer = YES;
        int randomDelay = arc4random() % 3  + 1;
        id delay = [CCDelayTime actionWithDuration:randomDelay];
        int temp1 = [[missingCustomerIndex objectAtIndex:[missingCustomerIndex count]-1] intValue];
        [missingCustomerIndex removeLastObject];
        NSNumber* temp2 = [NSNumber numberWithInt:temp1];
        id action = [CCCallFuncND actionWithTarget:self selector:@selector(doSpawnNewCustomer:index:) data:temp2];
        [self runAction:[CCSequence actions:delay, action, nil]];
    }
}

//-(void)updateScore{
//    if (tempScore >= actualScore) {
//        tempScore = actualScore;
//        [self unschedule:@selector(updateScore)];
//        isScoreUpdating = NO;
//        return;
//    }
//    
//    tempScore += 5;
//    [scoreLabel setString:[NSString stringWithFormat:@"$%i", tempScore]];
//}

-(void)doAddScore:(int)amount{
    actualScore += amount;
    
//    NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:customerIndex];
    
    CCLabelTTF* additionalScoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%i", amount] fontName:@"Marker Felt" fontSize:30];
    additionalScoreLabel.position = scoreLabel.position;
    [self addChild:additionalScoreLabel];
    [additionalScoreLabels addObject:additionalScoreLabel];
    id move = [CCMoveBy actionWithDuration:2 position:ccp(0, -50)];
    id delete = [CCCallFunc actionWithTarget:self selector:@selector(deleteAdditionalScoreLabel)];
    [additionalScoreLabel runAction:[CCSequence actions:move, delete, nil]];
    
//    if (!isScoreUpdating) {
//        [self schedule:@selector(updateScore) interval:1.0f/60.0f];
//        isScoreUpdating = YES;
//    }
    
    isScoreUpdating = YES;
}

-(void)deleteAdditionalScoreLabel{
    [[additionalScoreLabels objectAtIndex:0] removeFromParentAndCleanup:YES];
    [additionalScoreLabels removeObjectAtIndex:0];
}

-(void)doFulfillCustomer:(int)index flowerScore:(int)flowerScore{
    NBCustomer* thatCustomer = (NBCustomer*)[self.customersArray objectAtIndex:index];
    int requestScore = thatCustomer.requestScore;
    int totalScore = flowerScore + requestScore;
    [self doAddScore:totalScore];
    [thatCustomer doCustomerLeave];
}

-(void)doSpawnNewCustomer:(id)sender index:(NSNumber*)index{
    CCLOG(@"OH");
    
    int temp = [index intValue];
    NBCustomer* newCustomer = [[NBCustomer alloc] initWithIndex:temp];
//    newCustomer.position = ccp(newCustomer.position.x, screenSize.height + newCustomer.boundingBox.size.height);
    [self addChild:newCustomer z:-2];
    [self.customersArray addObject:newCustomer];
//    [customersArray replaceObjectAtIndex:temp withObject:newCustomer]; //problem
    
    isSpawningCustomer = NO;
}

@end
