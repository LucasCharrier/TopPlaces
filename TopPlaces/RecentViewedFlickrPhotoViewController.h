//
//  RecentViewedFlickrPhotoViewController.h
//  TopPlaces
//
//  Created by Lucas Charrier on 16/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface RecentViewedFlickrPhotoViewController : UITableViewController
@property (nonatomic,strong) NSArray* photos;
@end
