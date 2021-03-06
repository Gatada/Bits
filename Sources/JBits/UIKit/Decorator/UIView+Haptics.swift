//
//  UIView+Haptics.swift
//  
//
//  Created by Johan Basberg on 02/02/2021.
//

#if !os(tvOS)

import UIKit

public extension UIView {
    
    static var hapticSelection: UISelectionFeedbackGenerator?
    
    func gestureHasState(_ state: UIGestureRecognizer.State) {
        switch state {
        case .began:
            prepareHapticFeedback()
        case .changed:
            break
        case .ended:
            doneWithHapticFeedback()
        default:
            break
        }
    }
    
    // MARK:  Haptics
    
    /// Called to optionally prepare for haptic feedback, and reduce latency when triggering feedback.
    ///
    /// Calling this is useful when you need to syncronize haptic with audio feedback.
    ///
    /// Try to do this a second or so before the haptic is triggered. Longer than that, and
    /// the Taptic engine will turn off again.
    func prepareHapticFeedback() {
        UIView.hapticSelection = UISelectionFeedbackGenerator()
        UIView.hapticSelection?.prepare()
    }
    
    /// Triggers haptic feedback.
    ///
    /// This triggers the selection changed haptic feedback type.
    func fireHapticFeedback() {
        UIView.hapticSelection?.selectionChanged()
    }
    
    /// Optionally call this to release the haptic generator.
    func doneWithHapticFeedback() {
        UIView.hapticSelection = nil
    }
}

#endif
