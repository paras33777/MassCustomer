//
//  CabOrderDetailVC.swift
//  Customer BBC
//
//  Created by Himanshu on 22/11/22.
//

import UIKit
import FTIndicator
import UIView_Shimmer
import Razorpay
import SafariServices
import Stripe
import Kingfisher

class CabOrderDetailVC: UIViewController {
    @IBOutlet var tblBatchOrderDetail : UITableView!{
        didSet{
            tblBatchOrderDetail.alpha = 0
        }
    }
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblTitleMain: UILabel!{
        didSet{
            lblTitleMain.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        }
    }
    @IBOutlet weak var lblPaymentID: UILabel!
    @IBOutlet weak var stackTotalAmount: UIStackView!
    @IBOutlet weak var lblTTotal: UILabel!{
        didSet{
            lblTTotal.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var lblBottomVwTotal: UILabel!
    @IBOutlet weak var btnDownloadPay: UIButton!
    @IBOutlet var vwBottomPayment: UIView!
    @IBOutlet var vwnormalPayment: UIView!
    @IBOutlet weak var stackBottomSheet: UIStackView!
    
    @IBOutlet weak var lblTOrderID: UILabel!{
        didSet{
            lblTOrderID.font = UIFont(name: "Montserrat-SemiBold", size: 14)
         
        }
    }
    @IBOutlet weak var lblTTTotal: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!{
        didSet{
            lblOrderID.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var lblTotal: UILabel!{
        didSet{
            lblTotal.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var lblTDate: UILabel!
    @IBOutlet weak var lblDate: UILabel!{
        didSet{
            lblDate.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var ordertypeLabel: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var viewStatus: UIView!{
        didSet{
            viewStatus.cornerRadius = 1
        }
    }
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var lblStatusReason: UILabel!
    @IBOutlet weak var lblDetailTitle: UILabel!{
        didSet{
            lblDetailTitle.font = UIFont(name: "Montserrat-Bold", size: 16)
        }
    }
    var shimmeringAnimatedItems: [UIView]{
        [
            lblTOrderID,
            lblTTTotal,
            lblOrderID,
            lblTotal,
            lblTDate,
            lblDate,
            ordertypeLabel,
            lblStatus,
            lblStatusReason
            
        ]
    }
    
    private static let backendURL = URL(string: "https://api.stripe.com/v1/")!
    
    private var paymentIntentClientSecret: String?
    private var customerID: String?
    
    private var isLodinData = true
    var ordedrDetail : OrderList!
    var orderBatchInfo : OrderInfo?
    //    var orderInfo : OrderInfo?
    var storeInfo : StoreInfo!
    var orderType = ""
    var orderBatchId = ""
    var count = 0
    var razorpayObj : RazorpayCheckout? = nil
    var paymentMethod = ""
    var stripTransctionId = ""
    var currency = ""
    var productType = ""
    let hiddenOrigin: CGPoint = {
        let y = UIScreen.main.bounds.height + 60
        let x = CGFloat(0)
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    let fullScreenSize :CGSize = {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        let coordinate = CGSize.init(width: width, height: height)
        return coordinate
    }()
    let fullScreenOrigin: CGPoint = {
        let x = CGFloat(0)
        var y = CGFloat(UIScreen.main.bounds.origin.y)
        
        let coordinate = CGPoint.init(x: x, y: y)
        return coordinate
    }()
    var updateOrderList:(() -> Void)!
    var transfer_group = ""
    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        if let storid = ordedrDetail?.storeId{
            self.transfer_group =  "tr_gp_maas_" + storid
        }
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.showIndicator()
        getStoreInfoAPI()
        self.getOrderDetailByOrderID()
        //        updateUI(orderInfo: nil)
        
        
        getStoreInfoAPI(store_id:ordedrDetail?.storeId ?? "" )
    }
    func getStoreInfoAPI(){
        
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: Singleton.sharedInstance.storeInfo?.storeId ?? "", type: "store") {storeInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
                if storeInfo?.settings?.lowercased() == "enable"{
                    Singleton.sharedInstance.storeInfo = storeInfo
                    self.lblDate.text = storeInfo?.storeName ?? ""
                    //                    self.storeID = Singleton.sharedInstance.storeInfo.storeId ?? ""
                    
                }else{
                    
                    
                }
                //  FTIndicator.showToastMessage(msg)
            }
        }
    }
    //MARK: ************UPDATE NO DATA FOUND
    func updateNoData(message:String){
        if message == "" {
            self.tblBatchOrderDetail.backgroundView = UIView()
        }else{
            let vwNoData = ViewNoData()
            self.tblBatchOrderDetail.backgroundView = vwNoData
            vwNoData.center.x = self.view.center.x
            vwNoData.center.y =  self.view.center.y
            vwNoData.label.text = message
        }
    }
    
    func updateUIByBatchID(orderInfo :OrderInfo?){
        let currency = Singleton.sharedInstance.storeInfo?.storeName
        let s = currency?.split(separator: " ")
        print("currency type   ",s ?? "")
        if  s?.last ?? "" == "INR"{
            stackBottomSheet.subviews[3].isHidden = false
            stackBottomSheet.subviews[5].isHidden = true
            stackBottomSheet.subviews[4].isHidden = false
            //  secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            
            //  StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
            
        }else if s?.last ?? "" == "GBP"{
            stackBottomSheet.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackBottomSheet.subviews[5].isHidden = false
                }else{
                    stackBottomSheet.subviews[5].isHidden = true
                }
            }
            stackBottomSheet.subviews[3].isHidden = true
            
            
            //  secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            // StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
            
            
        }else if s?.last ?? "" == "EUR"{
            stackBottomSheet.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackBottomSheet.subviews[5].isHidden = false
                }else{
                    stackBottomSheet.subviews[5].isHidden = true
                }
            }
            stackBottomSheet.subviews[3].isHidden = true
            // secretKey = "sk_test_51LkT1vJKgibxtlZSWeBBdvrcpUGjaUAv8h2tjNQvgGpmptjCoL4JgJBYt4P041iuJmGGfZmYIwPGgNuznzuYy9rV005uHJUesP"
            //   StripeAPI.defaultPublishableKey = "pk_test_51LkT1vJKgibxtlZSQc4QsbGrC2kNuv3MpJ9OKsHfDwA3LlmHEkDV4MgRmrtaWHnr5Cu9iP8vDFEDH0Tav084I8Br00YpXYSCX7"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYBELGIUM ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYBELGIUM ?? ""
            }
            
        }else{
            stackBottomSheet.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackBottomSheet.subviews[5].isHidden = false
                }else{
                    stackBottomSheet.subviews[5].isHidden = true
                }
            }
            stackBottomSheet.subviews[3].isHidden = true
            //  secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            // StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
            
            
        }
        
        
        if let object =  Singleton.sharedInstance.storeInfo{
            if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                stackBottomSheet.subviews[5].isHidden = false
            }else{
                stackBottomSheet.subviews[5].isHidden = true
            }
        }
        
        //        lblConsumerName.text = "Store Name"
        //        lblMobile.text = ordedrDetail.storeName ?? ""
        //        lblStoreTypeCategory.text = ordedrDetail.category?.capitalized ?? ""
        //        retailerName.text = ordedrDetail.retailerName ?? ""
        lblOrderID.text = orderBatchInfo?.orderId ?? ""
        //        let currencySymbol = ordedrDetail.currencySymbol
        lblTTTotal.text = "Date"
        lblTotal.text = ordedrDetail.orderdate ?? ""//"\(currencySymbol ?? "") \(orderBatchInfo?.totalAmount ?? "")"
        lblStatus.text = orderBatchInfo?.paymentStatus?.capitalized ?? ""
        lblStatusReason.text = orderBatchInfo?.subStatus ?? ""
        //
        lblTDate.text = "Store Name"
        // cell.btnDownload.addTarget(self, action: #selector(btnDownloadInvoice(sender:)), for: .touchUpInside)
        
        if self.orderType == ""{
            ordertypeLabel.text = ""
        }else{
            ordertypeLabel.text = self.orderType
        }
        
        //        if orderBatchInfo?.subStatus ?? "" == ""{
        //            StackPaymentStatus.subviews[1].isHidden = true
        //        }else{
        //            StackPaymentStatus.subviews[1].isHidden = false
        //        }
