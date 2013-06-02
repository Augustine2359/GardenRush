//
//  HelloWorldLayer.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 4/5/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>
#import "NBGameKitHelper.h"
#import "NBBasicScreenLayer.h"
#import "NBTestNode.h"

// HelloWorldLayer
@interface MainGameLayer : NBBasicScreenLayer <NBGameKitHelperProtocol>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@property (nonatomic, retain) CCLabelTTF* testNodeCountLabel;
@property (nonatomic, retain) CCLabelTTF* layerNodeCountLabel;

@end
