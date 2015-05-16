//
//  sp_SearchPopOverViewController.h
//  Maple
//
//  Created by 01HW604371 on 1/6/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKGeometry.h>
#import <MapKit/MKMapItem.h>
#import <MapKit/MKPlacemark.h>
#import "sp_PopOverProtocol.h"

#define MAPVIEWDIDFINDLOCATION @"mapViewDidFindLocation"

enum {
	InRegion,
	InCountry,
	WorldWide
} SearchScope;

typedef void(^receivedLocation)(id);

@protocol SearchLocationProtocol <NSObject,sp_PopOverProtocol>
@optional
-(NSMutableArray*) searchText:(NSString*) strRequest inSelectedScope:(short) scope;
@end

@interface sp_SearchPopOverViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
- (IBAction)DoneButtonTapped:(UIBarButtonItem *)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak,nonatomic) id<SearchLocationProtocol> delegate;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (copy,nonatomic) receivedLocation onReceiveLocation;

@end
