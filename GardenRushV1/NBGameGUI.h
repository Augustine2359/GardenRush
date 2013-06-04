//
//  NBGameGUI.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 8/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBCustomer.h"


@interface NBGameGUI : CCLayer {
    CCSprite* GUIFrame;
    
    CCSprite* pauseButtonImage;
    
    CCArray* livesArray;
    int maxLives;
    
    CCLabelTTF* scoreLabel;
    CCArray* additionalScoreLabels;
    float tempScore, actualScore;
    float deltaScore;
    bool isScoreUpdating;
    
    CCArray* customersArray;
    CCArray* missingCustomerIndex;
    bool isSpawningCustomer;
    int minSpawnInterval, maxSpawnInterval;
}

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
-(void)doAddScore:(int)amount;
-(void)doFulfillCustomer:(int)index flowerScore:(int)flowerScore; //Index is 0, 1, 2
-(void)doSpawnNewCustomer:(id)sender index:(NSNumber*)index requestQuantity:(int)requestQuantity waitingTime:(float)waitingTime;
-(void)doDeleteCustomer:(NSNumber*)index;
-(void)doPauseGame;
-(void)doChangeLife:(int)amount;
-(void)doAssignSpawnInterval:(int)min max:(int)max;

@end
