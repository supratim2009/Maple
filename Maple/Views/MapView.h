//
//  MapView.h
//  Maple
//
//  Created by Fake Client on 16/05/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol MapViewTouchActionProtocol <NSObject>
@optional
-(void) showDetailsOfLocation:(CLLocation*) location AtPoint:(CGPoint) point;
@end

@interface MapView : MKMapView
@property (weak) id<MapViewTouchActionProtocol> touchDelegate;

@end
