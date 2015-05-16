	//
//  sp_ViewController.m
//  Maple
//
//  Created by 01HW604371 on 12/19/14.
//  Copyright (c) 2014 01HW604371. All rights reserved.
//

#import "sp_ViewController.h"
#import "sp_AnnotationView.h"

@interface sp_ViewController ()
{
	CLLocationManager *locationManager;
	
	CLLocationCoordinate2D dragInitialCoordinate;
	NSMutableArray* annotations;
	__block MKDirectionsResponse *result;
	__block NSError *err;
	UIActionSheet *actionSheet;
	BOOL isRecordingUserMovement;
	NSMutableArray *pathColorSet;
	NSMutableArray *instructionSet;
	NSMutableString *gpxFinalString;
	__block double **arrDist;
	BOOL isDragging;
	UIStoryboardPopoverSegue *popOverSegue;
}
@end

@implementation sp_ViewController
@synthesize coordinate,boundingMapRect;
static int pathNo=0;
-(BOOL) prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	isRecordingUserMovement=false;
	// Do any additional setup after loading the view, typically from a nib.
	//MKMapView
	
	self.mapVeiw.showsUserLocation=YES;
	self.mapVeiw.delegate = self;
	self.mapVeiw.userTrackingMode = MKUserTrackingModeFollowWithHeading;

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
		sp_Annotation *locAnnotate = [sp_Annotation new];
		locAnnotate.coordinate = loc;
		[annotations addObject:locAnnotate];
	}
	[self.mapVeiw showAnnotations:annotations animated:YES];
	
	actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do More" delegate:self cancelButtonTitle:Nil destructiveButtonTitle:Nil otherButtonTitles:@"Take Snapshot",@"Record Map in Background",nil];
	
	locationManager = [[CLLocationManager alloc] init];
	[locationManager requestAlwaysAuthorization];
	
    
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





- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	NSLog(@"Did select:%@",view);
	NSLog(@"Self.view=%@",self.view);
     if([[((UINavigationController*)popOverSegue.popoverController.contentViewController) topViewController] isKindOfClass:[sp_RouteFinderViewController class]]) {
		NSLog(@"Did select:%@",view);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewControllerDidSelectedMapPoint" object:Nil];
		
        if ([popOverSegue.destinationViewController isKindOfClass:[UINavigationController class]]) {
             CLLocation *location= [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
            if ([view.annotation isKindOfClass:[sp_Annotation class]]) {
               
                NSString *locName=((sp_Annotation*)view.annotation).shortDescription;
                if (locName) {
                    
                    ((sp_RouteFinderViewController*)((UINavigationController*)popOverSegue.destinationViewController).visibleViewController).onReceiveLocation(@{LOCATION:location,MESSAGE:locName});
                    return;
                }
            } else if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
                NSString *locName=((MKUserLocation*)view.annotation).title;
                if (locName) {
                    ((sp_RouteFinderViewController*)((UINavigationController*)popOverSegue.destinationViewController).visibleViewController).onReceiveLocation(@{LOCATION:location,MESSAGE:locName});
                    return;
                }
            }
            
        }
        
    }
	
	[self.mapVeiw resignFirstResponder];
	[self.view resignFirstResponder];
	
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
	
	[actionSheet showFromBarButtonItem:sender animated:YES];
	
}

- (IBAction)searchButtonTapped:(UIBarButtonItem *)sender {
	[self performSegueWithIdentifier:@"SEARCHSEGUEID" sender:self];
	
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Touch Began");
	for (UITouch *t in touches) {
		NSLog(@"view:%@",t.view);
	}
	
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	NSLog(@"touches end");
	if([[((UINavigationController*)popOverSegue.popoverController.contentViewController) topViewController] isKindOfClass:[sp_RouteFinderViewController class]]){
		[[NSNotificationCenter defaultCenter] postNotificationName:@"MapViewControllerDidSelectedMapPoint" object:Nil];
        CGPoint touchPoint = [((UITouch*)[touches anyObject]) locationInView:self.mapVeiw];
        NSLog(@"X:%f,Y:%f",touchPoint.x,touchPoint.y);
        CLLocationCoordinate2D coordinateAtPoint = [self.mapVeiw convertPoint:touchPoint toCoordinateFromView:self.mapVeiw];
        CLLocation *location= [[CLLocation alloc] initWithLatitude:coordinateAtPoint.latitude longitude:coordinateAtPoint.longitude];
        CLGeocoder *geoCoder=[[CLGeocoder alloc] init];
        
        __block NSString *msg;
        [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error) {
                CLPlacemark *placemark=placemarks[0];
                msg = [NSString stringWithFormat:@"%@,%@,%@,%@",placemark.name,placemark.locality,placemark.ISOcountryCode,placemark.postalCode];
                ((sp_RouteFinderViewController*)((UINavigationController*)popOverSegue.destinationViewController).visibleViewController).onReceiveLocation(@{LOCATION:location,MESSAGE:msg});
            }
            else {
                msg = [NSString stringWithFormat:@"%lf,%lf",location.coordinate.latitude,location.coordinate.longitude];
                ((sp_RouteFinderViewController*)((UINavigationController*)popOverSegue.destinationViewController).visibleViewController).onReceiveLocation(@{LOCATION:location,MESSAGE:msg});
            }
        }];
    }
			 
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
		
			[[NSNotificationCenter defaultCenter] postNotificationName:MAPVIEWDIDFINDLOCATION object:self userInfo:@{MAPVIEWDIDFINDLOCATION:response.mapItems}];
		
		
	}];
	return nil;
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

-(void) recordMap {
	
}

-(void) saveImageInDisk :(UIImage*) image {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Image.png"];
	
	// Save image.
	[UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
}

-(void) dismissPopOver {
	[popOverSegue.popoverController dismissPopoverAnimated:YES];
	popOverSegue=Nil;
}

-(void) createPDF {
	
}


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