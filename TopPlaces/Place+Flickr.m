//
//  Place+Flickr.m
//  TopPlaces
//
//  Created by Lucas Charrier on 09/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "Place+Flickr.h"
#import "FlickrFetcher.h"

@implementation Place (Flickr)

+ (Place *)placeWithFlickrInfo:(NSDictionary *)flickrInfo inContext:(NSManagedObjectContext *)context
{ 
    Place *place = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"title = %@",[flickrInfo objectForKey:FLICKR_PHOTO_PLACE_NAME]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    NSArray* matches = [context executeFetchRequest:request error:nil];
    if(matches == nil || [matches count]>1){
    }else if ([matches count]== 0) {
        place = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
        place.name = [flickrInfo objectForKey:FLICKR_PHOTO_PLACE_NAME];
    }else{
        place = [matches lastObject];
    }
    return place;
    
}

@end
