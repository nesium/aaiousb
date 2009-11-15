//
//  AAUSBDevice.m
//  iButton_Reader
//
//  Created by Marc Bauer on 15.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AAUSBDevice.h"

@interface AAUSBDevice (Private)
- (void)_fetchInterfaces;
@end


@implementation AAUSBDevice

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithDeviceDescriptor:(io_service_t)desc{
	if (self = [super init]){
		m_deviceDesc = desc;
		m_deviceOpen = NO;
		m_numConfigurations = -1;
		m_exclusiveAccess = NO;
		m_interfaces = nil;
		
		IOCFPlugInInterface **plugInInterface = NULL;
		SInt32 score;
		HRESULT result;
		kern_return_t err = IOCreatePlugInInterfaceForService(m_deviceDesc, 
			kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
		if (err || !plugInInterface){
			// @TODO improve error handling
			NSLog(@"Could not create plugin interface");
		}
		
		result = (*plugInInterface)->QueryInterface(plugInInterface, 
			CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID *)&m_device);
		(*plugInInterface)->Release(plugInInterface);
		if (err || !m_device){
			// @TODO improve error handling
			NSLog(@"Could not create device interface");
		}
	}
	return self;
}

- (void)dealloc{
	[self close];
	[m_interfaces release];
	IOObjectRelease(m_deviceDesc);
	(*m_device)->Release(m_device);
	[super dealloc];
}



#pragma mark -
#pragma mark Public methods

- (BOOL)startExclusiveAccess{
	if (m_exclusiveAccess) return YES;
	m_exclusiveAccess = [self open];
	return m_exclusiveAccess;
}

- (BOOL)stopExclusiveAccess{
	if (!m_exclusiveAccess) return YES;
	m_exclusiveAccess = NO;
	return [self close];
}

- (UInt8)numberOfConfigurations{
	if (m_numConfigurations != -1)
		return m_numConfigurations;
	IOReturn err;
	UInt8 numConf;
	err = (*m_device)->GetNumberOfConfigurations(m_device, &numConf);
	if (err){
		NSLog(@"Could not obtain number of configurations");
		m_numConfigurations = -1;
	}else{
		m_numConfigurations = numConf;
	}
	return numConf;
}

- (BOOL)setConfiguration:(UInt8)configNum{
	if (configNum > [self numberOfConfigurations]){
		NSLog(@"Config num is out of bounds");
		return NO;
	}
	BOOL success = YES;
	if ([self open]){
		IOReturn err;
		IOUSBConfigurationDescriptorPtr confDesc;
		err = (*m_device)->GetConfigurationDescriptorPtr(m_device, configNum, &confDesc);
		if (err){
			NSLog(@"Could not obtain configuration descriptor");
			success = NO;
		}else{
			err = (*m_device)->SetConfiguration(m_device, confDesc->bConfigurationValue);
			if (err){
				NSLog(@"Could not set configuration");
				success = NO;
			}
		}
	}else success = NO;
	[self close];
	return success;
}

- (BOOL)open{
	if (m_deviceOpen)
		return YES;
	IOReturn err;
	err = (*m_device)->USBDeviceOpen(m_device);
	if (err){
		NSLog(@"Could not open device");
		return NO;
	}
	m_deviceOpen = YES;
	return YES;
}

- (BOOL)close{
	if (!m_deviceOpen || m_exclusiveAccess)
		return YES;
	IOReturn err;
	err = (*m_device)->USBDeviceClose(m_device);
	if (err){
		NSLog(@"Closing device failed. Connection may no longer be valid");
		return NO;
	}
	m_deviceOpen = NO;
	return YES;
}

- (BOOL)reset{
	if ([self open]){
		IOReturn err = (*m_device)->ResetDevice(m_device);
		if (err){
			NSLog(@"Could not reset device");
			return NO;
		}else{
			// @TODO Update cached device descriptor
			// @SEE IOUSBDeviceInterface::ResetDevice
			return YES;
		}
	}else return NO;
}

- (NSString *)deviceName{
	kern_return_t err;
	io_name_t deviceName;
	NSString *deviceNameStr;
	err = IORegistryEntryGetName(m_deviceDesc, deviceName);
	if (err) deviceName[0] = '\0';
	deviceNameStr = (NSString *)CFStringCreateWithCString(kCFAllocatorDefault, deviceName, 
		kCFStringEncodingASCII);
	return [deviceNameStr autorelease];
}

