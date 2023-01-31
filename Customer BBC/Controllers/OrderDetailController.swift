//
//  OrderDetailController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 09/05/22.
//


import UIKit
import FTIndicator
import UIView_Shimmer
import Razorpay
import SafariServices
import Stripe

var secretKey = ""
var publishKey = ""

class OrderDetailController: UIViewController, RescheduleBack , cancelBooking ,confirmReschedule {
    func appointmentResponse() {
        self.pushToReschedule()
    }
    
    func cancelConfirm() {
        showIndicator()
        self.apiCancelBooking()
    }
    
    func callBackForReschdule() {
        self.getOrderDetailByOrderID()
    }
    var transfer_group = ""
    
    
    //MARK: - IBOUTLET
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var lblPaymentMethod: UILabel!
    @IBOutlet weak var lblPaymentID: UILabel!
    @IBOutlet weak var lblTitleMain: UILabel!{
        didSet{
            lblTitleMain.font = UIFont(name: "Montserrat-SemiBold", size: 16)
        }
    }
    @IBOutlet weak var stackTotalAmount: UIStackView!
    @IBOutlet weak var lblTTotal: UILabel!
    @IBOutlet weak var lblBottomVwTotal: UILabel!
    @IBOutlet weak var btnDownloadPay: UIButton!
    @IBOutlet var vwBottomPayment: UIView!
    @IBOutlet var vwnormalPayment: UIView!
    @IBOutlet weak var stackBottomSheet: UIStackView!
    @IBOutlet var imgEmptyImage : UIImageView!{
        didSet{
            imgEmptyImage.alpha = 0
        }
    }
    @IBOutlet weak var stackNetTotal: UIStackView!
    @IBOutlet weak var stackTax: UIStackView!
    @IBOutlet weak var labelTax: UILabel!
    @IBOutlet weak var labelNetTotal: UILabel!
    
    @IBOutlet weak var labelTaxConstant: UILabel!
    @IBOutlet weak var labelNetTotalConstant: UILabel!
    
    
    
    
    @IBOutlet var lblNoDataFound : UILabel!{
        didSet{
            lblNoDataFound.alpha = 0
        }
    }
    //MARK: - VARIABLES
    private static let backendURL = URL(string: "https://api.stripe.com/v1/")!
    
    private var paymentIntentClientSecret: String?
    private var customerID: String?
    
