//
//  NBBouquet.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 25/5/13.
//
//

#import "NBBouquet.h"

static int bouquetCount = 0;
static CGPoint scorePadPosition = {0, 0};

@interface NBBouquet()
{
    bool isScoringCompleted;
}

@end

@implementation NBBouquet

+(id)bloomBouquetWithType:(NBBouquetType)bouquetType withPosition:(CGPoint)position addToNode:(CCNode*)layer
{
    NBBouquet* bouquet = [[NBBouquet alloc] initWithBouquetType:bouquetType show:true];
    bouquet.position = position;
    [layer addChild:bouquet z:99];
    
    bouquet.flowerImage.scale = 0;
    CCScaleTo* scaleTo = [CCScaleTo actionWithDuration:0.75f scaleX:BOUQUET_SIZE_WIDTH / bouquet.flowerImage.contentSize.width scaleY:BOUQUET_SIZE_HEIGHT / bouquet.flowerImage.contentSize.height];
    [bouquet.flowerImage runAction:scaleTo];
    
    CCRotateBy* rotateBy = [CCRotateBy actionWithDuration:0.75f angle:360];
    [bouquet.flowerImage runAction:rotateBy];
    
    return bouquet;
}

+(id)createBouquet:(NBBouquetType)bouquetType show:(bool)show
{
    NBBouquet* bouquet = [[NBBouquet alloc] initWithBouquetType:bouquetType show:show];
    return bouquet;
}

+(int)getBouquetCount
{
    return bouquetCount;
}

+(void)setScorePadPosition:(CGPoint)position
{
    scorePadPosition = position;
}

-(id)initWithBouquetType:(NBBouquetType)bouquetType show:(bool)show
{
    if ((self = [[super init] autorelease]))
    {
        self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"bouquet_dummy.png"];;
        
        switch (bouquetType)
        {
            case btThreeOfAKind:
                self.flowerImage.color = ccc3(204, 51, 255);
                self.value = 300;
                break;
                
            case btFourOfAKind:
                self.flowerImage.color = ccc3(153, 51, 51);
                self.value = 500;
                break;
                
            case btFiveOfAKind:
                self.flowerImage.color = ccc3(228, 149, 202);
                self.value = 700;
                break;
                
            case btCornerFiveOfAKind:
                self.flowerImage.color = ccc3(228, 149, 202);
                self.value = 700;
                break;
                
            case btSixOfAKind:
                self.flowerImage.color = ccc3(228, 149, 202);
                self.value = 1000;
                break;
                
            case btSevenOfAKind:
                self.flowerImage.color = ccc3(228, 149, 202);
                self.value = 1500;
                break;
                
            default:
                break;
        }
        
        if (!show)
            self.flowerImage.visible = NO;
        
        self.bouquetType = bouquetType;
        self.flowerImage.anchorPoint = ccp(0.5, 0.5);
        self.flowerImage.scaleX = BOUQUET_SIZE_WIDTH / self.flowerImage.contentSize.width;
        self.flowerImage.scaleY = BOUQUET_SIZE_HEIGHT / self.flowerImage.contentSize.height;
        [self setContentSize:CGSizeMake(BOUQUET_SIZE_WIDTH, BOUQUET_SIZE_HEIGHT)];
        [self addChild:self.flowerImage];
        
        isScoringCompleted = false;
        
        bouquetCount++;
    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
    bouquetCount--;
}

-(void)show
{
    self.flowerImage.opacity = 0;
    self.flowerImage.visible = YES;
    CCFadeIn* fadeIn = [CCFadeIn actionWithDuration:0.2f];
    [self.flowerImage runAction:fadeIn];
}

-(void)performStandardScoringAndInformLayer:(CCNode*)node withSelector:(SEL)selector
{
    if (isScoringCompleted) return; //Avoid double scoring
    
    self.nodeToReportScore = node;
    self.selectorToReportScore = selector;
    
    CCDelayTime* delay = [CCDelayTime actionWithDuration:1.0f];
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:1.0f position:scorePadPosition];
    CCEaseInOut* easeInOut = [CCEaseInOut actionWithAction:moveTo rate:2];
    CCCallFunc* callFunc = [CCCallFunc actionWithTarget:self selector:@selector(onBouquetReachedScore)];
    CCSequence* sequence = [CCSequence actions:delay, easeInOut, callFunc, nil];
    [self runAction:sequence];
    
    isScoringCompleted = true;
}

-(void)performCustomerFulfillingScoringAtCustomerPosition:(CGPoint)position andIndex:(int)index andInformLayer:(CCNode*)node withSelector:(SEL)selector
{
    if (isScoringCompleted) return; //Avoid double scoring
    
    self.nodeToReportScore = node;
    self.selectorToReportScore = selector;
    self.fulfilledCustomerIndex = index;
    
    CCDelayTime* delay = [CCDelayTime actionWithDuration:1.0f];
    CCMoveTo* moveTo = [CCMoveTo actionWithDuration:1.0f position:position];
    CCEaseInOut* easeInOut = [CCEaseInOut actionWithAction:moveTo rate:2];
    CCCallFunc* callFunc = [CCCallFunc actionWithTarget:self selector:@selector(onBouquetReachedCustomer)];
    CCSequence* sequence = [CCSequence actions:delay, easeInOut, callFunc, nil];
    [self runAction:sequence];
    
    isScoringCompleted = true;
}

-(void)onBouquetReachedScore
{
    CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:0.5f];
    CCCallFunc* callFunc = [CCCallFunc actionWithTarget:self selector:@selector(onBouquetFadedOutAfterReachedScore)];
    CCSequence* sequence = [CCSequence actions:fadeOut, callFunc, nil];
    [self.flowerImage runAction:sequence];
}

-(void)onBouquetFadedOutAfterReachedScore
{
    [self.nodeToReportScore performSelector:self.selectorToReportScore withObject:self];
    
    self.nodeToReportScore = nil;
    self.selectorToReportScore = nil;
}

-(void)onBouquetReachedCustomer
{
    CCFadeOut* fadeOut = [CCFadeOut actionWithDuration:0.5f];
    CCCallFunc* callFunc = [CCCallFunc actionWithTarget:self selector:@selector(onBouquetFadedOutAfterReachedCustomer)];
    CCSequence* sequence = [CCSequence actions:fadeOut, callFunc, nil];
    [self.flowerImage runAction:sequence];
}

-(void)onBouquetFadedOutAfterReachedCustomer
{
    [self.nodeToReportScore performSelector:self.selectorToReportScore withObject:[NSNumber numberWithInt:self.fulfilledCustomerIndex] withObject:self];
    
    self.nodeToReportScore = nil;
    self.selectorToReportScore = nil;
}

@end
