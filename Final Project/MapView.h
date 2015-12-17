//  Puppy Playdate App
//  Mapview.h
//  by Kelly Wang
//
//  Map view for pins of current users using location services
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <Parse/Parse.h>

@interface MapView : UIViewController <MKMapViewDelegate,  CLLocationManagerDelegate>

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSMutableArray *usersCloseBy;

@end
