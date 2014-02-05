//
//  TabBarViewController.m
//  TopPlaces
//
//  Created by Lucas Charrier on 03/11/12.
//  Copyright (c) 2012 UTC. All rights reserved.
//

#import "TabBarViewController.h"
#import "SplitViewControllerBarButtonItemPresenter.h"


@interface TabBarViewController ()<UISplitViewControllerDelegate>

@end

@implementation TabBarViewController

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.splitViewController.delegate = self;
}

- (id <SplitViewControllerBarButtonItemPresenter>)splitViewBarButtomItemPresenter
{
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if(![detailVC conformsToProtocol:@protocol(SplitViewControllerBarButtonItemPresenter)]){
        detailVC = nil;
    }
    return detailVC;
}

- (BOOL)splitViewController:(UISplitViewController *)svc 
   shouldHideViewController:(UIViewController *)vc 
              inOrientation:(UIInterfaceOrientation)orientation
{
    return  [self splitViewBarButtomItemPresenter] ? (UIInterfaceOrientationIsPortrait(orientation)) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc 
     willHideViewController:(UIViewController *)aViewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = [[self.splitViewController.viewControllers objectAtIndex:0] title];
    [self splitViewBarButtomItemPresenter].splitViewBarButtonItem = barButtonItem;
    //tell the detail view to put the button up
}

- (void)splitViewController:(UISplitViewController *)svc 
     willShowViewController:(UIViewController *)aViewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    barButtonItem.title = self.title;
    [self splitViewBarButtomItemPresenter].splitViewBarButtonItem = nil;    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
