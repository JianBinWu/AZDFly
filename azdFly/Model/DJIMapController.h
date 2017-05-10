//
//  DJIMapController.h
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/21.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DJIAircraftAnnotation.h"

@interface DJIMapController : NSObject
@property (strong, nonatomic) NSMutableArray *editPoints;
@property (strong, nonatomic) DJIAircraftAnnotation *aircraftAnnotation;

- (void)addPoint:(CGPoint)point withMapView:(MAMapView *)mapView;

- (void)cleanAllPointsWithMapView:(MAMapView *)mapView;

- (void)cleanAircraftWithMapView:(MAMapView *)mapView;

- (NSArray *)wayPoints;

- (void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MAMapView *)mapView;

- (void)updateAircraftHeading:(float)heading;
@end
