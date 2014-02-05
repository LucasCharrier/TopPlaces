//
//  TopPlacesFlickrPhotoViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 15/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "TopPlacesFlickrPhotoViewController.h"
#import "FiftyPhotosOfPlaceViewController.h"
#import "MapViewController.h"
#import "FlickrPlacesAnnotations.h"

@interface TopPlacesFlickrPhotoViewController ()<MapViewControllerDelegate>
@end

@implementation TopPlacesFlickrPhotoViewController
@synthesize places = _places;



- (void)awakeFromNib {
    [super awakeFromNib];
    [self refresh:self.navigationItem.rightBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self updateMap];
}

- (IBAction)refresh:(id)sender {
    
    /* we creating the spinner and start to animate it */
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    
    /* we put the spinner into the navigation bar */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL); 
    /* multiphreading, we are creating a new phread in order to not blocked the application while we download the images */
    dispatch_async(downloadQueue, ^{

        NSArray* places = [self downloadImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{ 
            
            /* once we finished downloading the images we come back to the main thread to put these new photos */
            [spinner stopAnimating];
            self.navigationItem.rightBarButtonItem = sender;
            self.places = places;
        });
    });
    dispatch_release(downloadQueue);
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]){
        [segue.destinationViewController setPlace:[self.places objectAtIndex:  self.tableView.indexPathForSelectedRow.row]];
        [segue.destinationViewController setTitle:[[sender textLabel] text]];
    }else{
        NSLog(@"prepareForSegue1");
        [segue.destinationViewController setPlace:sender];
        NSLog(@"prepareForSegue2");
        [segue.destinationViewController setTitle:[sender objectForKey:FLICKR_PLACE_NAME]];
        NSLog(@"prepareForSegue3");
    }
}

- (void)segueMapAndController:(MapViewController *)sender place:(NSDictionary *)place
{ 
    NSLog(@"SetMapAndController1");
    [self performSegueWithIdentifier:@"50photos" sender:place];
    NSLog(@"SegueMapAndController2");
}

- (NSArray *) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.places count]];
    for(NSDictionary *place in self.places){
        [annotations addObject:[FlickrPlacesAnnotations annotationForPlace:place]];
    }
    return  annotations;
} 

- (void) updateMap 
{
    id detailView = [self.tabBarController.viewControllers objectAtIndex:2];
    if([detailView isKindOfClass:[MapViewController class]]){
        MapViewController * mapVC = (MapViewController *)detailView;
        mapVC.delegate = self;
        mapVC.annotations = [self mapAnnotations];
    }
    
}


- (void) setPlaces:(NSArray *)places
{
    if(places != _places){
        _places = places; /* if someone change my model I want the tableView to be reloaded */
        NSLog(@"setPlaces");
        [self updateMap];
        [self.tableView reloadData];
    }
}

- (NSArray *) downloadImage
{
    /* we are creating a descriptor for array which sorted an array using the name of his content, and in alphabetical order */
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [NSSortDescriptor sortDescriptorWithKey:CONTENT_KEY 
                                                             ascending:YES]];
    return [[FlickrFetcher topPlaces] sortedArrayUsingDescriptors:sortDescriptors];
    
    return  [FlickrFetcher topPlaces];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.places count];
}

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    FlickrPlacesAnnotations* fpa = (FlickrPlacesAnnotations *)annotation;
    NSURL * url = [FlickrFetcher urlForPhoto:fpa.place format:FlickrPhotoFormatSquare];
    NSData * data = [NSData dataWithContentsOfURL:url];
    return [UIImage imageWithData:data] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Top Places"; /* prototype cell's name */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        NSLog(@"cell = nil");
    }
  
    NSDictionary* place = [self.places objectAtIndex:indexPath.row];
    cell.textLabel.text = [place objectForKey:FLICKR_PLACE_NAME];
    cell.detailTextLabel.text = [place objectForKey:FLICKR_PLACE_FULLNAME];
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Table view delegate


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    PhotoViewController *detailViewController = [[PhotoViewController alloc] initWithNibName:@"photoViewController" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}
*/



@end
