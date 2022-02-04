//  
//  Created by Pavel Tikhonenko
//  Copyright © 2022 Dash Core Group. All rights reserved.
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

#import "DWExploreWhereToSpendViewController.h"
#import "DWExploreWhereToSpendInfoViewController.h"
#import "DWUIKit.h"
#import "DWGlobalOptions.h"

@interface DWExploreWhereToSpendViewController ()

@end

@implementation DWExploreWhereToSpendViewController

- (void)infoAction {
    [self showInfoViewController];
}

- (void)showInfoViewControllerIfNeeded {
    if(![DWGlobalOptions sharedInstance].dashpayExploreWhereToSpendInfoShown) {
        [self showInfoViewController];
        
        [DWGlobalOptions sharedInstance].dashpayExploreWhereToSpendInfoShown = YES;
    }
}

- (void)showInfoViewController {
    DWExploreWhereToSpendInfoViewController *vc = [[DWExploreWhereToSpendInfoViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (UIBarButtonItem *)cancelBarButton {
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [infoButton addTarget:self action:@selector(infoAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    return infoBarButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showInfoViewControllerIfNeeded];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor dw_backgroundColor];
    
    self.navigationItem.rightBarButtonItem = [self cancelBarButton];
}

@end
