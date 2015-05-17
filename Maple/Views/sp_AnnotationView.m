//
//  sp_AnnotationView.m
//  Maple
//
//  Created by 01HW604371 on 1/14/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import "sp_AnnotationView.h"

@implementation sp_AnnotationView
- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self) {
		self.image= [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"marker" ofType:@"png"]];
		self.draggable=NO;
//		self.canShowCallout = YES;
//		UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
//		view1.backgroundColor = [UIColor redColor];
//		UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(70, 0, 30, 20)] ;
//		view2.backgroundColor = [UIColor greenColor];
//		self.leftCalloutAccessoryView = view1;
//		self.rightCalloutAccessoryView = view2;
		
		
	}
	return self;
}


@end
