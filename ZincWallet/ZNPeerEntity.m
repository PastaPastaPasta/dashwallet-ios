//
//  ZNPeerEntity.m
//  ZincWallet
//
//  Created by Aaron Voisine on 10/6/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "ZNPeerEntity.h"
#import "NSManagedObject+Utils.h"
#import <arpa/inet.h>

@implementation ZNPeerEntity

@dynamic address;
@dynamic timestamp;
@dynamic port;
@dynamic services;

+ (instancetype)createOrUpdateWithAddress:(int32_t)address port:(int16_t)port timestamp:(NSTimeInterval)timestamp
services:(int64_t)services
{
    if (timestamp > [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970 + 60*60) {
        struct in_addr addr = { CFSwapInt32HostToBig(address) };
        char s[INET_ADDRSTRLEN];

        NSLog(@"%s:%d timestamp too far in the future", inet_ntop(AF_INET, &addr, s, INET_ADDRSTRLEN), port);
        return nil;
    }

    ZNPeerEntity *e = [self objectsMatching:@"address == %u && port == %u", address, port].lastObject;
    
    if (! e) e = [ZNPeerEntity managedObject];

    [e.managedObjectContext performBlockAndWait:^{
        e.address = address;
        e.port = port;
        if (timestamp > e.timestamp) e.timestamp = timestamp;
        e.services = services;
    }];

    return e;
}

@end
