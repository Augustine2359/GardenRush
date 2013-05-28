//
//  NBInAppPurchaseManager.m
//  ElementArmy1.0
//
//  Created by Augustine on 23/4/13.
//
//

#import "NBInAppPurchaseManager.h"

@interface NBInAppPurchaseManager() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSArray *productIdentifiers;

@end

@implementation NBInAppPurchaseManager

+ (NBInAppPurchaseManager *)sharedInstance {
  static NBInAppPurchaseManager *_sharedInstance = nil;
  static dispatch_once_t oncePredicate;
  dispatch_once(&oncePredicate, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    NSSet *identifiers = [NSSet setWithObject:EXPAND_FLOWER_FIELD];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
  }
  return self;
}

- (void)makePurchase:(NSString *)productID {
  if ([SKPaymentQueue canMakePayments] == NO) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot make payments" message:@"Please turn on In-App Purchases in Settings->General->Restrictions" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    return;
  }
  
  NSInteger index = [self.productIdentifiers indexOfObject:productID];
  if (index == NSNotFound) {
    DLog(@"Invalid product identifier");
    return;
  }
  
  SKProduct *product = [self.products objectAtIndex:index];
  SKPayment *payment = [SKPayment paymentWithProduct:product];
  [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Transaction completion methods

-(void)completeTransaction:(SKPaymentTransaction*)transaction
{
  // Your application should implement these two methods.
  //[self recordTransaction:transaction];
  //[self provideContent:transaction.payment.productIdentifier];
  DLog(@"Transaction %@ Completed", transaction.payment.productIdentifier);
  
  [self handleTransaction:transaction];
  // Remove the transaction from the payment queue.
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction*)transaction
{
  //[self recordTransaction: transaction];
  //[self provideContent: transaction.originalTransaction.payment.productIdentifier];
  DLog(@"Transaction %@ Restored", transaction.originalTransaction.payment.productIdentifier);
  
  [self handleTransaction:transaction];
  
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)failedTransaction:(SKPaymentTransaction*)transaction
{
  if (transaction.error.code != SKErrorPaymentCancelled)
  {
    DLog(@"Transaction %@ cancelled", transaction.originalTransaction.payment.productIdentifier);
  }
  
  DLog(@"%@", transaction.error);
  
  [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)handleTransaction:(SKPaymentTransaction *)transaction {
  SKPayment *payment = transaction.payment;
//  [self.delegate finishPurchaseForProductWithProductIdentifier:payment.productIdentifier];

  if ([payment.productIdentifier isEqualToString:EXPAND_FLOWER_FIELD]) {
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:IS_FLOWER_FIELD_EXPANDED];
  }
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
  self.products = response.products;
  self.productIdentifiers = [self.products valueForKey:@"productIdentifier"];
  
  DLog(@"products successfully requested");
  
  if ([[response invalidProductIdentifiers] count] > 0) {
    DLog(@"Oh no there's invalid product identifiers");
    DLog(@"%@", [response invalidProductIdentifiers]);
    return;
  }
  
//  [self makePurchase:EXPAND_FLOWER_FIELD];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  DLog(@"%@", request);
  DLog(@"%@", error);
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
  for (SKPaymentTransaction *transaction in transactions)
  {
    switch (transaction.transactionState)
    {
      case SKPaymentTransactionStatePurchased:
        [self completeTransaction:transaction];
        break;
      case SKPaymentTransactionStateFailed:
        [self failedTransaction:transaction];
        break;
      case SKPaymentTransactionStateRestored:
        [self restoreTransaction:transaction];
      default:
        break;
    }
  }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads {
}

@end
