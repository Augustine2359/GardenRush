//
//  NBGameGUI.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 8/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBCustomer.h"
#import "NBBasicScreenLayer.h"
#import "NBPauseLayer.h"

@interface NBGameGUI : CCLayer {
    //Misc
    CCSprite* GUIFrame;
    CCMenu* pauseMenu;
    NBPauseLayer* pauseLayer;
    
    //Life
    CCArray* livesArray;
    int maxLives;
    
    //Score
    CCLabelTTF* scoreLabel;
    CCArray* additionalScoreLabels;
    CCArray* customerExtraLabels;
    float tempScore, actualScore;
    float deltaScore;
    float scoreMultiplier;
    bool isScoreUpdating;
    
    CCArray* missingCustomerIndex;
    bool isSpawningCustomer;
    int minSpawnInterval, maxSpawnInterval;
    int averageRequestQuantity;
    float nextWaitingTime;
    CCArray* customersArray;
}

@property (nonatomic, retain) CCArray* customersArray;

//Private
-(void)initialiseLivesGUI;
-(void)initialiseScoreGUI;
-(void)initialiseCustomerGUI;
-(void)update:(ccTime)delta;
//-(void)updateScore;
-(void)deleteAdditionalScoreLabel;

//Public
+(NBGameGUI*)sharedGameGUI;
+(CGPoint)getScorePosition;
-(void)update:(ccTime)delta;
-(void)doAddScore:(int)amount;
-(void)doFulfillCustomer:(int)customerIndex flowerIndex:(int)flowerIndex flowerScore:(int)flowerScore; //Index is 0, 1, 2
-(void)doAngerCustomer:(int)customerIndex; //Index is 0, 1, 2
-(void)doSpawnNewCustomer:(id)sender index:(NSNumber*)index/* requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime*/;
-(void)doDeleteCustomer:(NSNumber*)index;
-(void)doPauseGame;
//-(void)doPauseGame;
//-(void)doResumeGame;
//-(void)doQuitGame;
-(void)doAddOneLife;
-(void)doMinusOneLife;
-(void)doChangeLife:(int)amount;
-(void)setSpawnInterval:(int)min max:(int)max;
-(void)setCustomerRequestAverageQuantity:(int)amount;
-(void)setNextCustomerWaitingTime:(float)time;

-(float)getScoreMultiplier;
-(void)setScoreMultiplier:(float)newMultiplier;
-(void)resetScoreMultiplier;

@end
