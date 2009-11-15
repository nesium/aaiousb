//
//  AAUSBDeviceInterface.h
//  iButton_Reader
//
//  Created by Marc Bauer on 15.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/IOCFPlugIn.h>
#import <IOKit/usb/IOUSBLib.h>
#import "AAUSBPipe.h"

@class AAUSBDevice;

@interface AAUSBInterface : NSObject{
	AAUSBDevice *m_device;
	io_service_t m_interfaceDesc;
	IOUSBInterfaceInterface **m_interface;
	BOOL m_interfaceOpen;
	BOOL m_exclusiveAccess;
	NSArray *m_pipes;
}
- (id)initWithInterfaceDesc:(io_service_t)interfaceDesc parentDevice:(AAUSBDevice *)device;

- (BOOL)startExclusiveAccess;
- (BOOL)stopExclusiveAccess;

- (BOOL)open;
- (BOOL)close;

- (AAUSBDevice *)device;
- (UInt8)interfaceClass;
- (UInt8)interfaceSubClass;
- (UInt8)interfaceNumber;
- (UInt8)protocol;
- (UInt32)locationId;
- (UInt8)numberOfEndpoints;
- (NSArray *)pipes;

// AbortPipe
// ClearPipeStall
// ControlRequest
// ControlRequestAsync
// CreateInterfaceAsyncEventSource
// CreateInterfaceAsyncPort
// GetAlternateSetting
// GetBusFrameNumber
// GetConfigurationValue
// GetInterfaceAsyncEventSource
// GetInterfaceAsyncPort
@end