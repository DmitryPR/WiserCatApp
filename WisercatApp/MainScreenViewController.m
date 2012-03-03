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
#import "Reachability.h"

@interface MainScreenViewController () <UITextFieldDelegate, 
CLLocationManagerDelegate, 
NSURLConnectionDataDelegate, 
NSURLConnectionDelegate, 
NSXMLParserDelegate> {
    CLLocationManager *locationManager;
    BOOL isUpdatingLocatons;
    Reachability *internetReachability;
    Reachability *hostReachability;
    BOOL isInternetActive;
    BOOL isHostReachable;
    
}
//Two methods needed for the parsing and notifying
-(void)checkNetworkStatus:(NSNotification *)notification;
-(void)initiateURLConnection;
-(void)processTheParsedInformation:(NSNotification *)notification;
@property (nonatomic, strong) NSMutableArray *annotaionsArray;
@property (nonatomic, strong) CLLocationManager *locationMagaer;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLPlacemark *currentPlace;
@property (nonatomic, strong) NSMutableData *xmlData;
@property (nonatomic, strong) NSMutableString *timezoneString;
@property (nonatomic, strong) NSMutableString *localTimeString;
@property (nonatomic) BOOL isUpdatingLocations;
@property (nonatomic, strong) Reachability *internetReachibility;
@property (nonatomic, strong) Reachability *hostReachability;
@property (nonatomic) BOOL isInternetActive;
@property (nonatomic) BOOL isHostReachable;
@end
@implementation MainScreenViewController
@synthesize cityNameTextField = _cityNameTextField;
@synthesize timezoneTextField = _timezoneTextField;
@synthesize localTimeTextField = _localTimeTextField;
@synthesize coordinateDictionary = _coordinateDictionary;
@synthesize annotaionsArray = _annotaionsArray;
@synthesize locationMagaer = _locationMagaer;
@synthesize currentLocation = _currentLocation;
@synthesize locationLabel = _locationLabel;
@synthesize currentPlace = _currentPlace;
@synthesize xmlData = _xmlData;
@synthesize localTimeString = _localTimeString;
@synthesize timezoneString = _timezoneString;
@synthesize isUpdatingLocations = _isUpdatingLocations;
@synthesize internetReachibility = _internetReachibility;
@synthesize hostReachability = _hostReachability;
@synthesize isInternetActive = _isInternetActive;
@synthesize isHostReachable = _isHostReachable;
#pragma mark - Location Delegate 
//Making a new loactionManager here which allows to reverse the geocode in order to get the required information
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    
    //For testing added the information to the label bellow
    NSString *locationString = [NSString stringWithFormat:@"%@", self.currentLocation];
    self.locationLabel.text = locationString;
     NSLog(@"%@", self.currentLocation);
    //
    
   
    CLGeocoder *geoCoder = [CLGeocoder new];
    [geoCoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks){
            //Get the current placemark to get the locality after
            self.currentPlace = [[CLPlacemark alloc] initWithPlacemark:placemark];
        }
    }];
    [self.locationMagaer stopUpdatingLocation];
     
}

#pragma mark - Text Field Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    //Text field keyboard hiding after the user presses done.
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - IBActions

- (IBAction)gpsCoordinatesButtonPressed:(id)sender {
    if (!self.isUpdatingLocations) {
        [self.locationMagaer startUpdatingLocation];
    }
    //Adding some time here for a better result.
    if (!self.isInternetActive) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"The Internet connection is down. Please try again later..." delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    else {
        [self performSelector:@selector(initiateURLConnection) withObject:nil afterDelay:0.5];
    }
    
}

- (IBAction)saveToMapButtonPressed:(id)sender {
    //Dictionary of the current location for annotations.
    NSMutableDictionary *savedDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                            [NSNumber numberWithDouble:self.currentLocation.coordinate.longitude], 
                                            COORDINATE_LONGITUDE, 
                                            [NSNumber numberWithDouble:self.currentLocation.coordinate.latitude],
                                            COORDINATE_LATITUDE, 
                                            self.cityNameTextField.text, 
                                            COORDINATE_CITYNAME, 
                                            self.timezoneTextField.text, 
                                            COORDINATE_TIMEZONE, 
                                            self.localTimeTextField.text, 
                                            COORDINATE_LOCALTIME, nil];
    self.coordinateDictionary = savedDictionary;
    [self.annotaionsArray addObject:[MapViewAnnotaion annotationForMapView:self.coordinateDictionary]];
}

- (IBAction)clearTheMapButtonPressed:(id)sender {
    self.coordinateDictionary = nil;
    self.annotaionsArray = [[NSMutableArray alloc] init];
    self.cityNameTextField.text = @"";
    self.localTimeTextField.text = @"";
    self.timezoneTextField.text = @"";
    
}

