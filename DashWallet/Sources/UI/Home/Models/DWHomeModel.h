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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DWTransactionListDataSource;
@class DWSyncModel;
@class DWHomeModel;
@class DWBalanceModel;
@class DWReceiveModel;

typedef NS_ENUM(NSUInteger, DWHomeTxDisplayMode) {
    DWHomeTxDisplayMode_All,
    DWHomeTxDisplayMode_Received,
    DWHomeTxDisplayMode_Sent,
};

@protocol DWHomeModelUpdatesObserver <NSObject>

- (void)homeModel:(DWHomeModel *)model didUpdateDataSourceShouldAnimate:(BOOL)shouldAnimate;

@end

@interface DWHomeModel : NSObject

@property (nonatomic, assign) DWHomeTxDisplayMode displayMode;
@property (readonly, nonatomic, strong) DWTransactionListDataSource *dataSource;

@property (readonly, nonatomic, strong) DWSyncModel *syncModel;
@property (readonly, nonatomic, strong) DWBalanceModel *balanceModel;
@property (readonly, nonatomic, strong) DWReceiveModel *receiveModel;

@property (nullable, nonatomic, weak) id<DWHomeModelUpdatesObserver> updatesObserver;

@property (readonly, nonatomic, assign, getter=isJailbroken) BOOL jailbroken;
@property (readonly, nonatomic, assign, getter=isWalletEmpty) BOOL walletEmpty;

@end

NS_ASSUME_NONNULL_END
