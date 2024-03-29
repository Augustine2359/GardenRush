//
//  NBBouquet.h
//  GardenRushV1
//
//  Created by Romy Irawaty on 25/5/13.
//
//

#import <Foundation/Foundation.h>

#define BOUQUET_SIZE_WIDTH 20
#define BOUQUET_SIZE_HEIGHT 20

typedef enum
{
    btNoMatch = 0,
    btThreeOfAKind,
    btFourOfAKind,
    btFiveOfAKind,
    btCornerFiveOfAKind,
    btSixOfAKind,
    btSevenOfAKind
} NBBouquetType;

@interface NBBouquet : CCNode

+(id)bloomBouquetWithType:(NBBouquetType)bouquetType withPosition:(CGPoint)position addToNode:(CCNode*)layer;
+(id)createBouquet:(NBBouquetType)bouquetType show:(bool)show;
+(int)getBouquetCount;
+(void)setScorePadPosition:(CGPoint)position;
-(void)performStandardScoringAndInformLayer:(CCNode*)node withSelector:(SEL)selector;
-(void)performCustomerFulfillingScoringAtCustomerPosition:(CGPoint)position andIndex:(int)index andInformLayer:(CCNode*)node withSelector:(SEL)selector;

@property (nonatomic, retain) CCSprite* flowerImage;
@property (nonatomic, assign) NBBouquetType bouquetType;
@property (nonatomic, assign) int value;
@property (nonatomic, retain) CCNode* nodeToReportScore;
@property (nonatomic, assign) SEL selectorToReportScore;
@property (nonatomic, assign) int fulfilledCustomerIndex;

@end
