//
//  VirtualVacationViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 08/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "VirtualVacationViewController.h"
#import "FlickrFetcher.h"
#import "Place.h"
#import "Photo+Flickr.h"
#import "FiftyPhotosOfPlaceViewController.h"

@interface VirtualVacationViewController ()
@property (nonatomic,strong) NSArray * virtualVacationURLs;
@end

@implementation VirtualVacationViewController
@synthesize virtualVacationURLs = _virtualVacationURLs;
@synthesize virtualVacation = _virtualVacation;

- (void)setVirtualVacation:(UIManagedDocument *)virtualVacation
{
    if(_virtualVacation != virtualVacation){
        _virtualVacation = virtualVacation;
        [self useDocument:self.virtualVacation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.virtualVacation){
        NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory  inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Virtual Vacation"];
        self.virtualVacation = [[UIManagedDocument alloc] initWithFileURL:url];
        [self refresh];
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


- (void)setUpFetchedResultsController:(UIManagedDocument*)document
{
    NSFetchRequest * request = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}
- (void)fetchFlickrDataIntoDocument:(UIManagedDocument *)document
{
    
    dispatch_queue_t QFetch = dispatch_queue_create("QFetch", NULL);
    dispatch_async(QFetch, ^{
        NSArray * photos = [FlickrFetcher recentGeoreferencedPhotos];
        [document.managedObjectContext performBlock:^{ // perform in the NSMOC's safe thread (main thread)
            for (NSDictionary *flickrInfo in photos) {
                [Photo photoWithFlickrInfo:flickrInfo inContext:document.managedObjectContext];
            }
        }];
    });
    NSLog(@"fetchFlickrDataIntoDocument");
    dispatch_release(QFetch); 

}

+ (UIManagedDocument *)createUIManagedDocument:(NSString *)nom
{
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    NSString * nomDocument = [@"virtualVacation/" stringByAppendingString:nom];
    url = [url URLByAppendingPathComponent:nomDocument];
    NSLog(@"create ui managed document url : %@",url);
    UIManagedDocument *manageDocument = [[UIManagedDocument alloc]initWithFileURL:url];
    return manageDocument;
}

- (void)useDocument:(UIManagedDocument *)document
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[document.fileURL path]]){
        // if the document doesn't exist
        NSLog(@"document.file URL path : %@", [document.fileURL path]);
        [document saveToURL: document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){}];
        [self fetchFlickrDataIntoDocument:document];
        NSLog(@"useDocument: Document créé");
        [self setUpFetchedResultsController:document];
    }else if (document.documentState == UIDocumentStateClosed) {
        NSLog(@"document fermé");
        // if the document state is closed
        [self setUpFetchedResultsController:document];
    }else if(document.documentState == UIDocumentStateNormal){
        // if the document already exist
        NSLog(@"document state normal");
        [self setUpFetchedResultsController:document];
    }
} 

- (void)awakeFromNib
{
    /*[super awakeFromNib];
    UIManagedDocument* managedDocument = [VirtualVacationViewController createUIManagedDocument:@"myVacation"];
    [self useDocument:managedDocument];
    [self refresh];*/
}


- (void) refresh

{
    NSLog(@"refresh");
    NSFileManager* fileManager = [[NSFileManager alloc]init];
    NSArray * properties =  [NSArray arrayWithObjects: NSURLNameKey, NSURLIsDirectoryKey, NSURLCreationDateKey, nil];
    NSURL * documentDirectoryURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
    NSURL * virtualVacationDirectoryURL = [documentDirectoryURL URLByAppendingPathComponent:@"Virtual Vacation"];
    self.virtualVacationURLs = [fileManager contentsOfDirectoryAtURL:virtualVacationDirectoryURL includingPropertiesForKeys:properties options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:nil];
    NSLog(@" virtual vacation url %@",self.virtualVacationURLs);
    [self setUpFetchedResultsController:self.virtualVacation];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
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
    NSLog(@"numberOfRowsInSection : %d",[self.virtualVacationURLs count]);
    return [self.virtualVacationURLs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Virtual Vacation";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = @"Virtual Vacation";
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
