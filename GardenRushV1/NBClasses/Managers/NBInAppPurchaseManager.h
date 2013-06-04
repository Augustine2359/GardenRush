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

@protocol NBInAppPurchaseManagerDelegate <NSObject>

- (void)finishPurchaseForProductWithProductIdentifier:(NSString *)productIdentifier;

@end

@interface NBInAppPurchaseManager : NSObject

@property (nonatomic, strong) id<NBInAppPurchaseManagerDelegate> delegate;

+(NBInAppPurchaseManager*)sharedInstance;
-(void)makePurchase:(NSString*)productID;

@end
