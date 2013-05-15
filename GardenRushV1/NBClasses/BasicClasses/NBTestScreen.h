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

@interface NBTestScreen : NBBasicScreenLayer

-(void)update:(ccTime)delta;

@property (nonatomic, retain) CCScene* currentScene;
@property (nonatomic, retain) NBFlowerFieldGameGrid* flowerFieldGameGrid;

@end