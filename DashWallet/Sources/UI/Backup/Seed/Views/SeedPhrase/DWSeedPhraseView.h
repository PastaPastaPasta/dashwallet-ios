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

#import <UIKit/UIKit.h>

#import "DWSeedPhraseType.h"

NS_ASSUME_NONNULL_BEGIN

@class DWSeedPhraseModel;
@class DWSeedPhraseView;
@class DWSeedWordModel;

@protocol DWSeedPhraseViewDelegate <NSObject>

- (BOOL)seedPhraseView:(DWSeedPhraseView *)view allowedToSelectWord:(DWSeedWordModel *)wordModel;
- (void)seedPhraseView:(DWSeedPhraseView *)view didSelectWord:(DWSeedWordModel *)wordModel;

@end

@interface DWSeedPhraseView : UIView

@property (nullable, nonatomic, strong) DWSeedPhraseModel *model;
@property (nullable, nonatomic, weak) id<DWSeedPhraseViewDelegate> delegate;

- (instancetype)initWithType:(DWSeedPhraseType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (void)prepareForAppearanceAnimation;
- (void)showSeedPhraseAnimated;

@end

NS_ASSUME_NONNULL_END
