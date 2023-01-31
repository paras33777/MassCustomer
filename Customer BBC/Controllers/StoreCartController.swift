//
//  StoreCartController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 06/05/22.
//

import UIKit
import FTIndicator
import Razorpay
import SafariServices
import Stripe

class StoreCartController: UIViewController, tableSelectionBack, skipTableSelection, scanningBack ,orderProcessSuccessfull, bookedSlot{
    func bookedSlotDone() {
        self.getCartAPI()
        
        self.tabBarController?.selectedIndex = 2
        if  let vc = self.tabBarController?.selectedViewController  as? OrdersListController{
            vc.viewDidLoad()
        }
    }
    
    func orderSuccess() {
        self.getCartAPI()
        //        let drpDwn =  DropdownActionPopUp.init(title: "Order ID : \(orderID ?? "")",header:"your order has been processed!",action: .Okay,type:.openCart, sender: self, image: nil,tapDismiss:true)
        //        drpDwn.alertActionVC.delegate = self
        self.tabBarController?.selectedIndex = 2
        if  let vc = self.tabBarController?.selectedViewController  as? OrdersListController{
            vc.viewDidLoad()
        }
    }
    
    func scanningCallBack(tableNumber: String, tableID: String) {
        self.tableIds.append(tableID)
        self.tableNumbers.append(tableNumber)
        self.lblTableNumber.text = "Table:\(tableNumber)"
        diveTakeAwayView.isHidden = true
        proceedPaymentButton.isHidden = false
        
    }
    
    //    func skipTableSelectionData() {
    //        self.lblTableNumber.text = ""
    //            generateOrderIdAPI(cartMainID: self.cartProductList[0].cartMainId!, paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: "")
    //            let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
    //            self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(cartInfo.GrandTotal ?? "")"
    //
    //
    //    }
    func skipTableSelectionData() {
        self.lblTableNumber.text = ""
        self.tableIds.removeAll()
        self.tableNumbers.removeAll()
        orderType = "Dine In"
        
        generateOrderIdAPI(cartMainID: self.cartProductList[0].cartMainId!, paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: self.orderType)
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(cartInfo.GrandTotal ?? "")"
    }
    func tableSelectionCallBack(ids: [String], numbers: [String], isFromTable: String) {
        print("Ids and Numbers --- > ",ids,numbers)
        self.lblTableNumber.text = "Table:\(numbers.joined(separator: ","))"
        self.tableIds = ids
        self.tableNumbers = numbers
        diveTakeAwayView.isHidden = true
        proceedPaymentButton.isHidden = true
        isFromTableee = isFromTable
        orderType = "Dine In"
        
        
    }
    //    func tableSelectionCallBack(ids: [String], numbers: [String]) {
    //        print("Ids and Numbers --- > ",ids,numbers)
    //        self.lblTableNumber.text = "Table:\(numbers.joined(separator: ","))"
    //        self.tableIds = ids
    //        self.tableNumbers = numbers
    //        diveTakeAwayView.isHidden = true
    //        proceedPaymentButton.isHidden = false
    //    }
    
    //MARK: - IBOUTLETS
    @IBOutlet weak var stackviewCartPriceInfo: UIStackView!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var labelNetTotal: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var lblTotalPriceConstant: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    
    @IBOutlet var vwBottomPayment: UIView!
    @IBOutlet weak var lbltotalPayment: UILabel!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var stackPaymentType: UIStackView!
    @IBOutlet var lblTableNumber : UILabel!
    
    @IBOutlet weak var heightTax: NSLayoutConstraint!
    
    @IBOutlet weak var diveTakeAwayView: UIView!{
        didSet{
            diveTakeAwayView.isHidden = true
        }
    }
    @IBOutlet weak var proceedPaymentButton: UIButton!{
        didSet{
            proceedPaymentButton.isHidden = true
        }
    }
    @IBOutlet var btnBack : UIButton!
    
    
    //MARK: - VARIABLES
    var isFromTableee = ""
    private var isLodinData = true
    private static let backendURL = URL(string: "https://api.stripe.com/v1/")!
    private var paymentIntentClientSecret: String?
    var stripTransctionId = ""
    var storeID = String()
    var orderID = String()
    var cartMainID = String()
    var cartProductList = [Productlist]()
    var cartInfo : Cartinfo!
    var orderType = ""
    var iscomingFromSlot : Bool = false
    var tableIds = [String]()
    var tableNumbers = [String]()
    var tblNumbers = ""
    var currency = ""
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
    private var customerID: String?
    
