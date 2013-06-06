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

@synthesize customersArray;

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
        [self initialiseMisc];
        [self initialiseLivesGUI];
        [self initialiseScoreGUI];
        [self initialiseCustomerGUI];
        [self scheduleUpdate];
        
        sharedGameGUI = self;
    }
    return self;
}

-(void)initialiseMisc{
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Main frame for GUI
    GUIFrame = [CCSprite spriteWithSpriteFrameName:@"staticbox_green.png"];
    CGSize frameSize = GUIFrame.boundingBox.size;
    [GUIFrame setScaleX:(screenSize.width/frameSize.width)];
    [GUIFrame setScaleY:(screenSize.height*0.1/frameSize.height)];
    frameSize = GUIFrame.boundingBox.size;
    [GUIFrame setPosition:ccp(screenSize.width*0.5, screenSize.height - frameSize.height*0.5)];
    [self addChild:GUIFrame];
    
    //Pause button
    pauseButtonImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
//    CCMenuItem* pauseButton = [CCMenuItemImage itemWithNormalSprite:pauseButtonImage selectedSprite:pauseButtonImage target:self selector:@selector(doPauseGame)];//itemWithNormalImage:@"staticbox_red.png" selectedImage:@"staticbox_red.png" target:self selector:@selector(doPauseGame)];
    
//    CCMenuItemSprite* pauseButton = [[CCMenuItemSprite alloc] initWithNormalSprite:pauseButtonImage selectedSprite:pauseButtonImage disabledSprite:pauseButtonImage target:self selector:@selector(doPauseGame)];
    
    CGSize buttonSize = pauseButtonImage.boundingBox.size;
    [pauseButtonImage setScaleX:(frameSize.width*0.1/buttonSize.width)];
    [pauseButtonImage setScaleY:(frameSize.height*0.5/buttonSize.height)];
//    buttonSize = pauseButtonImage.boundingBox.size;
    [pauseButtonImage setPosition:ccp(frameSize.width*0.1, GUIFrame.position.y)];
    
    [self addChild:pauseButtonImage z:1];
    
//    CCMenu* GUIMenu = [CCMenu menuWithItems:pauseButton, nil];
//    [self addChild:GUIMenu];
}

-(void)initialiseLivesGUI{
    livesArray = [CCArray new];
    [livesArray retain];
    //Read from datamanager when available
    maxLives = 5;
    
    CGSize frameSize = GUIFrame.boundingBox.size;
    
    for (int x = 0; x < 3; x++) {
        CCSprite* lifeSprite = [[CCSprite alloc] initWithFile:@"Icon.png"];
        CGSize spriteSize = lifeSprite.boundingBox.size;
        [lifeSprite setScaleX:(frameSize.width*0.1/spriteSize.width)];
        [lifeSprite setScaleY:(frameSize.height*0.5/spriteSize.height)];
        spriteSize = lifeSprite.boundingBox.size;
        float liveOffsetFromLeft = GUIFrame.position.x*0.5;
        [lifeSprite setPosition:ccp(liveOffsetFromLeft + spriteSize.width*x, GUIFrame.position.y)];
        [self addChild:lifeSprite];
        [livesArray addObject:lifeSprite];
    }
    
    //Testing only
//    [self doChangeLife:-4];
}

-(void)initialiseScoreGUI{
    additionalScoreLabels = [CCArray new];
    [additionalScoreLabels retain];
    
    actualScore = 0;
    tempScore = actualScore;
    
    scoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"$%i", (int)tempScore] fontName:@"Marker Felt" fontSize:30];
    [scoreLabel setPosition:ccp(GUIFrame.boundingBox.size.width*0.8, GUIFrame.position.y)];
    [self addChild:scoreLabel];
    
    //Testing only 
//    id delay = [CCDelayTime actionWithDuration:2];
//    NSNumber* temp = [NSNumber numberWithInt:100];
//    id asd = [CCCallFuncND actionWithTarget:self selector:@selector(doAddScore:) data:temp];
//    [self runAction:[CCSequence actions:delay, asd, delay, asd, nil]];
}

-(void)initialiseCustomerGUI{
    customersArray = [[CCArray alloc] initWithCapacity:3];
    [customersArray addObject:NULL];
    [customersArray addObject:NULL];
    [customersArray addObject:NULL];
    
    missingCustomerIndex = [[CCArray alloc] initWithCapacity:3];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:2]];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:1]];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:0]];
    
    [self setSpawnInterval:1 max:3];
    [self setNextCustomerWaitingTime:30];
    [self setCustomerRequestAverageQuantity:3];
    
    //Testing
//    [self doFulfillCustomer:1 flowerScore:100];
//    [self doSpawnNewCustomer];
}