//        if orderBatchInfo?.paymentStatus!.lowercased() == "completed"{
//            // cell.btnDownload.alpha = 0
//            lblStatus.textColor = hexStringToUIColor(hex: Color.greenApproved.rawValue)
//        }else if orderBatchInfo?.paymentStatus!.lowercased() == "pending" {
//            //   cell.btnDownload.alpha = 1
//            lblStatus.textColor = hexStringToUIColor(hex: Color.pending.rawValue)
//        }else{
//            //  cell.btnDownload.alpha = 0
//            lblStatus.textColor = hexStringToUIColor(hex: Color.red_error.rawValue)
//        }
        
        if orderBatchInfo?.paymentStatus ?? "".lowercased() == "complete"{
            // cell.btnDownload.alpha = 0
            self.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.greenApproved.rawValue)
            self.imgStatus.image = UIImage(named: "ic_status_complete")
        }else if orderBatchInfo?.paymentStatus ?? "".lowercased() == "pending" {
            //   cell.btnDownload.alpha = 1
            self.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
            self.imgStatus.image = UIImage(named: "ic_status_pending")
        }else if orderBatchInfo?.paymentStatus ?? "".lowercased() == "prepared"{
            //  cell.btnDownload.alpha = 0
            self.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.prepared.rawValue)
            self.imgStatus.image = UIImage(named: "ic_status_prepared")
        }else if orderBatchInfo?.paymentStatus ?? "".lowercased() == "preparing"{
            //  cell.btnDownload.alpha = 0
            self.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.preparing.rawValue)
            self.imgStatus.image = UIImage(named: "ic_status_preparing")
        }else if orderBatchInfo?.paymentStatus ?? "".lowercased() == "rejected" || orderInfo?.paymentStatus ?? "".lowercased() == "cancel"{
            //  cell.btnDownload.alpha = 0
            self.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.cancel.rawValue)
            self.imgStatus.image = UIImage(named: "ic_status_cancel")
        }else{
            self.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
            self.imgStatus.image = UIImage(named: "ic_status_pending")
        }
        
        vwBottomPayment.alpha = 0
        self.view.addSubview(vwBottomPayment)
        hideBottomVw(vw: vwBottomPayment)
        let currencySymbol1 = ordedrDetail.currencySymbol ?? ""
        if orderInfo == nil{
            lblPaymentMethod.text = ordedrDetail.paymentMethod ?? ""
            lblPaymentID.text = ordedrDetail.transactionId ?? ""
            if ordedrDetail.transactionId ?? "" == ""{
                stackTotalAmount.subviews[1].isHidden = true
            }else{
                stackTotalAmount.subviews[1].isHidden = false
            }
            lblTTotal.text = "\(currencySymbol1 ) \(ordedrDetail.totalAmount ?? "")"
            
            if ordedrDetail.status!.uppercased() ==  "PENDING"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
                btnDownloadPay.alpha = 1
            }else if ordedrDetail.status!.uppercased()   == "COMPLETED" || ordedrDetail.status!.uppercased()   == "COMPLETE"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Download Invoice", for: .normal)
                btnDownloadPay.alpha = 1
            }else{
                stackTotalAmount.subviews[3].isHidden = true
                btnDownloadPay.alpha = 0
                // btnDownloadPay.setTitle("Pay Now", for: .normal)
            }
        }else{
            lblPaymentMethod.text = orderInfo?.paymentMethod ?? ""
            lblPaymentID.text = orderInfo?.paymentId ?? ""
            if orderInfo?.paymentId ?? "" == ""{
                stackTotalAmount.subviews[1].isHidden = true
            }else{
                stackTotalAmount.subviews[1].isHidden = false
            }
            if orderInfo?.paymentMethod ?? "" == ""{
                stackTotalAmount.subviews[0].isHidden = true
            }else{
                stackTotalAmount.subviews[0].isHidden = false
            }
            lblTTotal.text = "\(currencySymbol1 ) \(orderInfo?.totalAmount ?? "")"
            
            if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
                btnDownloadPay.alpha = 1
            }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETED" || orderInfo?.paymentStatus!.uppercased()   == "COMPLETE"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Download Invoice", for: .normal)
                btnDownloadPay.alpha = 1
            }else{
                stackTotalAmount.subviews[3].isHidden = true
                btnDownloadPay.alpha = 0
                // btnDownloadPay.setTitle("Pay Now", for: .normal)
            }
        }
    }
    //MARK: SHOW HIDE BOTTTOM SHEETS
    @objc func hideBottomVw(vw:UIView){
        //   self.inputField.text = ""
        //    self.inputField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            vw.frame.origin = self.hiddenOrigin
            vw.layoutIfNeeded()
            vw.alpha = 0
        })
    }
    func showBottomVw(vw:UIView){
        //   style()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [.beginFromCurrentState], animations: {
            vw.frame.origin = self.fullScreenOrigin
            vw.frame = CGRect.init(origin: self.fullScreenOrigin, size: self.fullScreenSize)
            // self.inputField.becomeFirstResponder()
            vw.layoutIfNeeded()
            vw.alpha = 1
        })
    }
    //MARK: - ORDER SUCCESS API
    func orderSuccessAPI(order_id: String, transaction_id: String, cart_main_id: String, payment_method: String, inventory: String, vertical: String, store_type: String, method_type: String, response_type: String, reason: String,taxi_id:String,transfer_group:String = ""){
        showIndicator()
        WebServiceManager.sharedInstance.orderSuccessAPI(storeID: ordedrDetail.storeId!, order_id: order_id, transaction_id: transaction_id, cart_main_id: cart_main_id, payment_method: payment_method, inventory: inventory, vertical: vertical, store_type: store_type, method_type: method_type, response_type: response_type, reason: reason,room_id: "", doctor_id: "", taxi_id: taxi_id,transfer_group:transfer_group) { id, msg, status in
            self.hideIndicator()
            if status == "1"{
                self.updateOrderList()
                self.getOrderDetailByOrderID()
                let drpDwn =  DropdownActionPopUp.init(title: "Payment done successfully",header:"Success", action: .Okay, type: .none, sender: self,image: UIImage(named: "Success"),tapDismiss:true)
                drpDwn.alertActionVC.delegate = self
            }else{
                self.getOrderDetailByOrderID()
                let drpDwn = DropdownActionPopUp.init(title: msg!,header:"Payment Failed",  action:.Okay, type: .none, sender: self,image: UIImage(named: "fail"),tapDismiss:true)
                drpDwn.alertActionVC.delegate = self
                // FTIndicator.showToastMessage(msg!)
            }
            
        }
    }
    //MARK: BUTTON ACTION
    @IBAction func btnBackAction(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDownloadInvoice(sender:UIButton){
        if sender.currentTitle == "Download Invoice"{
            guard let url = orderBatchInfo?.invoiceLink else{return}
            FTIndicator.showToastMessage("Downloding...")
            WebServiceManager.sharedInstance.downloadFile(url: url) { fileURL, progressCompleted, msg, downloaded in
                switch msg{
                case "Error":
                    self.dismiss(animated: true, completion: {
                        FTIndicator.showToastMessage("Downloding error from server.")
                    })
                case "Success":
                    self.dismiss(animated: true, completion:{
                        let activityViewController = UIActivityViewController(activityItems: [fileURL!], applicationActivities: nil)
                        activityViewController.excludedActivityTypes = [.markupAsPDF,.openInIBooks]
                        activityViewController.popoverPresentationController?.sourceView = UIView()
                        UIApplication.shared.keyWindow?.rootViewController!.present(activityViewController, animated: true, completion: nil)
                    })
                case "":
                    print(progressCompleted)
                    //                var newProgress: CGFloat = self.progressVW.progress
                    //                newProgress = CGFloat(progressCompleted)
                    //                self.progressVW.animateTo(progress: newProgress)
                default:
                    break
                }
            }
        }else{
            guard storeInfo != nil else{ FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
                return
            }
            let currencySymbol = ordedrDetail.currencySymbol
            if orderBatchInfo != nil{
                self.lblBottomVwTotal.text = "Total Bill: \(currencySymbol ?? "") \(orderBatchInfo?.totalAmount ?? "")"
                showBottomVw(vw: vwBottomPayment)
            }
            
        }
    }
    @IBAction func btnBottomVwHideAction(_ sender: UIButton) {
        hideBottomVw(vw: vwBottomPayment)
    }
    @IBAction func btnStripPayment(_ sender: Any) {
        let amount1 = (Double(orderBatchInfo?.totalAmount ?? "0") ?? 0)
        let newAmount = Int(amount1)
        if newAmount <= 999999{
            self.createCustomer()
        }else{
            
            FTIndicator.showToastMessage(StoreConstant.TenLakhEX)
        }
        
        
    }
    
    @IBAction func btnPaymentAction(_ sender: UIButton) {
        
        switch sender.tag{
        case 100:
            print( "Gpay")
            upiPaymentAction(type: "Gpay")
        case 200:
            print( "Paytm")
            upiPaymentAction(type: "Paytm")
        case 300:
            print( "PhonePe")
            upiPaymentAction(type: "PhonePe")
        case 400:
            print( "Online")
            self.paymentMethod =  "Online"
            self.openRazorpayCheckout()
            //product/restaurant/salon
        case 500:
            guard storeInfo != nil else{ FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
                return
            }
            orderSuccessAPI(order_id: self.orderBatchInfo?.orderId ?? "", transaction_id: "", cart_main_id: orderBatchInfo?.cartMainId ?? "", payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: "Cash", response_type: "Completed", reason: "Transaction successful.", taxi_id: orderBatchInfo?.productList?.first?.taxiId ?? "")
            print( "Cash")
        default:break
        }
        
        hideBottomVw(vw: vwBottomPayment)
        
    }
    //MARK: - GET STORE INFO
    func getStoreInfoAPI(store_id:String){
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: store_id, type: "store") {storeInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
                self.storeInfo = storeInfo
                self.lblDate.text = storeInfo?.storeName ?? ""
                // self.lblTitle.text = storeInfo?.storeName
                //  FTIndicator.showToastMessage(msg)
            }else{
                FTIndicator.showToastMessage(msg)
            }
        }
    }
    //MARK: - ORDER DETAIL BY ID
    func getOrderDetailByOrderID(){
        WebServiceManager.sharedInstance.getOrderDetails(vertical: ordedrDetail?.category ?? "", orderID: ordedrDetail?.orderId ?? "", user_id: Singleton.sharedInstance.userInfo.userId ?? "", paymentMethod: ordedrDetail?.storePaymentType ?? "", product_type: "Product") { orderInfo, msg, status in
            self.isLodinData = false
            self.hideIndicator()
            if status == "1"{
                //                    self.imgEmptyImage.alpha = 0
                //                    self.lblNoDataFound.alpha = 0
                self.tblBatchOrderDetail.alpha = 1
                self.orderBatchInfo = orderInfo
                print("Taxi Id from product list ==?",self.orderBatchInfo?.productList?.first?.taxiId ?? "")
                //                self.createCustomer()
                self.tblBatchOrderDetail.reloadData()
                //                    self.updateUI(orderInfo: orderInfo)
                self.updateUIByBatchID(orderInfo: orderInfo)
                self.updateNoData(message: "")
            }else if status == "0"{
                self.updateNoData(message: msg!)
                //                    self.imgEmptyImage.alpha = 1
                //                    self.lblNoDataFound.alpha = 1
                self.tblBatchOrderDetail.alpha = 0
                self.tblBatchOrderDetail.reloadData()
            }
        }
    }
    //MARK: - ADD ACTIVITY
    func addActivity(store_id:String,status_comment:String){
        //  Item Added to Cart
        //            Order Placed
        //            Visit
        WebServiceManager.sharedInstance.addUserHistoryAPI(store_id: store_id, status_comment: status_comment) { msg, status in
            if status == "1"{
                
            }else{
                
            }
        }
    }
    func upiPaymentAction(type:String){
        let paValue = "Q204475529@ybl"     //payee address upi id
        let pnValue = "Merchant Name"     // payee name
        let trValue = "1234ABCD"          //tansaction Id
        let urlValue = "http://url/of/the/order/in/your/website" //url for refernec
        let mcValue = "1234"            // retailer category code :- user id
        let tnValue = "Purchase in Merchant" //transction Note
        let amValue = "1"             //amount to pay
        let cuValue = "INR"          //currency
        var str = String()
        if type == "Paytm"{
            str = "paytm://upi/pay?pa=\(paValue)&pn=\(pnValue)&tr=\(trValue)&mc=\(mcValue)&tn=\(tnValue)&am=\(amValue)&cu=\(cuValue)"
        }else if type == "Gpay"{
            str = "gpay://upi/pay?pa=\(paValue)&pn=\(pnValue)&tr=\(trValue)&mc=\(mcValue)&tn=\(tnValue)&am=\(amValue)&cu=\(cuValue)"
        } else if type == "PhonePe"{
            str = "phonepe://upi/pay?pa=\(paValue)&pn=\(pnValue)&tr=\(trValue)&mc=\(mcValue)&tn=\(tnValue)&am=\(amValue)&cu=\(cuValue)"
        }
        
        guard let urlString = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else {
            return
        }
        
        guard let url = URL(string: urlString) else{
            return
        }
        UIApplication.shared.open(url)
    }
    @IBAction func btnProceedCheckOutAction(_ sender: UIButton) {
        
    }
    //MARK: -  Strip Setup
    func createCustomer(){
        self.showIndicator()
        let url = URL(string: "https://api.stripe.com/v1/customers")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let clientSecret = json["id"] as? String
            else {
                let message = error?.localizedDescription ?? "Failed to decode response from server."
                //                self?.displayAlert(title: "Error loading page", message: message)
                print("Error loading page")
                return
            }
            self?.customerID = clientSecret
            self?.fetchPaymentIntent()
            
        })
        
        task.resume()
    }
    func fetchPaymentIntent() {
        var amount = Double()
        
        let currency = storeInfo?.storeName
        var currencyName = "GBP"
        if let s = currency?.split(separator: " "){
            currencyName = String(s.last ?? "")
        }
        
        amount = (Double(orderBatchInfo?.totalAmount ?? "0") ?? 0) * Double(100)
        let newAmount = Int(amount)
        
        let parameters = "currency=\(currencyName)&amount=\(String(newAmount))&customer=\(self.customerID ?? "")"
        let postData =  parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: "https://api.stripe.com/v1/payment_intents")!,timeoutInterval: Double.infinity)
        request.addValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!)
            
            let jsonString = (String(data: data, encoding: .utf8)!)
            let dataa: Data? = jsonString.data(using: .utf8)
            let json = (try? JSONSerialization.jsonObject(with: dataa!, options: [])) as? [String:AnyObject]
            print(json ?? "Empty Data")
            self.stripTransctionId = json?["id"] as? String ?? ""
            self.paymentIntentClientSecret = json?["client_secret"] as? String ?? ""
            DispatchQueue.main.async {
                self.hideIndicator()
                
                self.pay()
            }
        }
        
        task.resume()
        
        
        
    }
    
    func pay(){
        //        self.payButton.isEnabled = false
        guard let paymentIntentClientSecret = self.paymentIntentClientSecret else {
            return
        }
        
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "BBC"
        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentClientSecret,
            configuration: configuration)
        
        paymentSheet.present(from: self) { [weak self] (paymentResult) in
            
            switch paymentResult {
            case .completed:
                self?.orderSuccessAPI(order_id: self?.orderBatchInfo?.orderId ?? "", transaction_id: self?.stripTransctionId ?? "", cart_main_id: self?.orderBatchInfo?.cartMainId ?? "", payment_method: self?.storeInfo.paymentMethod ?? "", inventory: self?.storeInfo.inventory ?? "", vertical: self?.storeInfo.category ?? "", store_type: self?.storeInfo.storeType ?? "", method_type: EndPoint.methodType, response_type: "Completed", reason: "Transaction successful.", taxi_id: self?.orderBatchInfo?.productList?.first?.taxiId ?? "",transfer_group: self?.transfer_group ?? "")
                //                self?.displayAlert(title: "Payment complete!")
                self?.dismiss(animated: true)
            case .canceled:
                print("Payment canceled!")
                //                let storeInfo = Singleton.sharedInstance.storeInfo!
                self?.orderSuccessAPI(order_id: self?.orderBatchInfo?.orderId ?? "", transaction_id: self?.stripTransctionId ?? "", cart_main_id: self?.orderBatchInfo?.cartMainId ?? "", payment_method: self?.storeInfo.paymentMethod ?? "", inventory: self?.storeInfo.inventory ?? "", vertical: self?.storeInfo.category ?? "", store_type: self?.storeInfo.storeType ?? "", method_type: EndPoint.methodType, response_type: "Cancelled", reason: "Payment cancelled by user.", taxi_id: self?.orderBatchInfo?.productList?.first?.taxiId ?? "",transfer_group: self?.transfer_group ?? "")
                
            case .failed(let error):
                self?.displayAlert(title: "Payment failed", message: error.localizedDescription)
            }
        }
    }
    func displayAlert(title: String, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let stripeHandled = StripeAPI.handleURLCallback(with: url)
        if (stripeHandled) {
            return true
        } else {
            // This was not a stripe url – do whatever url handling your app
            // normally does, if any.
        }
        return false
    }
    
    // This method handles opening universal link URLs (for example, "https://example.com/stripe_ios_callback")
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                let stripeHandled = StripeAPI.handleURLCallback(with: url)
                if (stripeHandled) {
                    return true
                } else {
                    // This was not a stripe url – do whatever url handling your app
                    // normally does, if any.
                }
            }
        }
        return false
    }
    
}
//MARK: TABLEVIEW DELEGATE AND DATA SOURCE
extension CabOrderDetailVC : UITableViewDelegate,UITableViewDataSource{
    //    func numberOfSections(in tableView: UITableView) -> Int {
    //        guard isLodinData == false else{return 1}
    //
    //            return orderBatchInfo?.orderData?.count ?? 0
    //
    //
    //    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isLodinData == false else{return 5}
        return orderBatchInfo?.productList?.count ?? 0
        //        return orderBatchInfo?.orderData?[section].orderInfo?.productList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblBatchOrderDetail.dequeueReusableCell(withIdentifier: "cabOrderDetailCell", for: indexPath) as! cabOrderDetailCell
        guard isLodinData == false else{return cell}
        cell.setTemplateWithSubviews(isLodinData)
        let product = self.orderBatchInfo?.productList?[indexPath.row]
        cell.lblName.text = product?.driverName
        cell.lblServiceName.text = product?.ProductName
        //        cell.lblTaxiNumber.text = "Taxi Number: \(product?.taxiNumber ?? "")"
        cell.lblDistance.text = "Distance: \(product?.ProductQuantity ?? "")km"
        self.count =  self.orderBatchInfo?.productList?.count ?? 0
        print("Product Count -- ? " ,self.count,indexPath.section)
        cell.lblTime.text = "\(product?.slotDate ?? "") (\(product?.slotTime ?? ""))"
        cell.lblTime.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        //        if orderBatchInfo?.paymentStatus!.lowercased() == "complete"{
        //            cell.btnDeleteItem.isHidden = true
        //        }else{
        //            if self.count > 1{
        //                cell.btnDeleteItem.isHidden = false
        //            }else{
        //                cell.btnDeleteItem.isHidden = true
        //            }
        //        }
        let url = URL(string: product?.ProductMediumImage ?? "")
        cell.imgProduct.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"))
        cell.lblDropLocation.text = product?.to_address ?? ""
        cell.lblPickupLocation.text = product?.from_address ?? ""
        //        if self.count > 1{
        //            cell.btnDeleteItem.isHidden = false
        //        }else{
        //            cell.btnDeleteItem.isHidden = true
        //        }
        
