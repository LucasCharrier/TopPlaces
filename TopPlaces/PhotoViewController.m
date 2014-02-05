//
//  PhotoViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 20/10/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "PhotoViewController.h"
#import "FlickrFetcher.h"
#define RECENT_PHOTOS @"recent"


@interface PhotoViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation PhotoViewController
@synthesize scrollView = _scrollView;
@synthesize imageView = _imageView;
@synthesize toolbar = _toolbar;
@synthesize photo = _photo;
@synthesize city = _city;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem;

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if(_splitViewBarButtonItem != splitViewBarButtonItem){
        NSMutableArray * toolbarItems = [self.toolbar.items mutableCopy];
        if(_splitViewBarButtonItem)[toolbarItems removeObject:_splitViewBarButtonItem];
        if(splitViewBarButtonItem)[toolbarItems addObject:splitViewBarButtonItem];
        self.toolbar.items = toolbarItems;
        _splitViewBarButtonItem = splitViewBarButtonItem;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) setPhoto:(NSDictionary *)photo
{
    if(_photo != photo)
    {
        _photo = photo;
        [self refresh];
    }
}

- (NSString *) photoID 
{
    return [self.photo objectForKey:FLICKR_PHOTO_ID];
}

- (NSData *) fetchPhoto 
{
    NSData * imageCache = [DataCache fetchData:[self photoID]];
    
    if(imageCache){ 
        NSLog(@"already in cache");
        return imageCache;
    }else{
        NSLog(@"not in cache");
        return [NSData dataWithContentsOfURL:[FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge]];
    }
}


- (void) storePhoto:(NSString *)name :(NSData *)imageData 
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* recentViewed = [[NSMutableArray alloc] initWithArray: [userDefault objectForKey:RECENT_PHOTOS]];
    
    if(!recentViewed) recentViewed = [NSMutableArray array];
    
    if([recentViewed containsObject:self.photo]){
        
        NSLog(@"remove already existing object");
        [recentViewed removeObject:self.photo];
    
    }
    NSLog(@"remove first object");
    
    if(recentViewed.count > MAX_PHOTOS)[recentViewed removeObjectAtIndex:0];
    [recentViewed addObject:self.photo];
    [userDefault setObject:recentViewed forKey:RECENT_PHOTOS];
    [DataCache storeData:name :imageData];
    [userDefault synchronize];
}



- (void)buildView:(NSData *)imadeData 
{
    self.imageView.image = [UIImage imageWithData:imadeData];
    
    self.scrollView.zoomScale = 1;
    
    self.scrollView.contentSize = self.imageView.image.size;
    
    self.imageView.frame = CGRectMake(0, 0, self.imageView.image.size.width, self.imageView.image.size.height);
    
    self.navigationItem.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
    
    NSLog(@"%@", [self.toolbar isHidden]);
}

- (void)fillView
{
    // Width ratio compares the width of the viewing area with the width of the image	
	float widthRatio = self.scrollView.bounds.size.width / self.imageView.image.size.width;
	
	// Height ratio compares the height of the viewing area with the height of the image	
	float heightRatio = self.scrollView.bounds.size.height / self.imageView.image.size.height; 
	
	// Update the zoom scale
	self.scrollView.zoomScale = MAX(widthRatio, heightRatio);
	
}

- (void) refresh
{
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [spinner startAnimating];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloading", NULL); 
    
    dispatch_async(downloadQueue, ^{
        
        
        NSString *photoID = [self photoID];
		NSData *imageData = [self fetchPhoto];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self storePhoto:photoID :imageData];
            [self buildView:imageData];
            [self fillView];
            [spinner stopAnimating];
            
        });
        
    });
}

- (void)viewWillAppear:(BOOL)animated {	
	
	// Refresh if we have a photo set
	if (self.photo) [self refresh];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.delegate = self;
        
	// Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews 
{
    [self fillView];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setScrollView:nil];
    [self setToolbar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
