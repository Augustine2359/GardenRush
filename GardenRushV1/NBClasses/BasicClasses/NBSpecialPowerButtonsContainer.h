//
//  NBSpecialPowerButton.h
//  GardenRushV1
//
//  Created by Augustine on 28/5/13.
//
//

#import "CCNode.h"

@protocol NBSpecialPowerButtonsContainerDelegate <NSObject>

- (void)onButtonPressed:(CCSprite *)buttonSprite;

@end

@interface NBSpecialPowerButtonsContainer : CCNode

@property (nonatomic, strong) id<NBSpecialPowerButtonsContainerDelegate> delegate;

- (void)setShouldRespondToTouches:(BOOL)shouldRespondToTouches;
- (BOOL)containsButton:(CCSprite *)buttonSprite;

@end
