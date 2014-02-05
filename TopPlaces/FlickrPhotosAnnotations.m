//
//  FlickrPhotosAnnotations.m
//  TopPlaces
//
//  Created by Lucas Charrier on 01/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "FlickrPhotosAnnotations.h"
#import "FlickrFetcher.h"

@implementation FlickrPhotosAnnotations
@synthesize photo = _photo;
+ (FlickrPhotosAnnotations *) annotationForPhoto:(NSDictionary *)photo
{
    FlickrPhotosAnnotations * annotations = [[FlickrPhotosAnnotations alloc]init];
    annotations.photo = photo;
    return annotations;
}

- (NSString *) title 
{
    return [self.photo objectForKey:FLICKR_PHOTO_TITLE];
}

- (NSString *) subtitle 
{
    return [[self.photo objectForKey:FLICKR_PHOTO_DESCRIPTION]objectForKey:FLICKR_PHOTO_CONTENT];
}

- (CLLocationCoordinate2D)coordinate
{   
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
