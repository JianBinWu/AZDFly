//
//  DJIMapController.m
//  GSDemo
//
//  Created by 吴剑斌 on 2017/4/21.
//  Copyright © 2017年 xmazd. All rights reserved.
//

#import "DJIMapController.h"

@implementation DJIMapController

- (instancetype)init{
    if (self = [super init]) {
        self.editPoints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addPoint:(CGPoint)point withMapView:(MAMapView *)mapView{
    CLLocationCoordinate2D coordinate = [mapView convertPoint:point toCoordinateFromView:mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [_editPoints addObject:location];
    MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
    annotation.coordinate = location.coordinate;
    [mapView addAnnotation:annotation];
}

- (void)cleanAllPointsWithMapView:(MKMapView *)mapView{
    [_editPoints removeAllObjects];
    NSArray *annos = [NSArray arrayWithArray:mapView.annotations];
    for (int i = 0; i < annos.count; i++) {
        id<MKAnnotation> ann = [annos objectAtIndex:i];
        if (!([ann isEqual:self.aircraftAnnotation] ||[ann isEqual:self.userLocationAnnotation])) {
            [mapView removeAnnotation:ann];
        }
    }
}

- (void)cleanAircraftWithMapView:(MAMapView *)mapView{
    if (self.aircraftAnnotation) {
        [mapView removeAnnotation:self.aircraftAnnotation];
        self.aircraftAnnotation = nil;
    }
}

- (NSArray *)wayPoints{
    return self.editPoints;
}

- (void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MAMapView *)mapView{
    if (self.aircraftAnnotation == nil) {
        self.aircraftAnnotation = [[AircraftAnnotation alloc] initWithCoordinate:location];
        [mapView addAnnotation:self.aircraftAnnotation];
    }
    
    [self.aircraftAnnotation setCoordinate:location];
}

- (void)updateAircraftHeading:(float)heading{
    if (self.aircraftAnnotation) {
        [self.aircraftAnnotation updateHeading:heading];
    }
}

@end
