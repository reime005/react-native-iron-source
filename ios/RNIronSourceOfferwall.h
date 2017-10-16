//
//  RNIronSourceOfferwall.h
//  GetRich
//
//  Created by Marius Reimer on 15.10.17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#ifndef RNIronSourceOfferwall_h
#define RNIronSourceOfferwall_h

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import "IronSource/IronSource.h"

@interface RNIronSourceOfferwall : NSObject <RCTBridgeModule, ISOfferwallDelegate>

@end

#endif /* RNIronSourceOfferwall_h */

