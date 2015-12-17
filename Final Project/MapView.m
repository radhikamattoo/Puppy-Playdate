//  Puppy Playdate App
//  Mapview.m
//  by Kelly Wang
//
//  Map view for pins of current users using location services
//


#import "MapView.h"
#import <Parse/Parse.h>
#import "ListView.h"
#import "ProfileView.h"
@interface MapView () {
    BOOL otherUser;
    PFUser *userSelected;
}

@end

@implementation MapView
@synthesize mapView;
@synthesize usersCloseBy;
@synthesize locationManager;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    
    //allocate map view
    mapView.delegate = self;
    self.usersCloseBy = [[NSMutableArray alloc]init];
    self.locationManager = [[CLLocationManager alloc] init];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleGesture:)];
    tgr.numberOfTapsRequired = 2;
    tgr.numberOfTouchesRequired = 1;
    [mapView addGestureRecognizer:tgr];
    self.locationManager.delegate = self;
    
    // need this otherwise silent failure
    // can change to in use auth
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
    
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        NSLog(@"view did appear %@", [self deviceLocation]);
        MKCoordinateRegion region = { { 0.0, 0.0 }, { 0.0, 0.0 } };
        region.center.latitude = locationManager.location.coordinate.latitude;
        region.center.longitude = locationManager.location.coordinate.longitude;
        region.span.longitudeDelta = 0.015f;
        region.span.longitudeDelta = 0.015f;
        
        [self.mapView setRegion:region animated:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    // some initial setup
    otherUser = false;
    
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    NSLog(@"%@", [self deviceLocation]);
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //Update the user's position
    PFUser *curUser = [PFUser currentUser];
    curUser[@"position"] = [PFGeoPoint geoPointWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
    [curUser saveInBackground];
    
    
    //Query through the users and find the ones with close geopoints
    PFQuery *query = [PFUser query];
    [query whereKey:@"position" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude] withinMiles:5];
    query.limit = 100;
    NSArray *results = [query findObjects];
    [self.usersCloseBy removeAllObjects];
    
    //go through results and find all users
    for (PFUser * user in results) {
        if(![user.username isEqualToString:[PFUser currentUser].username])
        {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = ((PFGeoPoint*)user[@"position"]).latitude;
            coordinate.longitude = ((PFGeoPoint*)user[@"position"]).longitude;
            
            MKPointAnnotation *dogPoint = [[MKPointAnnotation alloc]init];
            dogPoint.coordinate = coordinate;
            dogPoint.title = user.username;
            dogPoint.subtitle = user[@"dogName"];
            [self.mapView addAnnotation:dogPoint];
            [self.usersCloseBy addObject:user];
        }
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //set up information
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure
                                                
                                                ];
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    //segue to profile view when tapped
    
    //get username
    MKPointAnnotation *selectedAnnotation = view.annotation;
    NSString *usernameSelected = selectedAnnotation.title;
    
    //find proper PFUser to segue to
    for (int i = 0; i < self.usersCloseBy.count; i++) {
        PFUser *thisUser = [self.usersCloseBy objectAtIndex:i];
        if ([thisUser.username isEqualToString:usernameSelected] ) {
            userSelected = thisUser;
            otherUser = true;
            [self performSegueWithIdentifier:@"toProfile" sender:self];
        }
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //segue to either list view or profile view
    
    if([[segue identifier] isEqualToString:@"toListView"]) {
        //Profile view is editable
        ListView *lV = (ListView*)[segue destinationViewController];
        
        //set the list view nearby users to the users that are close by
        lV.nearbyUsers = self.usersCloseBy;
        
    }else if([[segue identifier] isEqualToString:@"toProfile"]) {
        //someone else's profile?
        if (otherUser == true) {
            ProfileView *pV = (ProfileView*)[segue destinationViewController];
            pV.segueUser = userSelected;
            pV.notEditable = YES;
            
        }
        //or just own user's profile
        else {
            ProfileView *pV = (ProfileView*)[segue destinationViewController];
            pV.edit.hidden = NO;
        }
    }
}
 
//debugging method, prints long/lat
- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [mapView convertPoint:touchPoint toCoordinateFromView:mapView];
    
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    pa.title = @"Hello";
    [mapView addAnnotation:pa];
    
}

@end
