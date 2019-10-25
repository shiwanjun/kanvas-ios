//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import UIKit

/// Protocol for the text view inside text tools
protocol MainTextViewDelegate: class {
    
    /// Called when the background was touched
    func didTapBackground()
}

/// Main text view for editing
final class MainTextView: StylableTextView {
    
    weak var textViewDelegate: MainTextViewDelegate?
    
    override var contentSize: CGSize {
        didSet {
            centerContentVertically()
        }
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        centerContentVertically()
    }
    
    override init() {
        super.init()
        setUpView()
        setUpGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    private func setUpView() {
        backgroundColor = .clear
        tintColor = .white
        showsVerticalScrollIndicator = false
        autocorrectionType = .no
    }
    
    private func setUpGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(recognizer:)))
        addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Private utilities
    
    private func centerContentVertically() {
        var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2
        topCorrection = max(0, topCorrection)
        contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func textViewTapped(recognizer: UITapGestureRecognizer) {
        let point = recognizer.location(in: recognizer.view)
        if !textInputView.frame.contains(point) {
            textViewDelegate?.didTapBackground()
        }
    }
}