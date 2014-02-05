//
//  PhotoViewController.h
//  TopPlaces
//
//  Created by Lucas Charrier on 20/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataCache.h"
#import "SplitViewControllerBarButtonItemPresenter.h"

@interface PhotoViewController : UIViewController <SplitViewControllerBarButtonItemPresenter>
@property (nonatomic,strong) NSDictionary* photo;
@property (nonatomic,strong) NSString* city;
@end
