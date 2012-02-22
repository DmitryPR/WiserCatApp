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

@interface MainScreenViewController () <UITextFieldDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    CLLocationManager *loactionManager;
    
}
-(void)initiateURLConnection;
@property (nonatomic, strong) NSMutableArray *annotaionsArray;
@property (nonatomic, strong) CLLocationManager *locationMagaer;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLPlacemark *currentPlace;
@property (nonatomic, strong) NSMutableData *xmlData;
@end

@implementation MainScreenViewController
@synthesize cityNameTextField = _cityNameTextField;
@synthesize timezoneTextField = _timezoneTextField;
@synthesize localTimeTextField = _localTimeTextField;
@synthesize delegate = _delegate;
@synthesize coordinateDictionary = _coordinateDictionary;
@synthesize annotaionsArray = _annotaionsArray;
@synthesize locationMagaer = _locationMagaer;
@synthesize currentLocation = _currentLocation;
@synthesize locationLabel = _locationLabel;
@synthesize currentPlace = _currentPlace;
@synthesize xmlData = _xmlData;



#pragma mark - Location Delegate 
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    NSString *loactionString = [NSString stringWithFormat:@"%@", self.currentLocation];
    self.locationLabel.text = loactionString;
    NSLog(@"%@", self.currentLocation);
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks){
            self.currentPlace = placemark;
        }
        
    }];
    
    
}

#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
   //TODO do something when the editing is finished
}

#pragma mark - IBActions

- (IBAction)gpsCoordinatesButtonPressed:(id)sender {
    self.cityNameTextField.text = [self.currentPlace locality];
    [self initiateURLConnection];
    [self.coordinateDictionary setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.longitude] forKey:COORDINATE_LONGITUDE];
    [self.coordinateDictionary setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.latitude] forKey:COORDINATE_LATITUDE];
    [self.coordinateDictionary setValue:self.cityNameTextField.text forKey:COORDINATE_CITYNAME];
    [self.coordinateDictionary setValue:self.timezoneTextField.text forKey:COORDINATE_TIMEZONE];
    [self.coordinateDictionary setValue:self.localTimeTextField.text forKey:COORDINATE_LOCALTIME];
    NSMutableArray *annotations = [[NSMutableArray alloc] init];
    for (NSDictionary *coordinates in self.coordinateDictionary) {
        [annotations addObject:[MapViewAnnotaion annotationForMapView:coordinates]];
    }
    self.annotaionsArray = annotations;
    [self.delegate mainScreenDidUpdateTheGpsCoordinates:self withAnnotaions:self.annotaionsArray];
    
}

#pragma mark NSURLConnectionDataDelegate

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *xmlString = [[NSString alloc] initWithData:self.xmlData encoding:NSUTF8StringEncoding];
    NSLog(@"incoming xml =  %@", xmlString);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
  //TODO something to see the response if we need it
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    //Append the incoming data
    self.xmlData = [[NSMutableData alloc] init];
    [self.xmlData appendData:data];
}

#pragma mark NSURLConnectionDelegate 

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed");
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"Connection is set");
    
}

#pragma mark - Methods 
-(void)initiateURLConnection{
    NSString *connectionLatitude = [[NSString alloc] initWithFormat:@"%d", [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude]];
    NSString *connectionLongitude = [[NSString alloc] initWithFormat:@"%d", [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude]];

    NSMutableString *connectionString = [NSMutableString stringWithFormat:@"http://www.earthtools.org/timezone/%@/%@", connectionLatitude, connectionLongitude];
    NSURL *url = [NSURL URLWithString:connectionString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
}

#pragma mark - System Stuff
-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.cityNameTextField.delegate = self;
    self.localTimeTextField.delegate = self;
    self.timezoneTextField.delegate = self;
    self.annotaionsArray = [[NSMutableArray alloc] init];
    self.coordinateDictionary = [[NSMutableDictionary alloc] init];
    self.locationMagaer = [[CLLocationManager alloc] init];
    [self.locationMagaer setDistanceFilter:kCLDistanceFilterNone];
    [self.locationMagaer setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationMagaer startUpdatingLocation];
    [self.locationMagaer setDelegate:self];
   
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
    [self.locationMagaer stopUpdatingLocation];
}

@end
