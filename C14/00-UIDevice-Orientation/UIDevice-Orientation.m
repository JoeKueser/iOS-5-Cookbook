/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 5.0 Edition
 BSD License, Use at your own risk
 */

// Thanks jweinberg, Emanuele Vulcano, rincewind42, Jonah Williams

#import "UIDevice-Orientation.h"

@implementation UIDevice (Orientation)
#pragma mark current angle
float device_angle;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	float xx = acceleration.x;
	float yy = -acceleration.y;
	device_angle = M_PI / 2.0f - atan2(yy, xx);
    
    if (device_angle > M_PI)
        device_angle -= 2 * M_PI;
	
	CFRunLoopStop(CFRunLoopGetCurrent());
}

- (float) orientationAngle
{
#if TARGET_IPHONE_SIMULATOR
	switch (self.orientation)
	{
		case UIDeviceOrientationPortrait: 
			return 0.0f;
		case UIDeviceOrientationPortraitUpsideDown:
			return M_PI;
		case UIDeviceOrientationLandscapeLeft: 
			return -(M_PI/2.0f);
		case UIDeviceOrientationLandscapeRight: 
			return (M_PI/2.0f);
		default:
			return 0.0f;
	}
#else
    // supercede current delegate
	id priorDelegate = [UIAccelerometer sharedAccelerometer].delegate;
	[UIAccelerometer sharedAccelerometer].delegate = self;
	
	// Wait for a reading
	CFRunLoopRun();
    
    // restore delgate
	[UIAccelerometer sharedAccelerometer].delegate = priorDelegate;
	
	return device_angle;
#endif
}

#pragma mark relative orientation

// Thanks Jonah Williams
- (float) orientationAngleRelativeToOrientation:(UIDeviceOrientation) someOrientation
{
 	float dOrientation = 0.0f;
	switch (someOrientation)
	{
		case UIDeviceOrientationPortraitUpsideDown: {dOrientation = M_PI; break;}
		case UIDeviceOrientationLandscapeLeft: {dOrientation = -(M_PI/2.0f); break;}
		case UIDeviceOrientationLandscapeRight: {dOrientation = (M_PI/2.0f); break;}
		default: break;
	}
	
	float adjustedAngle = fmod(self.orientationAngle - dOrientation, 2.0f * M_PI);
	if (adjustedAngle > (M_PI + 0.01f)) 
        adjustedAngle = (adjustedAngle - 2.0f * M_PI);
	return adjustedAngle;
}

#pragma mark basic orientation

- (BOOL) isLandscape
{
	return UIDeviceOrientationIsLandscape(self.orientation);
}

- (BOOL) isPortrait
{
	return UIDeviceOrientationIsPortrait(self.orientation);
}

- (NSString *) orientationString
{
	switch ([[UIDevice currentDevice] orientation])
	{
		case UIDeviceOrientationUnknown: return @"Unknown";
		case UIDeviceOrientationPortrait: return @"Portrait";
		case UIDeviceOrientationPortraitUpsideDown: return @"Portrait Upside Down";
		case UIDeviceOrientationLandscapeLeft: return @"Landscape Left";
		case UIDeviceOrientationLandscapeRight: return @"Landscape Right";
		case UIDeviceOrientationFaceUp: return @"Face Up";
		case UIDeviceOrientationFaceDown: return @"Face Down";
		default: break;
	}
	return nil;
}
@end