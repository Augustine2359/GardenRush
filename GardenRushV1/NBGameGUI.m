//
//  NBGameGUI.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 8/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBGameGUI.h"
#import "NBDifficultyTier.h"
#import "NBTestScreen.h"

static NBGameGUI* sharedGameGUI = nil;
static CGPoint scorePosition = {0, 0};
bool isPaused = false;


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
        
        /*[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];*/
        
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
    CCSprite* pauseButtonImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCSprite* pauseButtonImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCMenuItemSprite* pauseButton = [CCMenuItemSprite itemWithNormalSprite:pauseButtonImageNormal selectedSprite:pauseButtonImageSelected target:self selector:@selector(doPauseGame)];
    
    [pauseButton setScale:2];
    [pauseButton setPosition:ccp(-screenSize.width*0.5 + frameSize.width*0.1, -screenSize.height*0.5 + GUIFrame.position.y)];
    
    CCMenu* GUIMenu = [CCMenu menuWithItems:pauseButton, nil];
    [self addChild:GUIMenu];
    
    NBDifficultyTier* difficultyTier = [NBDifficultyTier new];
    [difficultyTier setTier:1];
    [self addChild:difficultyTier];
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
    
    [self setSpawnInterval:14 max:21];
    [self setNextCustomerWaitingTime:60];
    [self setCustomerRequestAverageQuantity:1];
    
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
    [[NBDifficultyTier sharedDifficulty] checkTierUpdate:(int)actualScore];
}

-(void)deleteAdditionalScoreLabel{
    [[additionalScoreLabels objectAtIndex:0] removeFromParentAndCleanup:YES];
    [additionalScoreLabels removeObjectAtIndex:0];
}

-(void)doFulfillCustomer:(int)customerIndex flowerIndex:(int)flowerIndex flowerScore:(int)flowerScore{
    if (customerIndex > [customersArray count]) {
        CCLOG(@"Invalid customer index");
        return;
    }
    
    //Add score
    NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:customerIndex];
    int requestScore = thatCustomer.requestScore;
    int totalScore = flowerScore + requestScore;
    [self doAddScore:totalScore];
    
    //Update requests
    NBBouquet* thatFlower = (NBBouquet*)[thatCustomer.request objectAtIndex:flowerIndex];
    [thatFlower removeFromParentAndCleanup:YES];
    [thatCustomer.request removeObjectAtIndex:flowerIndex];
    
    //Completed all requests
    if (thatCustomer.request.count <= 0) {
        [thatCustomer doCustomerLeave];
        [self doDeleteCustomer:[NSNumber numberWithInt:customerIndex]];
    }
}

-(void)doSpawnNewCustomer:(id)sender index:(NSNumber*)index/* requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime*/{
    int temp = [index intValue];
    
    //Quantity is the average +- 1
    int quantity = arc4random() % 3 - 1;
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
    if (isPaused) {
        return;
    }
    
    CCLOG(@"Paused game!");
    isPaused = YES;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Set timeScale to 0
    [self pauseSchedulerAndActions];
    for(CCSprite *sprite in [self children]) {
        [[[CCDirector sharedDirector] actionManager] pauseTarget:sprite];
    }
    for(int x = 0; x < [customersArray count]; x++){
        if ([customersArray objectAtIndex:x] != NULL) {
            NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:x];
            [thatCustomer pauseSchedulerAndActions];
        }
    }
    
    //Pause GUI
    CCSprite* pauseFrameImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_sky.png"];
    CCSprite* pauseFrameImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_sky.png"];
    CCMenuItemImage* pauseFrame = [CCMenuItemImage itemWithNormalSprite:pauseFrameImageNormal selectedSprite:pauseFrameImageSelected];
    CGSize frameSize = pauseFrame.boundingBox.size;
    [pauseFrame setScaleX:(screenSize.width/frameSize.width)];
    [pauseFrame setScaleY:(screenSize.height*0.9/frameSize.height)];
    frameSize = pauseFrame.boundingBox.size;
    [pauseFrame setPosition:ccp(screenSize.width*0.5, frameSize.height*0.5)];
    [pauseFrame setIsEnabled:NO];
    
    CCSprite* resumeButtonImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCSprite* resumeButtonImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCMenuItemImage* resumeButton = [CCMenuItemSprite itemWithNormalSprite:resumeButtonImageNormal selectedSprite:resumeButtonImageSelected target:self selector:@selector(doResumeGame)];
    frameSize = resumeButton.boundingBox.size;
    [resumeButton setScaleX:(screenSize.width*0.5/frameSize.width)];
    [resumeButton setScaleY:(screenSize.width*0.1/frameSize.height)];
    [resumeButton setPosition:ccp(screenSize.width*0.5, screenSize.height*0.7)];
    
    CCSprite* quitButtonImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCSprite* quitButtonImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCMenuItemImage* quitButton = [CCMenuItemSprite itemWithNormalSprite:quitButtonImageNormal selectedSprite:quitButtonImageSelected target:self selector:@selector(doQuitGame)];
    frameSize = quitButton.boundingBox.size;
    [quitButton setScaleX:(screenSize.width*0.5/frameSize.width)];
    [quitButton setScaleY:(screenSize.width*0.1/frameSize.height)];
    [quitButton setPosition:ccp(screenSize.width*0.5, screenSize.height*0.3)];
    
    pauseMenu = [CCMenu menuWithItems: pauseFrame, resumeButton, quitButton, nil];
    [pauseMenu setPosition:ccp(0, screenSize.height)];
    [self addChild:pauseMenu z:-1];
    
    //Pause transition
    [pauseMenu runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0, -screenSize.height)]];
}

-(void)doResumeGame{
    CCLOG(@"Resume Game!");
    isPaused = NO;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    id move = [CCMoveBy actionWithDuration:0.25 position:ccp(0, screenSize.height)];
    id action = [CCCallFunc actionWithTarget:self selector:@selector(doResumeGameCallback)];
    [pauseMenu runAction:[CCSequence actions:move, action, nil]];
}

-(void)doResumeGameCallback{
    [self resumeSchedulerAndActions];
    for(CCSprite *sprite in [self children]) {
        [[[CCDirector sharedDirector] actionManager] resumeTarget:sprite];
    }
    
    for(int x = 0; x < [customersArray count]; x++){
        if ([customersArray objectAtIndex:x] != NULL) {
            NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:x];
            [thatCustomer resumeSchedulerAndActions];
        }
    }
    
    [pauseMenu removeFromParentAndCleanup:YES];
}

-(void)doQuitGame{
    CCLOG(@"Quit Game!");
    isPaused = NO;
    NBBasicScreenLayer* parentLayer = (NBBasicScreenLayer*)[self parent];
    [parentLayer changeToScene:TargetSceneMain];
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
