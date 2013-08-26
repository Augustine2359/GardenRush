//
//  NBPreGameScreen.h
//  GardenRushV1
//
//  Created by Augustine on 31/5/13.
//
//

#import "NBBasicScreenLayer.h"
#import <UIKit/UIKit.h>

@interface NBPreGameScreen : NBBasicScreenLayer{
    
    int energyLevel, energyMaxLevel;
    int item0Quantity, item1Quantity, item2Quantity;
    CCLabelTTF* energyLabel;
    CCLabelTTF* item0QuantityLabel;
    CCLabelTTF* item1QuantityLabel;
    CCLabelTTF* item2QuantityLabel;
}

-(void)doReduceEnergy:(int)reducedEnergy;
//-(void)doStartEnergyTimer;
//-(void)updateEnergyTimer;

-(void)onBuyButtonPressed/*:(id)buyButton*/;
-(void)goToAppStore;
-(void)goToGame;

@end
