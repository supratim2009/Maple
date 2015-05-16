//
//  sp_SearchPopOverViewController.m
//  Maple
//
//  Created by 01HW604371 on 1/6/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import "sp_SearchPopOverViewController.h"
#import "sp_MapSearchResultDetailsViewController.h"

@interface sp_SearchPopOverViewController ()
{
	__block NSMutableArray *marrSearchResult;
	MKCoordinateRegion *searchRegion;
	short selectedIndex;
}
@end

@implementation sp_SearchPopOverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		marrSearchResult = [NSMutableArray new];
		
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delegateDidPostNotification:) name:MAPVIEWDIDFINDLOCATION object:self.delegate];
}
-(void) viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	marrSearchResult = [NSMutableArray new];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MAPVIEWDIDFINDLOCATION object:self.delegate];
	
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"PUSHTODETAILSVIEW"]) {
		
		((sp_MapSearchResultDetailsViewController*) segue.destinationViewController).mapItem = marrSearchResult [self.searchResultTableView.indexPathForSelectedRow.row];
	}
}
- (IBAction)DoneButtonTapped:(UIBarButtonItem *)sender {
	[self.delegate dismissPopOver];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [marrSearchResult count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SEARCHRESULTDISSPLAYCELL"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SEARCHRESULTDISSPLAYCELL"];
	}
	MKPlacemark *rPlaceMark = ((MKMapItem*)marrSearchResult[indexPath.row]).placemark;
	NSMutableString *mstrCellText = [NSMutableString new];
	[mstrCellText appendString:((rPlaceMark.name)?[rPlaceMark.name stringByAppendingString:@","]:@"")];
	[mstrCellText appendString:((rPlaceMark.locality)?[rPlaceMark.locality stringByAppendingString:@","]:@"")];
	//[mstrCellText appendString:((rPlaceMark.administrativeArea)?[rPlaceMark.administrativeArea stringByAppendingString:@","]:@"")];
	[mstrCellText appendString:((rPlaceMark.subAdministrativeArea)?[rPlaceMark.subAdministrativeArea stringByAppendingString:@","]:@"")];
	[mstrCellText appendString:((rPlaceMark.postalCode)?[rPlaceMark.postalCode stringByAppendingString:@","]:@"")];
	[mstrCellText appendString:((rPlaceMark.country)?rPlaceMark.country:@"")];
	
	cell.textLabel.text = mstrCellText;
	cell.textLabel.textColor = [UIColor blackColor];
	
	
	return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	
	
	if (![searchBar.text isEqualToString:@""]) {
		[self.delegate searchText:searchBar.text inSelectedScope:selectedIndex];
	}
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	selectedIndex = selectedScope;
	if (![searchBar.text isEqualToString:@""]) {
		[self searchBar:searchBar textDidChange:searchBar.text];
	}
}

-(void) delegateDidPostNotification:(id) notification {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		NSLog(@"MAPVIEWDIDFINDLOCATION Notification Received");
		marrSearchResult =  [[[notification userInfo] objectForKey:MAPVIEWDIDFINDLOCATION] mutableCopy] ;
		[self.searchResultTableView reloadData];
	}];
	
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
		[tableView setSeparatorInset:UIEdgeInsetsZero];
	}
	
	if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
		[tableView setLayoutMargins:UIEdgeInsetsZero];
	}
	
	if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
		[cell setLayoutMargins:UIEdgeInsetsZero];
	}
	[cell setBackgroundColor:[UIColor clearColor]];
	
}
-(void) dealloc {
	
	self.delegate=Nil;

}

@end