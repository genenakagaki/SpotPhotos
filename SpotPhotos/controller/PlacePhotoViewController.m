//
//  PlacePhotoViewController.m
//  SpotPhotos
//
//  Created by User on 11/25/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "PlacePhotoViewController.h"

@interface PlacePhotoViewController ()

@end

@implementation PlacePhotoViewController

- (void)setPlaceId:(NSString *)placeId {
    _placeId = placeId;
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
    
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:self.placeId maxResults:50];
    
    // create a new queue to do the fetching
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    
    // dispatch the fetch on this queue
    dispatch_async(fetchQ, ^{
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        NSDictionary *propertyListResults = [NSJSONSerialization
                                             JSONObjectWithData:jsonResults
                                             options:0
                                             error:NULL];
        
        //        NSLog(@"Flickr Result = %@", propertyListResults);
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        NSLog(@"%@", photos);
        
        // This needs to be done on the main thrread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.photos = photos;
            [self.tableView reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    
}

@end
