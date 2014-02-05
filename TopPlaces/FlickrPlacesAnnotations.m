//
//  FlickrPlacesAnnotations.m
//  TopPlaces
//
//  Created by Lucas Charrier on 03/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "FlickrPlacesAnnotations.h"
#import "FlickrFetcher.h"

@implementation FlickrPlacesAnnotations

@synthesize place = _place;

+ (FlickrPlacesAnnotations *) annotationForPlace:(NSDictionary *)place
{
    FlickrPlacesAnnotations * annotation = [[FlickrPlacesAnnotations alloc]init];
    annotation.place = place;
    return annotation;
}

- (NSString *) title
{
    return [self.place objectForKey:FLICKR_PLACE_NAME];
}

- (NSString *) subtitle
{
    return  [self.place objectForKey:FLICKR_PLACE_FULLNAME];
}

- (CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[self.place objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[self.place objectForKey:FLICKR_LONGITUDE] doubleValue];
    return coordinate;
}

@end
