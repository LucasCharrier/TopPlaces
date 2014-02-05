//
//  Photo+Flickr.h
//  TopPlaces
//
//  Created by Lucas Charrier on 09/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+(Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inContext:(NSManagedObjectContext *)context;

@end
