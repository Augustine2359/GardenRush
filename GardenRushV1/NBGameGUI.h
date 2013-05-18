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
    
    CCLabelTTF* moneyLabel;
    int tempMoney, actualMoney;
    
    CCArray* customersArray;
}

-(void)initialiseLivesGUI;
-(void)initialiseMoneyGUI;
-(void)initialiseCustomerGUI;

-(void)updateCustomer:(ccTime)deltaTime;
-(void)updateMoney;

-(void)doAddMoney:(int)amount;

@end
