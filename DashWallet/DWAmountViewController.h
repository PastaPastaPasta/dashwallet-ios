//
//  DWAmountViewController.h
//  DashWallet
//
//  Created by Aaron Voisine for BreadWallet on 6/4/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//  Copyright (c) 2018 Dash Core Group <contact@dash.org>
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

#import <UIKit/UIKit.h>

@class DWAmountViewController;

@protocol DWAmountViewControllerDelegate <NSObject>
@required

- (void)amountViewController:(DWAmountViewController *)amountViewController selectedAmount:(uint64_t)amount;
@optional
- (void)amountViewController:(DWAmountViewController *)amountViewController shapeshiftBitcoinAmount:(uint64_t)amount approximateDashAmount:(uint64_t)dashAmount;
- (void)amountViewController:(DWAmountViewController *)amountViewController shapeshiftDashAmount:(uint64_t)amount;

@end

@interface DWAmountViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<DWAmountViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, assign) BOOL usingShapeshift;
@property (nonatomic, assign) BOOL requestingAmount;
@property (nonatomic, strong) NSString * payeeCurrency;

@end
