//
//  MapViewAnnotaions.m
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 22.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import "MapViewAnnotaion.h"
#import "MainScreenViewController.h"


@implementation MapViewAnnotaion

@synthesize coordinateDictionary = _coordinateDictionary;

+ (MapViewAnnotaion *)annotationForMapView:(NSDictionary *)coordinateDictionary {
    MapViewAnnotaion *annotataion = [[MapViewAnnotaion alloc] init];
    annotataion.coordinateDictionary = coordinateDictionary;
    return annotataion;
}

-(NSString *)title {
    NSString *titleForAnnotatation = [self.coordinateDictionary objectForKey:COORDINATE_CITYNAME];
    return titleForAnnotatation;
}

-(NSString *)subtitle {
    NSString *subtileForAnnotation = [self.coordinateDictionary objectForKey:COORDINATE_LOCALTIME];
    return subtileForAnnotation;
}

-(CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D coordinateForAnnotation; 
    coordinateForAnnotation.latitude = [[self.coordinateDictionary objectForKey:COORDINATE_LATITUDE] doubleValue];
    coordinateForAnnotation.longitude = [[self.coordinateDictionary valueForKey:COORDINATE_LONGITUDE]doubleValue];
    return coordinateForAnnotation;
}
@end
