//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "DWPayModel.h"

#import <CoreNFC/CoreNFC.h>

#import "DWEnvironment.h"
#import "DWFrequentContactsDataSource.h"
#import "DWGlobalOptions.h"
#import "DWPasteboardAddressExtractor.h"
#import "DWPayOptionModel.h"
#import "DWPaymentInputBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWPayModel () <NFCNDEFReaderSessionDelegate>

@property (readonly, nonatomic, strong) DWPaymentInputBuilder *inputBuilder;
@property (readonly, nonatomic, strong) DWPasteboardAddressExtractor *pasteboardExtractor;
@property (readonly, nonatomic, strong) DWPayOptionModel *pasteboardOption;
@property (readonly, nonatomic, strong) DWPayOptionModel *usersOption;

@property (nullable, nonatomic, strong) DWPaymentInput *pasteboardPaymentInput;
@property (nullable, nonatomic, copy) void (^nfcReadingCompletion)(DWPaymentInput *paymentInput);

@end

@implementation DWPayModel

@synthesize options = _options;

- (instancetype)init {
    self = [super init];
    if (self) {
        _inputBuilder = [[DWPaymentInputBuilder alloc] init];
        _pasteboardExtractor = [[DWPasteboardAddressExtractor alloc] init];

        [self updatePaymentOptions];
    }
    return self;
}

- (void)dealloc {
    DSLog(@"☠️ %@", NSStringFromClass(self.class));
}

- (void)updatePaymentOptions {
    NSMutableArray<DWPayOptionModel *> *options = [NSMutableArray array];

    DSBlockchainIdentity *blockchainIdentity = [DWEnvironment sharedInstance].currentWallet.defaultBlockchainIdentity;
    if (blockchainIdentity.currentDashpayUsername != nil) {
        DWPayOptionModel *option = [[DWPayOptionModel alloc] initWithType:DWPayOptionModelType_DashPayUser];
        option.details = [[DWFrequentContactsDataSource alloc] init];
        [options addObject:option];
        _usersOption = option;
    }

    // CoreNFC is optional framework
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        Class NFCNDEFReaderSessionClass = NSClassFromString(@"NFCNDEFReaderSession");
        if ([NFCNDEFReaderSessionClass respondsToSelector:@selector(readingAvailable)] &&
            [(id)NFCNDEFReaderSessionClass readingAvailable]) {
            DWPayOptionModel *nfcOption = [[DWPayOptionModel alloc]
                initWithType:DWPayOptionModelType_NFC];
            [options addObject:nfcOption];
        }
    }

    DWPayOptionModel *scanQROption = [[DWPayOptionModel alloc]
        initWithType:DWPayOptionModelType_ScanQR];
    [options addObject:scanQROption];

    DWPayOptionModel *pasteboardOption = [[DWPayOptionModel alloc]
        initWithType:DWPayOptionModelType_Pasteboard];
    [options addObject:pasteboardOption];
    _pasteboardOption = pasteboardOption;

    // CoreNFC is optional framework
    Class NFCNDEFReaderSessionClass = NSClassFromString(@"NFCNDEFReaderSession");
    if ([(id)NFCNDEFReaderSessionClass readingAvailable]) {
        DWPayOptionModel *nfcOption = [[DWPayOptionModel alloc]
            initWithType:DWPayOptionModelType_NFC];
        [options addObject:nfcOption];
    }

    _options = [options copy];
}

- (void)updateFrequentContacts {
    DWFrequentContactsDataSource *dataSource = (DWFrequentContactsDataSource *)self.usersOption.details;
    if (dataSource) {
        [dataSource updateItems];
    }
}