        //            cell.btnDeleteItemHander = {
        //                self.showIndicator()
        //                self.ApiDeleteOrderItem(cart_id: self.orderBatchInfo?.orderData?[indexPath.section].orderInfo?.cartMainId ?? "", user_id: Singleton.sharedInstance.userInfo.userId ?? "", product_id: product?.ProductId ?? "", vertical: self.ordedrDetail.category ?? "", inventory: self.storeInfo.inventory ?? "", order_id:  self.orderBatchInfo?.orderData?[indexPath.section].orderInfo?.orderId ?? "", payment_method: self.ordedrDetail.storePaymentType ?? "", status: self.orderBatchInfo?.orderData?[indexPath.section].orderInfo?.orderStatus ?? "")
        //            }
        // cell.lblMainCategory.text = product.MainCategory
        // cell.lblDescription.text = product.ProductSHORTDESCRIPTION
        
        // cell.lblCostPrice.attributedText = "₹ \(product.ProductPrice!)".strikeThrough()
        let currencySymbol = ordedrDetail.currencySymbol
        
        cell.lblPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")(per km)"
        
        
        return cell
    }
    func getAttrbText(simpleText:String,text:String) -> NSMutableAttributedString{
        
        let range = (text as NSString).range(of: String(text))
        let range1 = (text as NSString).range(of: String(simpleText))
        
        let attribute = NSMutableAttributedString.init(string: text)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Montserrat-SemiBold", size: 14)!, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Montserrat-Regular", size: 14)!, range: range1)
        return attribute
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}
//MARK: - RAZORPAY HANDLING *******DELEGATES HANDLING
extension CabOrderDetailVC :RazorpayPaymentCompletionProtocol,RazorpayPaymentCompletionProtocolWithData,SFSafariViewControllerDelegate{
    