- (UInt8)deviceClass{
	IOReturn err;
	UInt8 devClass;
	err = (*m_device)->GetDeviceClass(m_device, &devClass);
	if (err) NSLog(@"Could not obtain device class");
	return devClass;
}

- (UInt8)deviceSubClass{
	IOReturn err;
	UInt8 devSubClass;
	err = (*m_device)->GetDeviceSubClass(m_device, &devSubClass);
	if (err) NSLog(@"Could not obtain device subclass");
	return devSubClass;
}

- (UInt16)vendorId{
	IOReturn err;
	UInt16 devVendor;
	err = (*m_device)->GetDeviceVendor(m_device, &devVendor);
	if (err) NSLog(@"Could not obtain device vendor");
	return devVendor;
}

- (UInt16)productId{
	IOReturn err;
	UInt16 devProduct;
	err = (*m_device)->GetDeviceProduct(m_device, &devProduct);
	if (err) NSLog(@"Could not obtain device product");
	return devProduct;
}

- (UInt32)locationId{
	IOReturn err;
	UInt32 locationId;
	err = (*m_device)->GetLocationID(m_device, &locationId);
	if (err) NSLog(@"Could not obtain location id");
	return locationId;
}

- (UInt8)protocol{
	IOReturn err;
	UInt8 devProtocol;
	err = (*m_device)->GetDeviceProtocol(m_device, &devProtocol);
	if (err) NSLog(@"Could not obtain device protocol");
	return devProtocol;
}

- (UInt16)releaseNumber{
	IOReturn err;
	UInt16 devRelNum;
	err = (*m_device)->GetDeviceReleaseNumber(m_device, &devRelNum);
	if (err) NSLog(@"Could not obtain device release number");
	return devRelNum;
}

- (UInt8)speed{
	IOReturn err;
	UInt8 devSpeed;
	err = (*m_device)->GetDeviceSpeed(m_device, &devSpeed);
	if (err) NSLog(@"Could not obtain device speed");
	return devSpeed;
}

- (UInt32)busPowerAvailable{
	IOReturn err;
	UInt32 powerAvailable;
	err = (*m_device)->GetDeviceBusPowerAvailable(m_device, &powerAvailable);
	if (err) NSLog(@"Could not obtain device bus power available");
	return powerAvailable;
}

- (USBDeviceAddress)address{
	IOReturn err;
	USBDeviceAddress addr;
	err = (*m_device)->GetDeviceAddress(m_device, &addr);
	if (err) NSLog(@"Could not obtain device address");
	return addr;
}

- (NSUInteger)numberOfInterfaces{
	if (!m_interfaces) [self _fetchInterfaces];
	return [m_interfaces count];
}

- (NSArray *)interfaces{
	if (!m_interfaces) [self _fetchInterfaces];
	return m_interfaces;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | name: %@ vendor: 0x%04x product: 0x%04x release: 0x%04x numConfigurations: %d>", 
		[self class], (long)self, [self deviceName], [self vendorId], [self productId], 
		[self releaseNumber], [self numberOfConfigurations]];
}



#pragma mark -
#pragma mark Private methods

- (void)_fetchInterfaces{
	NSLog(@"_fetchInterfaces");
	IOReturn err;
	IOUSBFindInterfaceRequest request;
	io_iterator_t iterator;
	io_service_t interfaceDesc;
	NSMutableArray *foundInterfaces = [NSMutableArray array];
	
	request.bInterfaceClass = kIOUSBFindInterfaceDontCare;
	request.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;
	request.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;
	request.bAlternateSetting = kIOUSBFindInterfaceDontCare;
	
	err = (*m_device)->CreateInterfaceIterator(m_device, &request, &iterator);
	if (err) NSLog(@"Could not create interface iterator");
	while (interfaceDesc = IOIteratorNext(iterator)){
		NSLog(@"found interface");
		AAUSBInterface *usbInterface = [[AAUSBInterface alloc] 
			initWithInterfaceDesc:interfaceDesc parentDevice:self];
		[foundInterfaces addObject:usbInterface];
		[usbInterface release];
	}
	m_interfaces = [foundInterfaces copy];
}

@end