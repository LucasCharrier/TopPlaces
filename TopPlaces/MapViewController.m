//
//  MapViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 01/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "FlickrPhotosAnnotations.h"
#import "FlickrPlacesAnnotations.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"



@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate;

- (void) setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void) setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}


- (void) updateMapView
{
    if(self.mapView.annotations)[self.mapView removeAnnotations:self.mapView.annotations];
    if(self.annotations)[self.mapView addAnnotations:self.annotations];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id<MKAnnotation>)annotation
{

    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if(!aView)
    {
        aView =[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
         if([aView.annotation isKindOfClass:[FlickrPhotosAnnotations class]]){
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
         }
    }
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    UIButton * detailDisclosure = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //[detailDisclosure addTarget:self action:@selector(displayClickedImage:) forControlEvents:UIControlEventTouchUpInside];
    aView.rightCalloutAccessoryView = detailDisclosure;
  
    return aView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view 
calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = view.annotation;
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if([view.annotation isKindOfClass:[FlickrPhotosAnnotations class]]){
        if([detailVC isKindOfClass:[PhotoViewController class]]){
            FlickrPhotosAnnotations* photoAnnotation = (FlickrPhotosAnnotations *)annotation;
            [detailVC setPhoto:photoAnnotation.photo];
        }
    }else{
        if([detailVC isKindOfClass:[PhotoViewController class]]){
            FlickrPlacesAnnotations * placeAnnotation = (FlickrPlacesAnnotations *)annotation;
            view.rightCalloutAccessoryView = nil;
            [self.delegate segueMapAndController:self place:placeAnnotation.place];
        }
    }
}



// when someone click on the pin

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
   
    if([aView.annotation isKindOfClass:[FlickrPhotosAnnotations class]]){
        NSLog(@"didSelectAnnotationView");
        UIImage * image = [self.delegate mapViewController:self imageForAnnotation:aView.annotation];
        [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
    }


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    
}

@end
