//
//  sp_MapSearchResultDetailsViewController.h
//  Maple
//
//  Created by 01HW604371 on 2/5/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MKGeometry.h>
#import <MapKit/MKMapItem.h>
#import <MapKit/MKPlacemark.h>

@interface sp_MapSearchResultDetailsViewController : UIViewController
@property (strong) MKMapItem *mapItem;
@end
