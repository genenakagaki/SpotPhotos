//
//  PhotoTableViewController.m
//  SpotPhotos
//
//  Created by User on 11/18/15.
//  Copyright (c) 2015 Lehman College. All rights reserved.
//

#import "PhotoTableViewController.h"

@interface PhotoTableViewController ()

@end

@implementation PhotoTableViewController

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
}

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo Cell" forIndexPath:indexPath];
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [photo objectForKey:@"title"];
    if ([cell.textLabel.text length] == 0) {
        cell.textLabel.text = [[photo objectForKey:@"description"] objectForKey:@"_content"];
        
        if (cell.textLabel.text.length == 0) {
            cell.textLabel.text = @"Unknown";
        }
    }
    
    cell.detailTextLabel.text = [[photo objectForKey:@"description"] objectForKey:@"_content"];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    if ([segue.identifier isEqualToString:@"Display Photo"]) {
        ImageViewController *vc = segue.destinationViewController;
        
        NSDictionary *photo = self.photos[indexPath.row];
        
        [self prepareImageViewController:vc toDisplayPhoto:photo];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id detail = self.splitViewController.viewControllers[1];
    
    [self savePhotoToRecent:indexPath];
    
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[ImageViewController class]]) {
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
    }
}

- (void)prepareImageViewController:(ImageViewController *)vc toDisplayPhoto:(NSDictionary *)photo {
    vc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    vc.title = [photo valueForKey:FLICKR_PHOTO_TITLE];
}

- (void)savePhotoToRecent:(NSIndexPath *)indexPath {
    
    NSDictionary *photo = self.photos[indexPath.row];
    
    // store in nsuserdefaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *recentPhotos = [userDefaults objectForKey:@"recentPhotos"];
    
    NSMutableArray *newRecentPhotos;
    if (!recentPhotos) {
        newRecentPhotos = [[NSMutableArray alloc] init];
    }
    else {
        newRecentPhotos = [recentPhotos mutableCopy];
    }
    
    // check for duplicates
    int duplicateIndex = -1;
    for (int i = 0; i < [recentPhotos count]; i++) {
        NSDictionary *recentPhoto = [recentPhotos objectAtIndex:i];
        
        if ([recentPhoto isEqualToDictionary:photo]) {
            duplicateIndex = i;
            break;
        }
    }
    
    if (duplicateIndex != -1) {
        [newRecentPhotos removeObjectAtIndex:duplicateIndex];
    }
    
    [newRecentPhotos insertObject:photo atIndex:0];
    
    if ([newRecentPhotos count] > 20) {
        [newRecentPhotos removeLastObject];
    }
    
    [userDefaults setObject:newRecentPhotos forKey:@"recentPhotos"];
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
