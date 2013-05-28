//
//  NBSpecialPowerButton.h
//  GardenRushV1
//
//  Created by Augustine on 28/5/13.
//
//

#import "CCNode.h"

@protocol NBSpecialPowerButtonsContainerDelegate <NSObject>

- (void)onButtonPressed:(NSInteger)button;

@end

@interface NBSpecialPowerButtonsContainer : CCNode

@property (nonatomic, strong) id<NBSpecialPowerButtonsContainerDelegate> delegate;

@end
