//
//  sp_RouteFinderViewController.h
//  Maple
//
//  Created by 01HW604371 on 1/13/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CLGeocoder.h>
#import "sp_PopOverProtocol.h"
#import <MapKit/MKDirectionsTypes.h>

#define LOCATION @"location"
#define MESSAGE @"locationText"

typedef void(^receivedLocation)(id);

@protocol RouteFinderPopUpDelegate <NSObject,sp_PopOverProtocol>
@optional
-(void) showRouteFrom:(CLLocation*) source toDestinationAt:(CLLocation*) destination TransportType:(MKDirectionsTransportType) transportType;

@end

@interface sp_RouteFinderViewController : UIViewController<UITextFieldDelegate>
@property (weak,nonatomic) id<RouteFinderPopUpDelegate> delegate;
@property (copy,nonatomic) receivedLocation onReceiveLocation;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)showRouteBtnTapped:(UIButton *)sender;
- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)clearText:(UIButton *)sender;
- (IBAction)setTransportType:(UISegmentedControl *)sender;


@end
