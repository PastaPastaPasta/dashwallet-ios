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

import Foundation
import SQLite

@objc class AddressUserInfo: NSObject {
    @objc var address: String
    @objc var taxCategory: TxUserInfoTaxCategory = .unknown
    
    @objc init(address: String, taxCategory: TxUserInfoTaxCategory) {
        self.address = address
        self.taxCategory = taxCategory
    }
    
    init(row: Row) {
        self.address = row[AddressUserInfo.addressColumn]
        self.taxCategory = TxUserInfoTaxCategory(rawValue: row[TxUserInfo.txCategoryColumn]) ?? .unknown
        
        super.init()
    }
}

@objc extension AddressUserInfo {
    @objc func taxCategoryString() -> String {
        return taxCategory.stringValue
    }
}

extension AddressUserInfo {
    static var table: Table { return Table("address_userinfo") }
    static var txCategoryColumn: Expression<Int> { return Expression<Int>("taxCategory") }
    static var addressColumn: Expression<String> { return Expression<String>("address") }
}
