//
//  NBGameGUI.h
//  GardenRushV1
//
//  Created by NebulaMac1 on 8/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NBCustomer.h"


@interface NBGameGUI : CCLayer {
    CCArray* livesArray;
    
    CCLabelTTF* scoreLabel;
    CCArray* additionalScoreLabels;
    int tempScore, actualScore;
    bool isScoreUpdating;
    
    CCArray* customersArray;
}

-(void)initialiseLivesGUI;
-(void)initialiseScoreGUI;
-(void)initialiseCustomerGUI;

-(void)updateCustomer:(ccTime)deltaTime;
-(void)updateScore;
-(void)deleteAdditionalScoreLabel;

-(void)doAddScore:(int)amount;

@end
