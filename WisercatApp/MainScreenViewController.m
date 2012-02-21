//
//  MainScreenViewController.m
//  WisercatApp
//
//  Created by Dmitry Preobrazhenskiy on 21.02.12.
//  Copyright (c) 2012 TTU. All rights reserved.
//

#import "MainScreenViewController.h"
#import "GoogleMapViewController.h"
#import "MapViewAnnotaion.h"
#import <MapKit/MapKit.h>

@interface MainScreenViewController () <UITextFieldDelegate> {
    
}
@property (nonatomic, strong) NSMutableArray *annotaionsArray;
@end

@implementation MainScreenViewController
@synthesize cityNameTextField = _cityNameTextField;
@synthesize timezoneTextField = _timezoneTextField;
@synthesize localTimeTextField = _localTimeTextField;
@synthesize delegate = _delegate;
@synthesize coordinateDictionary = _coordinateDictionary;
@synthesize annotaionsArray = _annotaionsArray;


#pragma mark - Text Field Delegate

-(void)textFieldDidEndEditing:(UITextField *)textField {
   
    [self resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)gpsCoordinatesButtonPressed:(id)sender {
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (NSDictionary *coordinates in self.coordinateDictionary) {
        [annotations addObject:[MapViewAnnotaion annotationForMapView:coordinates]];
    }
    self.annotaionsArray = annotations;
    [self.delegate mainScreenDidUpdateTheGpsCoordinates:self withAnnotaions:self.annotaionsArray];
    
}

#pragma mark - System Stuff
-(void)viewDidLoad {
    [super viewDidLoad];
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"ShowGoogleMap"]) {
        self.delegate = segue.destinationViewController;
        if ([segue.destinationViewController respondsToSelector:@selector(setAnnotationsArray:)]) {
            [segue.destinationViewController setAnnotationsArray:self.annotaionsArray];
        }
    }
}
- (void)viewDidUnload {
    [self setCityNameTextField:nil];
    [self setTimezoneTextField:nil];
    [self setLocalTimeTextField:nil];
    [super viewDidUnload];
}

@end
