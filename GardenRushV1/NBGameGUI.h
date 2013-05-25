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

//Private
-(void)initialiseLivesGUI;
-(void)initialiseScoreGUI;
-(void)initialiseCustomerGUI;
-(void)updateScore;
-(void)doAddScore:(int)amount index:(int)customerIndex;
-(void)deleteAdditionalScoreLabel;

//Public
-(void)doFulfillCustomer:(int)index flowerScore:(int)flowerScore; //Index is 0, 1, 2

@end