    private var isLodinData = true
    var ordedrDetail : OrderList?
    var orderInfo : OrderInfo?
    var orderBatchInfo : OrderBatchInfo?
    let sectionTitles = ["","Customer Name","Details"]
    var storeInfo : StoreInfo?
    var orderType = ""
    var storeID = ""
    var count = 0
    var category = ""
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
    //MARK: - IBACTIONS
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnDownloadInvoice(sender:UIButton){
        if sender.currentTitle == "Download Invoice"{
            guard let url = orderInfo?.invoiceLink else{return}
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
            //           guard storeInfo != nil else{ FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
            //               return
            //           }
            let currencySymbol = ordedrDetail?.currencySymbol
            if orderInfo != nil{
                self.lblBottomVwTotal.text = "Total Bill: \(currencySymbol ?? "") \(orderInfo?.GrandTotal ?? "")"
                showBottomVw(vw: vwBottomPayment)
            }
            
        }
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
        
        
        amount = (Double(orderInfo?.totalAmount ?? "0") ?? 0) * Double(100)
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
                self?.orderSuccessAPI(order_id: self?.orderInfo?.orderId ?? "", transaction_id: self?.stripTransctionId ?? "", cart_main_id: self?.orderInfo?.cartMainId ?? "", payment_method: self?.storeInfo?.paymentMethod ?? "", inventory: self?.storeInfo?.inventory ?? "", vertical: self?.storeInfo?.category ?? "", store_type: self?.storeInfo?.storeType ?? "", method_type: EndPoint.methodType, response_type: "Completed", reason: "Transaction successful.",transfer_group: self?.transfer_group ?? "")
                //                self?.displayAlert(title: "Payment complete!")
                self?.dismiss(animated: true)
            case .canceled:
                print("Payment canceled!")
                //                let storeInfo = Singleton.sharedInstance.storeInfo!
                self?.orderSuccessAPI(order_id: self?.orderInfo?.orderId ?? "", transaction_id: self?.stripTransctionId ?? "", cart_main_id: self?.orderInfo?.cartMainId ?? "", payment_method: self?.storeInfo?.paymentMethod ?? "", inventory: self?.storeInfo?.inventory ?? "", vertical: self?.storeInfo?.category ?? "", store_type: self?.storeInfo?.storeType ?? "", method_type: EndPoint.methodType , response_type: "Cancelled", reason: "Payment cancelled by user.",transfer_group: self?.transfer_group ?? "")
                
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
    @IBAction func btnBottomVwHideAction(_ sender: UIButton) {
        hideBottomVw(vw: vwBottomPayment)
    }
    @IBAction func btnStripPayment(_ sender: Any) {
        let  amount1 =  (Double(orderInfo?.totalAmount ?? "0") ?? 0)
        let newAmount = Int(amount1)
        if newAmount <= 999999{
            self.createCustomer()
        }else{
            
            FTIndicator.showToastMessage(StoreConstant.TenLakhEX)
        }
        
        
    }
    func getStoreInfoAPI(){
        
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: storeID, type: "store") {storeInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
                if storeInfo?.settings?.lowercased() == "enable"{
                    Singleton.sharedInstance.storeInfo = storeInfo
                    self.storeID = Singleton.sharedInstance.storeInfo.storeId ?? ""
                    
                }else{
                    
                    
                }
                //  FTIndicator.showToastMessage(msg)
            }
        }
    }
    @IBAction func btnPaymentAction(_ sender: UIButton) {
        //        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as! CheckoutViewController
        ////        vc.ordedrDetail = order
        ////        vc.orderType = order.order_type ?? ""
        ////        vc.updateOrderList = {
        ////            let jsonEncoder = JSONEncoder()
        ////            do {
        ////                let jsonData = try jsonEncoder.encode(self.commonFilter)
        ////                let jsonString = String(data: jsonData, encoding: .utf8)
        ////                self.getOrderListAPI(page: self.page, commonFilter: jsonString!)
        ////                print("JSON String : " + jsonString!)
        ////            }
        ////            catch {
        ////            }
        ////        }
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        
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
            //            guard storeInfo != nil else{ FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
            //                return
            //            }
            orderSuccessAPI(order_id: self.orderInfo?.orderId ?? "", transaction_id: "", cart_main_id: orderInfo?.cartMainId ?? "", payment_method: storeInfo?.paymentMethod ?? "", inventory: storeInfo?.inventory ?? "", vertical: storeInfo?.category ?? "", store_type: storeInfo?.storeType ?? "", method_type: "Cash", response_type: "Completed", reason: "Transaction successful.")
            print( "Cash")
        default:break
        }
        
        hideBottomVw(vw: vwBottomPayment)
        
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
    //MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        if let storid = ordedrDetail?.storeId{
            self.transfer_group =  "tr_gp_maas_" + storid
        }
        
        //        getStoreInfoAPI()
        //        updateUI(orderInfo: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        getStoreInfoAPI()
        self.getOrderDetailByOrderID()
        updateUI(orderInfo: nil)
        
        self.stackTax.isHidden = true
        self.stackNetTotal.isHidden = true
        getStoreInfoAPI(store_id:ordedrDetail?.storeId ?? "" )
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let footerView = self.tblVw.tableFooterView else {
            return
        }
        let width = self.tblVw.bounds.size.width
        let size = footerView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
        if footerView.frame.size.height != size.height {
            footerView.frame.size.height = size.height
            self.tblVw.tableFooterView = footerView
        }
    }
    //MARK: ************UPDATE NO DATA FOUND
    func updateNoData(message:String){
        if message == "" {
            self.tblVw.backgroundView = UIView()
        }else{
            let vwNoData = ViewNoData()
            self.tblVw.backgroundView = vwNoData
            vwNoData.center.x = self.view.center.x
            vwNoData.center.y =  self.view.center.y
            vwNoData.label.text = message
        }
    }
    //MARK: - UPDATE UI
    func updateUI(orderInfo :OrderInfo?){
        let currency = Singleton.sharedInstance.storeInfo?.storeName
        let s = currency?.split(separator: " ")
        print(s)
        
        if  s?.last ?? "" == "INR"{
            stackBottomSheet.subviews[3].isHidden = false
            stackBottomSheet.subviews[5].isHidden = true
            stackBottomSheet.subviews[4].isHidden = false
            /* secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
             StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
             */
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
        }else if s?.last ?? ""  == "GBP"{
            stackBottomSheet.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackBottomSheet.subviews[5].isHidden = false
                }else{
                    stackBottomSheet.subviews[5].isHidden = true
                }
            }
            stackBottomSheet.subviews[3].isHidden = true
            //secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            //StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
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
            
            // StripeAPI.defaultPublishableKey = "pk_test_51LkT1vJKgibxtlZSQc4QsbGrC2kNuv3MpJ9OKsHfDwA3LlmHEkDV4MgRmrtaWHnr5Cu9iP8vDFEDH0Tav084I8Br00YpXYSCX7"
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
            // secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            // StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
            
        }
        
        
        vwBottomPayment.alpha = 0
        self.view.addSubview(vwBottomPayment)
        hideBottomVw(vw: vwBottomPayment)
        let currencySymbol = ordedrDetail?.currencySymbol ?? ""
        if orderInfo == nil{
            lblPaymentMethod.text = ordedrDetail?.paymentMethod ?? ""
            lblPaymentID.text = ordedrDetail?.transactionId ?? ""
            if ordedrDetail?.transactionId ?? "" == ""{
                stackTotalAmount.subviews[1].isHidden = true
            }else{
                stackTotalAmount.subviews[1].isHidden = false
            }
            
            
            
            self.stackNetTotal.isHidden = true
            self.stackTax.isHidden = true
            lblTTotal.text = "\(currencySymbol ) \(ordedrDetail?.totalAmount ?? "")"
            
            var status = ordedrDetail?.status ?? ""
            status = status.uppercased()
            
            if status ==  "PENDING"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
                btnDownloadPay.alpha = 1
            }else if status   == "COMPLETED" || status == "COMPLETE"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Download Invoice", for: .normal)
                btnDownloadPay.alpha = 1
            }else if status == "CANCELLED"{
                stackTotalAmount.subviews[3].isHidden = true
                btnDownloadPay.alpha = 0
            }else if status == "PREPARED"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
                btnDownloadPay.alpha = 1
            }else{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
                btnDownloadPay.alpha = 1
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
            var taxStatus = ""
            if let tax = Singleton.sharedInstance.storeInfo{
                taxStatus = Singleton.sharedInstance.storeInfo.taxStatus ?? ""
            }
            
            if taxStatus == "enable" && Singleton.sharedInstance.storeInfo.taxType?.lowercased() != "inclusive"{
                self.stackNetTotal.isHidden = false
                self.stackTax.isHidden = false
                labelNetTotal.text = "\(currencySymbol ) \(orderInfo?.totalAmount ?? "")"
                labelTax.text = "\(currencySymbol ) \(orderInfo?.taxAmount ?? "")"
                lblTTotal.text = "\(currencySymbol ) \(orderInfo?.GrandTotal ?? "")"
                
                labelTaxConstant.text = OrderConstant.Tax
                labelNetTotalConstant.text = OrderConstant.NetTotal
                
                if orderInfo?.taxAmount == ""{
                    self.stackNetTotal.isHidden = true
                    self.stackTax.isHidden = true
                    labelTaxConstant.text = ""
                    labelNetTotalConstant.text = ""
                    
                    labelTax.text = ""
                    labelNetTotal.text = ""
                    
                }
                
            }else{
                if orderInfo?.taxAmount ?? "" == ""{
                    self.stackNetTotal.isHidden = true
                    self.stackTax.isHidden = true
                    lblTTotal.text = "\(currencySymbol ) \(orderInfo?.GrandTotal ?? "")"
                }else{
                    self.stackNetTotal.isHidden = true
                    self.stackTax.isHidden = true
                    lblTTotal.text = "\(currencySymbol ) \(orderInfo?.GrandTotal ?? "")"
                }
                
                labelTaxConstant.text = ""
                labelNetTotalConstant.text = ""
                
                labelTax.text = ""
                labelNetTotal.text = ""
            }
            if self.category == StoreCateType.hostpital{
                if storeInfo?.AppointmentConfirmation == "enable"{
                    if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                        stackTotalAmount.subviews[3].isHidden = true
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        btnDownloadPay.setTitle("Pay Now", for: .normal)
                        btnDownloadPay.alpha = 0
                    }else if orderInfo?.paymentStatus!.uppercased() ==  "ACCEPTED"{
                        stackTotalAmount.subviews[3].isHidden = false
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        btnDownloadPay.setTitle("Pay Now", for: .normal)
                        btnDownloadPay.alpha = 1
                    }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETED" || orderInfo?.paymentStatus!.uppercased()   == "COMPLETE"{
                        stackTotalAmount.subviews[3].isHidden = false
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        btnDownloadPay.setTitle("Download Invoice", for: .normal)
                        btnDownloadPay.alpha = 1
                    }else{
                        stackTotalAmount.subviews[3].isHidden = true
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        // btnDownloadPay.setTitle("Pay Now", for: .normal)
                        btnDownloadPay.alpha = 0
                    }
                }else{
                    if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                        stackTotalAmount.subviews[3].isHidden = false
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        btnDownloadPay.setTitle("Pay Now", for: .normal)
                        btnDownloadPay.alpha = 1
                    }else if orderInfo?.paymentStatus!.uppercased() ==  "ACCEPTED"{
                        stackTotalAmount.subviews[3].isHidden = false
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        btnDownloadPay.setTitle("Pay Now", for: .normal)
                        btnDownloadPay.alpha = 1
                    }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETED" || orderInfo?.paymentStatus!.uppercased()   == "COMPLETE"{
                        stackTotalAmount.subviews[3].isHidden = false
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        btnDownloadPay.setTitle("Download Invoice", for: .normal)
                        btnDownloadPay.alpha = 1
                    }else{
                        stackTotalAmount.subviews[3].isHidden = true
                        if orderInfo?.paymentMethod == ""{
                            stackTotalAmount.subviews[0].isHidden = true
                        }else{
                            stackTotalAmount.subviews[0].isHidden = false
                        }
                        // btnDownloadPay.setTitle("Pay Now", for: .normal)
                        btnDownloadPay.alpha = 0
                    }
                }
                
            }else if self.category == StoreCateType.cabService{
                if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 1
                }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETED" || orderInfo?.paymentStatus!.uppercased()   == "COMPLETE"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Download Invoice", for: .normal)
                    btnDownloadPay.alpha = 1
                }else{
                    stackTotalAmount.subviews[3].isHidden = true
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.alpha = 0
                    // btnDownloadPay.setTitle("Pay Now", for: .normal)
                }
            }else if self.category == StoreCateType.restaurant{
                if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 1
                }else if orderInfo?.paymentStatus!.uppercased() ==  "ACCEPTED"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 1
                }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETE" || orderInfo?.paymentStatus!.uppercased()   == "COMPLETED"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Download Invoice", for: .normal)
                    btnDownloadPay.alpha = 1
                }else if orderInfo?.paymentStatus!.uppercased() == "PREPARED"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 1
                }else{
                    stackTotalAmount.subviews[3].isHidden = true
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    // btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 0
                }
            }else if self.category == StoreCateType.fmcg{
                if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 1
                }else if orderInfo?.paymentStatus!.uppercased() ==  "ACCEPTED"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 1
                }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETED" || orderInfo?.paymentStatus!.uppercased()   == "COMPLETE"{
                    stackTotalAmount.subviews[3].isHidden = false
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    btnDownloadPay.setTitle("Download Invoice", for: .normal)
                    btnDownloadPay.alpha = 1
                }else{
                    stackTotalAmount.subviews[3].isHidden = true
                    if orderInfo?.paymentMethod == ""{
                        stackTotalAmount.subviews[0].isHidden = true
                    }else{
                        stackTotalAmount.subviews[0].isHidden = false
                    }
                    // btnDownloadPay.setTitle("Pay Now", for: .normal)
                    btnDownloadPay.alpha = 0
                }
            }else{
                
            }
        }
    }
    func updateUIByBatchID(orderInfo :OrderBatchInfo?){
        if  storeInfo?.currency ?? "" == "₹"{
            stackBottomSheet.subviews[3].isHidden = false
            stackBottomSheet.subviews[5].isHidden = true
            
        }else if ordedrDetail?.currencySymbol ?? "" == "£"{
            stackBottomSheet.subviews[5].isHidden = false
            stackBottomSheet.subviews[3].isHidden = false
        }else{
            stackBottomSheet.subviews[5].isHidden = true
            stackBottomSheet.subviews[3].isHidden = false
            
        }
        
        
        vwBottomPayment.alpha = 0
        self.view.addSubview(vwBottomPayment)
        hideBottomVw(vw: vwBottomPayment)
        let currencySymbol = ordedrDetail?.currencySymbol ?? ""
        if orderInfo == nil{
            lblPaymentMethod.text = ordedrDetail?.paymentMethod ?? ""
            lblPaymentID.text = ordedrDetail?.transactionId ?? ""
            if ordedrDetail?.transactionId ?? "" == ""{
                stackTotalAmount.subviews[1].isHidden = true
            }else{
                stackTotalAmount.subviews[1].isHidden = false
            }
            lblTTotal.text = "\(currencySymbol ) \(ordedrDetail?.totalAmount ?? "")"
            if ordedrDetail?.status ?? "".uppercased() ==  "PENDING"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
            }else if ordedrDetail?.status ?? "".uppercased()   == "COMPLETE"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Download Invoice", for: .normal)
            }else{
                stackTotalAmount.subviews[3].isHidden = true
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
            stackTax.isHidden = true
            stackTax.isHidden = true
            lblTTotal.text = "\(currencySymbol) \(orderInfo?.totalAmount ?? "")"
            
            if orderInfo?.paymentStatus!.uppercased() ==  "PENDING"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Pay Now", for: .normal)
            }else if orderInfo?.paymentStatus!.uppercased()   == "COMPLETE"{
                stackTotalAmount.subviews[3].isHidden = false
                btnDownloadPay.setTitle("Download Invoice", for: .normal)
            }else{
                stackTotalAmount.subviews[3].isHidden = true
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
    func orderSuccessAPI(order_id: String, transaction_id: String, cart_main_id: String, payment_method: String, inventory: String, vertical: String, store_type: String, method_type: String, response_type: String, reason: String,transfer_group:String = ""){
        showIndicator()
        WebServiceManager.sharedInstance.orderSuccessAPI(storeID: ordedrDetail?.storeId ?? "", order_id: order_id, transaction_id: transaction_id, cart_main_id: cart_main_id, payment_method: payment_method, inventory: inventory, vertical: vertical, store_type: store_type, method_type: method_type, response_type: response_type, reason: reason,room_id: self.orderInfo?.productList?.first?.roomId ?? "",doctor_id: self.orderInfo?.productList?.first?.doctorId ?? "", taxi_id: "",transfer_group:transfer_group) { id, msg, status in
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
    //MARK: - DELETE ORDER ITEM
    func ApiDeleteOrderItem(cart_id:String,user_id: String,product_id:String,vertical:String,inventory:String,order_id:String,payment_method:String,status:String){
        
        WebServiceManager.sharedInstance.getApiDeleteOrderItem(cart_id: cart_id, user_id: user_id, product_id: product_id, vertical: vertical, inventory: inventory, order_id: order_id, status: status, paymentMethod: payment_method) { msg, status in
            self.hideIndicator()
            self.getOrderDetailByOrderID()
            self.tblVw.reloadData()
        }
    }
    
    //MARK: - GET STORE INFO
    func getStoreInfoAPI(store_id:String){
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: store_id, type: "store") {storeInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
                self.storeInfo = storeInfo
                Singleton.sharedInstance.storeInfo = storeInfo
                self.getOrderDetailByOrderID()
                // self.lblTitle.text = storeInfo?.storeName
                //  FTIndicator.showToastMessage(msg)
            }else{
                FTIndicator.showToastMessage(msg)
            }
        }
    }
    //MARK: - ORDER DETAIL BY ID
    func getOrderDetailByOrderID(){
        WebServiceManager.sharedInstance.getOrderDetails(vertical: ordedrDetail?.category ?? "", orderID: ordedrDetail?.orderId ?? "", user_id: Singleton.sharedInstance.userInfo.userId ?? "", paymentMethod: ordedrDetail?.storePaymentType ?? "",product_type: "" ) { orderInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
                self.imgEmptyImage.alpha = 0
                self.lblNoDataFound.alpha = 0
                self.orderInfo = orderInfo
                //                self.createCustomer()
                self.tblVw.reloadData()
                self.updateUI(orderInfo: orderInfo)
                self.updateNoData(message: "")
            }else if status == "0"{
                self.updateNoData(message: msg!)
                self.imgEmptyImage.alpha = 1
                self.lblNoDataFound.alpha = 1
                self.tblVw.alpha = 0
                self.tblVw.reloadData()
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
    
    
    func apiCancelBooking(){
        let indexPath1 = IndexPath(row: 0, section: 2)
        
        let cell = tblVw.cellForRow(at: indexPath1) as! ProductTableCell
        
        let product = orderInfo?.productList?[indexPath1.row]
        WebServiceManager.sharedInstance.CancelOrderDetailAPI(store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", room_id: product?.roomId ?? "", slot_date: "\(product?.appointmentDate ?? "") (\(product?.appointmentTime ?? ""))", user_id: Singleton.sharedInstance.userInfo.userId ?? "", slot_id: product?.slot_id ?? "", user_name: cell.lblName.text ?? "", service_id:  product?.ProductId ?? "", vertical: "hospital", doctor_name: product?.doctorName ?? "", order_id: self.orderInfo?.orderId ?? "", status: "cancel") { msg, status in
            self.hideIndicator()
            if status == "1"{
                self.hideIndicator()
                self.getOrderDetailByOrderID()
            }else{
                self.hideIndicator()
                // FTIndicator.showToastMessage(msg!)
            }
            
        }
    }
    
    func pushToReschedule(){
        let indexPath1 = IndexPath(row: 0, section: 2)
        let cell = tblVw.cellForRow(at: indexPath1) as! ProductTableCell
        let product = orderInfo?.productList?[indexPath1.row]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleAppoinmentVC")as! ScheduleAppoinmentVC
        
        print("Doctor Id ---> ",product?.doctor_id ?? "")
        vc.doctorId = product?.doctorId ?? ""
        
        //                vc.appoinmentDate = product
        vc.productId = product?.ProductId ?? ""
        vc.room_id = product?.roomId ?? ""
        vc.product = product
        vc.orderId = self.ordedrDetail?.orderId ?? ""
        vc.iscomingFromReschedule = true
        vc.slot_id = product?.slot_id ?? ""
        vc.paymentMethod = self.orderInfo?.paymentMethod ?? ""
        vc.doctorName = product?.doctorName ?? ""
        vc.userName = self.ordedrDetail?.userName ?? ""
        vc.delegateReschedule = self
    
        vc.previousDate = "\(product?.appointmentDate ?? "") (\(product?.appointmentTime ?? ""))"
        //                vc.openCart = {
        //                    self.tabBarController?.selectedIndex = 1
        //
        //                }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension OrderDetailController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        guard isLodinData == false else{return 1}
        return 3
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = .white
        let label = UILabel()
        label.frame = CGRect.init(x: 10, y: 10, width: headerView.frame.width-20, height: 40)
        label.font = UIFont(name: "Montserrat-Bold",size: 14.0)!
        label.textColor = UIColor.black // my custom colour
        let seprator = UIView.init(frame: CGRect.init(x: 5, y: headerView.bounds.height, width: tableView.frame.width-10, height: 1))
        seprator.backgroundColor = .lightGray
        // headerView.addSubview(seprator)
        headerView.addSubview(label)
        guard isLodinData == false else{return UIView()}
        switch sectionTitles[section]{
        case "":
            return UIView()
        case "Customer Name":
            return UIView()
        case "Details":
            if self.category == StoreCateType.hostpital{
                label.text = "Appointment Details"
            }else {
                label.text = "Order Details"
            }
            
            return headerView
        default :
            return UIView()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sectionTitles[indexPath.section]{
        case "":
            return 150
        case "Customer Name":
            if self.category == StoreCateType.hostpital{
                return 0
            }else if self.category == StoreCateType.restaurant{
                return 0
            }else{
                return 0
            }
            
        case "Details":
            if self.category == StoreCateType.hostpital{
                return 190
            }else if self.category == StoreCateType.restaurant{
                return 155
            }else{
                return 155
            }
            
        default :
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard isLodinData == false else{return 0}
        if sectionTitles[section] == "" || sectionTitles[section] == "Customer Name"{
            return 0
        }else{
            return 40
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard isLodinData == false else{return 0}
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isLodinData == false else{return 5}
        //        guard orderInfo != nil else{return 0}
        
        switch sectionTitles[section]{
        case "":
            return 1
        case "Customer Name":
            return 1
        case "Details":
            guard orderInfo != nil else{return 0}
            guard let products = orderInfo?.productList  else{return 0}
            return products.count
            
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //           let cell =  OrderDetailTableCell
        //           guard orderInfo != nil else{return cell}
        //          guard let products = orderInfo.productList  else{return cell}
        switch sectionTitles[indexPath.section]{
        case "":
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop") as! OrderDetailTableCell
            if ordedrDetail?.category ?? "" == StoreCateType.hostpital{
                cell.selectionStyle = .none
                guard isLodinData == false else{return cell}
                cell.setTemplateWithSubviews(isLodinData)
                cell.lblOrderID.text = orderInfo?.orderId ?? ""
                let currencySymbol = ordedrDetail?.currencySymbol
                cell.lblTTotal.text = "Date"
                cell.lblTotal.text = orderInfo?.orderdate ?? ""
                cell.lblStatus.text = orderInfo?.paymentStatus?.capitalized ?? ""
                cell.lblStatusReason.text = orderInfo?.subStatus ?? ""
                cell.lblTDate.text = "Store Name"
                cell.lblDate.text = storeInfo?.storeName ?? ""
                // cell.btnDownload.addTarget(self, action: #selector(btnDownloadInvoice(sender:)), for: .touchUpInside)
                cell.selectionStyle = .none
                if self.orderType == ""{
                    cell.ordertypeLabel.text = ""
                }else{
                    cell.ordertypeLabel.text = self.orderType
                }
                
                if orderInfo?.subStatus ?? "" == ""{
                    cell.StackPaymentStatus.subviews[0].isHidden = true
                }else{
                    cell.StackPaymentStatus.subviews[0].isHidden = false
                }
                // if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
                
                // }else{
                
                //}
                
                if orderInfo?.paymentStatus ?? "".lowercased() == "complete"{
                    // cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.greenApproved.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_complete")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "pending" {
                    //   cell.btnDownload.alpha = 1
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_pending")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "prepared"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.prepared.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_prepared")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "preparing"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.preparing.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_preparing")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "rejected" || orderInfo?.paymentStatus ?? "".lowercased() == "cancel"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.cancel.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_cancel")
                }else{
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_pending")
                }
                
            }else if ordedrDetail?.category ?? "" == StoreCateType.restaurant{
                cell.selectionStyle = .none
                guard isLodinData == false else{return cell}
                cell.setTemplateWithSubviews(isLodinData)
                cell.lblOrderID.text = orderInfo?.orderId ?? ""
                let currencySymbol = ordedrDetail?.currencySymbol
                cell.lblTTotal.text = "Date"
                cell.lblTotal.text = orderInfo?.orderdate ?? ""
                //                cell.lblTTotal.text = "Total"
                //                cell.lblTotal.text = "\(currencySymbol ?? "") \(ordedrDetail?.totalAmount ?? "")"
                cell.lblStatus.text = orderInfo?.paymentStatus?.capitalized ?? ""
                cell.lblStatusReason.text = orderInfo?.subStatus ?? ""
                cell.lblTDate.text = "Store Name"
                cell.lblDate.text = storeInfo?.storeName ?? ""
                // cell.btnDownload.addTarget(self, action: #selector(btnDownloadInvoice(sender:)), for: .touchUpInside)
                cell.selectionStyle = .none
                if self.orderType == ""{
                    cell.ordertypeLabel.text = ""
                }else{
                    cell.ordertypeLabel.text = self.orderType
                }
                
                if orderInfo?.subStatus ?? "" == ""{
                    cell.StackPaymentStatus.subviews[0].isHidden = true
                }else{
                    cell.StackPaymentStatus.subviews[0].isHidden = false
                }
                // if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
                
                // }else{
                
                //}
                
                if orderInfo?.paymentStatus ?? "".lowercased() == "complete"{
                    // cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.greenApproved.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_complete")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "pending" {
                    //   cell.btnDownload.alpha = 1
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_pending")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "prepared"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.prepared.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_prepared")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "preparing"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.preparing.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_preparing")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "rejected" || orderInfo?.paymentStatus ?? "".lowercased() == "cancel"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.cancel.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_cancel")
                }else{
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_pending")
                }
                
                
            }else{
                cell.selectionStyle = .none
                guard isLodinData == false else{return cell}
                cell.setTemplateWithSubviews(isLodinData)
                cell.lblOrderID.text = orderInfo?.orderId ?? ""
                let currencySymbol = ordedrDetail?.currencySymbol
                cell.lblTTotal.text = "Date"
                cell.lblTotal.text = orderInfo?.orderdate ?? ""
                //                cell.lblTTotal.text = "Total"
                //                cell.lblTotal.text = "\(currencySymbol ?? "") \(ordedrDetail?.totalAmount ?? "")"
                cell.lblStatus.text = orderInfo?.paymentStatus?.capitalized ?? ""
                cell.lblStatusReason.text = orderInfo?.subStatus ?? ""
                cell.lblTDate.text = "Store Name"
                cell.lblDate.text = storeInfo?.storeName ?? ""
                // cell.btnDownload.addTarget(self, action: #selector(btnDownloadInvoice(sender:)), for: .touchUpInside)
                cell.selectionStyle = .none
                if self.orderType == ""{
                    cell.ordertypeLabel.text = ""
                }else{
                    cell.ordertypeLabel.text = self.orderType
                }
                
                if orderInfo?.subStatus ?? "" == ""{
                    cell.StackPaymentStatus.subviews[0].isHidden = true
                }else{
                    cell.StackPaymentStatus.subviews[0].isHidden = false
                }
                // if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
                
                // }else{
                
                //}
                
                if orderInfo?.paymentStatus ?? "".lowercased() == "complete"{
                    // cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.greenApproved.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_complete")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "pending" {
                    //   cell.btnDownload.alpha = 1
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_pending")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "prepared"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.prepared.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_prepared")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "preparing"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.preparing.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_preparing")
                }else if orderInfo?.paymentStatus ?? "".lowercased() == "rejected" || orderInfo?.paymentStatus ?? "".lowercased() == "cancel"{
                    //  cell.btnDownload.alpha = 0
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.cancel.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_cancel")
                }else{
                    cell.viewStatus.backgroundColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
                    cell.imgStatus.image = UIImage(named: "ic_status_pending")
                }
            }
            
            return cell
        case "Customer Name":
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUserName") as! OrderDetailTableCell
            if ordedrDetail?.category == StoreCateType.hostpital{
                cell.lblConsumerName.text = "Store Name"
                cell.lblMobile.text = ordedrDetail?.storeName ?? ""
                cell.lblStoreTypeCategory.text = ordedrDetail?.category?.capitalized ?? ""
                cell.retailerName.text = ordedrDetail?.retailerName ?? ""
            }else if ordedrDetail?.category == StoreCateType.restaurant{
                cell.lblConsumerName.text = "Store Name"
                cell.lblMobile.text = ordedrDetail?.storeName ?? ""
                cell.retailerName.isHidden = true
                cell.lblRetailer.isHidden = true
                cell.lblStoreTypeCategory.text = ""
                cell.retailerName.text = ordedrDetail?.retailerName ?? ""
            }else{
                cell.lblConsumerName.text = "Store Name"
                cell.lblMobile.text = ordedrDetail?.storeName ?? ""
                cell.lblStoreTypeCategory.text = ""
                cell.retailerName.isHidden = true
                cell.lblRetailer.isHidden = true
                cell.retailerName.text = ""
                //                cell.lblRetailer.text = ""
            }
            
            return cell
        case "Details":
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableCell
            
            let product = orderInfo?.productList![indexPath.row]
            
            // cell.lblMainCategory.text = product.MainCategory
            // cell.lblDescription.text = product.ProductSHORTDESCRIPTION
            
            // cell.lblCostPrice.attributedText = "₹ \(product.ProductPrice!)".strikeThrough()
            self.count = orderInfo?.productList?.count ?? 0
            if self.category == StoreCateType.hostpital && (product?.productType == "" || product?.productType == "Service" || product?.productType == nil){
                cell.lblName.alpha = 1
                cell.lblName.isHidden = false
                cell.labelQuantityWidth.constant = 150
                cell.labelProductNameHospital.alpha = 1
                cell.labelProductNameHospital.isHidden = false
                cell.btnCancel.isHidden = false
                cell.btnCancel.alpha = 1
                cell.imgIconClock.alpha = 1
                cell.btnReschedule.isHidden = false
                cell.btnReschedule.alpha = 1
                cell.lblName.text = product?.doctorName?.capitalized
                cell.btnDeleteItem.isHidden = true
                cell.labelProductNameHospital.text = product?.ProductName?.capitalized
                //    cell.lblOfferPrice.text = product?.ProductName?.capitalized
                cell.lblQuantity.text = "Room Number : \(product?.roomNumber ?? "")"
                let currencySymbol = ordedrDetail?.currencySymbol
                cell.lblDoctorPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                cell.lblAppoinmentTime.text = "\(product?.appointmentDate ?? "") (\(product?.appointmentTime ?? ""))"
                cell.lblAppoinmentTime.font = UIFont(name: "Montserrat-SemiBold", size: 10)
            }else if self.category == StoreCateType.restaurant && (product?.productType == "" || product?.productType == "Service" || product?.productType == nil){
                if orderInfo?.paymentStatus!.lowercased() == "completed" || orderInfo?.paymentStatus!.lowercased() == "complete"{
                    cell.btnDeleteItem.isHidden = true
                } else if orderInfo?.paymentStatus?.lowercased() == "cancelled"{
                    cell.btnDeleteItem.isHidden = true
                }else if orderInfo?.paymentStatus?.lowercased() == "pending"{
                    if self.count > 1{
                        cell.btnDeleteItem.isHidden = false
                    }else{
                        cell.btnDeleteItem.isHidden = true
                    }
                }else if orderInfo?.paymentStatus?.lowercased() == "prepared"{
                    cell.btnDeleteItem.isHidden = true
                }else if orderInfo?.paymentStatus?.lowercased() == "accepted"{
                    cell.btnDeleteItem.isHidden = true
                }else{
                    if self.count > 1{
                        cell.btnDeleteItem.isHidden = false
                    }else{
                        cell.btnDeleteItem.isHidden = true
                    }
                }
                cell.btnCancel.isHidden = true
                cell.btnCancel.alpha = 0
                cell.btnReschedule.isHidden = true
                cell.btnReschedule.alpha = 0
                cell.labelQuantityWidth.constant = 114
                cell.labelProductNameHospital.text = product?.ProductName?.capitalized
                //                cell.btnDeleteItem.isHidden = true
                cell.lblDoctorPrice.alpha = 0
                cell.lblAppoinmentTime.alpha = 0
                cell.imgIconClock.alpha = 0
                let currencySymbol = ordedrDetail?.currencySymbol
                if product?.packageType?.lowercased() == "half"{
                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                    cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Qty: \(product?.ProductQuantity ?? "") (\(product?.packageType?.capitalized ?? ""))")
                    
                }else if product?.packageType?.lowercased() == "full"{
                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                    cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Qty: \(product?.ProductQuantity ?? "") (\(product?.packageType?.capitalized ?? ""))")
                }else{
                    cell.lblQuantity.text = "Qty: \(product?.ProductQuantity ?? "")"
                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                }
                cell.lblName.alpha = 0
                cell.lblName.isHidden = true
                cell.labelProductNameHospital.alpha = 1
                cell.labelProductNameHospital.isHidden = false
            }else if ordedrDetail?.category == StoreCateType.fmcg{
                if orderInfo?.paymentStatus!.lowercased() == "completed" || orderInfo?.paymentStatus!.lowercased() == "complete"{
                    cell.btnDeleteItem.isHidden = true
                } else if orderInfo?.paymentStatus?.lowercased() == "cancelled"{
                    cell.btnDeleteItem.isHidden = true
                }else if orderInfo?.paymentStatus?.lowercased() == "pending"{
                    if self.count > 1{
                        cell.btnDeleteItem.isHidden = false
                    }else{
                        cell.btnDeleteItem.isHidden = true
                    }
                }else if orderInfo?.paymentStatus?.lowercased() == "accepted"{
                    cell.btnDeleteItem.isHidden = true
                }else{
                    if self.count > 1{
                        cell.btnDeleteItem.isHidden = false
                    }else{
                        cell.btnDeleteItem.isHidden = true
                    }
                }
                //            if self.category == StoreCateType.{
                cell.btnCancel.isHidden = true
                cell.btnCancel.alpha = 0
                cell.btnReschedule.isHidden = true
                cell.btnReschedule.alpha = 0
                cell.labelQuantityWidth.constant = 114
                cell.labelProductNameHospital.text = product?.ProductName?.capitalized
                //  cell.btnDeleteItem.isHidden = false
                cell.btnDeleteItemHander = {
                    self.showIndicator()
                    self.ApiDeleteOrderItem(cart_id: self.orderInfo?.cartMainId ?? "", user_id: Singleton.sharedInstance.userInfo.userId ?? "", product_id: product?.ProductId ?? "", vertical: self.category, inventory: self.storeInfo?.inventory ?? "", order_id:  self.orderInfo?.orderId ?? "", payment_method: self.ordedrDetail?.storePaymentType ?? "", status: self.orderInfo?.paymentStatus ?? "")
                }
                cell.lblDoctorPrice.alpha = 0
                cell.lblAppoinmentTime.alpha = 0
                cell.imgIconClock.alpha = 0
                cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Qty: \(product?.ProductQuantity ?? "")")
                let currencySymbol = ordedrDetail?.currencySymbol
                //                if product?.packageType?.lowercased() == "half"{
                //                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                //                    cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Quantity: \(product?.ProductQuantity ?? "") (\(product?.packageType?.capitalized ?? ""))")
                //
                //                }else if product?.packageType?.lowercased() == "full"{
                //                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                //                    cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Quantity: \(product?.ProductQuantity ?? "") (\(product?.packageType?.capitalized ?? ""))")
                //
                //                }else{
                cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                //                }
                cell.labelProductNameHospital.alpha = 1
                cell.labelProductNameHospital.isHidden = false
                cell.lblName.alpha = 0
                cell.lblName.isHidden = true
            }else{
                cell.btnCancel.isHidden = true
                cell.btnCancel.alpha = 0
                cell.btnReschedule.isHidden = true
                cell.btnReschedule.alpha = 0
                cell.lblName.text = product?.ProductName?.capitalized
                cell.btnDeleteItem.isHidden = true
                cell.labelQuantityWidth.constant = 114
                cell.lblDoctorPrice.alpha = 0
                cell.lblAppoinmentTime.alpha = 0
                cell.imgIconClock.alpha = 0
                cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Qty: \(product?.ProductQuantity ?? "")")
                let currencySymbol = ordedrDetail?.currencySymbol
                //                if product?.packageType?.lowercased() == "half"{
                //                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                //                    cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Quantity: \(product?.ProductQuantity ?? "") (\(product?.packageType?.capitalized ?? ""))")
                //
                //                }else if product?.packageType?.lowercased() == "full"{
                //                    cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                //                    cell.lblQuantity.attributedText = getAttrbText(simpleText: product?.ProductQuantity ?? "", text:  "Quantity: \(product?.ProductQuantity ?? "") (\(product?.packageType?.capitalized ?? ""))")
                //
                //                }else{
                cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product?.ProductOfferPrice ?? "")"
                //                }
                cell.labelProductNameHospital.alpha = 0
                cell.labelProductNameHospital.isHidden = true
                cell.lblName.alpha = 1
                cell.lblName.isHidden = false
            }
            if orderInfo?.paymentStatus ?? "".lowercased() == "complete"{
                cell.btnCancel.isHidden = false
                cell.btnReschedule.isHidden = false
            }else{
                cell.btnCancel.isHidden = true
                cell.btnReschedule.isHidden = true
            }
            cell.btnCancelHandler = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "CancelBookingVC") as! CancelBookingVC
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                //                WebServiceManager.sharedInstance.CancelOrderDetailAPI(user_id: "26428", order_id: self.orderInfo.orderId ?? "") { msg, status in
                //                    self.hideIndicator()
                //                    if status == "1"{
                //                        self.getOrderDetailByOrderID()
                //                    }else{
                //
                //                       // FTIndicator.showToastMessage(msg!)
                //                    }
                //
                //                }
            }
            cell.btnRescheduleHandler = {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmAppointmentVC") as! ConfirmAppointmentVC
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
            }
            cell.lblProductDes.text =  product?.ProductDETAIL ?? ""
            
            if product?.package_status ?? "" == "1"{
                let calculation =  (product?.product_unit ?? "") + " * " + (product?.package_quantity ?? "")
                cell.lblProductDes.text =  "Pack of  " + calculation
            }
            
            
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }
    func getAttrbText(simpleText:String,text:String) -> NSMutableAttributedString{
        
        let range = (text as NSString).range(of: String(text))
        let range1 = (text as NSString).range(of: String(simpleText))
        
        let attribute = NSMutableAttributedString.init(string: text)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Montserrat-SemiBold", size: 14)!, range: range)
        attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Montserrat-Regular", size: 14)!, range: range1)
        return attribute
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if sectionTitles[indexPath.section] == "Details"{
            (cell as! ProductTableCell).imgVwProduct.kf.cancelDownloadTask()
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLodinData == false else{
            cell.setTemplateWithSubviews(isLodinData,viewBackgroundColor: .lightGray)
            return}
        
        if sectionTitles[indexPath.section] == "Details"{
            
            let product = orderInfo?.productList![indexPath.row]
            if product?.ProductMediumImage == ""{
                (cell as! ProductTableCell).imgVwProduct.image = #imageLiteral(resourceName: "imagePlaceholder")
            }else{
                let url:URL = URL(string: product?.ProductMediumImage ?? "")!
                _ = (cell as! ProductTableCell).imgVwProduct.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"))
            }
            
            
        }
    }
}
//MARK: - RAZORPAY HANDLING *******DELEGATES HANDLING
extension OrderDetailController :RazorpayPaymentCompletionProtocol,RazorpayPaymentCompletionProtocolWithData,SFSafariViewControllerDelegate{
    
