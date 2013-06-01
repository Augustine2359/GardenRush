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
        [self initialiseMisc];
        [self initialiseLivesGUI];
        [self initialiseScoreGUI];
        [self initialiseCustomerGUI];
    }
    return self;
}

-(void)initialiseMisc{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Main frame for GUI
    GUIFrame = [[CCSprite alloc] initWithSpriteFrameName:@"staticbox_green.png"];
    CGSize frameSize = GUIFrame.boundingBox.size;
    [GUIFrame setScaleX:(screenSize.width/frameSize.width)];
    [GUIFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
    frameSize = GUIFrame.boundingBox.size;
    [GUIFrame setPosition:ccp(screenSize.width*0.5, screenSize.height - frameSize.height*0.5)];
    [self addChild:GUIFrame];
    
    //Pause button
    CCSprite* pauseButton = [[CCSprite alloc] initWithSpriteFrameName:@"staticbox_red.png"];
    CCMenuItem* asd = [[CCMenuItem alloc] initWithTarget:self selector:@selector(doPauseGame)];
//    CGSize frameSize = GUIFrame.boundingBox.size;
//    [GUIFrame setScaleX:(screenSize.width/frameSize.width)];
//    [GUIFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
//    frameSize = GUIFrame.boundingBox.size;
//    [GUIFrame setPosition:ccp(screenSize.width*0.5, screenSize.height - frameSize.height*0.5)];
//    [self addChild:GUIFrame];
}

-(void)initialiseLivesGUI{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    //Read from datamanager when available
    int currentLives = 5;
    
    CGSize frameSize = GUIFrame.boundingBox.size;
    
    for (int x = 0; x < currentLives; x++) {
        CCSprite* lifeSprite = [[CCSprite alloc] initWithFile:@"Icon.png"];
        CGSize spriteSize = lifeSprite.boundingBox.size;
        [lifeSprite setScaleX:(frameSize.width*0.1/spriteSize.width)];
        [lifeSprite setScaleY:(frameSize.height*0.5/spriteSize.height)];
        spriteSize = lifeSprite.boundingBox.size;
        float liveOffsetFromLeft = GUIFrame.position.x*0.5 - spriteSize.width*0.5;
        [lifeSprite setPosition:ccp(liveOffsetFromLeft + spriteSize.width*x, screenSize.height - frameSize.height*0.5)];
//        [lifeSprite setPosition:ccp(0, 0)];
        [self addChild:lifeSprite];
        [livesArray addObject:lifeSprite];
    }
}

-(void)initialiseScoreGUI{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    additionalScoreLabels = [CCArray new];
    [additionalScoreLabels retain];
    
    actualScore = 0;
    tempScore = actualScore;
    
//    CCSprite* scoreFrame = [[CCSprite alloc] initWithSpriteFrameName:@"staticbox_green.png"];
//    CGSize frameSize = scoreFrame.boundingBox.size;
//    [scoreFrame setScaleX:(screenSize.width*0.4/frameSize.width)];
//    [scoreFrame setScaleY:(screenSize.height*0.08/frameSize.height)];
//    frameSize = scoreFrame.boundingBox.size;
//    [scoreFrame setPosition:ccp(screenSize.width*0.75, screenSize.height - frameSize.height*0.5)];
//    [self addChild:scoreFrame];
    
    scoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"$%i", tempScore] fontName:@"Marker Felt" fontSize:30];
    [scoreLabel setPosition:ccp(GUIFrame.boundingBox.size.width*0.8, GUIFrame.position.y)];
    [self addChild:scoreLabel];
    
    [self scheduleUpdate];
    
    //Testing only 
//    id delay = [CCDelayTime actionWithDuration:3];
//    id asd = [CCCallFunc actionWithTarget:self selector:@selector(doFulfillCustomer)];
//    [self runAction:[CCSequence actions:delay, asd, nil]];
}

-(void)initialiseCustomerGUI{
    customersArray = [[CCArray alloc] initWithCapacity:3];
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
    NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:index];
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
    [customersArray addObject:newCustomer];
//    [customersArray replaceObjectAtIndex:temp withObject:newCustomer]; //problem
    
    isSpawningCustomer = NO;
}

-(void)doPauseGame{
    //Set timeScale to 0
    //Transit image down cover screen
    //Resume and quit button
}

@end
