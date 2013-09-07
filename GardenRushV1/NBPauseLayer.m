//
//  NBPauseLayer.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 10/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBPauseLayer.h"
#import "NBGameGUI.h"

bool isGamePaused = NO;


@implementation NBPauseLayer


-(id)initialise{
    [self setIsTouchEnabled:YES];
    [self retain];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    //Pause GUI
    CCSprite* pauseFrameImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_sky.png"];
    CCSprite* pauseFrameImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_sky.png"];
    CCMenuItemImage* pauseFrame = [CCMenuItemImage itemWithNormalSprite:pauseFrameImageNormal selectedSprite:pauseFrameImageSelected];
    CGSize frameSize = pauseFrame.boundingBox.size;
    [pauseFrame setScaleX:(screenSize.width/frameSize.width)];
    [pauseFrame setScaleY:(screenSize.height*0.9/frameSize.height)];
    frameSize = pauseFrame.boundingBox.size;
    [pauseFrame setPosition:ccp(screenSize.width*0.5, frameSize.height*0.5)];
//    [pauseFrame setIsEnabled:NO];
    
    CCSprite* resumeButtonImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCSprite* resumeButtonImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCMenuItemImage* resumeButton = [CCMenuItemSprite itemWithNormalSprite:resumeButtonImageNormal selectedSprite:resumeButtonImageSelected target:self selector:@selector(resumeGame)];
    frameSize = resumeButton.boundingBox.size;
    [resumeButton setScaleX:(screenSize.width*0.5/frameSize.width)];
    [resumeButton setScaleY:(screenSize.width*0.1/frameSize.height)];
    [resumeButton setPosition:ccp(screenSize.width*0.5, screenSize.height*0.7)];
    
    CCSprite* quitButtonImageNormal = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCSprite* quitButtonImageSelected = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    CCMenuItemImage* quitButton = [CCMenuItemSprite itemWithNormalSprite:quitButtonImageNormal selectedSprite:quitButtonImageSelected target:self selector:@selector(quitGame)];
    frameSize = quitButton.boundingBox.size;
    [quitButton setScaleX:(screenSize.width*0.5/frameSize.width)];
    [quitButton setScaleY:(screenSize.width*0.1/frameSize.height)];
    [quitButton setPosition:ccp(screenSize.width*0.5, screenSize.height*0.3)];
    
    pauseMenu = [CCMenu menuWithItems: pauseFrame, resumeButton, quitButton, nil];
    [pauseMenu setPosition:ccp(0, 0)];
//    [pauseMenu setPosition:ccp(0, screenSize.height)];
    [self addChild:pauseMenu z:-1];
    
    return self;
}


-(void)pauseGame{
    if (isGamePaused) {
        return;
    }
    
    CCLOG(@"Paused game!");
    isGamePaused = YES;
    
    //Set timeScale to 0
    [self.parent pauseSchedulerAndActions];
//    for(CCSprite *sprite in [self.parent children]) {
//        [[[CCDirector sharedDirector] actionManager] pauseTarget:sprite];
//    }
//    [self pauseSchedulerAndActions];
//    for(CCSprite *sprite in [self children]) {
//        [[[CCDirector sharedDirector] actionManager] pauseTarget:sprite];
//    }
    CCArray* customersArray = [[NBGameGUI sharedGameGUI] customersArray];
    for(int x = 0; x < [customersArray count]; x++){
        if ([customersArray objectAtIndex:x] != NULL) {
            NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:x];
            [thatCustomer pauseSchedulerAndActions];
        }
    }
    
    //Pause transition
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    [self runAction:[CCMoveBy actionWithDuration:0.25 position:ccp(0, -screenSize.height)]];
}

-(void)resumeGame{
    CCLOG(@"Resume Game!");
    isGamePaused = NO;
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    id move = [CCMoveBy actionWithDuration:0.25 position:ccp(0, screenSize.height)];
    id action = [CCCallFunc actionWithTarget:self selector:@selector(doResumeGameCallback)];
    [self runAction:[CCSequence actions:move, action, nil]];
}

-(void)doResumeGameCallback{
    [self.parent resumeSchedulerAndActions];
//    for(CCSprite *sprite in [self.parent children]) {
//        [[[CCDirector sharedDirector] actionManager] resumeTarget:sprite];
//    }
//    [self resumeSchedulerAndActions];
//    for(CCSprite *sprite in [self children]) {
//        [[[CCDirector sharedDirector] actionManager] resumeTarget:sprite];
//    }
    
    CCArray* customersArray = [[NBGameGUI sharedGameGUI] customersArray];
    for(int x = 0; x < [customersArray count]; x++){
        if ([customersArray objectAtIndex:x] != NULL) {
            NBCustomer* thatCustomer = (NBCustomer*)[customersArray objectAtIndex:x];
            [thatCustomer resumeSchedulerAndActions];
        }
    }
    
//    [pauseMenu removeFromParentAndCleanup:YES];
}

-(void)quitGame{
    CCLOG(@"Quit Game!");
    isGamePaused = NO;
    NBBasicScreenLayer* parentLayer = (NBBasicScreenLayer*)[self.parent parent];
    [parentLayer changeToScene:TargetSceneMain];
    [self release];
}

@end
