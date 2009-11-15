//
//  AAUSBPipe.h
//  iButton_Reader
//
//  Created by Marc Bauer on 15.11.09.
//  Copyright 2009 nesiumdotcom. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/usb/IOUSBLib.h>

#define USB_ENDPOINT_ADDRESS_MASK       0x0f    /* in bEndpointAddress */
#define USB_ENDPOINT_DIR_MASK           0x80

@class AAUSBInterface;

@interface AAUSBPipe : NSObject{
	AAUSBInterface *m_interface;
	UInt8 m_direction;
	UInt8 m_number;
	UInt8 m_transferType;
	UInt8 m_maxPacketSize;
	UInt8 m_interval;
	UInt8 m_address;
}
- (id)initWithDirection:(UInt8)direction number:(UInt8)number transferType:(UInt8)transferType 
	maxPacketSize:(UInt8)maxPacketSize interval:(UInt8)interval 
	parentInterface:(AAUSBInterface *)interface;

- (UInt8)direction;
- (UInt8)pipeNumber;
- (UInt8)transferType;
- (UInt8)maxPacketSize;
- (UInt8)interval;
- (UInt8)address;
@end