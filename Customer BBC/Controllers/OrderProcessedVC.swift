//
//  OrderProcessedVC.swift
//  Customer BBC
//
//  Created by Himanshu on 17/11/22.
//

import UIKit
protocol orderProcessSuccessfull{
    func orderSuccess()
}

class OrderProcessedVC: UIViewController {

    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewOkButton: UIView!{
        didSet{
            viewOkButton.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var labelOrderId: UILabel!
    @IBOutlet var lblTitle : UILabel!
    var orderId = ""
    var tableNumber = [String]()
    var delegate : orderProcessSuccessfull?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.labelOrderId.text = "Order id is \(self.orderId)"
        if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService{
            lblTitle.text = "Your Ride has been Booked."
        }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
            lblTitle.text = "Your appointment has been  processed."
        }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.restaurant{
            if self.tableNumber.isEmpty == true{
                 self.viewHeight.constant = 270
                lblTitle.text = "Your order has been  processed."
            }else{
                self.viewHeight.constant = 300
                lblTitle.text = "Your order has been  processed for table number \(self.tableNumber.joined(separator: ","))."
            }
        }else{
            lblTitle.text = "Your order has been  processed."
        }
        
    }
    
    @IBAction func buttonOkAction(_ sender: UIButton) {
        if let del = self.delegate{
            self.dismiss(animated: true)
            del.orderSuccess()
        }
    }
    


}
