//
//  NBParticleScreen.m
//  GardenRushV1
//
//  Created by Augustine on 6/6/13.
//
//

#import "NBParticleScreen.h"

@interface NBParticleScreen()<CCTargetedTouchDelegate>

@property (nonatomic, strong) CCParticleSystemQuad *particleSystem;

@end

@implementation NBParticleScreen

+(CCScene*)scene
{
  return [NBParticleScreen sceneAndSetAsDefault:NO];
}

+(CCScene*)sceneAndSetAsDefault:(BOOL)makeDefault
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	NBParticleScreen *layer = [NBParticleScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
  
  if (makeDefault)
    [NBBasicScreenLayer setDefaultScreen:scene];
	
	// return the scene
	return scene;
}

- (void)onEnter {
  [super onEnter];

  [self prepareParticleSystem];

  [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

#pragma mark - CCTargetedTouchDelegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
  self.particleSystem.position = touchLocation;
  self.particleSystem.emissionRate = 100;
  
  return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
  CGPoint touchLocation = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
  self.particleSystem.position = touchLocation;
}

- (void)prepareParticleSystem {
  NSInteger totalParticles = 250;
  self.particleSystem = [[CCParticleSystemQuad alloc] initWithTotalParticles:totalParticles];
  self.particleSystem.emitterMode = kCCParticleModeGravity;
  self.particleSystem.gravity = ccp(0,0);
  self.particleSystem.radialAccel = 0;
  self.particleSystem.radialAccelVar = 0;
  self.particleSystem.speed = 60;
  self.particleSystem.speedVar = 20;
  self.particleSystem.angle = 90;
  self.particleSystem.angleVar = 10;

  CGFloat life = 3;
  self.particleSystem.duration = kCCParticleDurationInfinity;
  self.particleSystem.life = life;
  self.particleSystem.lifeVar = 0.25f;
  self.particleSystem.startSize = 54.0f;
  self.particleSystem.startSizeVar = 10.0f;
  self.particleSystem.endSize = kCCParticleStartSizeEqualToEndSize;
  self.particleSystem.emissionRate = totalParticles/life;
  self.particleSystem.startColor = ccc4f(0.76f, 0.25f, 0.12f, 1);
  self.particleSystem.endColor = ccc4f(0, 0, 0, 1);
  CGImageRef image = [[UIImage imageNamed:@"Particles_fire.png"] CGImage];
  CCTexture2D *texture = [[CCTexture2D alloc] initWithCGImage:image resolutionType:kCCResolutioniPhone];
  self.particleSystem.texture = texture;
  self.particleSystem.blendAdditive = YES;
  self.particleSystem.emissionRate = 0;
  [self addChild:self.particleSystem];
}

@end
