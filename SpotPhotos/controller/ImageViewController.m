//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Sameh Fakhouri on 11/4/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ImageViewController

-(UIImageView *)imageView
{
    if(!_imageView) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
    [self.spinner stopAnimating];
}


- (UIImage *)image
{
    return self.imageView.image;
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}


- (void)setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.delegate = self;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
}


- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self startDownloadingImage];
}


- (void)startDownloadingImage
{
    self.image = nil;
    [self.spinner startAnimating];
    if (self.imageURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        // explain difference between:
        //          ephemeralSessionConfiguration
        //          defaultSessionConfiguration
        //          backgroundSessionConfiguration
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration
                                                    ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession
                                 sessionWithConfiguration:configuration];
        
        // double click the completionHandler argument to insert the code.
        // change the location argument to localfile (more appropriate name)
        NSURLSessionDownloadTask *task = [session
                                          downloadTaskWithRequest:request
                                          completionHandler:^(NSURL *localFile, NSURLResponse *response,
                                                              NSError *error) {
                                              // make sure there is no error
                                              // you may want to display a message "URL Not Found" or "Download Error"
                                              if (!error) {
                                                  // this download could take a while
                                                  // Say it took 10 minutes, the user could have lost interest
                                                  // and chose a different image, or multiple images
                                                  // now we need to make sure that this download corresponds with
                                                  // what the app currently thinks is happening
                                                  if ([request.URL isEqual:self.imageURL]) {
                                                      UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localFile]];
                                                      // add this block to the end of the main queue
                                                      // it will get executed when the main queue
                                                      // has time and all the other blocks in front
                                                      // of it have completed execution
                                                      [self performSelectorOnMainThread:@selector(setImage:)
                                                                             withObject:image
                                                                          waitUntilDone:NO];
                                                      // another way to do this is:
                                                      // dispatch_async(dispatch_get_main_queue(), ^{self.image = image });
                                                  }
                                              }
                                          }];
        // notice warning that task is not used.
        [task resume];
    }
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}



#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}


- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}



- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}


- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}




@end
