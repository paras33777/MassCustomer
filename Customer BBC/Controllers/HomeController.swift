//
//  HomeController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 05/05/22.
//

import UIKit
import FTIndicator

class HomeController: UIViewController {
    
         //MARK: - IBOUTLET
        //MARK: - VARIABLES
        //MARK: - IBACTIONS
    @IBAction func btnScanQRCodeAction(_ sender: UIButton) {
        
        //QRCode scanner without Camera switch and Torch
       // let scanner = QRCodeScannerController()
        
        //QRCode with Camera switch and Torch
        let scanner = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeScannerController") as! QRCodeScannerController
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    @IBAction func btnOrderListAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrdersListController") as! OrdersListController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnRecentVisitsAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RecentVisitController") as! RecentVisitController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnLogoutAction(_ sender: UIButton) {
        let dropDown =  DropdownActionPopUp.init(title: "Are you sure you want to logout?",header:"",action: .YesNo, type: .logout, sender: self, image: nil,tapDismiss:true)
       
          dropDown.alertActionVC.delegate = self
    }
    @IBAction func userProfileAction(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserDetailVC") as! UserDetailVC
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        /*let vc = UIStoryboard.init(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentSettlementViewController") as! PaymentSettlementViewController
           self.navigationController?.pushViewController(vc, animated: true)
         */
        
    }
    //MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getStipeKeysAPI()
        }

    //MARK: - STrip API Keys UI
    func getStipeKeysAPI(){
    
        WebServiceManager.sharedInstance.getStripeKeysAPI() {storeInfo, msg, status in
            //self.isLodinData = false
            if status == "1"{
                Singleton.sharedInstance.stripeKeyInfo = storeInfo
                
             }
          }
        }
    
    //MARK: - UPDATE UI
    func updateUI(){
        
    }
    //MARK: - ADD ACTIVITY
    func addActivity(store_id:String,status_comment:String){
        WebServiceManager.sharedInstance.addUserHistoryAPI(store_id: store_id, status_comment: status_comment) { msg, status in
            if status == "1"{
                
            }else{
                
            }
        }
    }
    //MARK: - GET STORE INFO
    func getStoreInfoAPI(store_id:String,product:Productlist?){
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: store_id, type: "store") {storeInfo, msg, status in
            if status == "1"{
                if storeInfo?.settings?.lowercased() == "enable"{
                Singleton.sharedInstance.storeInfo = storeInfo
                self.addActivity(store_id: product?.StoreId ?? "", status_comment: "Visit")
                let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
                let vc1 = tabbar.viewControllers?.first as! StoreProductsController
                let vc2 = tabbar.viewControllers?[1] as! StoreCartController
                let vc3 = tabbar.viewControllers?[2] as! OrdersListController
                vc1.storeID = product?.StoreId ?? ""
                vc2.storeID = product?.StoreId ?? ""
                vc3.storeID = product?.StoreId ?? ""
                if product?.productType?.lowercased() == "service"{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDetailController") as! ServiceDetailController
                    vc.productDetail = product
                    vc.fromMainScanner = true
                        DispatchQueue.main.async(execute: {
                            self.navigationController?.viewControllers = [self,tabbar,vc]
                    })
               
                   // self..pushViewController(navController, animated: true)
                }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailController") as! ProductDetailController
                vc.productDetail = product
                vc.fromMainScanner = true
                    DispatchQueue.main.async(execute: {
                        self.navigationController?.viewControllers = [self,tabbar,vc]
                  
                })
                                             
                }
                }else{
                    let dropDown =  DropdownActionPopUp.init(title: "This store is not active yet!",header:"",action: .Okay,type: .storeInactive, sender: (UIApplication.shared.keyWindow?.rootViewController)!, image: nil,tapDismiss:false)
                      dropDown.alertActionVC.delegate = self
                }
             }else{
                 let dropDown =  DropdownActionPopUp.init(title: "This store is not active yet!",header:"",action: .Okay,type: .storeInactive, sender: (UIApplication.shared.keyWindow?.rootViewController)!, image: nil,tapDismiss:false)
                   dropDown.alertActionVC.delegate = self
            }
        }
       }
    //MARK: - GET PRODUCT BY SKU API
    func getProductBySkuAPI(sku:String){
        showIndicator()
        WebServiceManager.sharedInstance.getProductBySkuAPI(sku: sku){ product, msg, status in
            self.hideIndicator()
          //  self.isLodinData = false
            if status == "1"{
                self.getStoreInfoAPI(store_id: product?.StoreId ?? "", product: product)
              //  self.updateNoData(message: "")
             }else{
             FTIndicator.showToastMessage(msg!)
             }
             }
             }
}
extension HomeController:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            if type == .storeInactive{
                
            }else{
            Singleton.sharedInstance.userInfo = nil
            Singleton.sharedInstance.storeInfo = nil
            Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
            
        if let bundleID = Bundle.main.bundleIdentifier {
        UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
            let homeVC = self.storyboard?.instantiateViewController(withIdentifier: "FirstController") as! FirstController
            let window = UIApplication.shared.keyWindow
            window?.rootViewController = homeVC
            window?.makeKeyAndVisible()
        }
        }
    }
    
    
}
extension HomeController: QRScannerCodeDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
        print("result:\(result)")
        
        
        dismiss(animated: true)
        if result.contains("SKU"){
            print("simple")
            guard  let url:URL = URL(string:result) else{return}
     

                if  result.contains(EndPoint.url) || result.contains(EndPoint.url2){
                let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
                let vc1 = tabbar.viewControllers?.first as! StoreProductsController
                let vc2 = tabbar.viewControllers?[1] as! StoreCartController
                let vc3 = tabbar.viewControllers?[2] as! OrdersListController
                vc1.fromQRCodeScan = true
                 
                vc1.storeID = url.lastPathComponent
                vc2.storeID = url.lastPathComponent
                vc3.storeID = url.lastPathComponent
                print(url.lastPathComponent)
                addActivity(store_id: url.lastPathComponent, status_comment: "Visit")
                self.navigationController?.pushViewController(tabbar, animated: true)

            }else  if result.contains("SKU_"){
                getProductBySkuAPI(sku:result)
            }else{
               FTIndicator.showToastMessage("Invalid QR Code")
               
               }
        }else{
            let value = result.split(separator: "/")
            if value.last?.contains("Table") == true{
                print("Table")
                let split = value.last?.split(separator: "_")
                let id = split?.last
                getTRCStoreId(barID: "\(id ?? "")")
            }else{
                print("simple")
                guard  let url:URL = URL(string:result) else{return}
         

                    if  result.contains(EndPoint.url) || result.contains(EndPoint.url2){
                    let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
                    let vc1 = tabbar.viewControllers?.first as! StoreProductsController
                    let vc2 = tabbar.viewControllers?[1] as! StoreCartController
                    let vc3 = tabbar.viewControllers?[2] as! OrdersListController
                    vc1.fromQRCodeScan = true
                     
                    vc1.storeID = url.lastPathComponent
                    vc2.storeID = url.lastPathComponent
                    vc3.storeID = url.lastPathComponent
                    print(url.lastPathComponent)
                    addActivity(store_id: url.lastPathComponent, status_comment: "Visit")
                    self.navigationController?.pushViewController(tabbar, animated: true)

                }else  if result.contains("SKU_"){
                    getProductBySkuAPI(sku:result)
                }else{
                   FTIndicator.showToastMessage("Invalid QR Code")
                   
                   }

            }
        }

        
        }
    func getTRCStoreId(barID : String){
        print("ID ----",barID)
        WebServiceManager.sharedInstance.getTRCStoreId(barcodeId: barID){storeInfo, msg, status in
            if status == "1"{
                if storeInfo?.trcStatus == "Inactive"{
                    FTIndicator.showToastMessage("Table is inactive")
                }else{
                    let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
                    let vc1 = tabbar.viewControllers?.first as! StoreProductsController
                    let vc2 = tabbar.viewControllers?[1] as! StoreCartController
                    let vc3 = tabbar.viewControllers?[2] as! OrdersListController
                    vc1.fromQRCodeScan = true
                    vc1.tableNumber = storeInfo?.trcNumbers ?? ""
                    vc2.tblNumbers = storeInfo?.trcNumbers ?? ""
                    vc1.storeID = storeInfo?.storeId ?? ""
                    vc2.storeID = storeInfo?.storeId ?? ""
                    vc3.storeID = storeInfo?.storeId ?? ""
                    print(storeInfo?.storeId ?? "")
                    self.addActivity(store_id: storeInfo?.storeId ?? "", status_comment: "Visit")
                    self.navigationController?.pushViewController(tabbar, animated: true)
                }
               
              //  FTIndicator.showToastMessage(msg)
             }else{
                
             }
          }

    }
    func qrCodeScanningFailedWithError(error: String) {
        print("error:\(error)")
    }
}


