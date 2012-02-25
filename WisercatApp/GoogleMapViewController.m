//
//  GoogleMapViewController.m
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 21.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import "GoogleMapViewController.h"
#import "MainScreenViewController.h"

@interface GoogleMapViewController () {
}
-(void)updateMapView;
@end
@implementation GoogleMapViewController
@synthesize mapView = _mapView;
@synthesize annotationsArray = _annotationsArray;
#pragma mark - Methods 
-(void)updateMapView {
    if (self.mapView.annotations) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    if(self.annotationsArray) {
        [self.mapView addAnnotations:self.annotationsArray];
    }
}

#pragma mark - System Stuff
-(void)setMapView:(MKMapView *)mapView {
    _mapView = mapView;
    [self updateMapView];
}

-(void)setAnnotationsArray:(NSArray *)annotationsArray {
    _annotationsArray = annotationsArray;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
