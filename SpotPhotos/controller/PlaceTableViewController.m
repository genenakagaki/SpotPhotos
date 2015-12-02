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
        
        NSMutableDictionary *places = [[NSMutableDictionary alloc] init];
//        places = @{
//            @"<countryName>" = @{
//                    @"city"     = @"<city>",
//                    @"province" = @"<province>",
//                    @"placeId"  = @"<placeId>"
//                }
//        };
        
        for (NSDictionary *result in results) {
            // _content format: "city, province, county"
            NSString *content   = [result valueForKey:@"_content"];
            NSArray *contentArr = [content componentsSeparatedByString:@", "];
            
            NSString *country   = [contentArr lastObject];
            
            NSMutableArray *countryPlaces = [places objectForKey:country];
            if (!countryPlaces) {
                countryPlaces = [[NSMutableArray alloc] init];
            }
            
            NSMutableDictionary *place = [[NSMutableDictionary alloc] init];
//            place = @{
//                @"city"     = @"<cityName>",
//                @"province" = @"<provinceName>",
//                @"placeId"  = @"<placeId>"
//            };
            
            NSString *city = [contentArr objectAtIndex:0];
            [place setValue:city forKey:@"city"];
    
            NSString *province = [contentArr objectAtIndex:1];
            if ([province isEqualToString:country]) {
                [place setValue:@"" forKey:@"province"];
            }
            else {
                [place setValue:province forKey:@"province"];
            }
            
            NSString *placeId = [result valueForKey:@"place_id"];
            [place setValue:placeId forKey:@"placeId"];
            
            [countryPlaces addObject:place];
            
            [places setValue:countryPlaces forKey:country];
        }
        
        // sort countries alphabetically
        NSArray *countries = [[places allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
//        NSLog(@"%@", locations);
        
        
        // This needs to be done on the main thrread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing];
            self.places    = places;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Cell"
                                                            forIndexPath:indexPath];
    
    NSString *sectionTitle = [self.countries objectAtIndex:indexPath.section];
    NSArray *countryPlaces = [self.places objectForKey:sectionTitle];
    NSDictionary *place    = [countryPlaces objectAtIndex:indexPath.row];
    
    cell.textLabel.text       = [place objectForKey:@"city"];
    cell.detailTextLabel.text = [place objectForKey:@"province"];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        if ([segue.identifier isEqualToString:@"Display Photo Table"]) {
            // get the place dictionary
            NSString *sectionTitle = [self.countries objectAtIndex:indexPath.section];
            NSArray *countryPlaces = [self.places objectForKey:sectionTitle];
            NSDictionary *place    = [countryPlaces objectAtIndex:indexPath.row];
            
            PlacePhotoViewController *vc = segue.destinationViewController;
            
            NSLog(@"%@", [place objectForKey:@"placeId"]);
            vc.placeId = [place objectForKey:@"placeId"];
        }
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



@end
