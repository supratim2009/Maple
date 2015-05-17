//
//  MapView.m
//  Maple
//
//  Created by Fake Client on 16/05/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import "MapView.h"

@implementation MapView
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint touchPoint = [((UITouch*)[touches anyObject]) locationInView:self];
	NSLog(@"X:%f,Y:%f",touchPoint.x,touchPoint.y);
	CLLocationCoordinate2D coordinateAtPoint = [self convertPoint:touchPoint toCoordinateFromView:self];
	CLLocation *location= [[CLLocation alloc] initWithLatitude:coordinateAtPoint.latitude longitude:coordinateAtPoint.longitude];
	[self.touchDelegate showDetailsOfLocation:location AtPoint:touchPoint];
}


@end
