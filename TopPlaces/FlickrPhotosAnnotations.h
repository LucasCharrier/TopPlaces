//
//  FlickrPhotosAnnotations.h
//  TopPlaces
//
//  Created by Lucas Charrier on 01/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface FlickrPhotosAnnotations : NSObject <MKAnnotation>

+ (FlickrPhotosAnnotations *) annotationForPhoto:(NSDictionary*) photo; 

@property (nonatomic,strong) NSDictionary* photo;
@end
