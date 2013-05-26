//
//  NBBouquet.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 25/5/13.
//
//

#import "NBBouquet.h"

static int bouquetCount = 0;

@implementation NBBouquet

+(id)createBouquet:(NBBouquetType)bouquetType show:(bool)show
{
    NBBouquet* bouquet = [[NBBouquet alloc] initWithBouquetType:bouquetType show:show];
    return bouquet;
}

+(int)getBouquetCount
{
    return bouquetCount;
}

-(id)initWithBouquetType:(NBBouquetType)bouquetType show:(bool)show
{
    if ((self = [[super init] autorelease]))
    {
        self.flowerImage = [CCSprite spriteWithSpriteFrameName:@"staticbox_white.png"];;
        
        switch (bouquetType)
        {
            case btSingleFlower:
                self.flowerImage.color = ccWHITE;
                break;
                
            case btThreeOfAKind:
                self.flowerImage.color = ccRED;
                break;
                
            case btFourOfAKind:
                self.flowerImage.color = ccYELLOW;
                break;
                
            case btFiveOfAKind:
            case btCornerFiveOfAKind:
            case btSixOfAKind:
            case btSevenOfAKind:
                self.flowerImage.color = ccGREEN;
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

@end
