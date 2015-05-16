//
//  sp_Annotation.h
//  Maple
//
//  Created by 01HW604371 on 12/22/14.
//  Copyright (c) 2014 01HW604371. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface sp_Annotation : NSObject <MKAnnotation>
@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong) NSString *shortDescription;
@property (nonatomic,strong) NSString *name;
@end
