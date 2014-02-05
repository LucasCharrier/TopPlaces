//
//  DataCache.h
//  TopPlaces
//
//  Created by Lucas Charrier on 25/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataCache : NSObject

// Constant to define the maximum size of the cache
#define MAXIMUM_CACHE_SIZE 10485760 // 10Mb

// Constant to define the trim size of the cache
#define TRIM_CACHE_SIZE 5242880 // 5Mb

// Used to fetch data from the cache
+ (NSData *) fetchData: (NSString *) key;

// Used to store data in the cache
+ (void) storeData: (NSString *)key: (NSData *) data;


@end