    func openRazorpayCheckout() {
        // 1. Initialize razorpay object with provided key. Also depending on your requirement you can assign delegate to self. It can be one of the protocol from RazorpayPaymentCompletionProtocolWithData, RazorpayPaymentCompletionProtocol.
        razorpayObj = RazorpayCheckout.initWithKey(RazorpayConstants.razorpayKey, andDelegate: self)
        let logo = UIImage(named:"logoBig")!
        let imageData = logo.jpegData(compressionQuality: 1)!
        let logoBase64 =  imageData.base64EncodedString()
        let  totalAmmount = (Int(orderBatchInfo?.totalAmount ?? "0") ?? 0) * 100
        let options: [String:Any] = [
            "image":logo,
            "amount": String(totalAmmount), //This is in currency subunits. 100 = 100 paise= INR 1.
            "currency": "INR",//We support more that 92 international currencies.
            "description": "Order Payment",
            //"order_id": orderInfo.orderId ?? "",
            "name": "MAAS",
            "prefill": [
                "contact": Singleton.sharedInstance.userInfo.mobile,
                "email": Singleton.sharedInstance.userInfo.email
            ],
            "theme": [
                "color":"#b22724"
            ],
            "method": [
                "card": "1",
                "netbanking":"1",
                "upi": "0",
                "wallet": "0",
                "emi": "0"
            ]
            // follow link for more options - https://razorpay.com/docs/payment-gateway/web-integration/standard/checkout-form/
        ]
        if let rzp = self.razorpayObj {
            rzp.open(options)
        } else {
            print("Unable to initialize")
        }
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        print("error: ", code, str)
        guard storeInfo != nil else{FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
            return
        }
        orderSuccessAPI(order_id: orderBatchInfo?.orderId ?? "", transaction_id: "", cart_main_id: orderBatchInfo?.cartMainId ?? "", payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: ordedrDetail.category ?? "", store_type: ordedrDetail.storeType ?? "", method_type: "Online", response_type: "Cancelled", reason: "Payment cancelled by user.", taxi_id: self.orderBatchInfo?.productList?.first?.taxiId ?? "")
        
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
        guard storeInfo != nil else{FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
            return
        }
        orderSuccessAPI(order_id: orderBatchInfo?.orderId ?? "", transaction_id: payment_id, cart_main_id: orderBatchInfo?.cartMainId ?? "", payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: "Online", response_type: "Completed", reason: "Transaction successful.", taxi_id: self.orderBatchInfo?.productList?.first?.taxiId ?? "")
    }
    //COMPLETION PROTOCOL
    // RazorpayPaymentCompletionProtocol - This will execute two methods 1.Error and 2. Success case. On payment failure you will get a code and description. In payment success you will get the payment id.
    func onPaymentError(_ code: Int32, description str: String, andData response: [AnyHashable : Any]?) {
        print("error: ", code)
        //  _ = DropdownActionPopUp.init(title: str,header:"Alert",  action: .none, sender: self)
    }
    
