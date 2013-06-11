//
//  NBTestScreen.h
//  ElementArmy1.0
//
//  Created by Romy Irawaty on 19/1/13.
//
//

#import <Foundation/Foundation.h>
#import "NBBasicScreenLayer.h"
#import "NBGameGUI.h"
#import "NBFlowerFieldGameGrid.h"
#import "NBBouquet.h"

@interface NBTestScreen : NBBasicScreenLayer

-(void)update:(ccTime)delta;

@property (nonatomic, retain) CCScene* currentScene;
@property (nonatomic, retain) NBFlowerFieldGameGrid* flowerFieldGameGrid;
@property (nonatomic, retain) CCLabelTTF* flowerCountLabel;
@property (nonatomic, retain) CCLabelTTF* flowerFieldChildCountLabel;
@property (nonatomic, retain) CCLabelTTF* isProcessingMoveLabel;
@property (nonatomic, retain) CCLabelTTF* isProcessingMatchLabel;

@end