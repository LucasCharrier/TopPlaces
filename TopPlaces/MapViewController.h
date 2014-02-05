//
//  MapViewController.h
//  TopPlaces
//
//  Created by Lucas Charrier on 01/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class MapViewController;
@protocol MapViewControllerDelegate <NSObject>

@required
- (UIImage *)mapViewController:(MapViewController*)sender imageForAnnotation:(id <MKAnnotation>) annotation;
@optional
- (void) segueMapAndController:(MapViewController*)sender place:(NSDictionary*)place;


@end
   
@interface MapViewController : UIViewController
@property (nonatomic, strong) NSArray * annotations; // model
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@end
