	//
//  sp_ViewController.m
//  Maple
//
//  Created by Supratim on 12/19/14.
//  Copyright (c) 2014 Supratim. All rights reserved.
//

#import "sp_ViewController.h"
#import "sp_AnnotationView.h"
#import "LcationDetailsViewController.h"

@interface sp_ViewController () <MapViewDetailsDelegate>
{
	CLLocationManager *locationManager; // Corelocation Manager
	
	CLLocationCoordinate2D dragInitialCoordinate;
	NSMutableArray* annotations;
	__block MKDirectionsResponse *result; //
	__block NSError *err;
	__block BOOL isRecordingUserMovement;
	NSMutableArray *pathColorSet;
	NSMutableArray *instructionSet;
	NSMutableString *gpxFinalString;
	__block double **arrDist;
	BOOL isDragging;
	BOOL isSelectingAnnotationView;
	UIStoryboardPopoverSegue *popOverSegue;
	UIPopoverController *mapDetailCallOutPopOver;
	
}
@end

@implementation sp_ViewController
@synthesize coordinate,boundingMapRect;
static int pathNo=0;

//Keep status bar hidden
-(BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	isRecordingUserMovement=false;
	// Do any additional setup after loading the view, typically from a nib.
	//MKMapView
	
	//Setting up Mapview
	self.mapVeiw.showsUserLocation=YES;
	self.mapVeiw.delegate = self;
	self.mapVeiw.userTrackingMode = MKUserTrackingModeFollowWithHeading;
	self.mapVeiw.exclusiveTouch = YES;
	self.mapVeiw.touchDelegate = self;
	// Demo Mapview 
	NSArray* arrLocationList = @[@"14.622485,120.961231",@"14.617739,120.970256",@"14.614685,120.991388",@"14.603539,120.96753",
								 @"14.60056,120.985026",@"14.600252,120.985229",@"14.601628,120.982326",@"14.602294,120.982446",
								 @"14.603556,120.99262",@"14.601836,120.992486",@"14.603207,120.99181",@"14.604185,120.993186",
								 @"14.591271,121.018886",@"14.603674,120.999378",@"14.603674,120.999378",@"14.608882,120.996568",
								 @"14.618511,120.993885",@"14.610796,120.995808",@"14.603539,120.96753",@"14.603516,120.965901",
								 @"14.604363,120.967079",@"14.59215,120.97471",@"14.588645,120.977637",@"14.610061,120.995712",
								 @"14.609346,120.996189",@"14.609576,120.995867",@"14.608899,120.996417",@"14.606056,120.987453",
								 @"14.606106,120.98812",@"14.603539,120.96753",@"14.603437,120.967569",@"14.603516,120.965901",
								 @"14.604363,120.967079",@"14.635969,120.967085",@"14.622733,120.961034",@"14.622485,120.961231"
								 ];
	 annotations = [NSMutableArray new];
	
	for (NSString* location in arrLocationList) {
		CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([[location componentsSeparatedByString:@","][0] doubleValue], [[location componentsSeparatedByString:@","][1] doubleValue]);
		sp_Annotation *locAnnotate = [[sp_Annotation alloc] initWithCoordinate:loc addressDictionary:nil];
		[annotations addObject:locAnnotate];
	}
	[self.mapVeiw showAnnotations:annotations animated:YES];
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager requestAlwaysAuthorization];
	
    
}

