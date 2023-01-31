//
//  DotedView.swift
//  BBC Retail
//
//  Created by Prashant Kumar on 28/04/22.
//

import Foundation
import UIKit

class DashedBorderView: UIView {

    let _border = CAShapeLayer()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    init() {
        super.init(frame: .zero)
        setup()
    }

    func setup() {
        _border.strokeColor = UIColor.lightGray.cgColor
        _border.fillColor = nil
        _border.lineDashPattern = [4, 4]
        self.layer.addSublayer(_border)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _border.path = UIBezierPath(roundedRect: self.bounds, cornerRadius:5).cgPath
        _border.frame = self.bounds
    }
}
