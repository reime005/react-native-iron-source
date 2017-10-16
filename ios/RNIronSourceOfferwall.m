#import "RNIronSourceOfferwall.h"

@implementation RNIronSourceOfferwall

RCT_EXPORT_MODULE();

@synthesize bridge = _bridge;

// Initialize IronSource before showing the offerwall
RCT_EXPORT_METHOD(initializeOfferwall:(NSString *)appId userId:(NSString *)userId debugEnabled:(BOOL)debugEnabled)
{
    NSLog(@"initializeOfferwall called!! with key %@ and user id %@", appId, userId);
    [IronSource setOfferwallDelegate:self];
    [IronSource setUserId:userId];
    [IronSource initWithAppKey:appId];
    [IronSource setAdaptersDebug:debugEnabled];
    
    [ISIntegrationHelper validateIntegration];
}

//
// Show the Ad
//
RCT_EXPORT_METHOD(showOfferwall: (NSString *)placementName resolve:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject )
{
    if ([IronSource hasOfferwall]) {
        NSLog(@"showOfferwall - offerwall available");
        resolve(nil);
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [IronSource showOfferwallWithViewController:[UIApplication sharedApplication].delegate.window.rootViewController placement:placementName];
        });
    } else {
        NSLog(@"showOfferwall - offerwall unavailable");
        [RNIronSourceOfferwall rejectPromise:reject withError:nil];
    }
}

RCT_EXPORT_METHOD(getCredits)
{
    NSLog(@"offerwallCredits");
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [IronSource offerwallCredits];
    });
}

#pragma mark delegate events

/**
 Called after the offerwall has changed its availability.
 
 @param available The new offerwall availability. YES if available and ready to be shown, NO otherwise.
 */
- (void)offerwallHasChangedAvailability:(BOOL)available {
    if (available == YES) {
        [self.bridge.eventDispatcher sendDeviceEventWithName:@"offerwallHasChangedAvailability" body:@"true"];
    } else {
        [self.bridge.eventDispatcher sendDeviceEventWithName:@"offerwallHasChangedAvailability" body:@"false"];
    }
}

/**
 Called after the offerwall has been displayed on the screen.
 */
- (void)offerwallDidShow {
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"offerwallDidShow" body:nil];
}

/**
 Called after the offerwall has attempted to show but failed.
 
 @param error The reason for the error.
 */
- (void)offerwallDidFailToShowWithError:(NSError *)error {
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"offerwallDidFailToShowWithError" body:error];
}

/**
 Called after the offerwall has been dismissed.
 */
- (void)offerwallDidClose {
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"offerwallDidClose" body:nil];
}

/**
 @abstract Called each time the user completes an offer.
 @discussion creditInfo is a dictionary with the following key-value pairs:
 
 "credits" - (int) The number of credits the user has Earned since the last didReceiveOfferwallCredits event that returned YES. Note that the credits may represent multiple completions (see return parameter).
 
 "totalCredits" - (int) The total number of credits ever earned by the user.
 
 "totalCreditsFlag" - (BOOL) In some cases, we won’t be able to provide the exact amount of credits since the last event (specifically if the user clears the app’s data). In this case the ‘credits’ will be equal to the "totalCredits", and this flag will be YES.
 
 @param creditInfo Offerwall credit info.
 
 @return The publisher should return a BOOL stating if he handled this call (notified the user for example). if the return value is NO, the 'credits' value will be added to the next call.
 */
- (BOOL)didReceiveOfferwallCredits:(NSDictionary *)creditInfo {
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didReceiveOfferwallCredits" body:creditInfo];
    return YES;
}

/**
 Called after the 'offerwallCredits' method has attempted to retrieve user's credits info but failed.
 
 @param error The reason for the error.
 */
- (void)didFailToReceiveOfferwallCreditsWithError:(NSError *)error {
    [self.bridge.eventDispatcher sendDeviceEventWithName:@"didFailToReceiveOfferwallCreditsWithError" body:error];
}

#pragma mark - Helper Fuctions

+ (void)rejectPromise:(RCTPromiseRejectBlock)reject withError:(NSError *)error {
    reject([NSString stringWithFormat:@"%ld", error.code], error.localizedDescription, error);
}

+ (void)rejectPromise:(RCTPromiseRejectBlock)reject withMessage:(NSString *)message {
    reject([NSString stringWithFormat:@"%@", message], message, nil);
}

@end
