//
//  LcationDetailsViewController.h
//  Maple
//
//  Created by Supratim on 17/05/15.
//  Copyright (c) 2015 Supratim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sp_PopOverProtocol.h"
#import <CoreLocation/CLPlacemark.h>



@protocol MapViewDetailsDelegate <NSObject,sp_PopOverProtocol>
@required
-(void) placeAnnotationAtLocation:(CLPlacemark*) place;
@end

@interface LcationDetailsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;
@property (weak, nonatomic) id<MapViewDetailsDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong) CLPlacemark *selectedPlace;

-(void) updateUIWithPlaceMark:(CLPlacemark*) placemark;

@end
