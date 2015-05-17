//
//  LcationDetailsViewController.m
//  Maple
//
//  Created by Fake Client on 17/05/15.
//  Copyright (c) 2015 01HW604371. All rights reserved.
//

#import "LcationDetailsViewController.h"

@interface LcationDetailsViewController ()
{
	
}
@end

@implementation LcationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
	self.view.userInteractionEnabled=NO;
	[self.indicatorView startAnimating];
	if (self.selectedPlace) {
		[self updateUIWithPlaceMark:self.selectedPlace];
		((UIButton*)[self.view viewWithTag:5]).enabled = NO;
	}
}

-(void) updateUIWithPlaceMark:(CLPlacemark *)placemark {
	CGPoint nextPosition;
	
	self.selectedPlace = placemark;
	@try {
		if (placemark.name && ![placemark.name isEqualToString:@""]) {
			NSAttributedString *attStrName = [[NSAttributedString alloc] initWithString:placemark.name attributes:@{
																													NSFontAttributeName : [UIFont fontWithName:@"Verdana" size:30.0],			           NSForegroundColorAttributeName : [UIColor greenColor],
																													
																													}];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, attStrName.size.width,attStrName.size.height)];
			label.attributedText = attStrName;
			label.textAlignment = NSTextAlignmentCenter;
			[self.scrollView addSubview:label];
			nextPosition = CGPointMake(0, 10+attStrName.size.height+5);
			
		}
		if (placemark && placemark.addressDictionary) {
			NSMutableString *mstrAddress = [NSMutableString new];
					for (NSString* value in [placemark.addressDictionary objectForKey:@"FormattedAddressLines"]) {
						[mstrAddress appendFormat:@"%@,",value ];
					}
			//[mstrAddress appendString:[placemark.addressDictionary objectForKey:@"ZIP"]];
			NSAttributedString *attStrName = [[NSAttributedString alloc] initWithString:mstrAddress attributes:@{
																												 NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0],			           NSForegroundColorAttributeName : [UIColor blueColor],
																												 
																												 }];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(nextPosition.x, nextPosition.y, self.scrollView.frame.size.width,attStrName.size.height)];
			label.attributedText = attStrName;
			label.textAlignment = NSTextAlignmentCenter;
			label.numberOfLines = 5;
			label.lineBreakMode = NSLineBreakByWordWrapping;
			[self.scrollView addSubview:label];
			nextPosition = CGPointMake(0, nextPosition.y+attStrName.size.height+5);
		}
	}
	@catch (NSException *exception) {
		NSAttributedString *attStrName = [[NSAttributedString alloc] initWithString:@"OOPS!!!!!" attributes:@{
																												NSFontAttributeName : [UIFont fontWithName:@"Verdana" size:30.0],			           NSForegroundColorAttributeName : [UIColor redColor],
																												
																												}];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, attStrName.size.width,attStrName.size.height)];
		label.attributedText = attStrName;
		label.textAlignment = NSTextAlignmentCenter;
		[self.scrollView addSubview:label];
		nextPosition = CGPointMake(0, 10+attStrName.size.height+5);
	}
	@finally {
		[self.indicatorView stopAnimating];
		self.view.userInteractionEnabled=YES;
	}
	
}


- (IBAction)btnPlaceMarkerTapped:(id)sender {
	[self.delegate placeAnnotationAtLocation:self.selectedPlace];
}
- (IBAction)donebtnTapped:(id)sender {
	[self.delegate dismissPopOver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
