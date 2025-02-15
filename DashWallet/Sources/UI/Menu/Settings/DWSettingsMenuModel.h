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

@class DWBalanceDisplayOptions;
@class DWCSVExporter;
@interface DWSettingsMenuModel : NSObject

@property (readonly, copy, nonatomic) NSString *networkName;
@property (readonly, copy, nonatomic) NSString *localCurrencyCode;

@property (assign, nonatomic) BOOL notificationsEnabled;

+ (void)switchToMainnetWithCompletion:(void (^)(BOOL success))completion;
+ (void)switchToTestnetWithCompletion:(void (^)(BOOL success))completion;
+ (void)switchToEvonetWithCompletion:(void (^)(BOOL success))completion;

+ (void)rescanBlockchainActionFromController:(UIViewController *)controller
                                  sourceView:(UIView *)sourceView
                                  sourceRect:(CGRect)sourceRect
                                  completion:(void (^_Nullable)(BOOL confirmed))completion;

+ (void)generateCSVReportWithCompletionHandler:(void (^)(NSString *fileName, NSURL *file))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;
@end

NS_ASSUME_NONNULL_END
