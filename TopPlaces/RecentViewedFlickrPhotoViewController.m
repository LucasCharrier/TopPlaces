//
//  RecentViewedFlickrPhotoViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 16/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "RecentViewedFlickrPhotoViewController.h"
#import "MapViewController.h"
#import "FlickrPhotosAnnotations.h"
#define RECENT_PHOTOS @"recent"

@interface RecentViewedFlickrPhotoViewController ()<MapViewControllerDelegate>

@end

@implementation RecentViewedFlickrPhotoViewController
@synthesize photos = _photos;

- (void)awakeFromNib {
    [super awakeFromNib];
   
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"viewWillAppear");
    [self refresh:self.navigationItem.rightBarButtonItem];
    [self updateSplitViewDetail];
}

- (IBAction)refresh:(id)sender {
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL); 
    /* multiphreading, we are creating a new phread in order to not blocked the application while we download the images */
    dispatch_async(downloadQueue, ^{
        NSArray* photos = [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS];
        
        NSLog(@"%@",photos);
        dispatch_async(dispatch_get_main_queue(), ^{ 
            /* once we finished downloading the images we come back to the main thread to put these new photos */
            self.navigationItem.rightBarButtonItem = sender;
            self.photos = photos;
        });
    });
    dispatch_release(downloadQueue);
    
    
}

- (NSArray *) mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for(NSDictionary *photo in self.photos){
        [annotations addObject:[FlickrPhotosAnnotations annotationForPhoto:photo]];
    }
    return  annotations;
} 

- (void) updateSplitViewDetail 
{
    id detailView = [self.tabBarController.viewControllers objectAtIndex:2];
    if([detailView isKindOfClass:[MapViewController class]]){
        NSLog(@"mapView recentviewed");
        MapViewController * mapVC = (MapViewController *)detailView;
        mapVC.delegate = self;
        mapVC.annotations = [self mapAnnotations];
    }
    
}

- (UIImage *)mapViewController:(MapViewController *)sender imageForAnnotation:(id<MKAnnotation>)annotation
{
    FlickrPhotosAnnotations* fpa = (FlickrPhotosAnnotations *)annotation;
    NSURL * url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData * data = [NSData dataWithContentsOfURL:url];
    NSLog(@"data %@",data);
    return [UIImage imageWithData:data]; //data ? [UIImage imageWithData:data] : nil;
}

- (void) setPhotos:(NSArray *)photos
{
    if(photos != _photos){
        _photos = photos;
        [self updateSplitViewDetail];
        if(self.tableView.window)[self.tableView reloadData];
    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
   
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photos";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [[self.photos objectAtIndex:[self.photos indexOfObject:self.photos.lastObject]-indexPath.row] objectForKey:FLICKR_PHOTO_TITLE];
    
    cell.detailTextLabel.text = [[[self.photos objectAtIndex:[self.photos indexOfObject:self.photos.lastObject]-indexPath.row] objectForKey:FLICKR_PHOTO_DESCRIPTION]objectForKey:FLICKR_PHOTO_CONTENT];
    
    if([cell.textLabel.text isEqualToString:@""] && [cell.detailTextLabel.text isEqualToString:@""]){
        cell.textLabel.text = @"UNKNOWN";
    }else if ([cell.textLabel.text isEqualToString:@""]) {
        NSLog(@"no title but description");
        cell.textLabel.text = cell.detailTextLabel.text;
        cell.detailTextLabel.text = NULL;
    }
    NSLog(@"%@", self.photos);
    
    // Configure the cell...
    
    return cell;
}

- (PhotoViewController*) photoForPhotoViewController
{
    id pvc = [self.splitViewController.viewControllers lastObject];
    if(![pvc isKindOfClass:[PhotoViewController class]]){
        pvc = Nil;
    }
    return pvc;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue");
    if([self photoForPhotoViewController])
    {
        NSLog(@"photoForViewController Test1 OK");
        [[self photoForPhotoViewController] setPhoto:[self.photos objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
        NSLog(@"photoForViewController Test2 OK");
        [[self photoForPhotoViewController] setCity:[[sender textLabel] text]];
        NSLog(@"photoForViewController Test3 OK");
    }else{
        NSLog(@"else");

        [segue.destinationViewController setPhoto:[self.photos objectAtIndex:self.tableView.indexPathForSelectedRow.row]];
        [segue.destinationViewController  setCity:[[sender textLabel] text]];
    }    
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    PhotoViewController *detailViewController = [self photoForPhotoViewController];
    // ...
    // Pass the selected object to the new view controller.
    if(detailViewController)
    {
        NSLog(@"tableview");
        [detailViewController setPhoto:[self.photos objectAtIndex:[self.photos indexOfObject:self.photos.lastObject]- indexPath.row]];
    }
    
}

@end
