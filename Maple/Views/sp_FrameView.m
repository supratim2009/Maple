//
//  sp_FrameView.m
//  Maple
//
//  Created by 01HW604371 on 2/6/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import "sp_FrameView.h"

@implementation sp_FrameView

-(id) initWithFrame:(CGRect)frame {
	self = [super init];
	if (self) {
		self.frame = frame;
		self.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
		
	}
	
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	
	
	self.layer.borderColor = [[UIColor blackColor] CGColor];
	self.layer.borderWidth = 1;
	
	/*Add Slider*/
}


@end