    func openRazorpayCheckout() {
        // 1. Initialize razorpay object with provided key. Also depending on your requirement you can assign delegate to self. It can be one of the protocol from RazorpayPaymentCompletionProtocolWithData, RazorpayPaymentCompletionProtocol.
        razorpayObj = RazorpayCheckout.initWithKey(RazorpayConstants.razorpayKey, andDelegate: self)
        let logo = UIImage(named:"logoBig")!
        let imageData = logo.jpegData(compressionQuality: 1)!
        let logoBase64 =  imageData.base64EncodedString()
        let  totalAmmount = (Int(orderInfo?.totalAmount ?? "0") ?? 0) * 100
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
        //        guard storeInfo != nil else{FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
        //            return
        //        }
        orderSuccessAPI(order_id: orderInfo?.orderId ?? "", transaction_id: "", cart_main_id: orderInfo?.cartMainId ?? "", payment_method: storeInfo?.paymentMethod ?? "", inventory: storeInfo?.inventory ?? "", vertical: ordedrDetail?.category ?? "", store_type: ordedrDetail?.storeType ?? "", method_type: "Online", response_type: "Cancelled", reason: "Payment cancelled by user.")
        
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
        //        guard storeInfo != nil else{FTIndicator.showToastMessage("Please check internet connection or reload page an error occured")
        //            return
        //        }
        orderSuccessAPI(order_id: orderInfo?.orderId ?? "", transaction_id: payment_id, cart_main_id: orderInfo?.cartMainId ?? "", payment_method: storeInfo?.paymentMethod ?? "", inventory: storeInfo?.inventory ?? "", vertical: storeInfo?.category ?? "", store_type: storeInfo?.storeType ?? "", method_type: "Online", response_type: "Completed", reason: "Transaction successful.")
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



extension OrderDetailController:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            // self.tabBarController?.selectedIndex = 2
            // self.navigationController?.popViewController(animated: true)
        }else{
            // self.navigationController?.popViewController(animated: true)
        }
    }
}

