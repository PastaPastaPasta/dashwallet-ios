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

let pageLimit = 100

struct PaginationResult<Item> {
    var items: [Item]
    var offset: Int
}

@dynamicMemberLookup
struct PointOfUseDAOFilters {
    private var storage: [String: Any?] = [:]
    
    init(filters: [String: Any?]) {
        self.storage = filters
    }
    
    subscript(dynamicMember string: String) -> Any? {
        return storage[string] as? Any
    }
}

protocol PointOfUseDAO {
    associatedtype Item
    
    func items(filters: PointOfUseDAOFilters, completion: @escaping (Swift.Result<PaginationResult<Item>, Error>) -> Void)
}
