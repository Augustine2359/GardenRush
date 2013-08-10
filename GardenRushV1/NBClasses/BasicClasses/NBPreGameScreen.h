//
//  NBPreGameScreen.h
//  GardenRushV1
//
//  Created by Augustine on 31/5/13.
//
//

#import "NBBasicScreenLayer.h"

@interface NBPreGameScreen : NBBasicScreenLayer
{
    int item0Quantity, item1Quantity, item2Quantity;
    CCLabelTTF* item0QuantityLabel;
    CCLabelTTF* item1QuantityLabel;
    CCLabelTTF* item2QuantityLabel;
}

-(void)goToAppStore/*:(id)buyButton*/;
-(void)goToGame;

@end