-(UIAlertController*) getAlertController {
	UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Do More With Maps" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	UIAlertAction *action = [UIAlertAction actionWithTitle:@"Take Snapshot" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self performSelectorInBackground:@selector(makeSnapShot) withObject:nil];
	}];
	[actionSheet addAction:action];
	action = nil;
	
	action = [UIAlertAction actionWithTitle:(!isRecordingUserMovement)?@"Start Tracking User Movement":@"Stop Tracking User Movement" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		isRecordingUserMovement = !isRecordingUserMovement;
	}];
	[actionSheet addAction:action];
	action = nil;
	
	return actionSheet;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
		popOverSegue = (UIStoryboardPopoverSegue*) segue;
		if ([popOverSegue.destinationViewController isKindOfClass:[UINavigationController class]]) {

            ((UINavigationController*)popOverSegue.destinationViewController).delegate=self;
		}
	}
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isKindOfClass:[sp_SearchPopOverViewController class]]) {
        ((sp_SearchPopOverViewController*) viewController).delegate=self;
    } else if ([viewController isKindOfClass:[sp_RouteFinderViewController class]]) {
        ((sp_RouteFinderViewController*) viewController).delegate=self;
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Change the map type when segmentedcontrol index changes

- (IBAction)segmentValueChanged:(UISegmentedControl *)sender {
	switch (sender.selectedSegmentIndex) {
		case 0:
			self.mapVeiw.mapType = MKMapTypeStandard;
			break;
		case 1:
			self.mapVeiw.mapType = MKMapTypeSatellite;
			break;
		case 2:
			self.mapVeiw.mapType = MKMapTypeHybrid;
			break;
		default:
			break;
	}
}
- (IBAction)setMyLocation:(id)sender {
	[locationManager startUpdatingLocation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	MKAnnotationView *defaultView = [self.mapVeiw dequeueReusableAnnotationViewWithIdentifier:@"ReUser"];
	if (defaultView==Nil) {
		defaultView = [[sp_AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ReUser"];
	}
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		defaultView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"mylocImg" ofType:@"png"]];
	}
	return defaultView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	isSelectingAnnotationView = YES;
	if (!popOverSegue.popoverController) {
	UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
	UINavigationController *navigationController = [st instantiateViewControllerWithIdentifier:@"LOCATIONDETAILSCALLOUTVIEWCONTROLLER"];
	((LcationDetailsViewController*) navigationController.viewControllers[0]).delegate = self;
	((LcationDetailsViewController*) navigationController.viewControllers[0]).selectedPlace = ((sp_Annotation*)view.annotation);
	mapDetailCallOutPopOver = [[UIPopoverController alloc] initWithContentViewController:navigationController];
		mapDetailCallOutPopOver.delegate = self;
	[mapDetailCallOutPopOver presentPopoverFromRect:CGRectMake(view.frame.origin.x, view.frame.origin.y, 1, 1) inView:mapView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else if([[((UINavigationController*)popOverSegue.popoverController.contentViewController) topViewController] isKindOfClass:[sp_RouteFinderViewController class]]){
		CLPlacemark *placemark=((sp_Annotation*)view.annotation);
		NSMutableString *msg = [NSMutableString new];
		[msg appendString:(placemark.name)?placemark.name:@""];
		[msg appendString:(placemark.locality)?placemark.locality:@""];
		[msg appendString:(placemark.ISOcountryCode)?placemark.ISOcountryCode:@""];
		[msg appendString:(placemark.postalCode)?placemark.postalCode:@""];
		if ([msg isEqualToString:@""]) {
			[msg appendString:[NSString stringWithFormat:@"%lf,%lf",((sp_Annotation*)view.annotation).location.coordinate.latitude, ((sp_Annotation*)view.annotation).location.coordinate.longitude]];
		}
		((sp_RouteFinderViewController*)((UINavigationController*)popOverSegue.destinationViewController).visibleViewController).onReceiveLocation(@{LOCATION:placemark.location,MESSAGE:msg, @"PlaceMark":placemark});
		
	}
	
}

-(void) drawPathTo:(MKDirectionsResponse*) response {
	pathColorSet=nil;
	pathColorSet = [NSMutableArray new];
	NSArray *sortedRoots = [response.routes sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		double distance1 = ((MKRoute*)obj1).distance;
		double distance2 = ((MKRoute*)obj2).distance;
		if (distance1>distance2) {
			return NSOrderedAscending;
		}
		else if (distance1<distance2) {
			return NSOrderedDescending;
		} else return NSOrderedSame;
		
	}];
	
	
	
	for (MKRoute *route in sortedRoots) {
//		MKRoute *route = response.routes[0];
		NSLog(@"Est. Distance :%lf",route.distance);
		//NSArray *notices = route.advisoryNotices;
		MKPolyline *linePath = route.polyline;
		if ([route isEqual:[sortedRoots lastObject]]) {
			[pathColorSet addObject:[UIColor greenColor]];
		} else [pathColorSet addObject:[UIColor blueColor]];
		[[NSOperationQueue mainQueue] addOperationWithBlock:^ {[self.mapVeiw addOverlay:linePath level:MKOverlayLevelAboveRoads]; }];
		
	}
	
}
- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay
{
	
	NSLog(@"Drawing Rout Index = %d",pathNo);
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.lineWidth = 5.0;
    renderer.strokeColor = pathColorSet[pathNo++];
	//renderer.strokeColor=[UIColor blueColor];
	return renderer;
}



- (IBAction)showActionViewOnTap:(UIBarButtonItem *)sender {
	
//	[actionSheet showFromBarButtonItem:sender animated:YES];
	UIPopoverController *popover= [[UIPopoverController alloc] initWithContentViewController:[self getAlertController]];
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	
}

- (IBAction)searchButtonTapped:(UIBarButtonItem *)sender {
	[self performSegueWithIdentifier:@"SEARCHSEGUEID" sender:self];
	
}




-(void) showDetailsOfLocation:(CLLocation *)location AtPoint:(CGPoint)point {
	if (!isSelectingAnnotationView || popOverSegue.popoverController) {
		if([[((UINavigationController*)popOverSegue.popoverController.contentViewController) topViewController] isKindOfClass:[sp_RouteFinderViewController class]]){
			[[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewControllerDidSelectedMapPoint" object:Nil];
		} else {
			[self createAnnnotationDetailsViewPopoverAtPoint:point];
		}
		CLGeocoder *geoCoder=[[CLGeocoder alloc] init];
		[geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
			NSString *msg;
			
			
			if([[((UINavigationController*)popOverSegue.popoverController.contentViewController) topViewController] isKindOfClass:[sp_RouteFinderViewController class]]){
				if (!error) {
					CLPlacemark *placemark=placemarks[0];
					msg = [NSString stringWithFormat:@"%@,%@,%@,%@",placemark.name,placemark.locality,placemark.ISOcountryCode,placemark.postalCode];
					
				}
				else {
					msg = [NSString stringWithFormat:@"%lf,%lf",location.coordinate.latitude,location.coordinate.longitude];
				}
				((sp_RouteFinderViewController*)((UINavigationController*)popOverSegue.destinationViewController).visibleViewController).onReceiveLocation(@{LOCATION:location,MESSAGE:msg, @"PlaceMark":placemarks});
			}
			else {
				if (!error) {
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{
					[((LcationDetailsViewController*)((UINavigationController*)self.presentedViewController).topViewController) updateUIWithPlaceMark:placemarks[0]];
					}];
				}
				
			}
		}];
	}
	
}

-(void) createAnnnotationDetailsViewPopoverAtPoint:(CGPoint) point {
	UIStoryboard *st = [UIStoryboard storyboardWithName:[[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"] bundle:[NSBundle mainBundle]];
	UINavigationController *navigationController = [st instantiateViewControllerWithIdentifier:@"LOCATIONDETAILSCALLOUTVIEWCONTROLLER"];
	((LcationDetailsViewController*) navigationController.viewControllers[0]).delegate = self;
	
	mapDetailCallOutPopOver = [[UIPopoverController alloc] initWithContentViewController:navigationController];
	mapDetailCallOutPopOver.delegate = self;
	[mapDetailCallOutPopOver presentPopoverFromRect:CGRectMake(point.x, point.y, 1, 1) inView:self.mapVeiw permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}



- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
	
		NSLog(@"Current User Location is At lat:%lf,lon:%lf",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
	
}



-(void)showRouteFrom:(CLLocation*) source toDestinationAt:(CLLocation*) destination TransportType:(MKDirectionsTransportType) transportType; {
    [instructionSet removeAllObjects];
    instructionSet = Nil;
    [self.mapVeiw removeOverlays:self.mapVeiw.overlays];
    pathNo=0;
    MKDirectionsRequest *directionReq = [[MKDirectionsRequest alloc] init];
    MKMapItem *destinationPlace,*sourcePlace;
    if (source) {
        MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:[source coordinate] addressDictionary:nil];
        sourcePlace = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    }
    else
        sourcePlace=[MKMapItem mapItemForCurrentLocation];
    if (destination) {
        MKPlacemark *destPlaceMark = [[MKPlacemark alloc] initWithCoordinate:[destination coordinate] addressDictionary:nil];
        destinationPlace = [[MKMapItem alloc] initWithPlacemark:destPlaceMark];
    }
    else destinationPlace = [MKMapItem mapItemForCurrentLocation];
    NSLog(@"Destination  Latitude:%f & Longitude : %f",[destination coordinate].latitude,[destination coordinate].longitude);
    directionReq.source = sourcePlace;
    directionReq.destination = destinationPlace;
    directionReq.transportType = MKDirectionsTransportTypeAny;
    directionReq.requestsAlternateRoutes =  YES;
    directionReq.departureDate = [NSDate date];
    MKDirections *direction = [[MKDirections alloc] initWithRequest:directionReq];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            [self drawPathTo:response];
        }
        else NSLog(@"%@",error);
    }];
}

-(MKCoordinateRegion) getRegionFromScopeIndex :(short) scope {
	MKCoordinateRegion region;
	switch (scope) {
		case InRegion:
			region = self.mapVeiw.region;
			break;
		case InCountry :
		case WorldWide :
			region = MKCoordinateRegionForMapRect(MKMapRectWorld);
			break;
		default:
			break;
	}
	
	return region;
}
-(NSMutableArray*) searchText:(NSString*) strRequest inSelectedScope:(short) scope {
	MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
	searchRequest.naturalLanguageQuery=strRequest;
	searchRequest.region  =[self getRegionFromScopeIndex:scope];
	MKLocalSearch *localSearch= [[MKLocalSearch alloc] initWithRequest:searchRequest];
	[localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
		if (!error) {
			[[NSNotificationCenter defaultCenter] postNotificationName:MAPVIEWDIDFINDLOCATION object:self userInfo:@{MAPVIEWDIDFINDLOCATION:(response.mapItems)?response.mapItems:@[]}];
		}
	}];
	return nil;
}

-(void) placeAnnotationAtLocation:(CLPlacemark *)place {
	sp_Annotation *annotation = [[sp_Annotation alloc] initWithCoordinate:place.location.coordinate addressDictionary:place.addressDictionary];
	[self.mapVeiw addAnnotation:annotation];
	
}

-(void) makeSnapShot {
	MKMapSnapshotOptions *snapshotOption = [[MKMapSnapshotOptions alloc] init];
	snapshotOption.mapType = self.mapVeiw.mapType;
	snapshotOption.region = self.mapVeiw.region;
	snapshotOption.mapRect = self.mapVeiw.visibleMapRect;
	snapshotOption.size = CGSizeMake(1024,768);
	
	MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:snapshotOption];
	[snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
		[self saveImageInDisk:snapshot.image];
	}];
	
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	isSelectingAnnotationView = NO;
	for (sp_Annotation *annotation in [self.mapVeiw selectedAnnotations]) {
		[self.mapVeiw deselectAnnotation:annotation animated:YES];
	}
	mapDetailCallOutPopOver=nil;
	return YES;
}