-(void)update:(ccTime)delta{
    //Update score
    if (isScoreUpdating) {
        tempScore += deltaScore;
        [scoreLabel setString:[NSString stringWithFormat:@"$%i", (int)tempScore]];
        
        if (tempScore >= actualScore) {
            tempScore = actualScore;
            isScoreUpdating = NO;
        }
    }
    
    //Spawn customer
    if ([missingCustomerIndex count] > 0 && !isSpawningCustomer) {
        CCLOG(@"Spawn customer!");
        isSpawningCustomer = YES;
        int randomDelay = arc4random() % maxSpawnInterval + minSpawnInterval;
        id delay = [CCDelayTime actionWithDuration:randomDelay];
        int temp1 = [[missingCustomerIndex objectAtIndex:[missingCustomerIndex count]-1] intValue];
        [missingCustomerIndex removeLastObject];
        NSNumber* temp2 = [NSNumber numberWithInt:temp1];
        id action = [CCCallFuncND actionWithTarget:self selector:@selector(doSpawnNewCustomer:index:/*requestQuantity:waitingTime:*/) data:temp2];
        [self runAction:[CCSequence actions:delay, action, nil]];
    }
}

-(void)doAddScore:(int)amount{
//    amount = 200;
    actualScore += amount;
    deltaScore = actualScore - tempScore;
    deltaScore = deltaScore / 60;
    
    CCLabelTTF* additionalScoreLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"+%i", amount] fontName:@"Marker Felt" fontSize:30];
    additionalScoreLabel.position = scoreLabel.position;
    [self addChild:additionalScoreLabel];
    [additionalScoreLabels addObject:additionalScoreLabel];
    id move = [CCMoveBy actionWithDuration:2 position:ccp(0, -50)];
    id delete = [CCCallFunc actionWithTarget:self selector:@selector(deleteAdditionalScoreLabel)];
    [additionalScoreLabel runAction:[CCSequence actions:move, delete, nil]];
    
    isScoreUpdating = YES;
}

-(void)deleteAdditionalScoreLabel{
    [[additionalScoreLabels objectAtIndex:0] removeFromParentAndCleanup:YES];
    [additionalScoreLabels removeObjectAtIndex:0];
}

-(void)doFulfillCustomer:(int)index flowerScore:(int)flowerScore{
    if (index > [customersArray count]) {
        CCLOG(@"Invalid customer index");
        return;
    }
    
    NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:index];
    int requestScore = thatCustomer.requestScore;
    int totalScore = flowerScore + requestScore;
    [self doAddScore:totalScore];
    [thatCustomer doCustomerLeave];
    [self doDeleteCustomer:[NSNumber numberWithInt:index]];
}

-(void)doSpawnNewCustomer:(id)sender index:(NSNumber*)index/* requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime*/{
    int temp = [index intValue];
    
    //Quantity is the average +- 1
    int quantity = arc4random() * 3 - 1;
    quantity += averageRequestQuantity;
    if (quantity < 1) {
        quantity = 1;
    }
    else if (quantity > 5){
        quantity = 5;
    }
    
    NBCustomer* newCustomer = [[NBCustomer alloc] initWithIndex:temp/* layer:self leaveSelector:@selector(doDeleteCustomer)*/ requestQuantity:quantity waitingTime:nextWaitingTime];
    [self addChild:newCustomer z:-2];
    [customersArray replaceObjectAtIndex:temp withObject:newCustomer];
    
    isSpawningCustomer = NO;
}

-(void)doDeleteCustomer:(NSNumber*)index{
    int thatIndex = [index intValue];
    [missingCustomerIndex addObject:[NSNumber numberWithInt:thatIndex]];
    [customersArray replaceObjectAtIndex:thatIndex withObject:NULL];
}

-(void)doPauseGame{
    CCLOG(@"Paused game!");
    //Set timeScale to 0
    //Transit image down cover screen
    //Resume and quit button
}

-(void)doChangeLife:(int)amount{
    if (amount > 0) {
        for (int x = 0; x < amount; x++) {
            if ([livesArray count] == maxLives) {
                CCLOG(@"Full life");
                return;
            }
            
            CGSize frameSize = GUIFrame.boundingBox.size;

            CCSprite* lifeSprite = [[CCSprite alloc] initWithFile:@"Icon.png"];
            CGSize spriteSize = lifeSprite.boundingBox.size;
            [lifeSprite setScaleX:(frameSize.width*0.1/spriteSize.width)];
            [lifeSprite setScaleY:(frameSize.height*0.5/spriteSize.height)];
            spriteSize = lifeSprite.boundingBox.size;
            float liveOffsetFromLeft = GUIFrame.position.x*0.5;
            int index = [livesArray count];
            [lifeSprite setPosition:ccp(liveOffsetFromLeft + spriteSize.width*index, GUIFrame.position.y)];
            [self addChild:lifeSprite];
            [livesArray addObject:lifeSprite];
        }
    }
    else if (amount < 0){
        for (int x = amount; x < 0; x++) {
            if ([livesArray count] == 0) {
                CCLOG(@"No more lives");
                //Call game over method here
                return;
            }
            
            [[livesArray objectAtIndex:[livesArray count]-1] removeFromParentAndCleanup:YES];
            [livesArray removeLastObject];
        }
    }
}

-(void)setSpawnInterval:(int)min max:(int)max{
    minSpawnInterval = min;
    maxSpawnInterval = max - min + 1;
}

-(void)setCustomerRequestAverageQuantity:(int)amount{
    averageRequestQuantity = amount;
}

-(void)setNextCustomerWaitingTime:(float)time{
    nextWaitingTime = time;
}

@end