class OrderDetailTableCell:UITableViewCell,ShimmeringViewProtocol{
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var imgStatus: UIImageView!
    @IBOutlet weak var viewStatus: UIView!{
        didSet{
            viewStatus.cornerRadius = 1
        }
    }
    @IBOutlet weak var lblTOrderID: UILabel!{
        didSet{
            lblTOrderID.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var lblTTotal: UILabel!{
        didSet{
            lblTTotal.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var lblTDate: UILabel!{
        didSet{
            lblTDate.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
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
    @IBOutlet weak var lblDate: UILabel!{
        didSet{
            lblDate.font = UIFont(name: "Montserrat-SemiBold", size: 14)
        }
    }
    @IBOutlet weak var ordertypeLabel: UILabel!
    @IBOutlet weak var lblConsumerName: UILabel!
    @IBOutlet weak var lblMobile: UILabel!
    @IBOutlet weak var StackPaymentStatus: UIStackView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblStatusReason: UILabel!
    @IBOutlet weak var lblStoreTypeCategory: UILabel!
    @IBOutlet weak var retailerName: UILabel!
    @IBOutlet var lblRetailer : UILabel!
    var shimmeringAnimatedItems: [UIView]{
        [
            lblTOrderID,
            lblTTotal,
            lblTDate,
            lblOrderID,
            lblTotal,
            lblDate,
            StackPaymentStatus
        ]
    }
}
