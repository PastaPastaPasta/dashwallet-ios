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

#import "DWBasePayViewController.h"

#import "DWHomeProtocol.h"
#import "DWWipeDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class DWHomeViewController;

@protocol DWHomeViewControllerDelegate <NSObject>

- (void)homeViewControllerShowReceivePayment:(DWHomeViewController *)controller;

@end

@interface DWHomeViewController : DWBasePayViewController

@property (strong, nonatomic) id<DWHomeProtocol> model;
@property (nullable, nonatomic, weak) id<DWHomeViewControllerDelegate, DWWipeDelegate> delegate;

- (void)handleDeeplink:(NSURL *)url definedUsername:(NSString *)definedUsername;

@end

NS_ASSUME_NONNULL_END
