//
//  BMBatteryManager.m
//  Battery
//
//  Created by John Kueh on 19/01/2016.
//  Copyright © 2016 Beaconmaker. All rights reserved.
//

#import "BMBatteryManager.h"
#import "KontaktSDK.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"


@interface BMBatteryManager () <KTKBluetoothManagerDelegate>
@property (assign, nonatomic) NSString *apiKey;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSTimeInterval interval;
@property (assign, nonatomic) NSTimeInterval scanInterval;

@property (strong, nonatomic) KTKClient *kontaktClient;
@property (strong, nonatomic) KTKBluetoothManager *bluetoothManager;
@property (strong, nonatomic) NSMutableArray *devices;
@property (strong, nonatomic) NSMutableSet *deviceIds;
@end

@implementation BMBatteryManager
+ (BMBatteryManager *)sharedManager {
    static dispatch_once_t onceToken;
    static BMBatteryManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[BMBatteryManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    if (self) {
        self.bluetoothManager = [KTKBluetoothManager new];
        self.bluetoothManager.delegate = self;
        
        self.kontaktClient = [KTKClient new];
        
        self.devices = [NSMutableArray new];
        self.deviceIds = [NSMutableSet new];
        self.scanInterval = 30; // How long to scan for before reporting
    }
    return self;
}

- (void)dealloc {
    [self.timer invalidate];
}

- (void)startUpdatingWithInterval:(NSTimeInterval)interval {
    [self.bluetoothManager startFindingDevices];
    NSLog(@"<-- startFindingDevices");
    self.interval = interval;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.scanInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateBatteryForBeaconDevices];
    });
    //    [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(updateBatteryForBeaconDevices) userInfo:nil repeats:YES];
}

- (void)stopUpdating {
    [self.bluetoothManager stopFindingDevices];
    [self.timer invalidate];
    NSLog(@"<-- stopUpdating");
}

- (void)setApiKey:(NSString *)apiKey {
    self.kontaktClient.apiKey = apiKey;
}

#pragma mark - KTKBluetoothManager delegate methods
- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didChangeDevices:(NSSet *)devices {
    
    self.deviceIds = [NSMutableSet new];
    for (KTKBeaconDevice *oldDevice in self.devices) {
        [self.deviceIds addObject:oldDevice.uniqueID];
    }
    
    for (KTKBeaconDevice *newDevice in devices) {
        if (![self.deviceIds containsObject:newDevice.uniqueID]) {
            [self.devices addObject:newDevice];
        }
    }
}

- (void)updateBatteryForBeaconDevices {
    NSLog(@"<-- updateBatteryForBeaconDevices: %@ devices", @(self.devices.count));
    dispatch_group_t dataGroup = dispatch_group_create();
    
    for (KTKBeaconDevice *beaconDevice in self.devices) {
        dispatch_group_enter(dataGroup);
        [self updateBatteryForBeaconDevice:beaconDevice withCompletion:^{
            dispatch_group_leave(dataGroup);
        }];
    }
    
    dispatch_group_notify(dataGroup, dispatch_get_main_queue(), ^{
        NSLog(@"<-- finishedUpdatingAllBatteries");
        [self.devices removeAllObjects];
        self.bluetoothManager.stopFindingDevices;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startUpdatingWithInterval:self.interval];
        });
        
        NSLog(@"%@ devices stored", @(self.devices.count));
    });
}

- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didChangeEddystones:(NSSet *)eddystones {
}

- (void)updateBatteryForBeaconDevice:(KTKBeaconDevice *)beaconDevice withCompletion:(void (^)())completion {
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.kontakt.io/device/update?uniqueId=%@&deviceType=beacon&metadata=batteryLevel:%@", beaconDevice.uniqueID, @(beaconDevice.batteryLevel)];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = @YES;
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [manager.requestSerializer setValue:@"pUXInVBGYjogDWAWSYlZjKsrxzdXsKBF" forHTTPHeaderField:@"Api-Key"];
    [manager.requestSerializer setValue:@"application/vnd.com.kontakt+json;version=6" forHTTPHeaderField:@"Accept"];
    
    [manager POST:urlString parameters:nil constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        completion();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion();
    }];
    
}
@end
