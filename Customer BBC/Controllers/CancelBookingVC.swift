//
//  CancelBookingVC.swift
//  Customer BBC
//
//  Created by Himanshu on 16/11/22.
//

import UIKit
protocol cancelBooking{
    func cancelConfirm()
}

class CancelBookingVC: UIViewController {

    @IBOutlet weak var buttonNo: UIButton!
    @IBOutlet weak var viewNo: UIView!{
        didSet{
            viewNo.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var viewYes: UIView!{
        didSet{
            viewYes.layer.cornerRadius = 5
            viewYes.layer.borderWidth = 2
            viewYes.layer.borderColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
        }
    }
    @IBOutlet weak var imageCancel: UIImageView!
    @IBOutlet weak var mianView: UIView!{
        didSet{
            mianView.layer.cornerRadius = 15
        }
    }
    
    var delegate : cancelBooking?
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    @IBAction func buttonYesAction(_ sender: UIButton) {
        if let del = self.delegate{
            self.dismiss(animated: true)
            del.cancelConfirm()
        }
    }
    @IBAction func buttonNoAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    

}
