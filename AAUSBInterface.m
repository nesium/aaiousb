//
//  AAUSBDeviceInterface.m
//  iButton_Reader
//
//  Created by Marc Bauer on 15.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AAUSBInterface.h"

@interface AAUSBInterface (Private)
- (void)_fetchPipes;
@end


@implementation AAUSBInterface

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithInterfaceDesc:(io_service_t)interfaceDesc parentDevice:(AAUSBDevice *)device{
	if (self = [super init]){
		m_interfaceDesc = interfaceDesc;
		m_interfaceOpen = NO;
		m_exclusiveAccess = NO;
		m_device = device;
		m_pipes = nil;
		
		IOCFPlugInInterface **plugInInterface = NULL;
		SInt32 score;
		HRESULT result;
		kern_return_t err = IOCreatePlugInInterfaceForService(m_interfaceDesc, 
			kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score);
		if (err || !plugInInterface){
			// @TODO improve error handling
			NSLog(@"Could not create plugin interface");
		}
		
		result = (*plugInInterface)->QueryInterface(plugInInterface, 
			CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), (LPVOID *)&m_interface);
		(*plugInInterface)->Release(plugInInterface);
		if (err || !m_interface){
			// @TODO improve error handling
			NSLog(@"Could not create interface interface");
		}
	}
	return self;
}

- (void)dealloc{
	[m_pipes release];
	IOObjectRelease(m_interfaceDesc);
	[self close];
	(*m_interface)->Release(m_interface);
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

- (BOOL)open{
	if (m_interfaceOpen)
		return YES;
	IOReturn err;
	err = (*m_interface)->USBInterfaceOpen(m_interface);
	if (err){
		NSLog(@"Could not open interface");
		return NO;
	}
	m_interfaceOpen = YES;
	return YES;
}

- (BOOL)close{
	if (!m_interfaceOpen || m_exclusiveAccess)
		return YES;
	IOReturn err;
	err = (*m_interface)->USBInterfaceClose(m_interface);
	if (err){
		NSLog(@"Closing interface failed. Connection may no longer be valid");
		return NO;
	}
	m_interfaceOpen = NO;
	return YES;
}

- (AAUSBDevice *)device{
	return m_device;
}

- (UInt8)interfaceClass{
	IOReturn err;
	UInt8 intfClass;
	err = (*m_interface)->GetInterfaceClass(m_interface, &intfClass);
	if (err) NSLog(@"Could not obtain interface class");
	return intfClass;
}

- (UInt8)interfaceSubClass{
	IOReturn err;
	UInt8 intfSubClass;
	err = (*m_interface)->GetInterfaceSubClass(m_interface, &intfSubClass);
	if (err) NSLog(@"Could not obtain interface subclass");
	return intfSubClass;
}

- (UInt8)interfaceNumber{
	IOReturn err;
	UInt8 intfNumber;
	err = (*m_interface)->GetInterfaceNumber(m_interface, &intfNumber);
	if (err) NSLog(@"Could not obtain interface number");
	return intfNumber;
}

- (UInt8)protocol{
	IOReturn err;
	UInt8 intfProtocol;
	err = (*m_interface)->GetInterfaceProtocol(m_interface, &intfProtocol);
	if (err) NSLog(@"Could not obtain interface protocol");
	return intfProtocol;
}

- (UInt32)locationId{
	IOReturn err;
	UInt32 locationId;
	err = (*m_interface)->GetLocationID(m_interface, &locationId);
	if (err) NSLog(@"Could not obtain location id");
	return locationId;
}

- (UInt8)numberOfEndpoints{
	IOReturn err;
	UInt8 numEndpoints;
	err = (*m_interface)->GetNumEndpoints(m_interface, &numEndpoints);
	if (err) NSLog(@"Could not obtain number of endpoints");
	return numEndpoints;
}

- (NSArray *)pipes{
	if (!m_pipes) [self _fetchPipes];
	return m_pipes;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | interfaceClass: 0x%04x interfaceSubClass: 0x%04x protocol: 0x%04x number: %d numEndpoints: %d>", 
		[self class], (long)self, [self interfaceClass], [self interfaceSubClass], [self protocol], 
		[self interfaceNumber], [self numberOfEndpoints]];
}



#pragma mark -
#pragma mark Private methods

- (void)_fetchPipes{
	if (![self open])
		return;
	UInt8 numEndpoints = [self numberOfEndpoints];
	UInt8 pipeRef;
	IOReturn err;
	NSMutableArray *foundPipes = [NSMutableArray array];
	for (pipeRef = 1; pipeRef <= numEndpoints; pipeRef++){
		UInt8 direction;
		UInt8 number;
		UInt8 transferType;
		UInt16 maxPacketSize;
		UInt8 interval;
		
		err = (*m_interface)->GetPipeProperties(m_interface, pipeRef, &direction, &number, 
			&transferType, &maxPacketSize, &interval);
		if (err){
			NSLog(@"Could not retreive properties of pipe %d", pipeRef);
			continue;
		}
		AAUSBPipe *pipe = [[AAUSBPipe alloc] initWithDirection:direction number:number 
			transferType:transferType maxPacketSize:maxPacketSize interval:interval 
			parentInterface:self];
		[foundPipes addObject:pipe];
		[pipe release];
	}
	m_pipes = [foundPipes copy];
	[self close];
}
@end