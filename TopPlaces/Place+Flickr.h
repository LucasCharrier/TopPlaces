//
//  Place+Flickr.h
//  TopPlaces
//
//  Created by Lucas Charrier on 09/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "Place.h"

@interface Place (Flickr)

+(Place *)placeWithFlickrInfo:(NSDictionary *)flickrInfo inContext:(NSManagedObjectContext *)context;

@end
