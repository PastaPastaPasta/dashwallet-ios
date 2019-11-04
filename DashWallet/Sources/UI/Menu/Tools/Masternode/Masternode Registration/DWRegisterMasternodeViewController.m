//
//  DWRegisterMasternodeViewController.m
//  DashWallet
//
//  Created by Sam Westrich on 2/9/19.
//  Copyright © 2019 Dash Core Group. All rights reserved.
//

#import "DWRegisterMasternodeViewController.h"
#import "DWEnvironment.h"
#import "DWFormTableViewController.h"
#import "DWKeyValueFormTableViewCell.h"
#import "DWMasternodeRegistrationModel.h"
#import "DWPublicKeyGenerationTableViewCell.h"
#import "DWSignPayloadViewController.h"
#import "DWUIKit.h"
#include <arpa/inet.h>

#define INPUT_CELL_HEIGHT 75
#define PUBLIC_KEY_CELL_HEIGHT 150

typedef NS_ENUM(NSUInteger, DWMasternodeRegistrationCell) {
    DWMasternodeRegistrationCell_CollateralTx,
    DWMasternodeRegistrationCell_CollateralIndex,
    DWMasternodeRegistrationCell_IPAddress,
    DWMasternodeRegistrationCell_Port,
    DWMasternodeRegistrationCell_PayoutAddress,
    DWMasternodeRegistrationCell_OwnerKey,
    DWMasternodeRegistrationCell_OperatorKey,
    DWMasternodeRegistrationCell_VotingKey,
    _DWMasternodeRegistrationCell_Count,
};

typedef NS_ENUM(NSUInteger, DWMasternodeRegistrationCellType) {
    DWMasternodeRegistrationCellType_InputValue,
    DWMasternodeRegistrationCellType_PublicKey,
};

@interface DWRegisterMasternodeViewController ()

@property (nonatomic, strong) DSAccount *account;
@property (nonatomic, strong) DSProviderRegistrationTransaction *providerRegistrationTransaction;
@property (nonatomic, strong) DSTransaction *collateralTransaction;
@property (null_resettable, nonatomic, strong) DWMasternodeRegistrationModel *model;
@property (nonatomic, strong) DWFormTableViewController *formController;

@end

@implementation DWRegisterMasternodeViewController

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _model = [[DWMasternodeRegistrationModel alloc] initForWallet:[DWEnvironment sharedInstance].currentWallet];
        self.account = [DWEnvironment sharedInstance].currentAccount;
        self.title = NSLocalizedString(@"Registration", nil);
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor dw_secondaryBackgroundColor];

    DWFormTableViewController *formController = [[DWFormTableViewController alloc] initWithStyle:UITableViewStylePlain];
    [formController setSections:[self sections] placeholderText:nil];

    [self addChildViewController:formController];
    formController.view.frame = self.view.bounds;
    formController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:formController.view];
    [formController didMoveToParentViewController:self];
    self.formController = formController;


    //    self.view.backgroundColor = [UIColor dw_secondaryBackgroundColor];
    //    self.tableView.rowHeight = UITableViewAutomaticDimension;
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    self.tableView.tableFooterView = [[UIView alloc] init];
    //    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    //    self.tableView.estimatedSectionHeaderHeight = 30.0;
    //
    //    NSArray<Class> *cellClasses = @[
    //        DWKeyValueFormTableViewCell.class,
    //        DWPublicKeyGenerationTableViewCell.class,
    //    ];
    //
    //    for (Class cellClass in cellClasses) {
    //        [self.tableView registerClass:cellClass forCellReuseIdentifier:NSStringFromClass(cellClass)];
    //    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Data Source

