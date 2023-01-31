//
//  ConfirmAppointmentVC.swift
//  Customer BBC
//
//  Created by Himanshu on 16/11/22.
//

import UIKit
protocol confirmReschedule{
    func appointmentResponse()
}

class ConfirmAppointmentVC: UIViewController {
    @IBOutlet weak var mainView: UIView!{
        didSet{
            mainView.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var buttonNo: UIButton!
    @IBOutlet weak var viewNo: UIView! {
        didSet{
            viewNo.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var viewYes: UIView!{
        didSet{
            viewYes.cornerRadius = 5
            viewYes.layer.borderColor = #colorLiteral(red: 0.2408570349, green: 0.7025892138, blue: 0.2526496351, alpha: 1)
            viewYes.layer.borderWidth = 2
        }
    }
    
    var delegate : confirmReschedule?
    
    @IBOutlet weak var imageReschedule: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    @IBAction func buttonYesAction(_ sender: UIButton) {
        if let del = self.delegate{
            self.dismiss(animated: true)
            del.appointmentResponse()
        }
    }
    @IBAction func buttonNo(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


