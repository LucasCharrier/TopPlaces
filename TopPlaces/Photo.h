//
//  Photo.h
//  TopPlaces
//
//  Created by Lucas Charrier on 09/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Place;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) Place *whereTaken;

@end