- (NSString *)titleForCellAtRow:(NSUInteger)row {
    switch (row) {
        case DWMasternodeRegistrationCell_CollateralTx:
            return NSLocalizedString(@"Collateral Tx", nil);
        case DWMasternodeRegistrationCell_CollateralIndex:
            return NSLocalizedString(@"Collateral Index", nil);
        case DWMasternodeRegistrationCell_IPAddress:
            return NSLocalizedString(@"IP Address", nil);
        case DWMasternodeRegistrationCell_Port:
            return NSLocalizedString(@"Port", nil);
        case DWMasternodeRegistrationCell_PayoutAddress:
            return NSLocalizedString(@"Payout Address", nil);
        case DWMasternodeRegistrationCell_OwnerKey:
            return NSLocalizedString(@"Owner Public Key", nil);
        case DWMasternodeRegistrationCell_OperatorKey:
            return NSLocalizedString(@"Operator Public Key", nil);
        case DWMasternodeRegistrationCell_VotingKey:
            return NSLocalizedString(@"Voting Public Key", nil);
    }
    return @"";
}

- (DWMasternodeRegistrationCellType)typeForCellAtRow:(NSUInteger)row {
    switch (row) {
        case DWMasternodeRegistrationCell_CollateralTx:
        case DWMasternodeRegistrationCell_CollateralIndex:
        case DWMasternodeRegistrationCell_IPAddress:
        case DWMasternodeRegistrationCell_Port:
        case DWMasternodeRegistrationCell_PayoutAddress:
            return DWMasternodeRegistrationCellType_InputValue;
        case DWMasternodeRegistrationCell_OwnerKey:
        case DWMasternodeRegistrationCell_OperatorKey:
        case DWMasternodeRegistrationCell_VotingKey:
            return DWMasternodeRegistrationCellType_PublicKey;
    }
    return DWMasternodeRegistrationCellType_InputValue;
}

- (DWBaseFormCellModel *)modelForRow:(NSUInteger)row {
    switch ([self typeForCellAtRow:row]) {
        case DWMasternodeRegistrationCellType_InputValue:
            return [[DWKeyValueFormCellModel alloc] initWithTitle:[self titleForCellAtRow:row]];
        case DWMasternodeRegistrationCellType_PublicKey:
            return [[DWPublicKeyGenerationCellModel alloc] initWithTitle:[self titleForCellAtRow:row]];
    }
}

- (NSArray<DWBaseFormCellModel *> *)items {
    __weak typeof(self) weakSelf = self;

    NSMutableArray<DWBaseFormCellModel *> *items = [NSMutableArray array];

    for (NSUInteger i = 0; i < _DWMasternodeRegistrationCell_Count; i++) {
        [items addObject:[self modelForRow:i]];
    }
    return items;
}

- (NSArray<DWFormSectionModel *> *)sections {
    DWFormSectionModel *section = [[DWFormSectionModel alloc] init];
    section.items = [self items];

    return @[ section ];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _DWMasternodeRegistrationCell_Count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self typeForCellAtRow:indexPath.row]) {
        case DWMasternodeRegistrationCellType_InputValue:
            return INPUT_CELL_HEIGHT;
        case DWMasternodeRegistrationCellType_PublicKey:
            return PUBLIC_KEY_CELL_HEIGHT;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId;
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                case 3:
                case 4: {
                    cellId = DWKeyValueFormTableViewCell.dw_reuseIdentifier;
                    DWKeyValueFormTableViewCell *cell =
                        (DWKeyValueFormTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId
                                                                                       forIndexPath:indexPath];
                    return cell;
                }
                case 5:
                case 6:
                case 7: {
                    cellId = DWPublicKeyGenerationTableViewCell.dw_reuseIdentifier;
                    DWPublicKeyGenerationTableViewCell *cell =
                        (DWPublicKeyGenerationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId
                                                                                              forIndexPath:indexPath];
                    return cell;
                }
            }
        }
    }

    return nil;
}

