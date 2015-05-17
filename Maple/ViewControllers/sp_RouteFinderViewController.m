//
//  sp_RouteFinderViewController.m
//  Maple
//
//  Created by Supratim on 1/13/15.
//  Copyright (c) 2015 Supratim. All rights reserved.
//

#import "sp_RouteFinderViewController.h"


#define SOURCE @"source"
#define DESTINATION @"destination"

@interface sp_RouteFinderViewController ()
{
    int activeTag;
    NSMutableDictionary *mdictLcation;
    MKDirectionsTransportType transportType;
}
@end

@implementation sp_RouteFinderViewController

-(id) initWithCoder:(NSCoder *)aDecoder {
    self=[super initWithCoder:aDecoder];
    if (self) {
		
		__weak sp_RouteFinderViewController *weakself=self;
        self.onReceiveLocation=^(NSDictionary *dictLocation) {
			sp_RouteFinderViewController *this = weakself;
			[this updateUIonReceiveResponse:dictLocation];
            dictLocation=Nil;
        };
        return self;
    }
    return nil;
}

-(void) updateUIonReceiveResponse:(NSDictionary*) dictResponse {
	[((UITextField*)[self.view viewWithTag:activeTag]) setText:[dictResponse objectForKey:MESSAGE]];
	if (!mdictLcation) {
		mdictLcation = [NSMutableDictionary new];
		
	}
	if (activeTag==17) {
		if ([mdictLcation objectForKey:SOURCE]) {
			[mdictLcation removeObjectForKey:SOURCE];
		}
		[mdictLcation setObject:[dictResponse objectForKey:LOCATION] forKey:SOURCE];
		((UIButton*) [self.view viewWithTag:7]).hidden=NO;
		[self.view bringSubviewToFront: ((UIButton*) [self.view viewWithTag:7])];
		
	} else if (activeTag==18){
		if ([mdictLcation objectForKey:DESTINATION]) {
			[mdictLcation removeObjectForKey:DESTINATION];
		}
		[mdictLcation setObject:[dictResponse objectForKey:LOCATION] forKey:DESTINATION];
		((UIButton*) [self.view viewWithTag:8]).hidden=NO;
		[self.view bringSubviewToFront: ((UIButton*) [self.view viewWithTag:8])];
	}
	[self stopActivityIndicator];
}

-(void) viewDidLoad {
	[super viewDidLoad];
    ((UIButton*) [self.view viewWithTag:8]).hidden=YES;
    ((UIButton*) [self.view viewWithTag:7]).hidden=YES;
    transportType=MKDirectionsTransportTypeAny;
    activeTag=17;
	[self.activityIndicator stopAnimating];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startActivityIndicator) name:@"MapViewControllerDidSelectedMapPoint" object:Nil];
}

-(void) startActivityIndicator {
	NSLog(@"Listening MapViewControllerDidSelectedMapPoint");
	[self.activityIndicator startAnimating];
	self.view.userInteractionEnabled=NO;
}

-(void) stopActivityIndicator {
	
	[self.activityIndicator stopAnimating];
	self.view.userInteractionEnabled=YES;

}
- (IBAction)showRouteBtnTapped:(UIButton *)sender {
    NSLog(@"%@",mdictLcation);
    if (!mdictLcation ) {
           ((UILabel*) [self.view viewWithTag:12]).hidden=NO;
        
        
    } else {
        if (![mdictLcation objectForKey:SOURCE] && ![mdictLcation objectForKey:DESTINATION]) {
            ((UILabel*) [self.view viewWithTag:12]).hidden=NO;
        }
        else
        [self.delegate showRouteFrom:[mdictLcation objectForKey:SOURCE] toDestinationAt:[mdictLcation objectForKey:DESTINATION] TransportType:transportType];
    }
}

- (IBAction)doneButtonTapped:(id)sender {
	[self.delegate dismissPopOver];
}

- (IBAction)clearText:(UIButton *)sender {
    sender.hidden=YES;
    if (sender.tag==7) {
        [((UITextField*)[self.view viewWithTag:17]) setText:@""];
         [mdictLcation removeObjectForKey:SOURCE];
    } else if (sender.tag==8){
        [((UITextField*)[self.view viewWithTag:18]) setText:@""];
         [mdictLcation removeObjectForKey:DESTINATION];
    }

}

- (IBAction)setTransportType:(UISegmentedControl *)sender {
    //MKDirectionsTransportTypeAny
    switch (sender.selectedSegmentIndex) {
        case 0:
            transportType=MKDirectionsTransportTypeAutomobile;
            break;
        case 1:
            transportType=MKDirectionsTransportTypeWalking;
            break;
        default:
            transportType=MKDirectionsTransportTypeAny;
            break;
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
		((UILabel*) [self.view viewWithTag:12]).hidden=YES;
		activeTag=(int)textField.tag;
		textField.autocorrectionType=UITextAutocorrectionTypeNo;
		return NO;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}
-(void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"MapViewControllerDidSelectedMapPoint" object:Nil];
}
@end