    var razorpayObj : RazorpayCheckout? = nil
    // var merchantDetails : MerchantsDetails = MerchantsDetails.getDefaultData()
    // Sign up for a Razorpay Account(https://dashboard.razorpay.com/#/access/signin) and generate the API Keys(https://razorpay.com/docs/payment-gateway/dashboard-guide/settings/#api-keys/) from the Razorpay Dashboard.
    //MARK: - IBACTIONS
    @IBAction func btnBackAction(_ sender: UIButton) {
        let dropDown =  DropdownActionPopUp.init(title: "Are you sure, you want to exit from store",header:"",action: .YesNo,type:.changeStore,sender: self, image: nil,tapDismiss:true)
        dropDown.alertActionVC.delegate = self
        
    }
    @IBAction func btnDismissBottomView(_ sender : Any){
        if cartProductList.count > 0{
            // hideBottomVw(vw: vwBottomPayment)
            hideBottomVw(vw: vwBottomPayment)
            
            let seconds = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                // Put your code which should be executed with a delay here
                FTIndicator.showToastMessage("Order generated successfully!")
                self.orderSuccess()
            }
        }else{
            hideBottomVw(vw: vwBottomPayment)
            FTIndicator.showToastMessage("Order generated successfully!")
        }
    }
    
    @IBAction func btnBottomVwHideAction(_ sender: UIButton) {
        if cartProductList.count > 0{
            // hideBottomVw(vw: vwBottomPayment)
            hideBottomVw(vw: vwBottomPayment)
            
            let seconds = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                // Put your code which should be executed with a delay here
                FTIndicator.showToastMessage("Order generated successfully!")
                self.orderSuccess()
            }
            
            
        }else{
            
            hideBottomVw(vw: vwBottomPayment)
            
            FTIndicator.showToastMessage("Order generated successfully!")
            
        }
    }
    @IBAction func btnStripPayment(_ sender: Any) {
        let  amount1 = (Double(cartInfo.totalAmount ?? "0") ?? 0)
        let newAmount = Int(amount1)
        if newAmount <= 999999 {
            hideBottomVw(vw: vwBottomPayment)
            self.createCustomer()
        }
        else{
            FTIndicator.showToastMessage(StoreConstant.TenLakhEX)
        }
        
    }
    @IBAction func deliveryButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddressListViewController") as! AddressListViewController
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func diveInAction(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TableSelectionVC")as! TableSelectionVC
        vc.delegate = self
        vc.skipDelegate = self
        vc.scanDelegate = self
        vc.storeID = Singleton.sharedInstance.storeInfo.storeId ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        //        orderType = "Dine In"
        
        //        generateOrderIdAPI(cartMainID: self.cartProductList[0].cartMainId!, paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: "Dine In")
        //        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        //        self.lbltotalPayment.text = "Total Bill: \(currencySymbol!) \(cartInfo.totalAmount ?? "")"
        //
    }
    
    @IBAction func takeAwayAction(_ sender: UIButton){
        orderType = "Take Away"
        generateOrderIdAPI(cartMainID: self.cartProductList[0].cartMainId!, paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: "Take Away")
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(cartInfo.GrandTotal ?? "")"
        //        if (Singleton.sharedInstance.storeInfo != nil){
        //            if Singleton.sharedInstance.storeInfo.googlepay == "enable" {
        //                stackPaymentType.subviews[0].isHidden = false
        //            }
        //            if Singleton.sharedInstance.storeInfo.paytm == "enable" {
        //                stackPaymentType.subviews[1].isHidden = false
        //            }
        //            if Singleton.sharedInstance.storeInfo.phonepay == "enable" {
        //                stackPaymentType.subviews[2].isHidden = false
        //            }
        //
        //        }
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
            self.openRazorpayCheckout()
            //product/restaurant/salon
            
        case 500:
            let storeInfo = Singleton.sharedInstance.storeInfo!
            orderSuccessAPI(order_id: self.orderID, transaction_id: "", cart_main_id: cartMainID, payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: "Cash", response_type: "Completed", reason: "Transaction successful.")
            print( "Cash")
        default:break
        }
        
        hideBottomVw(vw: vwBottomPayment)
    }
    func upiPaymentAction(type:String){
        let paValue = "Q204475529@ybl"  //payee address upi id
        let pnValue = "Merchant Name"     // payee name
        let trValue = "1234ABCD"        //tansaction Id
        let urlValue = "http://url/of/the/order/in/your/website" //url for refernec
        let mcValue = "1234"  // retailer category code :- user id
        let tnValue = "Purchase in Merchant" //transction Note
        let amValue = "1"  //amount to pay
        let cuValue = "INR"    //currency
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
        /* let  amount1 = (Double(cartInfo.totalAmount ?? "0") ?? 0) * Double(100)
         let newAmount = Int(amount1)
         if newAmount > 99999{
         FTIndicator.showToastMessage(StoreConstant.TenLakhEX)
         }
         else*/
        if self.cartProductList.count > 0{
            generateOrderIdAPI(cartMainID: self.cartProductList[0].cartMainId!, paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: self.orderType)
            let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
            self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(cartInfo.GrandTotal ?? "")"
        }
        
    }
    //MARK: - VIEW LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if tblNumbers == ""{
            self.lblTableNumber.text = ""
        }else{
            if tableNumbers.count == 0{
                self.lblTableNumber.text = ""
            }else{
                self.lblTableNumber.text = "Table:\(tableNumbers.joined(separator: ","))"
            }
        }
        getCartAPI()
        updateUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getCartAPI()
        print(UserDefaults.standard.string(forKey: "slot_time") ?? "")
        print(UserDefaults.standard.string(forKey: "slot_id") ?? "")
        print(UserDefaults.standard.string(forKey: "slot_date") ?? "")
        print(UserDefaults.standard.string(forKey: "room_id") ?? "")
        print(UserDefaults.standard.string(forKey: "is_booking") ?? "")
        cartProductList =  Singleton.sharedInstance.cartInfo.cartList
        self.cartInfo =  Singleton.sharedInstance.cartInfo.cartDetail
        setCartItem(productList: cartProductList, cartInfo: self.cartInfo)
        
        guard  Singleton.sharedInstance.cartInfo.cartList.count > 0 else{return}
        if  Singleton.sharedInstance.cartInfo.cartList[0].ProductTotalQuantity == nil{
            getCartAPI()
        }else{
            
        }
        
        self.checkEmptyCard()
        
    }
    
    //MARK: ************UPDATE NO DATA FOUND*********************
    func updateNoData(message:String){
        if self.cartProductList.count > 0 {
            self.tblVw.backgroundView = UIView()
        }else{
            let vwNoData = ViewNoData()
            self.tblVw.backgroundView = vwNoData
            vwNoData.center.x = self.view.center.x
            vwNoData.center.y =  self.view.center.y
            vwNoData.label.text = message
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
    //MARK: - GET CART API
    func getCartAPI(){
        WebServiceManager.sharedInstance.getCartAPI(store_id: Singleton.sharedInstance.storeInfo.storeId ?? "") { cartInfo, productList, msg, status in
            self.isLodinData = false
            if status == "1"{
                self.cartProductList = productList!
                
                self.setCartItem(productList: productList!, cartInfo: cartInfo!)
            }else{
                self.cartProductList = [Productlist]()
                
                Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
                self.updateNoData(message: "Cart is Empty!")
                self.tabBarController!.tabBar.items![1].badgeValue = nil
                self.tblVw.tableFooterView?.alpha = 0
                self.tableIds.removeAll()
                self.tableNumbers.removeAll()
                self.isFromTableee = ""
                self.lblTableNumber.text = ""
                self.tblVw.reloadData()
            }
            //                if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
            //                    if UserDefaults.standard.string(forKey: "is_booking") == "true"{
            //                        self.generateOrderIdAPI(cartMainID: self.cartProductList.first?.cartMainId ?? "", paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: "")
            //                    }else{
            //
            //                    }
            //
            //                }else
            if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService{
                if UserDefaults.standard.string(forKey: "is_booking") == "true"{
                    self.generateOrderIdAPI(cartMainID: self.cartProductList.first?.cartMainId ?? "", paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: "")
                }else{
                    
                }
                
            }else{
                if UserDefaults.standard.string(forKey: "is_booking") == "true"{
                    self.generateOrderIdAPI(cartMainID: self.cartProductList.first?.cartMainId ?? "", paymentMethod:Singleton.sharedInstance.storeInfo.paymentMethod ?? "",vertical:Singleton.sharedInstance.storeInfo.category ?? "",storeType: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", order_type: "")
                }else{
                    
                }
            }
        }
    }
    
    //
    //    //MARK: - GET STORE INFO
    //    func getStoreInfoAPI(store_id:String,product:Productlist?){
    //        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: store_id, type: "store") {storeInfo, msg, status in
    //            if status == "1"{
    //                Singleton.sharedInstance.storeInfo = storeInfo
    //                if storeInfo?.category == StoreCateType.restaurant{
    //                    self.proceedPaymentButton.isHidden = true
    //                    self.diveTakeAwayView.isHidden = false
    //                }else{
    //                    self.proceedPaymentButton.isHidden == false
    //                    self.diveTakeAwayView.isHidden = true
    //                }
    //
    //            }else{
    //                 let dropDown =  DropdownActionPopUp.init(title: "This store is not active yet!",header:"",action: .Okay,type: .storeInactive, sender: (UIApplication.shared.keyWindow?.rootViewController)!, image: nil,tapDismiss:false)
    //                   dropDown.alertActionVC.delegate = self
    //            }
    //        }
    //       }
    
    
    func setCartItem(productList:[Productlist],cartInfo:Cartinfo){
        if productList.count > 0{
            self.tblVw.tableFooterView?.alpha = 1
            self.updateNoData(message: "")
            
            let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
            self.lblTotalPrice.text = "\(currencySymbol ?? "") \(cartInfo.GrandTotal ?? "" )"
            self.lblQty.text = "\(cartInfo.totalQty ?? "" )"
            
            var taxStatus = ""
            if let tax = Singleton.sharedInstance.storeInfo{
                taxStatus = Singleton.sharedInstance.storeInfo.taxStatus ?? ""
            }
            if  taxStatus == "enable" && Singleton.sharedInstance.storeInfo.taxType?.lowercased() == "inclusive"{
                self.stackviewCartPriceInfo.isHidden = true
            }else{
                self.stackviewCartPriceInfo.isHidden = false
                self.lblTax.text = "\(currencySymbol ?? "") \(cartInfo.totalTax ?? "" )"
            }
            
            self.labelNetTotal.text = "\(currencySymbol ?? "") \(cartInfo.totalAmount ?? "" )"
            
            self.lblTotalPriceConstant.text = OrderConstant.Total
            
            self.proceedPaymentButton.isHidden = false
            
            
            checkEmptyCard()
            
        }else{
            
            
            
            checkEmptyCard()
        }
        if let tabItems = self.tabBarController!.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
            let tabItem = tabItems[1]
            if productList.count > 0{
                tabItem.badgeValue = String(productList.count)
            }else{
                tabItem.badgeValue = nil
            }
        }
        self.cartInfo = cartInfo
        
        
        
        
        
        self.cartProductList = productList
        Singleton.sharedInstance.cartInfo.cartDetail = cartInfo
        Singleton.sharedInstance.cartInfo.cartList = self.cartProductList
        self.tblVw.reloadData()
    }
    func checkEmptyCard(){
        if Singleton.sharedInstance.cartInfo.cartList.count == 0{
            
            self.tblVw.tableFooterView?.alpha = 0
            self.updateNoData(message: "Cart is Empty!")
            self.stackviewCartPriceInfo.isHidden = true
            self.lblTotalPrice.text =  ""
            self.lblTotalPriceConstant.text = ""
            self.diveTakeAwayView.isHidden = true
            
            self.proceedPaymentButton.isHidden = true
        }else{
            var taxStatus = ""
            if let tax = Singleton.sharedInstance.storeInfo{
                taxStatus = Singleton.sharedInstance.storeInfo.taxStatus ?? ""
            }
            if taxStatus == ""{
                self.stackviewCartPriceInfo.isHidden = true
            }
            else if  taxStatus == "enable" && Singleton.sharedInstance.storeInfo.taxType?.lowercased() == "inclusive"{
                self.stackviewCartPriceInfo.isHidden = true
            }else{
                self.stackviewCartPriceInfo.isHidden = false
            }
            if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital || Singleton.sharedInstance.storeInfo.category == StoreCateType.diagnostic || Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService || Singleton.sharedInstance.storeInfo.category == StoreCateType.restaurant{
                self.stackviewCartPriceInfo.isHidden = true
            }
            if Singleton.sharedInstance.storeInfo.category == StoreCateType.restaurant {
                if Singleton.sharedInstance.storeInfo.services?.contains("take away") == true{
                    if isFromTableee == "" {
                        self.proceedPaymentButton.isHidden = true
                        self.diveTakeAwayView.isHidden = false
                    }else{
                        self.proceedPaymentButton.isHidden = false
                        self.diveTakeAwayView.isHidden = true
                    }
                }else  if Singleton.sharedInstance.storeInfo.services == "take away,dine in" {
                    if isFromTableee == "" {
                        self.proceedPaymentButton.isHidden = true
                        self.diveTakeAwayView.isHidden = false
                    }else{
                        self.proceedPaymentButton.isHidden = true
                        self.diveTakeAwayView.isHidden = true
                    }
                }else{
                    self.proceedPaymentButton.isHidden = false
                    self.diveTakeAwayView.isHidden = true
                }
            }else if  (Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital || Singleton.sharedInstance.storeInfo.category ==  StoreCateType.diagnostic || Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService) && Singleton.sharedInstance.storeInfo.storeType?.lowercased() != "product_service" {
                self.proceedPaymentButton.isHidden = true
                self.diveTakeAwayView.isHidden = true
                self.stackviewCartPriceInfo.isHidden = true
                
                self.heightTax.constant = 0
                self.lblTax.text = ""
                
            }else{
                self.proceedPaymentButton.isHidden = false
                self.diveTakeAwayView.isHidden = true
                self.heightTax.constant = 98
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
    //MARK: - UPDATE CART API
    func updateCartAPI(product:Productlist ,qty:String){
        showIndicator()
        WebServiceManager.sharedInstance.updateCartAPI(cart_id: product.cartId ?? "", qty: qty, cart_main_id:  product.cartMainId ?? "") {  cartInfo, productList, msg, status in
            self.hideIndicator()
            if status == "1"{
                let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
                /* self.lblTotalPrice.text = "\(currencySymbol ?? "") \(cartInfo?.GrandTotal! ?? "" )"
                 self.lblQty.text = "\(cartInfo?.totalQty ?? "" )"
                 if cartInfo?.totalTax == "" || cartInfo?.totalTax == nil{
                 self.stackviewCartPriceInfo.isHidden = true
                 }else{
                 self.stackviewCartPriceInfo.isHidden = false
                 self.lblTax.text = "\(currencySymbol ?? "") \(cartInfo?.totalTax ?? "" )"
                 }
                 
                 self.labelNetTotal.text = "\(currencySymbol ?? "") \(cartInfo?.totalAmount ?? "" )"
                 */
                
                self.cartInfo = cartInfo
                self.getCartAPI()
                // self.setCartItem(productList: productList!, cartInfo: cartInfo!)
            }else{
                self.cartProductList = [Productlist]()
                self.updateNoData(message: "Cart is Empty!")
                self.tabBarController!.tabBar.items![1].badgeValue = nil
                self.tblVw.tableFooterView?.alpha = 0
                self.tblVw.reloadData()
            }
        }
    }
    //MARK: - DELETE CART API
    func deleteCartAPI(product:Productlist ){
        UserDefaults.standard.setValue("false", forKey: "is_booking")
        WebServiceManager.sharedInstance.deleteCartAPI(cart_id: product.cartId ?? "", cart_main_id: product.cartMainId ?? "") {  cartInfo, msg, status in
            if status == "1"{
                //Check if Product in Cart
                let cartList = Singleton.sharedInstance.cartInfo.cartList
                if cartList.contains(where: {$0.ProductId == product.ProductId && $0.cartId == product.cartId} ){
                    if let index = cartList.firstIndex(where: {$0.ProductId == product.ProductId}){
                        Singleton.sharedInstance.cartInfo.cartList.remove(at: index)  //Delete from Cart
                        if Singleton.sharedInstance.cartInfo.cartList.count > 0{
                            // self.setCartItem(productList: cartList, cartInfo: cartInfo!)
                            
                            self.tblVw.tableFooterView?.alpha = 0
                            self.updateNoData(message: "Cart is Empty!")
                        }else{
                            //  self.setCartItem(productList: Singleton.sharedInstance.cartInfo.cartList!, cartInfo: cartInfo!)
                            self.updateNoData(message: "Cart is Empty!") // SET if No Data
                            self.tabBarController!.tabBar.items![1].badgeValue = nil
                            self.tblVw.tableFooterView?.alpha = 0
                            self.tblVw.reloadData()
                            self.checkEmptyCard()
                        }
                    }
                }
                
                self.getCartAPI()
            }else{
                self.cartProductList = [Productlist]()
                Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
                self.updateNoData(message: "Cart is Empty!")
                self.tabBarController!.tabBar.items![1].badgeValue = nil
                self.tblVw.tableFooterView?.alpha = 0
                self.tblVw.reloadData()
            }
        }
    }
    //MARK: - GENERATE ORDER ID API
    func generateOrderIdAPI(cartMainID:String,paymentMethod:String,vertical:String,storeType:String, inventory:String,order_type:String ){
        showIndicator()
        var product_type: String = ""
        
        
        product_type = "product"
        for product in  cartProductList{
            if product.productType?.lowercased() == "service"{
                product_type = "service"
            }
        }
        
        
        let storeID = Singleton.sharedInstance.storeInfo.storeId
        if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService{
            WebServiceManager.sharedInstance.generateOrderIDAPI(storeID: storeID!, cartMainID: cartMainID, paymentMethod: paymentMethod, vertical: vertical, storeType: storeType, inventory: inventory, order_type: order_type, room_id: UserDefaults.standard.string(forKey: "room_id") ?? "", slot_id: UserDefaults.standard.string(forKey: "slot_id") ?? "", slot_date: UserDefaults.standard.string(forKey: "slot_date") ?? "", slot_time: UserDefaults.standard.string(forKey: "slot_time") ?? "", doctor_id: UserDefaults.standard.string(forKey: "doctor_id") ?? "",table_id: tableIds.joined(separator: ","),table_number: tableNumbers.joined(separator: ","),taxi_id: UserDefaults.standard.string(forKey: "taxi_id") ?? "",driver_id: UserDefaults.standard.string(forKey: "driverID") ?? "",product_type: product_type) { orderID, msg, status in
                self.hideIndicator()
                
                UserDefaults.standard.setValue("false", forKey: "is_booking")
                if status == "1"{
                    self.orderID = orderID!
                    self.cartMainID = cartMainID
                    //                    self.getCartAPI()
                    //                self.tabBarController!.tabBar.items![1].badgeValue = nil
                    //                Singleton.sharedInstance.cartProducts.removeAll()
                    //                self.cartProductList.removeAll()
                    //                self.updateNoData(message: "Cart Empty!")
                    //                self.tblVw.tableFooterView?.alpha = 0
                    //                self.tblVw.reloadData()
                    //                        if paymentMethod.contains("payment before"){ // payment after
                    //    //                        self.createCustomer()
                    //    //                        self.showBottomVw(vw: self.vwBottomPayment)
                    //                            self.showBottomVw(vw: self.vwBottomPayment)
                    //                            self.stackviewCartPriceInfo.isHidden = true
                    //
                    //                        }else{
                    self.stackviewCartPriceInfo.isHidden = true
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    vc.delegate = self
                    vc.orderId = self.orderID
                    self.present(vc, animated: true, completion: nil)
                    
                    
                    
                    
                    
                    
                    //                        }
                    // self.setCartItem(productList: productList!, cartInfo: cartInfo!)
                }else{
                    //      FTIndicator.showToastMessage(msg!)
                    //                self.cartProductList = [Productlist]()
                    //                Singleton.sharedInstance.cartProducts = [Productlist]()
                    //                self.updateNoData(message: "Cart Empty!")
                    //                self.tabBarController!.tabBar.items![1].badgeValue = nil
                    //                self.tblVw.tableFooterView?.alpha = 0
                    //                self.tblVw.reloadData()
                }
            }
        }else{
            WebServiceManager.sharedInstance.generateOrderIDAPI(storeID: storeID!, cartMainID: cartMainID, paymentMethod: paymentMethod, vertical: vertical, storeType: storeType, inventory: inventory, order_type: order_type, room_id: UserDefaults.standard.string(forKey: "room_id") ?? "", slot_id: UserDefaults.standard.string(forKey: "slot_id") ?? "", slot_date: UserDefaults.standard.string(forKey: "slot_date") ?? "", slot_time: UserDefaults.standard.string(forKey: "slot_time") ?? "", doctor_id: UserDefaults.standard.string(forKey: "doctor_id") ?? "",table_id: tableIds.joined(separator: ","),table_number: tableNumbers.joined(separator: ","),taxi_id: UserDefaults.standard.string(forKey: "taxi_id") ?? "",driver_id: UserDefaults.standard.string(forKey: "driverID") ?? "",product_type: product_type) { orderID, msg, status in
                self.hideIndicator()
                
                // UserDefaults.standard.setValue("false", forKey: "is_booking")
                UserDefaults.standard.setValue("false", forKey: "is_booking")
                if status == "1"{
                    self.orderID = orderID!
                    self.cartMainID = cartMainID
                    
                    if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
                        if Singleton.sharedInstance.storeInfo?.AppointmentConfirmation == "enable"{
                            self.stackviewCartPriceInfo.isHidden = true
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppoinmentBookedVC") as! AppoinmentBookedVC
                            vc.delegate = self
                            vc.modalTransitionStyle = .crossDissolve
                            vc.modalPresentationStyle = .overCurrentContext
                            self.present(vc, animated: true, completion: nil)
                            //                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
                            //                                vc.modalTransitionStyle = .crossDissolve
                            //                                vc.modalPresentationStyle = .overFullScreen
                            //                                vc.delegate = self
                            //                                vc.orderId = self.orderID
                            //                                self.present(vc, animated: true, completion: nil)
                        }else{
                            if paymentMethod.contains("payment before"){ // payment after
                                //                        self.createCustomer()
                                //                        self.showBottomVw(vw: self.vwBottomPayment)
                                self.showBottomVw(vw: self.vwBottomPayment)
                                self.stackviewCartPriceInfo.isHidden = true
                                let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
                                self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(self.cartInfo.GrandTotal ?? "")"
                            }else{
                                self.stackviewCartPriceInfo.isHidden = true
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
                                vc.modalTransitionStyle = .crossDissolve
                                vc.modalPresentationStyle = .overFullScreen
                                vc.delegate = self
                               
                                vc.orderId = self.orderID
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }else{
                        if paymentMethod.contains("payment before"){ // payment after
                            //                        self.createCustomer()
                            //                        self.showBottomVw(vw: self.vwBottomPayment)
                            self.showBottomVw(vw: self.vwBottomPayment)
                            self.stackviewCartPriceInfo.isHidden = true
                            let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
                            self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(self.cartInfo.GrandTotal ?? "")"
                        }else{
                            self.stackviewCartPriceInfo.isHidden = true
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
                            vc.modalTransitionStyle = .crossDissolve
                            vc.modalPresentationStyle = .overFullScreen
                            vc.delegate = self
                            vc.orderId = self.orderID
                            vc.tableNumber = self.tableNumbers
                            self.present(vc, animated: true, completion: nil)
                            
                        }
                    }
                    //                    self.getCartAPI()
                    //                self.tabBarController!.tabBar.items![1].badgeValue = nil
                    //                Singleton.sharedInstance.cartProducts.removeAll()
                    //                self.cartProductList.removeAll()
                    //                self.updateNoData(message: "Cart Empty!")
                    //                self.tblVw.tableFooterView?.alpha = 0
                    //                self.tblVw.reloadData()
                    
                    
                    
                    
                    // self.setCartItem(productList: productList!, cartInfo: cartInfo!)
                }else{
                    //  FTIndicator.showToastMessage(msg!)
                    //                self.cartProductList = [Productlist]()
                    //                Singleton.sharedInstance.cartProducts = [Productlist]()
                    //                self.updateNoData(message: "Cart Empty!")
                    //                self.tabBarController!.tabBar.items![1].badgeValue = nil
                    //                self.tblVw.tableFooterView?.alpha = 0
                    //                self.tblVw.reloadData()
                }
            }
        }
        
    }
    //        //MARK: - GENERATE ORDER ID API
    //        func generateOrderIdAPI(cartMainID:String,paymentMethod:String,vertical:String,storeType:String, inventory:String,order_type:String ){
    //            showIndicator()
    //
    //            let storeID = Singleton.sharedInstance.storeInfo.storeId
    //            if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService{
    //                WebServiceManager.sharedInstance.generateOrderIDAPI(storeID: storeID!, cartMainID: cartMainID, paymentMethod: paymentMethod, vertical: vertical, storeType: storeType, inventory: inventory, order_type: order_type, room_id: UserDefaults.standard.string(forKey: "room_id") ?? "", slot_id: UserDefaults.standard.string(forKey: "slot_id") ?? "", slot_date: UserDefaults.standard.string(forKey: "slot_date") ?? "", slot_time: UserDefaults.standard.string(forKey: "slot_time") ?? "", doctor_id: UserDefaults.standard.string(forKey: "doctor_id") ?? "",table_id: tableIds.joined(separator: ","),table_number: tableNumbers.joined(separator: ","),taxi_id: UserDefaults.standard.string(forKey: "taxi_id") ?? "",driver_id: UserDefaults.standard.string(forKey: "driverID") ?? "") { orderID, msg, status in
    //                    self.hideIndicator()
    //
    //                    UserDefaults.standard.setValue("false", forKey: "is_booking")
    //                    if status == "1"{
    //                        self.orderID = orderID!
    //                        self.cartMainID = cartMainID
    //    //                    self.getCartAPI()
    //                        //                self.tabBarController!.tabBar.items![1].badgeValue = nil
    //                        //                Singleton.sharedInstance.cartProducts.removeAll()
    //                        //                self.cartProductList.removeAll()
    //                        //                self.updateNoData(message: "Cart Empty!")
    //                        //                self.tblVw.tableFooterView?.alpha = 0
    //                        //                self.tblVw.reloadData()
    ////                        if paymentMethod.contains("payment before"){ // payment after
    ////    //                        self.createCustomer()
    ////    //                        self.showBottomVw(vw: self.vwBottomPayment)
    ////                            self.showBottomVw(vw: self.vwBottomPayment)
    ////                            self.stackviewCartPriceInfo.isHidden = true
    ////
    ////                        }else{
    //                            self.stackviewCartPriceInfo.isHidden = true
    //                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
    //                            vc.modalTransitionStyle = .crossDissolve
    //                            vc.modalPresentationStyle = .overFullScreen
    //                            vc.delegate = self
    //                            vc.orderId = self.orderID
    //                            self.present(vc, animated: true, completion: nil)
    //
    //
    //
    //
    //
    //
    ////                        }
    //                        // self.setCartItem(productList: productList!, cartInfo: cartInfo!)
    //                    }else{
    //                     //   FTIndicator.showToastMessage(msg!)
    //                        //                self.cartProductList = [Productlist]()
    //                        //                Singleton.sharedInstance.cartProducts = [Productlist]()
    //                        //                self.updateNoData(message: "Cart Empty!")
    //                        //                self.tabBarController!.tabBar.items![1].badgeValue = nil
    //                        //                self.tblVw.tableFooterView?.alpha = 0
    //                        //                self.tblVw.reloadData()
    //                    }
    //                }
    //            }else{
    //                WebServiceManager.sharedInstance.generateOrderIDAPI(storeID: storeID!, cartMainID: cartMainID, paymentMethod: paymentMethod, vertical: vertical, storeType: storeType, inventory: inventory, order_type: order_type, room_id: UserDefaults.standard.string(forKey: "room_id") ?? "", slot_id: UserDefaults.standard.string(forKey: "slot_id") ?? "", slot_date: UserDefaults.standard.string(forKey: "slot_date") ?? "", slot_time: UserDefaults.standard.string(forKey: "slot_time") ?? "", doctor_id: UserDefaults.standard.string(forKey: "doctor_id") ?? "",table_id: tableIds.joined(separator: ","),table_number: tableNumbers.joined(separator: ","),taxi_id: UserDefaults.standard.string(forKey: "taxi_id") ?? "",driver_id: UserDefaults.standard.string(forKey: "driverID") ?? "") { orderID, msg, status in
    //                    self.hideIndicator()
    //
    //                   // UserDefaults.standard.setValue("false", forKey: "is_booking")
    //                    UserDefaults.standard.setValue("false", forKey: "is_booking")
    //                    if status == "1"{
    //                        self.orderID = orderID!
    //                        self.cartMainID = cartMainID
    //
    //                        if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
    //                            if Singleton.sharedInstance.storeInfo?.AppointmentConfirmation == "enable"{
    //                                self.stackviewCartPriceInfo.isHidden = true
    //                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppoinmentBookedVC") as! AppoinmentBookedVC
    //                                       vc.delegate = self
    //                                vc.modalTransitionStyle = .crossDissolve
    //                                       vc.modalPresentationStyle = .overCurrentContext
    //                                       self.present(vc, animated: true, completion: nil)
    ////                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
    ////                                vc.modalTransitionStyle = .crossDissolve
    ////                                vc.modalPresentationStyle = .overFullScreen
    ////                                vc.delegate = self
    ////                                vc.orderId = self.orderID
    ////                                self.present(vc, animated: true, completion: nil)
    //                            }else{
    //                                if paymentMethod.contains("payment before"){ // payment after
    //            //                        self.createCustomer()
    //            //                        self.showBottomVw(vw: self.vwBottomPayment)
    //                                    self.showBottomVw(vw: self.vwBottomPayment)
    //                                    self.stackviewCartPriceInfo.isHidden = true
    //                                    let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
    //                                    self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(self.cartInfo.GrandTotal ?? "")"
    //                                }else{
    //                                    self.stackviewCartPriceInfo.isHidden = true
    //                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
    //                                    vc.modalTransitionStyle = .crossDissolve
    //                                    vc.modalPresentationStyle = .overFullScreen
    //                                    vc.delegate = self
    //                                    vc.orderId = self.orderID
    //                                    self.present(vc, animated: true, completion: nil)
    //                                }
    //                            }
    //                        }else{
    //                            if paymentMethod.contains("payment before"){ // payment after
    //        //                        self.createCustomer()
    //        //                        self.showBottomVw(vw: self.vwBottomPayment)
    //                                self.showBottomVw(vw: self.vwBottomPayment)
    //                                self.stackviewCartPriceInfo.isHidden = true
    //                                let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
    //                                self.lbltotalPayment.text = "Total Bill: \(currencySymbol ?? "") \(self.cartInfo.GrandTotal ?? "")"
    //                            }else{
    //                                self.stackviewCartPriceInfo.isHidden = true
    //                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderProcessedVC") as! OrderProcessedVC
    //                                vc.modalTransitionStyle = .crossDissolve
    //                                vc.modalPresentationStyle = .overFullScreen
    //                                vc.delegate = self
    //                                vc.orderId = self.orderID
    //                                self.present(vc, animated: true, completion: nil)
    //
    //                            }
    //                        }
    //    //                    self.getCartAPI()
    //                        //                self.tabBarController!.tabBar.items![1].badgeValue = nil
    //                        //                Singleton.sharedInstance.cartProducts.removeAll()
    //                        //                self.cartProductList.removeAll()
    //                        //                self.updateNoData(message: "Cart Empty!")
    //                        //                self.tblVw.tableFooterView?.alpha = 0
    //                        //                self.tblVw.reloadData()
    //
    //
    //
    //
    //                        // self.setCartItem(productList: productList!, cartInfo: cartInfo!)
    //                    }else{
    //                     //   FTIndicator.showToastMessage(msg!)
    //                        //                self.cartProductList = [Productlist]()
    //                        //                Singleton.sharedInstance.cartProducts = [Productlist]()
    //                        //                self.updateNoData(message: "Cart Empty!")
    //                        //                self.tabBarController!.tabBar.items![1].badgeValue = nil
    //                        //                self.tblVw.tableFooterView?.alpha = 0
    //                        //                self.tblVw.reloadData()
    //                    }
    //                }
    //            }
    //
    //
    //
    //
    //        }
    //MARK: - ORDER SUCCESS API
    func orderSuccessAPI(order_id: String, transaction_id: String, cart_main_id: String, payment_method: String, inventory: String, vertical: String, store_type: String, method_type: String, response_type: String, reason: String){
        showIndicator()
        let storeInfo  = Singleton.sharedInstance.storeInfo
        WebServiceManager.sharedInstance.orderSuccessAPI(storeID: (storeInfo?.storeId!)!, order_id: order_id, transaction_id: transaction_id, cart_main_id: cart_main_id, payment_method: payment_method, inventory: inventory, vertical: vertical, store_type: store_type, method_type: method_type, response_type: response_type, reason: reason,room_id: UserDefaults.standard.string(forKey: "room_id") ?? "",doctor_id: "", taxi_id: "") { id, msg, status in
            self.hideIndicator()
            if status == "1"{
                self.getCartAPI()
                let drpDwn =  DropdownActionPopUp.init(title: "Payment done successfully",header:"Success", action: .Okay, type: .none, sender: self, image: UIImage(named: "Success"),tapDismiss:true)
                drpDwn.alertActionVC.delegate = self
            }else{
                let drpDwn = DropdownActionPopUp.init(title: msg!,header:"Payment Failed",  action:.Okay, type: .none, sender: self, image: UIImage(named: "fail"),tapDismiss:true)
                drpDwn.alertActionVC.delegate = self
            }
            
        }
    }
    //MARK: -
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
        
        var currencyName = "GBP"
        let currency = Singleton.sharedInstance.storeInfo?.storeName
        if let s = currency?.split(separator: " "){
            currencyName = String(s.last ?? "")
        }
        
        amount = (Double(cartInfo.totalAmount ?? "0") ?? 0) * Double(100)
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
    
    func pay() {
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
                let storeInfo = Singleton.sharedInstance.storeInfo!
                self?.orderSuccessAPI(order_id: self?.orderID ?? "", transaction_id: self?.stripTransctionId ?? "", cart_main_id: self?.cartMainID ?? "", payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: EndPoint.methodType, response_type: "Completed", reason: "Transaction successful.")
                
                
                //                self?.displayAlert(title: "Payment complete!")
                self?.dismiss(animated: true)
            case .canceled:
                print("Payment canceled!")
                let storeInfo = Singleton.sharedInstance.storeInfo!
                self?.orderSuccessAPI(order_id: self?.orderID ?? "", transaction_id: self?.stripTransctionId ?? "", cart_main_id: self?.cartMainID ?? "", payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: EndPoint.methodType, response_type: "Cancelled", reason: "Payment cancelled by user.")
                
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
    //MARK: - UPDATE UI
    func updateUI(){
        //        if Singleton.sharedInstance.storeInfo.currencySymbol != "₹"{
        //            stackPaymentType.subviews[3].isHidden = true
        //        }else{
        //            stackPaymentType.subviews[3].isHidden = false
        //        }
        let currency = Singleton.sharedInstance.storeInfo.storeName
        let s = currency?.split(separator: " ")
        print(s)
        
        
        if  s?.last ?? "" == "INR"{
            stackPaymentType.subviews[3].isHidden = false
            stackPaymentType.subviews[5].isHidden = true
            stackPaymentType.subviews[4].isHidden = false
            //  secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            
            //  StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
            
        }else if s?.last ?? "" == "GBP"{
            stackPaymentType.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackPaymentType.subviews[5].isHidden = false
                }else{
                    stackPaymentType.subviews[5].isHidden = true
                }
            }
            stackPaymentType.subviews[3].isHidden = true
            
            
            //  secretKey = "sk_test_51LjyQ9AwEM7NyHuejPnaHRLG2MguLPDSNo8XIVpfHYy2q9AKPqwjcgbnniMFud0jBPwSino3Ltc89oFcJgcJFp3O00KE7viS5Z"
            // StripeAPI.defaultPublishableKey = "pk_test_51LjyQ9AwEM7NyHue2XYFfUGvUdAxy4ibmtLbNhWcoJhCNylTSER7H40V12pgDKmshIdMGJDL42qu18fD9i6Dr9GJ00ndoBpG0u"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYUK ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYUK ?? ""
            }
            
            
        }else if s?.last ?? "" == "EUR"{
            
            
            stackPaymentType.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackPaymentType.subviews[5].isHidden = false
                }else{
                    stackPaymentType.subviews[5].isHidden = true
                }
            }
            stackPaymentType.subviews[3].isHidden = true
            // secretKey = "sk_test_51LkT1vJKgibxtlZSWeBBdvrcpUGjaUAv8h2tjNQvgGpmptjCoL4JgJBYt4P041iuJmGGfZmYIwPGgNuznzuYy9rV005uHJUesP"
            //   StripeAPI.defaultPublishableKey = "pk_test_51LkT1vJKgibxtlZSQc4QsbGrC2kNuv3MpJ9OKsHfDwA3LlmHEkDV4MgRmrtaWHnr5Cu9iP8vDFEDH0Tav084I8Br00YpXYSCX7"
            
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                secretKey = object.sECRETKEYBELGIUM ?? ""
            }
            if let object =  Singleton.sharedInstance.stripeKeyInfo{
                StripeAPI.defaultPublishableKey = object.pUBLISHKEYBELGIUM ?? ""
            }
            
        }else{
            stackPaymentType.subviews[4].isHidden = false
            if let object =  Singleton.sharedInstance.storeInfo{
                if Singleton.sharedInstance.storeInfo.stripeStatus == "1"{
                    stackPaymentType.subviews[5].isHidden = false
                }else{
                    stackPaymentType.subviews[5].isHidden = true
                }
            }
            stackPaymentType.subviews[3].isHidden = true
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
                stackPaymentType.subviews[5].isHidden = false
            }else{
                stackPaymentType.subviews[5].isHidden = true
            }
        }
        vwBottomPayment.alpha = 0
        self.tabBarController?.view.addSubview(vwBottomPayment)
        hideBottomVw(vw: vwBottomPayment)
    }
    
}
extension StoreCartController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isLodinData == false else{return 5}
        return cartProductList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableCell
        guard isLodinData == false else{return cell}
        cell.setTemplateWithSubviews(isLodinData)
        if  Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital{
            cell.stackView.alpha = 0
        }else{
            cell.stackView.alpha = 1
        }
        if  Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital || Singleton.sharedInstance.storeInfo.category == StoreCateType.diagnostic || Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService
        {
            cell.btnDelete.isHidden = true
            cell.btnPlus.isHidden = true
            cell.btnMinus.isHidden = true
            cell.lblQuantity.isHidden = true
            
            
        }else {
            cell.btnDelete.isHidden = false
            cell.btnPlus.isHidden = false
            cell.btnMinus.isHidden = false
            cell.lblQuantity.isHidden = false
        }
        let product = cartProductList[indexPath.row]
        cell.lblName.text = product.ProductName?.capitalized
        cell.lblDescription.text = product.ProductSHORTDESCRIPTION
        cell.lblQuantity.text = product.ProductQuantity
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        if product.Package?.lowercased() == "half"{
            cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product.TotalPrice!) (\(product.Package?.capitalized ?? ""))"
        }else if product.Package?.lowercased() == "full" {
            cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product.TotalPrice!) (\(product.Package?.capitalized ?? ""))"
        }else{
            cell.lblOfferPrice.text = "\(currencySymbol ?? "") \(product.TotalPrice!)"
            cell.lblStatndardPrice.attributedText = "\(currencySymbol ?? "") \(product.ProductPrice!)".strikeThrough()
        }
        if Double(product.ProductOfferPrice!) == Double(product.ProductPrice!){
            cell.stackVwPrice.subviews[0].isHidden = true
        }else{
            cell.stackVwPrice.subviews[0].isHidden = true
        }
        
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteAction(sender:)), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(btnPlusAction(sender:)), for: .touchUpInside)
        cell.btnMinus.addTarget(self, action: #selector(btnMinusAction(sender:)), for: .touchUpInside)
        
        if product.package_status == "1"{
            cell.packageLabel.isHidden = true
            cell.packageLabelConstant.isHidden = true
            cell.packageView.isHidden = true
            cell.packageImageView.isHidden = true
            cell.packageLabel.isHidden = true
            // cell.offerPriceLabel.text = product.package_price
            // cell.packageLabel.text =  (product.product_unit ?? "") + " * " + (product.package_quantity ?? "")
            
            let calculation =  (product.package_quantity ?? "")  + " * " + (product.product_unit ?? "")
            cell.lblDescription.text =  "Pack of  " + calculation
            
            
        }else{
            cell.packageLabel.isHidden = true
            cell.packageLabelConstant.isHidden = true
            cell.packageView.isHidden = true
            cell.packageImageView.isHidden = true
            cell.packageLabel.isHidden = true
        }
        
        
        return cell
    }
    
    //MARK: - CELL BUTTON IBACTION
    @objc func btnDeleteAction(sender:UIButton){
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblVw)
        let indexPath = self.tblVw.indexPathForRow(at:buttonPosition)!
        //  let cell = self.tblVw.cellForRow(at: indexPath) as! ProductTableCell
        let product = cartProductList[indexPath.row]
        self.deleteCartAPI(product: product)
    }
    @objc func btnPlusAction(sender:UIButton){
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblVw)
        let indexPath = self.tblVw.indexPathForRow(at:buttonPosition)!
        let cell = self.tblVw.cellForRow(at: indexPath) as! ProductTableCell
        let product = cartProductList[indexPath.row]
        var productQty =  Int(product.ProductTotalQuantity ?? "1") ?? 0
        
        var selectedQty = Int(cell.lblQuantity.text!) ?? 1
        if product.package_status == "1"{
            if let package_quantity1 = Int(product.package_quantity ?? "1") {
                productQty = productQty / package_quantity1
            }
            
        }
        
        if selectedQty < productQty{
            // let qty = Int(cell.lblQuantity.text! ) ?? 1
            
        }else{
            if Singleton.sharedInstance.storeInfo.inventory == "without inventory"{
                
            }else{
                if product.package_status == "1"{
                    FTIndicator.showToastMessage("Maximum quantity available is \(selectedQty)")
                    return
                }else{
                    FTIndicator.showToastMessage("Product maximum quantity available is \(product.ProductQuantity ?? "")")
                    return
                }
            }
            
        }
        let qty = Int(cell.lblQuantity.text! ) ?? 1
        cell.lblQuantity.text =  String(qty + 1)
        updateCartAPI(product: product, qty: (String(qty+1)))
    }
    @objc func btnMinusAction(sender:UIButton){
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblVw)
        let indexPath = self.tblVw.indexPathForRow(at:buttonPosition)!
        let cell = self.tblVw.cellForRow(at: indexPath) as! ProductTableCell
        let product = cartProductList[indexPath.row]
        if Int(cell.lblQuantity.text!) ?? 1 ==  1{
            FTIndicator.showToastMessage("Minimum quantity cannot be less than 1")
        }else{
            let qty = Int(cell.lblQuantity.text! ) ?? 1
            cell.lblQuantity.text =  String(qty - 1)
            updateCartAPI(product: product, qty: (String(qty-1)))
            
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLodinData == false else{
            cell.setTemplateWithSubviews(isLodinData,viewBackgroundColor: .lightGray)
            return}
        let product = cartProductList[indexPath.row]
        if product.ProductMediumImage == ""{
            //  let cell =  (cell as! CellAssignedAsset)
            (cell as! ProductTableCell).imgVwProduct.image = #imageLiteral(resourceName: "imagePlaceholder")
        }else{
            let url:URL = URL(string: product.ProductMediumImage!)!
            _ = (cell as! ProductTableCell).imgVwProduct.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
            
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        (cell as! ProductTableCell).imgVwProduct.kf.cancelDownloadTask()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    /* func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
     
     guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettlementTotalAmountFooterTableViewCell") as? SettlementTotalAmountFooterTableViewCell else { return UITableViewCell.init() }
     
     //cell.titleLabel.font =  UIFont().MontserratBold(size: 17.0)
     // cell.titleLabel.font =  UIFont().MontserratBold(size: 17.0)
     //cell.titleLabel.text = "Total"
     //cell.descriptionLabel.text = self.totalAmount.text
     
     
     
     
     return cell
     }*/
    
    
}
//MARK: - RAZORPAY HANDLING *******DELEGATES HANDLING
extension StoreCartController :RazorpayPaymentCompletionProtocol,RazorpayPaymentCompletionProtocolWithData,SFSafariViewControllerDelegate{
    func openRazorpayCheckout() {
        // 1. Initialize razorpay object with provided key. Also depending on your requirement you can assign delegate to self. It can be one of the protocol from RazorpayPaymentCompletionProtocolWithData, RazorpayPaymentCompletionProtocol.
        razorpayObj = RazorpayCheckout.initWithKey(RazorpayConstants.razorpayKey, andDelegate: self)
        let logo = UIImage(named:"logoBig")!
        let imageData = logo.pngData()!
        let logoBase64 =  imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        let  totalAmmount = (Int(cartInfo.totalAmount ?? "0") ?? 0) * 100
        let options: [AnyHashable:Any] = [
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
        let storeInfo = Singleton.sharedInstance.storeInfo!
        orderSuccessAPI(order_id: self.orderID, transaction_id: "", cart_main_id: cartMainID, payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: "Online", response_type: "Cancelled", reason: "Payment cancelled by user.")
        //        let drpDwn = DropdownActionPopUp.init(title: str,header:"Payment Failed",  action: .Okay,type: .none, sender: self)
        //        drpDwn.alertActionVC.delegate = self
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        print("success: ", payment_id)
        let storeInfo = Singleton.sharedInstance.storeInfo!
        orderSuccessAPI(order_id: self.orderID, transaction_id: payment_id, cart_main_id: cartMainID, payment_method: storeInfo.paymentMethod ?? "", inventory: storeInfo.inventory ?? "", vertical: storeInfo.category ?? "", store_type: storeInfo.storeType ?? "", method_type: "Online", response_type: "Completed", reason: "Transaction successful.")
        //        let drpDwn =  DropdownActionPopUp.init(title: "Payment Succeeded",header:"Success", action: .Okay,type: .none, sender: self)
        //        drpDwn.alertActionVC.delegate = self
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
extension StoreCartController:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            if type == .changeStore{
                self.navigationController?.popViewController(animated: true)
            }else{
                self.tabBarController?.selectedIndex = 2
                if  let vc = self.tabBarController?.selectedViewController  as? OrdersListController{
                    vc.viewDidLoad()
                }
            }
            // self.navigationController?.popViewController(animated: true)
        }else{
            // self.navigationController?.popViewController(animated: true)
        }
    }
}
