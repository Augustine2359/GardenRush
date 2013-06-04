//
//  NBInAppPurchaseManager.h
//  GardenRushV1
//
//  Created by Augustine on 27/5/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define EXPAND_FLOWER_FIELD @"com.nebula.FlowerFun.9x9FlowerField"
#define COINS_100           @"com.nebula.flowerfrenzy.coin100"
#define COINS_300           @"com.nebula.flowerfrenzy.coin300"
#define COINS_750           @"com.nebula.flowerfrenzy.coin750"

@protocol NBInAppPurchaseManagerDelegate <NSObject>

- (void)finishPurchaseForProductWithProductIdentifier:(NSString *)productIdentifier;

@end

@interface NBInAppPurchaseManager : NSObject

@property (nonatomic, strong) id<NBInAppPurchaseManagerDelegate> delegate;

+(NBInAppPurchaseManager*)sharedInstance;
-(void)makePurchase:(NSString*)productID;

@end
