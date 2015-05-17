//
//  sp_ViewController.h
//  Maple
//
//  Created by 01HW604371 on 12/19/14.
//  Copyright (c) 2014 01HW604371. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapView.h"
#import "sp_Annotation.h"
#import "sp_SearchPopOverViewController.h"
#import "sp_RouteFinderViewController.h"

@class LcationDetailsViewController;

@interface sp_ViewController : UIViewController <MKAnnotation,MKMapViewDelegate,MKOverlay,UIActionSheetDelegate,UIAlertViewDelegate,RouteFinderPopUpDelegate,SearchLocationProtocol,UINavigationControllerDelegate,UIPopoverControllerDelegate,MapViewTouchActionProtocol>
@property (weak, nonatomic) IBOutlet MapView *mapVeiw;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender;
- (IBAction)setMyLocation:(id)sender;
- (IBAction)showActionViewOnTap:(UIBarButtonItem *)sender;
- (IBAction)searchButtonTapped:(UIBarButtonItem *)sender;
@end
//navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated