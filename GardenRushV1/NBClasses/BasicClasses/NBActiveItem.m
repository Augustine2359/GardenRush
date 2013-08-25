//
//  NBActiveItem.m
//  GardenRushV1
//
//  Created by Romy Irawaty on 28/7/13.
//
//

#import "NBActiveItem.h"

static CCArray* itemArray = nil;

@interface NBActiveItem()
{
    float remainingTime;
}

@end

@implementation NBActiveItem

+(id)createNewItemWithItemData:(NBItemData*)itemData withTypeOf:(NBItemType)itemType withStockAmount:(int)amount
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
    
    NBActiveItem* item = [[NBActiveItem alloc] initWithSpriteName:itemData.itemImageName withTypeOf:itemType];
    item.itemData = itemData;
    item.itemData.duration = DEFAULT_ITEM_DURATION;
    item.currentStock = amount;
    item.isActivated = NO;
    
    item.itemImage.anchorPoint = ccp(0, 0);
    item.itemImage.position = ccp(0 + ([itemArray count] * (winSize.width / 3)), 0);
    
    item.itemAvailableCountLabel = [[CCLabelAtlas alloc] initWithString:[NSString stringWithFormat:@"%i", amount] charMapFile:@"fps_images.png" itemWidth:12 itemHeight:32 startCharMap:'.'];
    item.itemAvailableCountLabel.anchorPoint = item.itemImage.anchorPoint;
    item.itemAvailableCountLabel.position = ccp(70, item.itemImage.position.y + 8);
    
    [item.itemImage addChild:item.itemAvailableCountLabel z:item.itemImage.zOrder + 1];
    
    if (!itemArray) itemArray = [CCArray arrayWithCapacity:SUPPORTED_ITEM_COUNT];
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
    if (!self.isActivated)
    {
        if (self.currentStock > 0)
        {
            CCLOG(@"Activate Item: %@", self.itemData.itemName);
            self.currentStock--;
            self.isActivated = YES;
            remainingTime = self.itemData.duration;
            
            [self updateLabel];
        }
        else
        {
            CCLOG(@"Ran out of stock");
        }
    }
    else
    {
        CCLOG(@"Item %@ is already activated.", self.itemData.itemName);
    }
}

-(void)deactivateItem
{
    if (self.isActivated)
    {
        self.isActivated = NO;
        remainingTime = 0;
        CCLOG(@"Deactivate Item: %@", self.itemData.itemName);
        [self updateLabel];
    }
    else
    {
        CCLOG(@"Item %@ is already deactivated.", self.itemData.itemName);
    }
}

-(void)assignName:(NSString*)name
{
    self.itemData.itemName = name;
}

-(void)addStock:(int)amount
{
    self.currentStock += amount;
}

-(void)removeStock:(int)amount
{
    self.currentStock -= amount;
}

-(void)updateLabel
{
    [self.itemAvailableCountLabel setString:[NSString stringWithFormat:@"%i", self.currentStock]];
}

-(void)update:(ccTime)delta
{
    if (self.isActivated)
    {
        remainingTime -= delta;
        
        if (remainingTime <= 0)
        {
            [self deactivateItem];
        }
    }
}

@end
