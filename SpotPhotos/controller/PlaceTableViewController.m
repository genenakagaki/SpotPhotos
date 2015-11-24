//
//  PhotoTableViewController.m
//  SpotPhotos
//
//  Created by User on 11/18/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "PlaceTableViewController.h"

@interface PlaceTableViewController ()

@property (nonatomic) NSDictionary *places;
@property (nonatomic) NSArray *countries;

@end

@implementation PlaceTableViewController

@synthesize places = _places;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [FlickrFetcher URLforTopPlaces];
    
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
        NSArray *results = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PLACES];
        
        NSMutableDictionary *locations = [[NSMutableDictionary alloc] init];
        
        for (NSDictionary *result in results) {
            NSString *location = [result valueForKey:@"_content"];
            NSArray *content = [[result valueForKey:@"_content"] componentsSeparatedByString:@", "];
            NSString *country = [content objectAtIndex:2];
            
            NSMutableArray *locArr = [locations objectForKey:country];
            if (!locArr) {
                locArr = [[NSMutableArray alloc] init];
            }
            [locArr addObject:location];
            [locArr sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [locations setValue:locArr forKey:country];
        }
        
        NSArray *countries = [[locations allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSLog(@"%@", locations);
        
        
        // This needs to be done on the main thrread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.places = locations;
            self.countries = countries;
            [self.tableView reloadData];
        });
    });
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.countries count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [self.countries objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSString *sectionTitle = [self.countries objectAtIndex:section];
    NSArray * sectionLocations = [self.places objectForKey:sectionTitle];
    return [sectionLocations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"location cell" forIndexPath:indexPath];
    
    NSString *sectionTitle = [self.countries objectAtIndex:indexPath.section];
    NSArray *sectionLocations = [self.places objectForKey:sectionTitle];
    NSString *location = [sectionLocations objectAtIndex:indexPath.row];
    cell.textLabel.text = location;
    
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