-(void) recordMap {
	
}

-(void) saveImageInDisk :(UIImage*) image {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
	
	// Save image.
	[UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

-(void) dismissPopOver {
	isSelectingAnnotationView = NO;
	if (popOverSegue) {
		[popOverSegue.popoverController dismissPopoverAnimated:YES];
		popOverSegue=Nil;
	} else {
		for (sp_Annotation *annotation in [self.mapVeiw selectedAnnotations]) {
			[self.mapVeiw deselectAnnotation:annotation animated:YES];
		}
		[mapDetailCallOutPopOver dismissPopoverAnimated:YES];
		mapDetailCallOutPopOver=nil;
		
	}
	
}

-(void) createPDF {
	
}

//-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//	UITouch *touch = (UITouch*)[touches anyObject];
//	
////	if (![touch.view isKindOfClass:[sp_AnnotationView class]]) {
//		CGPoint touchPoint = [((UITouch*)[touches anyObject]) locationInView:self.view];
//		NSLog(@"X:%f,Y:%f",touchPoint.x,touchPoint.y);
//		CLLocationCoordinate2D coordinateAtPoint = [self.mapVeiw convertPoint:touchPoint toCoordinateFromView:self.mapVeiw];
//		CLLocation *location= [[CLLocation alloc] initWithLatitude:coordinateAtPoint.latitude longitude:coordinateAtPoint.longitude];
//		[self showDetailsOfLocation:location AtPoint:touchPoint];
////	}
//	
//}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
		{
			//[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
			[self makeSnapShot];
			
		}
			break;
		case 1:
			[self performSelectorInBackground:@selector(recordMap) withObject:nil];
			break;
		case 2:
			[self performSelectorInBackground:@selector(createPDF) withObject:nil];
			break;
		case 3:
			//[locationManager startUpdatingLocation];
			break;
		case 4:
			isRecordingUserMovement = !isRecordingUserMovement;
			break;
		case 5:
			//[self performSelectorInBackground:@selector(getConnectedDistances) withObject:Nil];
			break;
		default:
			break;
	}
}
@end