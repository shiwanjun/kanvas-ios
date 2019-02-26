//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@testable import KanvasCamera
import FBSnapshotTestCase
import Foundation
import UIKit
import XCTest

final class FilterCollectionCellTests: FBSnapshotTestCase {
    
    override func setUp() {
        super.setUp()
        
        self.recordMode = false
    }
    
    func newCell() -> FilterCollectionCell {
        let frame = CGRect(origin: CGPoint.zero,
                           size: CGSize(width: FilterCollectionCell.width, height: FilterCollectionCell.minimumHeight))
        return FilterCollectionCell(frame: frame)
    }
    
    func testFilterCell() {
        let cell = newCell()
        let filter = Filter(representativeColor: .blue)
        cell.bindTo(filter)
        FBSnapshotVerifyView(cell)
    }
}