    func onPaymentSuccess(_ payment_id: String, andData response: [AnyHashable : Any]?) {
        print("success: ", payment_id)
        // _ =  DropdownActionPopUp.init(title: "Payment Succeeded",header:"Success", action: .none, sender: self)
        
    }
    
    //SAFARI DELEGATE
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}



extension CabOrderDetailVC:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            // self.tabBarController?.selectedIndex = 2
            // self.navigationController?.popViewController(animated: true)
        }else{
            // self.navigationController?.popViewController(animated: true)
        }
    }
}
class cabOrderDetailCell : UITableViewCell{
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblTaxiNumber : UILabel!
    @IBOutlet var lblDistance : UILabel!
    @IBOutlet var lblServiceName : UILabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var lblPrice : UILabel!
    @IBOutlet var lblPickupLocation : UILabel!{
        didSet{
            lblPickupLocation.font = UIFont(name: "Montserrat-Medium", size: 13)
        }
    }
    @IBOutlet var lblDropLocation : UILabel!{
    didSet{
        lblDropLocation.font = UIFont(name: "Montserrat-Medium", size: 13)
    }
}
    @IBOutlet var imgProduct : UIImageView!
    
    @IBOutlet var lblPickup : UILabel!{
        didSet{
            lblPickup.font = UIFont(name: "Montserrat-Medium", size: 12)
        }
    }
    @IBOutlet var lblDrop : UILabel!{
        didSet{
            lblDrop.font = UIFont(name: "Montserrat-Medium", size: 12)
        }
    }
}
