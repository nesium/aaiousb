//
//  DeviceMonitor.m
//  iButton_Reader
//
//  Created by Marc Bauer on 14.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "DeviceObserver.h"

@interface DeviceObserver (Private)
- (void)_deviceAdded:(io_iterator_t)deviceIterator;
- (void)_deviceNotification:(io_service_t)usbDevice messageType:(natural_t)messageType 
	messageArgument:(void *)messageArgument;
@end

static io_iterator_t g_deviceIterator;
static IONotificationPortRef g_notifyPort;

void DO_DeviceAdded(void *refCon, io_iterator_t iterator){
	[(DeviceObserver *)refCon _deviceAdded:iterator];
}

void DO_DeviceNotification(void *refCon, io_service_t service, natural_t messageType, 
	void *messageArgument){
	[(DeviceObserver *)refCon _deviceNotification:service messageType:messageType 
		messageArgument:messageArgument];
}



@implementation DeviceObserver

#pragma mark -
#pragma mark Properties

@synthesize deviceOnline=m_deviceOnline, 
			deviceInterface=m_deviceInterface, 
			deviceProperties=m_deviceProperties;



#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithVendorId:(uint16_t)vendorId productId:(uint16_t)productId{
	if (self = [super init]){
		m_vendorId = vendorId;
		m_productId = productId;
		m_deviceOnline = NO;
		m_deviceInterface = NULL;
		m_deviceProperties = nil;
	}
	return self;
}



#pragma mark -
#pragma mark Public methods

- (void)startObserving{
	NSMutableDictionary *matchingDict = (NSMutableDictionary *)IOServiceMatching(
		kIOUSBDeviceClassName);
	if (matchingDict == nil){
		NSLog(@"Could not create matching dict");
		return;
	}
	[matchingDict setObject:[NSNumber numberWithShort:m_vendorId] 
		forKey:(NSString *)CFSTR(kUSBVendorID)];
	[matchingDict setObject:[NSNumber numberWithShort:m_productId] 
		forKey:(NSString *)CFSTR(kUSBProductID)];
	
	g_notifyPort = IONotificationPortCreate(kIOMasterPortDefault);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(g_notifyPort), 
		kCFRunLoopDefaultMode);
	kern_return_t ret = IOServiceAddMatchingNotification(g_notifyPort, 
		kIOFirstMatchNotification, (CFDictionaryRef)matchingDict, DO_DeviceAdded, (void *)self, 
		&g_deviceIterator);
	if (ret != kIOReturnSuccess){
		NSLog(@"Could not setup IOService notification");
		return;
	}
	
	[self _deviceAdded:g_deviceIterator];
}



#pragma mark -
#pragma mark Private methods

- (void)_deviceAdded:(io_iterator_t)deviceIterator{
	io_service_t usbDeviceDesc;
	while (usbDeviceDesc = IOIteratorNext(deviceIterator)){	
		AAUSBDevice *usbDevice = [[AAUSBDevice alloc] initWithDeviceDescriptor:usbDeviceDesc];
		NSLog(@"%@", usbDevice);
		for (AAUSBInterface *interface in [usbDevice interfaces]){
			NSLog(@"%@", interface);
			for (AAUSBPipe *pipe in [interface pipes]){
				NSLog(@"%", pipe);
			}
		}
		
		
//		ret = IOServiceAddInterestNotification(g_notifyPort, usbDevice, kIOGeneralInterest, 
//			DO_DeviceNotification, (void *)self, &m_notification);
//		if (ret != kIOReturnSuccess){
//			NSLog(@"Could not add IOService interest notification");
//		}
	}
}

- (void)_deviceNotification:(io_service_t)usbDevice messageType:(natural_t)messageType 
	messageArgument:(void *)messageArgument{
	if (messageType != kIOMessageServiceIsTerminated)
		return;
	[self willChangeValueForKey:@"deviceOnline"];
	m_deviceOnline = NO;
	[self didChangeValueForKey:@"deviceOnline"];
	[m_deviceProperties release];
	m_deviceProperties = nil;
	(*m_deviceInterface)->Release(m_deviceInterface);
	IOObjectRelease(m_notification);
}
@end