//
//  AAUSBPipe.m
//  iButton_Reader
//
//  Created by Marc Bauer on 15.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import "AAUSBPipe.h"

@interface AAUSBPipe (Private)
- (NSString *)_directionString;
- (NSString *)_transferTypeString;
@end


@implementation AAUSBPipe

#pragma mark -
#pragma mark Initialization & Deallocation

- (id)initWithDirection:(UInt8)direction number:(UInt8)number transferType:(UInt8)transferType 
	maxPacketSize:(UInt8)maxPacketSize interval:(UInt8)interval 
	parentInterface:(AAUSBInterface *)interface{
	if (self = [super init]){
		m_direction = direction;
		m_number = number;
		m_transferType = transferType;
		m_maxPacketSize = maxPacketSize;
		m_interval = interval;
		m_interface = interface;
		m_address = ((direction << 7 & USB_ENDPOINT_DIR_MASK) | (number & USB_ENDPOINT_ADDRESS_MASK));
	}
	return self;
}




#pragma mark -
#pragma mark Public methods

- (UInt8)direction{
	return m_direction;
}

- (UInt8)pipeNumber{
	return m_number;
}

- (UInt8)transferType{
	return m_transferType;
}

- (UInt8)maxPacketSize{
	return m_maxPacketSize;
}

- (UInt8)interval{
	return m_interval;
}

- (UInt8)address{
	return m_address;
}

- (NSString *)description{
	return [NSString stringWithFormat:@"<%@ = 0x%08X | %@ address: 0x%02x (%@) number: %d maxPacketSize: %d interval: %d ms>", 
		[self class], (long)self, [self _transferTypeString], [self address], 
		[self _directionString], [self pipeNumber], [self maxPacketSize], [self interval]];
}



#pragma mark -
#pragma mark Private methods

- (NSString *)_directionString{
	NSString *str = nil;
	switch (m_direction){
		case kUSBOut:
			str = @"OUT";
			break;
		case kUSBIn:
			str = @"IN";
			break;
		case kUSBNone:
			str = @"NONE";
			break;
		case kUSBAnyDirn:
			str = @"ANY";
			break;
		default:
			str = @"UNKNOWN";
	}
	return str;
}

- (NSString *)_transferTypeString{
	NSString *str = nil;
	switch (m_transferType){
		case kUSBControl:
			str = @"Control";
			break;
		case kUSBIsoc:
			str = @"Isoc";
			break;
		case kUSBBulk:
			str = @"Bulk";
			break;
		case kUSBInterrupt:
			str = @"Interrupt";
			break;
		case kUSBAnyType:
			str = @"Any";
			break;
		default:
			str = @"Unknown";
	}
	return str;
}

@end