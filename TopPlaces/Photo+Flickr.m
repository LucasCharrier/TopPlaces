//
//  Photo+Flickr.m
//  TopPlaces
//
//  Created by Lucas Charrier on 09/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "Photo+Flickr.h"
#import "Place+Flickr.h"
#import "FlickrFetcher.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)flickrInfo inContext:(NSManagedObjectContext *)context
{ 
    Photo *photo = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@",[flickrInfo objectForKey:FLICKR_PHOTO_ID]];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    NSError* error = nil;
    NSArray* matches = [context executeFetchRequest:request error:&error];
    if(matches == nil || [matches count]>1){
    }else if ([matches count]== 0) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.title = [flickrInfo objectForKey:FLICKR_PHOTO_TITLE];
        photo.subtitle = [[flickrInfo objectForKey:FLICKR_PHOTO_DESCRIPTION] objectForKey:FLICKR_PHOTO_CONTENT];
        photo.unique = [flickrInfo objectForKey:FLICKR_PHOTO_ID];
        photo.imageURL = [[FlickrFetcher urlForPhoto:flickrInfo format:FlickrPhotoFormatLarge]absoluteString];
        photo.whereTaken = [Place placeWithFlickrInfo:flickrInfo inContext:context];
    }else{
        photo = [matches lastObject];
     }
    return photo;

}

@end
