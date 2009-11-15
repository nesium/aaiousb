//
//  AAUSBDevice.h
//  iButton_Reader
//
//  Created by Marc Bauer on 15.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>
#import "AAUSBInterface.h"


@interface AAUSBDevice : NSObject{
	io_service_t m_deviceDesc;
	IOUSBDeviceInterface **m_device;
	SInt16 m_numConfigurations;
	BOOL m_deviceOpen;
	BOOL m_exclusiveAccess;
	NSArray *m_interfaces;
}
- (id)initWithDeviceDescriptor:(io_service_t)desc;
- (UInt8)numberOfConfigurations;
- (BOOL)setConfiguration:(UInt8)configNum;

- (BOOL)startExclusiveAccess;
- (BOOL)stopExclusiveAccess;

- (BOOL)open;
- (BOOL)close;
- (BOOL)reset;

- (NSString *)deviceName;
- (UInt8)deviceClass;
- (UInt8)deviceSubClass;
- (UInt16)vendorId;
- (UInt16)productId;
- (UInt32)locationId;
- (UInt8)protocol;
- (UInt16)releaseNumber;
- (UInt8)speed;
- (UInt32)busPowerAvailable;
- (USBDeviceAddress)address;

- (NSUInteger)numberOfInterfaces;
- (NSArray *)interfaces;

// GetBusFrameNumber
// DeviceRequestAsync
// DeviceRequest
// CreateDeviceAsyncPort
// CreateDeviceAsyncEventSource
// GetConfiguration
@end