#pragma mark NSURLConnectionDataDelegate

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *xmlString = [[NSString alloc] initWithData:self.xmlData encoding:NSUTF8StringEncoding];
    
    //For testing logging the incoming xml
    NSLog(@"incoming xml =  %@", xmlString);
    //
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.xmlData];
    parser.delegate = self;
    [parser parse];
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
        //When the required is found we initialize a new string
         self.timezoneString= [[NSMutableString alloc] init];
    }
    else if ([elementName isEqualToString:@"localtime"]) {
        self.localTimeString = [[NSMutableString alloc] init];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    //checking if the string if not nil and appending the information to it and to the text field
    if (self.timezoneString != nil) {
        [self.timezoneString appendString:string];
         self.timezoneTextField.text = self.timezoneString;
    }
    else if (self.localTimeString != nil) {
        [self.localTimeString appendString:string];
        self.localTimeTextField.text = self.localTimeString;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //String to nil in order to clear it
    if ([elementName isEqualToString:@"offset"]) {
         self.timezoneString= nil;
    }
    
    else if ([elementName isEqualToString:@"localtime"]) {
         self.localTimeString = nil; 
    }
}
-(void)parserDidEndDocument:(NSXMLParser *)parser {
   //Additional notification that the parsing was successfully finished
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ParsingDidSucceed" object:self];
  
}

#pragma mark - Methods 
-(void)initiateURLConnection{
  
    NSString *connectionLatitude = [[NSString alloc] initWithFormat:@"%g", self.currentLocation.coordinate.latitude];
    NSString *connectionLongitude = [[NSString alloc] initWithFormat:@"%g", self.currentLocation.coordinate.longitude];
    
    //Testing the outgoing data
    NSLog(@"latitude is %@", connectionLatitude);
    NSLog(@"longitude is %@", connectionLongitude);
    //
    
    NSMutableString *connectionString = [NSMutableString stringWithFormat:@"http://www.earthtools.org/timezone/%@/%@", connectionLatitude, connectionLongitude];
    
    //Logging the string to see that it is correct
    NSLog(@"connection string is %@", connectionString);
    //
    
    NSURL *url = [NSURL URLWithString:connectionString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark - Notifications
-(void)checkNetworkStatus:(NSNotification *)notification {
    {
        // called after network status changes
        NetworkStatus internetStatus = [self.internetReachibility currentReachabilityStatus];
        switch (internetStatus)
        {
            case NotReachable:
            {
                NSLog(@"The internet is down.");
                self.isInternetActive = NO;
                
                break;
            }
            case ReachableViaWiFi:
            {
                NSLog(@"The internet is working via WIFI.");
                self.isInternetActive = YES;
                
                break;
            }
            case ReachableViaWWAN:
            {
                NSLog(@"The internet is working via WWAN.");
                self.isInternetActive = YES;
                
                break;
            }
    }
        NetworkStatus hostStatus = [self.hostReachability currentReachabilityStatus];
        switch (hostStatus)
        {
            case NotReachable:
            {
                NSLog(@"A gateway to the host server is down.");
                self.isHostReachable = NO;
                
                break;
            }
            case ReachableViaWiFi:
            {
                NSLog(@"A gateway to the host server is working via WIFI.");
                self.isHostReachable = YES;
                
                break;
            }
            case ReachableViaWWAN:
            {
                NSLog(@"A gateway to the host server is working via WWAN.");
                self.isHostReachable = YES;
                break;
            }
        }
    }
}

-(void)processTheParsedInformation:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"ParsingDidSucceed"]) {
        NSString *currentCityName = [self.currentPlace locality];
        self.cityNameTextField.text = currentCityName;
        
    }
}
#pragma mark - System Stuff
-(void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(processTheParsedInformation:) name:@"ParsingDidSucceed" object:nil];
    self.coordinateDictionary = [[NSMutableDictionary alloc] init];
    self.annotaionsArray = [[NSMutableArray alloc] init];
    self.currentLocation = [[CLLocation alloc] init];
    self.cityNameTextField.delegate = self;
    self.localTimeTextField.delegate = self;
    self.timezoneTextField.delegate = self;
    self.locationMagaer = [[CLLocationManager alloc] init];
    [self.locationMagaer setDistanceFilter:kCLDistanceFilterNone];
    [self.locationMagaer setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationMagaer setDelegate:self];
    [self.locationMagaer startUpdatingLocation];
    self.isUpdatingLocations = NO;
   
    
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    self.internetReachibility = [Reachability reachabilityForInternetConnection];
    [self.internetReachibility startNotifier];
    
    // check if a pathway to a random host exists
    self.hostReachability = [Reachability reachabilityWithHostName:@"www.earthtools.org"];
    [self.hostReachability startNotifier];
}

-(void)viewWillDisappear:(BOOL)animated {
      [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier hasPrefix:@"ShowGoogleMap"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setAnnotationsArray:)]) {
            [segue.destinationViewController setAnnotationsArray:self.annotaionsArray];
        }
    }
}
- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self setCityNameTextField:nil];
    [self setTimezoneTextField:nil];
    [self setLocalTimeTextField:nil];
    [super viewDidUnload];
    [self.locationMagaer stopUpdatingLocation];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
