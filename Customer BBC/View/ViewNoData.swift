//
//  File.swift
//  Newforce Admin
//
//  Created by MAC-mini on 27/10/20.
//  Copyright © 2020 NewforceTechnologies. All rights reserved.
//
import UIKit

//var SharedView : ViewNoData = ViewNoData()
class ViewNoData: UIView {
    let nibName = "ViewNoData"
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imgVw: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    func commonInit() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
       }
    func update(){
        label.text = "Hi"
    }
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
//    class var sharedInstance : ViewNoData {
//        return SharedView
//    }
}
