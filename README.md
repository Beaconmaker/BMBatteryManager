# BMBatteryManager

## Requirements

## Installation

BMBeaconManager is available on the Beaconmaker Github account. To install
it, simply add the following line to your Podfile:

```ruby
pod "BMBatteryManager", :git => 'https://github.com/Beaconmaker/BMBatteryManager.git'
```
## Usage

1. Add ```#import "BMBatteryManager"``` to AppDelegate.m
2. Add the following 2 lines to applicationDidBecomeActive in AppDelegate.m
```
# Init BMBatteryManager
[[BMBatteryManager sharedManager] setApiKey:@"<<YOUR_KONTAKT_API_KEY>>"];
[[BMBatteryManager sharedManager] startUpdatingWithInterval:30];
``` 

3. Add the following to applicationWillResignActive in AppDelegate.m
```
[[BMBatteryManager sharedManager] stopUpdating];
``` 

## Author

John Kueh, john@beaconmaker.com

## License

BMBatteryManager is available under the MIT license. See the LICENSE file for more info.
