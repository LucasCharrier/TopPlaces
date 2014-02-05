//
//  FlickrPlacesAnnotations.h
//  TopPlaces
//
//  Created by Lucas Charrier on 03/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/Mapkit.h>

@interface FlickrPlacesAnnotations : NSObject <MKAnnotation>

+ (FlickrPlacesAnnotations *) annotationForPlace:(NSDictionary *)place;
@property (nonatomic, strong) NSDictionary * place;

@end
