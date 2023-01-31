//
//  AppoinmentBookedVC.swift
//  Customer BBC
//
//  Created by Lakshay on 28/10/22.
//

import UIKit
protocol bookedSlot{
    func bookedSlotDone()
}

class AppoinmentBookedVC: UIViewController {
    //MARK: OUTLET
    @IBOutlet var lblOrderId : UILabel!
    @IBOutlet var lblTitle : UILabel!
    //MARK: VARIABLE
    var orderId = ""
    var delegate : bookedSlot?
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService{
            lblTitle.text = "THANK YOU FOR BOOKING WITH US,WE WILL NOTIFY YOU ONCE BOOKING GET CONFIRMED."
        }else{
            lblTitle.text = "THANK YOU FOR BOOKING APPOINTMENT WITH US,WE WILL NOTIFY YOU ONCE BOOKING GET CONFIRMED."
        }
        // Do any additional setup after loading the view.
    }
    //MARK: BUTTON ACTION
    @IBAction func btnOkAction(_ sender : Any){
        if let del = delegate{
            self.dismiss(animated: true)
            del.bookedSlotDone()
        }
        
    }


}
