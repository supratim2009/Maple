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
		self.exclusiveTouch=YES;
	}
	return self;
}


@end
