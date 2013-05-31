//
//  NBSpecialPowerButton.m
//  GardenRushV1
//
//  Created by Augustine on 28/5/13.
//
//

#import "NBSpecialPowerButtonsContainer.h"

@interface NBSpecialPowerButtonsContainer()<CCTargetedTouchDelegate>

@property (nonatomic, strong) NSMutableArray *buttonSprites;

@end

@implementation NBSpecialPowerButtonsContainer

- (id)init {
  self = [super init];
  if (self) {
    self.buttonSprites = [NSMutableArray array];
    
    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];
    sprite.scale = 5;
    sprite.position = CGPointMake(sprite.contentSize.width/2 * sprite.scale, sprite.contentSize.height/2 * sprite.scale);
    sprite.tag = 0;
    [self addChild:sprite];
    [self.buttonSprites addObject:sprite];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_red.png"];
    sprite.scale = 5;
    sprite.position = CGPointMake(150, sprite.contentSize.height/2 * sprite.scale);
    sprite.tag = 1;
    [self addChild:sprite];
    [self.buttonSprites addObject:sprite];
    
    sprite = [CCSprite spriteWithSpriteFrameName:@"staticbox_blue.png"];
    sprite.scale = 5;
    sprite.position = CGPointMake(250, sprite.contentSize.height/2 * sprite.scale);
    sprite.tag = 2;
    [self addChild:sprite];
    [self.buttonSprites addObject:sprite];

    [self setShouldRespondToTouches:YES];
  }

  return self;
}

- (BOOL)containsButton:(CCSprite *)buttonSprite {
  return [self.buttonSprites containsObject:buttonSprite];
}

- (void)setShouldRespondToTouches:(BOOL)shouldRespondToTouches {
  if (shouldRespondToTouches)
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
  else
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
  touchLocation.x -= self.position.x;
  touchLocation.y -= self.position.y;
  
  for (CCSprite *buttonSprite in self.buttonSprites) {
    if ([self touchLocation:touchLocation intersectsSprite:buttonSprite]) {
      if ([self.delegate respondsToSelector:@selector(onButtonPressed:)])
        [self.delegate onButtonPressed:buttonSprite];
      else
        DLog(@"DELEGATE NOT SET, WHAT'S WRONG");

      break;
    }
  }
  
  return YES;
}

- (BOOL)touchLocation:(CGPoint)location intersectsSprite:(CCSprite *)sprite {
  CGRect rectToTest = CGRectMake(sprite.position.x - sprite.contentSize.width/2 * sprite.scale,
                                 sprite.position.y - sprite.contentSize.height/2 * sprite.scale,
                                 sprite.contentSize.width * sprite.scale,
                                 sprite.contentSize.height * sprite.scale);
  return CGRectContainsPoint(rectToTest, location);
}

@end
