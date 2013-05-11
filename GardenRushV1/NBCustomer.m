//
//  NBCustomer.m
//  GardenRushV1
//
//  Created by NebulaMac1 on 11/5/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NBCustomer.h"


@implementation NBCustomer

-(id)initWithIndex:(int)index{
    if ([super init]) {
        CCLOG(@"creating cust");
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        //Background frame
        CCSprite* customerFrame = [[CCSprite alloc] initWithFile:@"Default-Landscape~ipad.png"];
        CGSize frameSize = customerFrame.boundingBox.size;
        [customerFrame setScaleX:((screenSize.width/3)/frameSize.width)];
        [customerFrame setScaleY:(screenSize.height*0.2/frameSize.height)];
        frameSize = customerFrame.boundingBox.size;
        [customerFrame setPosition:ccp(screenSize.width/3 * index + frameSize.width*0.5, screenSize.height - frameSize.height)];
        [self addChild:customerFrame];
        
        //Sprite image
        faceImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
        [faceImage setScale:2.5];
        [faceImage setPosition:ccp(customerFrame.position.x - customerFrame.boundingBox.size.width*0.25,
                                   customerFrame.position.y + customerFrame.boundingBox.size.height*0.25)];
        [self addChild:faceImage];
        
        //Request images
        //TimerBar image
    }
    return self;
}
@end
