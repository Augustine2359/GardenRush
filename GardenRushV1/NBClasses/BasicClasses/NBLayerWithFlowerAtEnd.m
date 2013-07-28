//
//  NBLayerWithFlowerAtEnd.m
//  GardenRushV1
//
//  Created by Augustine on 3/6/13.
//
//

#import "NBLayerWithFlowerAtEnd.h"

@interface NBLayerWithFlowerAtEnd()

@property (nonatomic, strong) CCSprite *petalSprite;

@end

@implementation NBLayerWithFlowerAtEnd

- (id)initWithColor:(ccColor4B)color width:(GLfloat)w height:(GLfloat)h
{
    self = [super initWithColor:color width:w height:h];
    
    if (self)
    {
        NBFlowerPetalType randomFlowerPetalType = (NBFlowerPetalType)(arc4random_uniform(fptMaxFlowerPetal - fptFlowerPetal1) + fptFlowerPetal1);
        
        switch (randomFlowerPetalType)
        {
            case fptFlowerPetal1:
                self.petalSprite = [CCSprite spriteWithSpriteFrameName:@"flower_petals1_64x64.png"];
                break;
                
            case fptFlowerPetal2:
                self.petalSprite = [CCSprite spriteWithSpriteFrameName:@"flower_petals2_64x64.png"];
                break;
            
            case fptFlowerPetal3:
                self.petalSprite = [CCSprite spriteWithSpriteFrameName:@"flower_petals3_64x64.png"];
                break;
                
            default:
                self.petalSprite = [CCSprite spriteWithSpriteFrameName:@"flower_petals1_64x64.png"];
                break;
        }
        
        //self.petalSprite.scaleX = 0.5;
        //self.petalSprite.scaleY = 0.5;
        self.petalSprite.position = CGPointMake(w/2, 0);
        [self addChild:self.petalSprite];

        CCMoveBy *moveBy = [[CCMoveBy alloc] initWithDuration:10 position:CGPointMake(0, -[[CCDirector sharedDirector] winSize].height - h)];
        CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(removeFromParentAndCleanup:)];
        CCSequence *sequence = [CCSequence actionOne:moveBy two:callFunc];
        [self runAction:sequence];

        [self randomlyRotate];
    }
  
    return self;
}

- (void)randomlyRotate {
  if (arc4random()%2)
    [self randomlyRotateClockwise];
  else
    [self randomlyRotateAnticlockwise];
}

- (void)randomlyRotateClockwise {
  NSInteger angle = arc4random()%15;
  angle += 15;
  CCRotateTo *rotateTo = [CCRotateTo actionWithDuration:1 angle:angle];
  CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(randomlyRotateAnticlockwise)];
  CCSequence *sequence = [CCSequence actionOne:rotateTo two:callFunc];
  [self runAction:sequence];

  [self randomlyRotatePetal];
}

- (void)randomlyRotateAnticlockwise {
  NSInteger angle = arc4random()%15;
  angle *= -1;
  angle -= 15;
  CCRotateTo *rotateTo = [CCRotateTo actionWithDuration:1 angle:angle];
  CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(randomlyRotateClockwise)];
  CCSequence *sequence = [CCSequence actionOne:rotateTo two:callFunc];
  [self runAction:sequence];

  [self randomlyRotatePetal];
}

- (void)randomlyRotatePetal {
  NSInteger angle = arc4random()%90;
  angle -=45;
  CCRotateTo *rotateTo = [CCRotateTo actionWithDuration:1 angle:angle];
  [self.petalSprite runAction:rotateTo];
}

@end
