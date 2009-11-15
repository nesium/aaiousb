//
//  DeviceMonitor.h
//  iButton_Reader
//
//  Created by Marc Bauer on 14.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOKitLib.h>
#import <IOKit/IOMessage.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>
#import "AAUSBDevice.h"
#import "AAUSBInterface.h"
#import "AAUSBPipe.h"


@interface DeviceObserver : NSObject{
	uint16_t m_vendorId;
	uint16_t m_productId;
	IOUSBDeviceInterface **m_deviceInterface;
	NSDictionary *m_deviceProperties;
	io_service_t m_notification;
	BOOL m_deviceOnline;
}
@property (nonatomic, readonly) BOOL deviceOnline;
@property (nonatomic, readonly) IOUSBDeviceInterface **deviceInterface;
@property (nonatomic, readonly) NSDictionary *deviceProperties;
- (id)initWithVendorId:(uint16_t)vendorId productId:(uint16_t)productId;
- (void)startObserving;
@end