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

@interface MainScreenViewController () <UITextFieldDelegate, CLLocationManagerDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, NSXMLParserDelegate> {
    CLLocationManager *loactionManager;
    
}
-(void)initiateURLConnection;
@property (nonatomic, strong) NSMutableArray *annotaionsArray;
@property (nonatomic, strong) CLLocationManager *locationMagaer;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLPlacemark *currentPlace;
@property (nonatomic, strong) NSMutableData *xmlData;
@property (nonatomic, strong) NSMutableString *timezoneString;
@property (nonatomic, strong) NSMutableString *localTimeString;
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
@synthesize localTimeString = _localTimeString;
@synthesize timezoneString = _timezoneString;


#pragma mark - Location Delegate 
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    NSString *loactionString = [NSString stringWithFormat:@"%@", self.currentLocation];
    self.locationLabel.text = loactionString;
    NSLog(@"%@", self.currentLocation);
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks){
            self.currentPlace = [[CLPlacemark alloc] initWithPlacemark:placemark];
            self.cityNameTextField.text = [self.currentPlace locality];
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
   
    [self initiateURLConnection];
    //self.cityNameTextField.text = [self.currentPlace locality];
}

- (IBAction)saveToMapButtonPressed:(id)sender {
    
    
    [self.coordinateDictionary setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.longitude] forKey:COORDINATE_LONGITUDE];
    [self.coordinateDictionary setObject:[NSNumber numberWithDouble:self.currentLocation.coordinate.latitude] forKey:COORDINATE_LATITUDE];
    [self.coordinateDictionary setValue:self.cityNameTextField.text forKey:COORDINATE_CITYNAME];
    [self.coordinateDictionary setValue:self.timezoneTextField.text forKey:COORDINATE_TIMEZONE];
    [self.coordinateDictionary setValue:self.localTimeTextField.text forKey:COORDINATE_LOCALTIME];
    self.annotaionsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *coordinates in self.coordinateDictionary) {
        [self.annotaionsArray addObject:[MapViewAnnotaion annotationForMapView:coordinates]];
    }
    
     [self.delegate mainScreenDidUpdateTheGpsCoordinates:self withAnnotaions:self.annotaionsArray];
}

#pragma mark NSURLConnectionDataDelegate

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *xmlString = [[NSString alloc] initWithData:self.xmlData encoding:NSUTF8StringEncoding];
    NSLog(@"incoming xml =  %@", xmlString);
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.xmlData];
    parser.delegate = self;
    [parser parse];
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

#pragma mark - NSXMLParserDelegate 
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"offset"]) {
        self.timezoneString= [[NSMutableString alloc] init];
    }
    if ([elementName isEqualToString:@"localtime"]) {
        self.localTimeString = [[NSMutableString alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"offset"]) {
        self.timezoneString= nil;
    }
    if ([elementName isEqualToString:@"localtime"]) {
        self.localTimeString = nil;
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.timezoneString != nil) {
        [self.timezoneString appendString:string];
        self.timezoneTextField.text = self.timezoneString;
        
    }
    if (self.localTimeString != nil) {
        [self.localTimeString appendString:string];
        self.localTimeTextField.text = self.localTimeString;
    }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"success on parsing");
}

#pragma mark - Methods 
-(void)initiateURLConnection{
    NSString *connectionLatitude = [[NSString alloc] initWithFormat:@"%g", self.currentLocation.coordinate.latitude];
    NSString *connectionLongitude = [[NSString alloc] initWithFormat:@"%g", self.currentLocation.coordinate.longitude];
    
    NSLog(@"latitude is %@", connectionLatitude);
    NSLog(@"longitude is %@", connectionLongitude);
    
    NSMutableString *connectionString = [NSMutableString stringWithFormat:@"http://www.earthtools.org/timezone/%@/%@", connectionLatitude, connectionLongitude];
    
    NSLog(@"connection string is %@", connectionString);
    NSURL *url = [NSURL URLWithString:connectionString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
    
}

#pragma mark - System Stuff
-(void)viewDidLoad {
    [super viewDidLoad];
    self.currentLocation = [[CLLocation alloc] init];
    self.cityNameTextField.delegate = self;
    self.localTimeTextField.delegate = self;
    self.timezoneTextField.delegate = self;
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