- (void)signTransactionInputs:(DSProviderRegistrationTransaction *)providerRegistrationTransaction {
    [self.account signTransaction:providerRegistrationTransaction
                       withPrompt:@"Would you like to register this masternode?"
                       completion:^(BOOL signedTransaction, BOOL cancelled) {
                           if (signedTransaction) {
                               [self.account.wallet.chain.chainManager.transactionManager publishTransaction:providerRegistrationTransaction
                                                                                                  completion:^(NSError *_Nullable error) {
                                                                                                      if (error) {
                                                                                                          [self raiseIssue:@"Error" message:error.localizedDescription];
                                                                                                      }
                                                                                                      else {
                                                                                                          //[masternode registerInWallet];
                                                                                                          [self.presentingViewController dismissViewControllerAnimated:TRUE completion:nil];
                                                                                                      }
                                                                                                  }];
                           }
                           else {
                               [self raiseIssue:@"Error" message:@"Transaction was not signed."];
                           }
                       }];
}

- (void)raiseIssue:(NSString *)issue message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:issue message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok"
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction *_Nonnull action){

                                            }]];
    [self presentViewController:alert
                       animated:TRUE
                     completion:^{

                     }];
}


//
//------
//
//    -(void)viewDidLoad {
//    [super viewDidLoad];
//
//    _model = [[DWMasternodeRegistrationModel alloc] initWithWallet:self.wallet];
//    self.view.backgroundColor = [UIColor dw_secondaryBackgroundColor];
//
//
//    self.wallet = [DWEnvironment sharedInstance].currentWallet;
//    self.account = [DWEnvironment sharedInstance].currentAccount;
//}
//
//#pragma mark - Table view data source
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    switch (indexPath.section) {
//        case 0: {
//            switch (indexPath.row) {
//                case 0:
//                    return self.collateralTransactionTableViewCell;
//                case 1:
//                    return self.collateralIndexTableViewCell;
//                case 2:
//                    return self.ipAddressTableViewCell;
//                case 3:
//                    return self.portTableViewCell;
//                case 4:
//                    return self.ownerIndexTableViewCell;
//                case 5:
//                    return self.operatorIndexTableViewCell;
//                case 6:
//                    return self.votingIndexTableViewCell;
//                case 7:
//                    return self.payToAddressTableViewCell;
//            }
//        }
//    }
//    return nil;
//}
//

//- (IBAction)registerMasternode:(id)sender {
//    NSString *ipAddressString = [self.ipAddressTableViewCell.valueTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    NSString *portString = [self.portTableViewCell.valueTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    UInt128 ipAddress = {.u32 = {0, 0, CFSwapInt32HostToBig(0xffff), 0}};
//    struct in_addr addrV4;
//    if (inet_aton([ipAddressString UTF8String], &addrV4) != 0) {
//        uint32_t ip = ntohl(addrV4.s_addr);
//        ipAddress.u32[3] = CFSwapInt32HostToBig(ip);
//        DSDLog(@"%08x", ip);
//    }
//    uint16_t port = [portString intValue];
//
//    uint32_t ownerWalletIndex = UINT32_MAX;
//    uint32_t votingWalletIndex = UINT32_MAX;
//    uint32_t operatorWalletIndex = UINT32_MAX;
//
//    if (self.ownerIndexTableViewCell.publicKeyTextField.text && ![self.ownerIndexTableViewCell.publicKeyTextField.text isEqualToString:@""]) {
//        ownerWalletIndex = (uint32_t)[self.ownerIndexTableViewCell.publicKeyTextField.text integerValue];
//    }
//
//    if (self.operatorIndexTableViewCell.publicKeyTextField.text && ![self.operatorIndexTableViewCell.publicKeyTextField.text isEqualToString:@""]) {
//        operatorWalletIndex = (uint32_t)[self.operatorIndexTableViewCell.publicKeyTextField.text integerValue];
//    }
//
//    if (self.votingIndexTableViewCell.publicKeyTextField.text && ![self.votingIndexTableViewCell.publicKeyTextField.text isEqualToString:@""]) {
//        votingWalletIndex = (uint32_t)[self.votingIndexTableViewCell.publicKeyTextField.text integerValue];
//    }
//
//    DSLocalMasternode *masternode = [self.chain.chainManager.masternodeManager createNewMasternodeWithIPAddress:ipAddress onPort:port inFundsWallet:self.wallet fundsWalletIndex:UINT32_MAX inOperatorWallet:self.wallet operatorWalletIndex:operatorWalletIndex inOwnerWallet:self.wallet ownerWalletIndex:ownerWalletIndex inVotingWallet:self.wallet votingWalletIndex:votingWalletIndex];
//
//    NSString *payoutAddress = [self.payToAddressTableViewCell.valueTextField.text isValidDashAddressOnChain:self.chain] ? self.payToAddressTableViewCell.textLabel.text : self.account.receiveAddress;
//
//
//    DSUTXO collateral = DSUTXO_ZERO;
//    UInt256 nonReversedCollateralHash = UINT256_ZERO;
//    NSString *collateralTransactionHash = self.collateralTransactionTableViewCell.valueTextField.text;
//    if (![collateralTransactionHash isEqual:@""]) {
//        NSData *collateralTransactionHashData = [collateralTransactionHash hexToData];
//        if (collateralTransactionHashData.length != 32)
//            return;
//        collateral.hash = collateralTransactionHashData.reverse.UInt256;
//
//        nonReversedCollateralHash = collateralTransactionHashData.UInt256;
//        collateral.n = [self.collateralIndexTableViewCell.valueTextField.text integerValue];
//    }
//
//
//    [masternode registrationTransactionFundedByAccount:self.account
//                                             toAddress:payoutAddress
//                                        withCollateral:collateral
//                                            completion:^(DSProviderRegistrationTransaction *_Nonnull providerRegistrationTransaction) {
//                                                if (providerRegistrationTransaction) {
//                                                    if (dsutxo_is_zero(collateral)) {
//                                                        [self signTransactionInputs:providerRegistrationTransaction];
//                                                    }
//                                                    else {
//                                                        [[DSInsightManager sharedInstance] queryInsightForTransactionWithHash:nonReversedCollateralHash
//                                                                                                                      onChain:self.chain
//                                                                                                                   completion:^(DSTransaction *transaction, NSError *error) {
//                                                                                                                       NSIndexSet *indexSet = [[transaction outputAmounts] indexesOfObjectsPassingTest:^BOOL(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
//                                                                                                                           if ([obj isEqual:@(MASTERNODE_COST)])
//                                                                                                                               return TRUE;
//                                                                                                                           return FALSE;
//                                                                                                                       }];
//                                                                                                                       if ([indexSet containsIndex:collateral.n]) {
//                                                                                                                           self.collateralTransaction = transaction;
//                                                                                                                           self.providerRegistrationTransaction = providerRegistrationTransaction;
//                                                                                                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                                                                                                               [self performSegueWithIdentifier:@"PayloadSigningSegue" sender:self];
//                                                                                                                           });
//                                                                                                                       }
//                                                                                                                       else {
//                                                                                                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                                                                                                               [self raiseIssue:@"Error" message:@"Incorrect collateral index"];
//                                                                                                                           });
//                                                                                                                       }
//                                                                                                                   }];
//                                                    }
//                                                }
//                                                else {
//                                                    [self raiseIssue:@"Error" message:@"Unable to create ProviderRegistrationTransaction."];
//                                                }
//                                            }];
//}
//

//
//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
//}
//
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"PayloadSigningSegue"]) {
//        DWSignPayloadViewController *signPayloadSegue = (DWSignPayloadViewController *)segue.destinationViewController;
//        signPayloadSegue.collateralAddress = self.collateralTransaction.outputAddresses[self.providerRegistrationTransaction.collateralOutpoint.n];
//        signPayloadSegue.providerRegistrationTransaction = self.providerRegistrationTransaction;
//        signPayloadSegue.delegate = self;
//    }
//}
//
//- (void)viewController:(nonnull UIViewController *)controller didReturnSignature:(nonnull NSData *)signature {
//    self.providerRegistrationTransaction.payloadSignature = signature;
//    [self signTransactionInputs:self.providerRegistrationTransaction];
//}


@end