- (void)performNFCReadingWithCompletion:(void (^)(DWPaymentInput *paymentInput))completion {
    NSParameterAssert(completion);

    self.nfcReadingCompletion = completion;

    dispatch_queue_t queue = dispatch_queue_create("org.dash.nfc-reading-queue", DISPATCH_QUEUE_CONCURRENT);
    NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc] initWithDelegate:self
                                                                             queue:queue
                                                          invalidateAfterFirstRead:NO];
    session.alertMessage = NSLocalizedString(@"Please place your phone near NFC device.", nil);
    [session beginSession];
}

- (void)checkPasteboardForAddresses {
    NSArray<NSString *> *contents = [self extractAddressesFromFromPasteboard];
    if (contents.count == 0) { return; }
    
    __weak typeof(self) weakSelf = self;
    [self.inputBuilder payFirstFromArray:contents
                                  source:DWPaymentInputSource_Pasteboard
                              completion:^(DWPaymentInput *_Nonnull paymentInput) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        
        strongSelf.pasteboardPaymentInput = paymentInput;
    }];
}

- (NSArray<NSString *>*)extractAddressesFromFromPasteboard {
    NSArray<NSString *> *contents = [self.pasteboardExtractor extractAddresses];
    return contents;
}

- (void)payToAddressFromPasteboardAvailable:(void (^)(BOOL success))completion {
    NSArray<NSString *> *contents = [self extractAddressesFromFromPasteboard];
    if (contents.count == 0) {
        self.pasteboardPaymentInput = nil;

        if (completion) {
            completion(NO);
        }
    }
    else {
        __weak typeof(self) weakSelf = self;
        [self.inputBuilder payFirstFromArray:contents
                                      source:DWPaymentInputSource_Pasteboard
                                  completion:^(DWPaymentInput *_Nonnull paymentInput) {
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      if (!strongSelf) {
                                          return;
                                      }

                                      strongSelf.pasteboardPaymentInput = paymentInput;

                                      if (completion) {
                                          BOOL success = paymentInput.request || paymentInput.protocolRequest;
                                          completion(success);
                                      }
                                  }];
    }
}

- (DWPaymentInput *)paymentInputWithURL:(NSURL *)url {
    return [self.inputBuilder paymentInputWithURL:url];
}

- (DWPaymentInput *)paymentInputWithUser:(id<DWDPBasicUserItem>)userItem {
    return [self.inputBuilder paymentInputWithUserItem:userItem];
}

#pragma mark - NFCNDEFReaderSessionDelegate

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages {
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *payload in message.records) {
            DSLogPrivate(@"NFC payload.payload %@", payload.payload);
            NSData *data = payload.payload;
            const unsigned char *bytes = data.bytes;

            if (bytes[0] == 0) {
                data = [data subdataWithRange:NSMakeRange(1, data.length - 1)];
            }
            DSLogPrivate(@"NFC Payload data: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            [array addObject:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.inputBuilder payFirstFromArray:array
                                      source:DWPaymentInputSource_NFC
                                  completion:^(DWPaymentInput *_Nonnull paymentInput) {
                                      if (self.nfcReadingCompletion) {
                                          self.nfcReadingCompletion(paymentInput);
                                      }
                                      self.nfcReadingCompletion = nil;
                                  }];
    });

    [session invalidateSession];
}

- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {
#ifdef DEBUG
    if (FALSE) {
        // this is kept here on purpose to keep the string in our localization script
        __unused NSString *s = NSLocalizedString(@"NFC device didn't transmit a valid Dash address", nil);
    }
#endif

    if (self.nfcReadingCompletion) {
        DWPaymentInput *paymentInput = [self.inputBuilder emptyPaymentInputWithSource:DWPaymentInputSource_NFC];
        self.nfcReadingCompletion(paymentInput);
    }

    self.nfcReadingCompletion = nil;
}

#pragma mark - Private

- (void)setPasteboardPaymentInput:(nullable DWPaymentInput *)pasteboardPaymentInput {
    _pasteboardPaymentInput = pasteboardPaymentInput;

    self.pasteboardOption.details = [pasteboardPaymentInput.userDetails copy];
}

@end

NS_ASSUME_NONNULL_END
