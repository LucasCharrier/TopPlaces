//
//  FiftyPhotosOfPlaceViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 16/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "FiftyPhotosOfPlaceViewController.h"

@implementation FiftyPhotosOfPlaceViewController

@synthesize place = _place;

- (void) setPlace:(NSDictionary *)place
{
    if(place != _place)
    {
        _place = place;
        [self.tableView reloadData];
        [self refresh:self.navigationItem.rightBarButtonItem];
    }
}

- (void)viewWillAppear:(BOOL)animated{
  
}

- (IBAction)refresh:(id)sender {
    
    /* we creating the spinner and start to animate it */
    NSLog(@"nombre de subview : %d",[self.tableView.subviews count]);
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(self.tableView.bounds.size.width/2-10,self.tableView.bounds.size.height/2 - 25, 20, 20)];
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    CGAffineTransform transform = CGAffineTransformMakeScale(2.f, 2.f);
    spinner.transform = transform;
    [self.tableView addSubview:spinner];
    [spinner startAnimating];
    NSLog(@"nombre de subview %d",[self.tableView.subviews count]);
    
    /* we put the spinner into the navigation bar */
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL); 
    /* multiphreading, we are creating a new phread in order to not blocked the application while we download the images */
   

    dispatch_async(downloadQueue, ^{
        
        NSArray* photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            
            /* once we finished downloading the images we come back to the main thread to put these new photos */
            self.photos = photos;
            [spinner stopAnimating];
            [spinner removeFromSuperview];
        });
          
    
    });
    
    dispatch_release(downloadQueue);
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photos";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = [[self.photos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text =[[[self.photos objectAtIndex:indexPath.row] objectForKey:FLICKR_PHOTO_DESCRIPTION]objectForKey:FLICKR_PHOTO_CONTENT];
    if([cell.textLabel.text isEqualToString:@""] && [cell.detailTextLabel.text isEqualToString:@""]){
        cell.textLabel.text = @"UNKNOWN";
    }else if ([cell.textLabel.text isEqualToString:@""]) {
        NSLog(@"no title but description");
        cell.textLabel.text = cell.detailTextLabel.text;
        cell.detailTextLabel.text = NULL;
    }
  
    
    // Configure the cell...
    
    return cell;
}






@end

