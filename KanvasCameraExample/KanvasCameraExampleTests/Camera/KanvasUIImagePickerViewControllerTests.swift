//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import XCTest
@testable import KanvasCamera

final class KanvasUIImagePickerViewControllerTests: XCTestCase {

    func testPrefersStatusBarHidden() {
        let c = KanvasUIImagePickerViewController(nibName: nil, bundle: nil)
        XCTAssert(c.prefersStatusBarHidden == true)
    }

    func testChildForStatusBarHidden() {
        let c = KanvasUIImagePickerViewController(nibName: nil, bundle: nil)
        XCTAssert(c.childForStatusBarHidden == nil)
    }
}