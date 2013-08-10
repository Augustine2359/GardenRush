//
//  NBActiveItem.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 28/7/13.
//
//

#import "NBActiveItem.h"

static CCArray* itemArray = nil;

@implementation NBActiveItem

+(id)createNewItem:(NSString*)frameName withTypeOf:(NBItemType)itemType withStockAmount:(int)amount
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if ([itemArray count] >= SUPPORTED_ITEM_COUNT)
    {
        CCLOG(@"Exceeding number of supported items in this version. Aborting...");
        return nil;
    }
    
    for (NBActiveItem* activeItem in itemArray)
    {
        if (activeItem.itemType == itemType)
        {
            CCLOG(@"Same Item Type has been created. Aborting...");
            return nil;
        }
    }
    
    NBActiveItem* item = [[NBActiveItem alloc] initWithSpriteName:frameName withTypeOf:itemType];
    item.currentStock = amount;
    
    item.itemImage.anchorPoint = ccp(0, 0);
    item.itemImage.position = ccp(0 + ([itemArray count] * (winSize.width / 3)), 0);
    
    if (!itemArray) itemArray = [CCArray arrayWithCapacity:SUPPORTED_ITEM_COUNT];
    item.itemName = [NSString stringWithFormat:@"item%i", [itemArray count]];
    [itemArray addObject:item];
    
    return item;
}

-(id)initWithSpriteName:(NSString*)frameName withTypeOf:(NBItemType)itemType
{
    if (self = [super init])
    {
        CCSprite* normalSprite = [CCSprite spriteWithSpriteFrameName:frameName];
        CCSprite* selectedSprite = [CCSprite spriteWithSpriteFrameName:frameName];
        
        self.itemImage = [CCMenuItemSprite itemWithNormalSprite:normalSprite selectedSprite:selectedSprite target:self selector:@selector(activateItem)];
        self.itemType = itemType;
    }
    
    return self;
}

-(void)activateItem
{
    if (self.currentStock > 0)
    {
        CCLOG(@"Activate Item: %@", self.itemName);
    }
    else
    {
        CCLOG(@"Ran out of stock");
    }
}

-(void)assignName:(NSString*)name
{
    self.itemName = name;
}

-(void)addStock:(int)amount
{
    self.currentStock += amount;
}

-(void)removeStock:(int)amount
{
    self.currentStock -= amount;
}

@end
