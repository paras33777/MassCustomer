//
//  StoreProductsController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 06/05/22.
//

import UIKit
import Kingfisher
import FTIndicator
import UIView_Shimmer
import CoreLocation


class StoreProductsController: UIViewController {
//    func callBack(products: Productlist?) {
////        productsss = products
//        let vc2 = self.tabBarController!.viewControllers?[1] as! StoreCartController
//    self.navigationController?.pushViewController(vc2, animated: true)
////        addToCartAPI(  action: "1", product: self.productsss!,package: "")
//    }
    
    
   
        
    
    //MARK: - IBOUTLET
    @IBOutlet weak var lbltotalCount: UILabel!
    @IBOutlet weak var vwBgSearchBar: UIView!
    @IBOutlet weak var btnBarCodeScanner: UIButton!{
        didSet{
            self.btnBarCodeScanner.isHidden = true
        }
    }
    @IBOutlet var constWidthBarCodeButton : NSLayoutConstraint!{
        didSet{
            self.constWidthBarCodeButton.constant = 0
        }
    }
    @IBOutlet weak var filterWidth: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var lblFilterCount: UILabel!
    //BottomSheet
    @IBOutlet var vwBottomSheetCustomise: UIView!
    @IBOutlet weak var imgeVwFullCheck: UIImageView!
    @IBOutlet weak var imgeVwHalfCheck: UIImageView!
    @IBOutlet weak var lblBtmShtFullAmt: UILabel!
    @IBOutlet weak var lblBtmShtHalfAmt: UILabel!
    @IBOutlet weak var lblBtmSheetItemName: UILabel!
    @IBOutlet weak var imageBtmSheetItem: UIImageView!
    
    @IBOutlet var lblTableNumber : UILabel!
    //MARK: - VARIABLES
    var totalCount = Int()
    var totalPage = Int()
    var page = 1
    var refreshControl: UIRefreshControl!
    var locationManager = CLLocationManager()

   var tableNumber = ""
    var pageLoading = false
    var storeID = String()
    var fromQRCodeScan = false
    var productList = [Productlist]()
    var productsss : Productlist?
    var filteredProducts = [Productlist]()
    var cartProductList = [Productlist]()
    var selectedService : Productlist!//only for botton VW add to order
    var commonFilter = [CommonFilter]()
    private var isLodinData = true
    private var searchActive = false
    var package = "" //only  for botton VW add toorder
    
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
    //MARK: - IBACTIONS
    @IBAction func btnBackAction(_ sender: UIButton) {
        let dropDown =  DropdownActionPopUp.init(title:"Are you sure, you want to exit from store",header:"",action: .YesNo,type: .storeExit, sender: self, image: nil,tapDismiss:true)
          dropDown.alertActionVC.delegate = self
      }
    @IBAction func btnOpenFilter(_ sender: UIButton) {
     let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonFilterController") as! CommonFilterController
        vc.storeID = storeID
        vc.type = "ProductList"
        vc.filters = commonFilter
        vc.applyFilter = { filter in
            self.commonFilter = filter
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(self.commonFilter)
                let jsonString = String(data: jsonData, encoding: .utf8)
                self.getProductListAPI(storeID: self.storeID, page: 1, commonFilter: jsonString!)
                print("JSON String : " + jsonString!)
            }
            catch {
            }
            var count = 0
            for item in self.commonFilter {
                if item.returnValue != ""{
                    count += 1
                 }
             }
            if count > 0{
                self.lblFilterCount.alpha = 1
                self.lblFilterCount.text = String(count)
            }else{
                self.lblFilterCount.alpha = 0
            }
        }
        self.navigationController!.present(vc, animated: true)
    }
    @IBAction func openBarcodeScannerAction(_ sender: UIButton) {
        let scanner = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeScannerController") as! QRCodeScannerController
        scanner.scannerType = "Bar"
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    //ACTION BOTTOM SHEET
    @IBAction func btnActionCheck(_ sender: UIButton) {
        if sender.tag == 100{
            imgeVwFullCheck.image = UIImage(named: "checkbox")
            imgeVwHalfCheck.image = UIImage(named: "unCheck")
            self.package = "full"
        }else{
            imgeVwFullCheck.image = UIImage(named: "unCheck")
            imgeVwHalfCheck.image = UIImage(named: "checkbox")
            self.package = "half"
        }
    }
    
    @IBAction func btnActionBtmAddToOrder(_ sender: UIButton) {
        self.hideBottomVw(vw: vwBottomSheetCustomise)
    addToCartAPI(  action: "1", product: selectedService,package: package)
    }
    
    @IBAction func btnActionBtmBack(_ sender: UIButton) {
      hideBottomVw(vw: vwBottomSheetCustomise)
    }
    
    //MARK: - VIEW LIFE CYCLE

    override func viewDidLoad(){
    super.viewDidLoad()
       
        if tableNumber == ""{
            self.lblTableNumber.alpha = 0
        }else{
            self.lblTableNumber.alpha = 1
            self.lblTableNumber.text = "Table:\(tableNumber)"
        }
        getCommonFilterAPI(mainCat: "")
     getStoreInfoAPI(store_id: storeID)
     updateUI()
     addToolbarToSearchKeyboard()
 
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateItemBadge(productList: Singleton.sharedInstance.cartInfo.cartList)
        self.tblVw.reloadData()
    }
    //MARK: - UPDATE UI
    func updateUI(){
        refreshDataControl()
        vwBottomSheetCustomise.alpha = 0
        self.tabBarController?.view.addSubview(vwBottomSheetCustomise)
        hideBottomVw(vw: vwBottomSheetCustomise)
        lblFilterCount.layer.borderColor = hexStringToUIColor(hex: Color.red.rawValue).cgColor
        lblFilterCount.layer.borderWidth = 1
        lblFilterCount.alpha = 0
        if #available(iOS 13.0, *) {
            vwBgSearchBar.backgroundColor = .clear
            searchBar[keyPath: \.searchTextField].font = UIFont.init(name: "Montserrat-Medium",size: 14)!
        }else {
            vwBgSearchBar.backgroundColor = hexStringToUIColor(hex:Color.searchBarBG.rawValue)
            
            let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
            let placeholderLabel       = textFieldInsideUISearchBar?.value(forKey: "placeholderLabel") as? UILabel
            placeholderLabel?.font     = UIFont.init(name: "Montserrat-Medium", size: 14)!
        }
      }
    //MARK: ***********Refresh Data
    func refreshDataControl(){
        tblVw.alwaysBounceVertical = true
        tblVw.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        self.tblVw.addSubview(refreshControl)
    }
    //MARK: ***********Refresh Data
    @objc func reloadData(){
        page = 1
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(self.commonFilter)
            let jsonString = String(data: jsonData, encoding: .utf8)
            getProductListAPI(storeID: storeID, page: 1, commonFilter: jsonString!)
          //  print("JSON String : " + jsonString!)
           }
        catch {
        }
      }
        
    //MARK: ************UPDATE NO DATA FOUND
    func updateNoData(message:String){
        if self.productList.count > 0 {
            self.tblVw.backgroundView = UIView()
        }else{
            let vwNoData = ViewNoData()
            self.tblVw.backgroundView = vwNoData
            vwNoData.imgVw.image = UIImage(named:"noDataFound")
            vwNoData.center.x =  self.view.center.x
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
    //MARK: - UPDATE CUSTOMISE SHEET
    func updateCustomiseSheet(product:Productlist){
        imgeVwFullCheck.image = UIImage(named: "unCheck")
        imgeVwHalfCheck.image = UIImage(named: "unCheck")
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        lblBtmShtFullAmt.text = "\(currencySymbol ?? "") \(product.FullPrice ?? "")"
        lblBtmShtHalfAmt.text =  "\(currencySymbol ?? "") \(product.HalfPrice ?? "")"
        lblBtmSheetItemName.text = product.ProductName?.capitalized ?? ""
        if let url:URL = URL(string:product.ProductImage ?? ""){
        imageBtmSheetItem.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
           }
    }
    //MARK: - CHECK IF MULTIPLE CUSTOMIZED PACKAGE
    func checkIfMultipleCustomizedPackage(product:Productlist){
        let  array = Singleton.sharedInstance.cartInfo.cartList.compactMap({$0.ProductId == product.ProductId})
        if array.count > 1{
            let dropDown =  DropdownActionPopUp.init(title: "This item has multiple customizations added. Proceed to cart to remove item?",header:"",action: .YesNo,type: .openCart, sender: self, image: nil,tapDismiss:true)
              dropDown.alertActionVC.delegate = self
        }
    }
    //MARK: - GET FILTER FOR PRODUCTS
    func getCommonFilterAPI(mainCat:String){
        WebServiceManager.sharedInstance.getCommonFilterAPI(type: "ProductList", store_id: storeID, mainCat: mainCat) { commonFilter, msg, status in
            if status == "1"{
                self.commonFilter = commonFilter!
            }else{
                
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
    //MARK: - GET PRODUCT BY SKU API
    func getProductBySkuAPI(sku:String){
        showIndicator()
        WebServiceManager.sharedInstance.getProductBySkuAPI(sku: sku){ product, msg, status in
            self.hideIndicator()
          //  self.isLodinData = false
            if status == "1"{
                
                if product?.packageType?.lowercased() == "service"{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDetailController") as! ServiceDetailController
                    vc.productDetail = product
                    vc.updateProductList = { value in
                        self.storeID = value
                        self.getStoreInfoAPI(store_id: self.storeID)
                        let vc2 = self.tabBarController!.viewControllers?[1] as! StoreCartController
                        let vc3 = self.tabBarController!.viewControllers?[2] as! OrdersListController
                        vc2.storeID = value
                        vc3.storeID = value
                    }
                    vc.openCart = {
                        self.tabBarController?.selectedIndex = 1
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailController") as! ProductDetailController
                vc.productDetail = product
                vc.updateProductList = { value in
                    self.storeID = value
                    self.getCartAPI()
                    self.getStoreInfoAPI(store_id: self.storeID)
                    let vc2 = self.tabBarController!.viewControllers?[1] as! StoreCartController
                    let vc3 = self.tabBarController!.viewControllers?[2] as! OrdersListController
                    vc2.storeID = value
                    vc3.storeID = value
                }
                vc.openCart = {
                    self.tabBarController?.selectedIndex = 1
                }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
               
              //  self.updateNoData(message: "")
                    
             }else{
             FTIndicator.showToastMessage(msg!)
             }
             }
             }
    //MARK: - GET PRODUCT LIST API
    func getProductListAPI(storeID:String,page:Int, commonFilter:String){
        guard let storeInfo = Singleton.sharedInstance.storeInfo else{return}
        WebServiceManager.sharedInstance.getProductListByStore(storeID: storeID, vertical: storeInfo.category ?? "", commonFilter: commonFilter, page:String(page)) { [self] productList, totalPage, totalCount, msg, status in
          //  self.isLodinData = false
            if page == 1{
             self.page = 1
            }
            self.refreshControl?.endRefreshing()
            self.tblVw.tableFooterView = nil
            if status == "1"{
                self.totalCount = totalCount!
                self.totalPage = totalPage!
                self.lbltotalCount.text = "Results Found \(String(self.totalCount))"
                if self.pageLoading == true && page > 1{
                    self.pageLoading = false
                    self.productList += productList!
                }else{
                    self.productList = productList!
                }
                self.updateNoData(message: "")
                self.tblVw.reloadData()
                var currentLoc: CLLocation!
                self.locationManager.requestWhenInUseAuthorization()
                if Singleton.sharedInstance.storeInfo?.category ?? "" == StoreCateType.cabService{
                    if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() == .authorizedAlways) {
                        currentLoc = self.locationManager.location
                        print(currentLoc.coordinate.latitude)
                        print(currentLoc.coordinate.longitude)
                         let location = CLLocation(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
                    }
                }
             }else{
                 self.lbltotalCount.text = ""
                 self.productList = [Productlist]()
                self.updateNoData(message: msg!)
                 self.tblVw.reloadData()
            }
        }
       }
    //MARK: - GET CART API
    func getCartAPI(){
        WebServiceManager.sharedInstance.getCartAPI(store_id: Singleton.sharedInstance.storeInfo.storeId!) { cartInfo, productList, msg, status in
            self.isLodinData = false
            if status == "1"{
                self.updateItemBadge(productList: productList!)
                self.cartProductList = productList!
                Singleton.sharedInstance.cartInfo.cartList = self.cartProductList
                Singleton.sharedInstance.cartInfo.cartDetail = cartInfo!
             // self.updateNoData(message: "")
                self.tblVw.reloadData()
             }else{
                 self.updateItemBadge(productList: [Productlist]())
                 Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
                 Singleton.sharedInstance.cartInfo.cartDetail =  Cartinfo.init(totalQty: "")
               // self.updateNoData(message: msg!)
                 self.tblVw.reloadData()
            }
        }
    }
    func updateItemBadge(productList:[Productlist]){
     //  print("Product List count \(productList.count)")
        if let tabItems = self.tabBarController!.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
            let tabItem = tabItems[1]
            if productList.count > 0{
                tabItem.badgeValue = String(productList.count)
            }else{
            tabItem.badgeValue = nil
            }
        }
    }
    //MARK: - ADD TO CART API
    func addToCartAPI(action:String,product:Productlist,package:String){
        let storeInfo = Singleton.sharedInstance.storeInfo
        
        var offerPrice = String()
        if package.lowercased() == "half"{
            offerPrice = product.HalfPrice ?? ""
        }else if package.lowercased() == "full"{
            offerPrice = product.FullPrice ?? ""
        }else{
            offerPrice = product.ProductOfferPrice ?? ""
        }
        showIndicator()
        WebServiceManager.sharedInstance.addToCartAPI(store_id: product.StoreId ?? "", productID: product.ProductId ?? "", qty: "1", action: action, offerPrice: offerPrice,payment_method:storeInfo?.paymentMethod ?? "", vertical:storeInfo?.category ?? "", store_type:storeInfo?.storeType ?? "", inventory:Singleton.sharedInstance.storeInfo.inventory ?? "", package_type:package) {msg, status in
            self.hideIndicator()
            self.isLodinData = false
            if status == "1"{
                 let cartList =  Singleton.sharedInstance.cartInfo.cartList
                if cartList.contains(where: {$0.ProductId == product.ProductId ?? "" && $0.Package == product.Package ?? "" }){ // Check if Id and Package Same
                    guard  let index =  cartList.firstIndex(where:{$0.ProductId == product.ProductId ?? "" && $0.Package == product.Package ?? ""}) else{return}
                    if action == "0"{
                        let qty:Int = Int(cartList[index].itemUnits ?? "1") ?? 1
                        Singleton.sharedInstance.cartInfo.cartList[index].itemUnits  = String(qty - 1)
                    }else{
                        let qty = Int(cartList[index].itemUnits ?? "1") ?? 1
                        Singleton.sharedInstance.cartInfo.cartList[index].itemUnits  = String(qty + 1)
                     }
                }else{
                    var productUpdated = product
                    productUpdated.itemUnits = "1"
                    Singleton.sharedInstance.cartInfo.cartList += [productUpdated]
                }
                self.getCartAPI()
              //  self.updateItemBadge(productList: Singleton.sharedInstance.cartProducts)
              //  self.tblVw.reloadData()
                FTIndicator.showToastMessage(msg)
             }else{
               FTIndicator.showToastMessage(msg)
            }
        }
       }
    //MARK: - GET STORE INFO
    func getStoreInfoAPI(store_id:String){
        let type: String?
        if fromQRCodeScan{
        type = ""
        }else{
        type = "store"
        }
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: store_id, type: type!) {storeInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
        
                if storeInfo?.settings?.lowercased() == "enable"{
                Singleton.sharedInstance.storeInfo = storeInfo
                    if Singleton.sharedInstance.storeInfo?.category == StoreCateType.hostpital{
                        self.btnBarCodeScanner.isHidden = true
                        self.constWidthBarCodeButton.constant = 0
                        self.filterWidth.constant = 0
                    }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.restaurant{
                        self.btnBarCodeScanner.isHidden = true
                        self.constWidthBarCodeButton.constant = 0
                        self.filterWidth.constant = 0
                    }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService{
                        self.btnBarCodeScanner.isHidden = true
                        self.constWidthBarCodeButton.constant = 0
                        self.filterWidth.constant = 0
                    }else{
                        self.btnBarCodeScanner.isHidden = false
                        self.constWidthBarCodeButton.constant = 44
                        self.filterWidth.constant = 44
                    }
                self.getCartAPI()
                    self.storeID = Singleton.sharedInstance.storeInfo.storeId ?? ""
                self.getProductListAPI(storeID: self.storeID, page: 1, commonFilter:"")
                self.lblTitle.text = storeInfo?.storeName?.capitalized
                }else{
                    let dropDown =  DropdownActionPopUp.init(title: "This store is not active yet!",header:"",action: .Okay,type: .storeInactive, sender: (UIApplication.shared.keyWindow?.rootViewController)!, image: nil,tapDismiss:false)
                      dropDown.alertActionVC.delegate = self
                   
                }
              //  FTIndicator.showToastMessage(msg)
             }else{
                 let dropDown =  DropdownActionPopUp.init(title: "This store is not active yet!",header:"",action: .Okay,type: .storeInactive, sender: (UIApplication.shared.keyWindow?.rootViewController)!, image: nil,tapDismiss:false)
                   dropDown.alertActionVC.delegate = self
               //  FTIndicator.showToastMessage(msg)
             }
          }
        }
       }
extension StoreProductsController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        guard isLodinData == false else{return 5}
        if searchActive{
            if self.filteredProducts.count == 0{
                self.lbltotalCount.text = "Not found"
            }else{
                self.lbltotalCount.text = "Results Found \(String(self.filteredProducts.count))"
            }
            
            return filteredProducts.count
            
        }else{
            if totalCount == 0{
                self.lbltotalCount.text = "Not found"
            }else{
                self.lbltotalCount.text = "Results Found \(String(self.totalCount))"
            }
            
        return productList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProductTableCell
        guard isLodinData == false else{return cell}
        cell.setTemplateWithSubviews(isLodinData)
        var list : [Productlist]!
        if searchActive{
            guard filteredProducts.count > 0 else{ return cell}
            list = filteredProducts
        }else{
            guard productList.count > 0 else{ return cell}
            list = productList
            }
        let product = list[indexPath.row]
        cell.selectionStyle  = .none
        cell.btnAddToCart.alpha = 1
        cell.btnAddToCart.addTarget(self, action: #selector(btnAddtoCartAction(sender: )), for: .touchUpInside)
        cell.btnPlus.addTarget(self, action: #selector(btnPlusAction(sender:)), for: .touchUpInside)
        cell.btnMinus.addTarget(self, action: #selector(btnMinusAction(sender:)), for: .touchUpInside)
        cell.lblName.text = product.ProductName?.capitalized
        cell.lblMaincat.text = product.MainCategory
        cell.lblQuantity.text = "1"
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        cell.lblDescription.text = product.ProductSHORTDESCRIPTION
//        cell.lblOfferPrice.text =  "\(currencySymbol ?? "") \(product.ProductOfferPrice!)"
//        cell.lblStatndardPrice.attributedText = "\(currencySymbol ?? "") \(product.ProductPrice!)".strikeThrough()
        //To Chek if Price Equal
        let productOfferPrice =  product.ProductOfferPrice ?? "0.0"
        let productPrice =  product.ProductPrice ?? "0.0"
        
        if Double(product.ProductOfferPrice!) == Double(productPrice){
            cell.stackVwPrice.subviews[1].isHidden = true
        }else{
           cell.stackVwPrice.subviews[1].isHidden = false
          }
        
        
        print("Product type -----> ", product.productType?.uppercased())
        if product.productType?.uppercased() == "PRODUCT"{
        if Singleton.sharedInstance.storeInfo.inventory == "without inventory"{
            cell.lblOutOfStock.alpha = 0

        }else{
            //To Chek Out of Stock
     
            if Int(product.ProductQuantity ?? "0") == 0{
                cell.StackPlusMinus.alpha = 0
                cell.lblOutOfStock.alpha = 1
                cell.btnAddToCart.alpha = 0
            }else if product.ProductQuantity ?? "0" == ""{
                cell.StackPlusMinus.alpha = 0
                cell.lblOutOfStock.alpha = 1
                cell.btnAddToCart.alpha = 0
            }else{
                cell.lblOutOfStock.alpha = 0

            }
            
        }
        }else if product.productType?.uppercased() == "SERVICE"{
            cell.StackPlusMinus.alpha = 0
            cell.lblOutOfStock.alpha = 0
            cell.btnAddToCart.alpha = 1

        }else{
            cell.lblOutOfStock.alpha = 0 // partial check
        }
        //To Chek if Customisable
        if product.HalfPrice != "" &&  product.FullPrice != "" && Singleton.sharedInstance.storeInfo.category == StoreCateType.restaurant{
            cell.lblCustomisable.alpha = 1
        }else{cell.lblCustomisable.alpha = 0}
        //To Chek Item in cart
        if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital && (product.productType == "" || product.productType == "Service" || product.productType == nil){
            cell.StackPlusMinus.alpha = 0
            cell.btnAddToCart.alpha = 1
            cell.btnAddToCart.setTitle("Book a Slot", for: .normal)
            cell.lblOfferPrice.text =  "\(currencySymbol ?? "") \(product.ProductOfferPrice!)"
            cell.lblStatndardPrice.attributedText = "\(currencySymbol ?? "") \(product.ProductPrice!)".strikeThrough()
        }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService && (product.productType == "" || product.productType == "Service" || product.productType == nil){
            cell.StackPlusMinus.alpha = 0
            cell.btnAddToCart.alpha = 1
            cell.btnAddToCart.setTitle("Book a Cab", for: .normal)
            cell.lblOfferPrice.text =  "\(currencySymbol ?? "") \(product.ProductOfferPrice!)(per km)"
            cell.lblStatndardPrice.attributedText = "\(currencySymbol ?? "") \(product.ProductPrice!)".strikeThrough()
        }else{
            cell.btnAddToCart.setTitle("Add to Order", for: .normal)
            let cartList =  Singleton.sharedInstance.cartInfo.cartList
            cell.lblOfferPrice.text =  "\(currencySymbol ?? "") \(product.ProductOfferPrice!)"
            cell.lblStatndardPrice.attributedText = "\(currencySymbol ?? "") \(product.ProductPrice!)".strikeThrough()
           if  cartList.contains(where: {$0.ProductId == product.ProductId}){
               guard  let index =  cartList.firstIndex(where:{$0.ProductId == product.ProductId ?? ""}) else{return cell}
              let foundedItem =  cartList[index] // chek if multiple package
               let  array = cartList.filter({$0.ProductId == foundedItem.ProductId})
               if  array.count > 1  {
                   let totalSumInt = array.map({Int($0.itemUnits ?? "0")!}).reduce(0, +)
                   cell.lblQuantity.text =  String(totalSumInt)
               }else{
               cell.lblQuantity.text =  cartList[index].itemUnits
               }
                   cell.btnAddToCart.alpha = 0
                   cell.StackPlusMinus.alpha = 1
               
           }else{
               cell.StackPlusMinus.alpha = 0
               }
        }
        if product.package_status ?? "" == "1"{
           let calculation =  (product.product_unit ?? "") + " * " + (product.package_quantity ?? "")
            cell.lblProductDes.text =  "Pack of  " + calculation
        }else{
            cell.lblProductDes.text = ""
        }
        self.loadMore(indexPath: indexPath)
        return cell
        }
//MARK: - CELL BUTTON IBACTIONS
   @objc func btnAddtoCartAction(sender:UIButton){
       
       
       let buttonPosition = sender.convert(CGPoint.zero, to: self.tblVw)
        let indexPath = self.tblVw.indexPathForRow(at:buttonPosition)!
       let cell = self.tblVw.cellForRow(at: indexPath) as! ProductTableCell
      // let index = sender.tag
       var list : [Productlist]!
       if searchActive{
         //  guard filteredProducts.count > 0 else{ return cell}
           list = filteredProducts
       }else{
         //  guard productList.count > 0 else{ return cell}
           list = productList
       }
       let product = list[indexPath.row]
       self.productsss = product
       if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital && (product.productType == "" || product.productType == "Service" || product.productType == nil){
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleAppoinmentVC")as! ScheduleAppoinmentVC
           print("Doctor Id ---> ",product.doctor_id ?? "")
           vc.doctorId = product.doctor_id ?? ""
           
           
           vc.productId = product.ProductId ?? ""
           vc.room_id = product.room_id ?? ""
           vc.product = product
           vc.openCart = {
               self.tabBarController?.selectedIndex = 1
               
           }
           self.navigationController?.pushViewController(vc, animated: true)
           
       }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService && (product.productType == "" || product.productType == "Service" || product.productType == nil){
           let vc = self.storyboard?.instantiateViewController(withIdentifier: "ScheduleCabViewController")as! ScheduleCabViewController
           vc.productId = product.ProductId ?? ""
           vc.taxiId = product.taxi_id ?? ""
           vc.driverID = product.driver_id ?? ""
           vc.product = product
           vc.openCart = {
               self.tabBarController?.selectedIndex = 1
               
           }
           self.navigationController?.pushViewController(vc, animated: true)
       } else{
           if product.productType == "Product"{
               addToCartAPI(  action: "1", product: product, package: "")
           }else{
               if product.HalfPrice != "" &&  product.FullPrice != ""{
                   selectedService = product
                   updateCustomiseSheet(product: product)
                   showBottomVw(vw: self.vwBottomSheetCustomise)
               }else{
                   addToCartAPI(  action: "1", product: product,package: "")
               }
             //  FTIndicator.showToastMessage("You can proceed only with product for now, this is a Service")
             }
       }
      
      }
    @objc func btnPlusAction(sender:UIButton){
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblVw)
         let indexPath = self.tblVw.indexPathForRow(at:buttonPosition)!
        let cell = self.tblVw.cellForRow(at: indexPath) as! ProductTableCell
       
        var list : [Productlist]!
        if searchActive{
          //  guard filteredProducts.count > 0 else{ return cell}
            list = filteredProducts
        }else{
          //  guard productList.count > 0 else{ return cell}
            list = productList
        }
        let product = list[indexPath.row]
        
       var productQuantity = Int(product.ProductQuantity ?? "1") ?? 1
        
        
        if product.package_status ?? "" == "1"{
           
            let productQuantity1 = Int(product.ProductQuantity ?? "1") ?? 1
            let packageQuantity = Int(product.package_quantity ?? "1") ?? 1
            productQuantity =  productQuantity1 / packageQuantity
        }
        
        if Int(cell.lblQuantity.text!) ?? 1 < productQuantity{
           // cell.lblQuantity.text =  String(Int(cell.lblQuantity.text!) ?? 1 + 1)
        }else{
            if product.productType?.uppercased() == "PRODUCT"{
            if Singleton.sharedInstance.storeInfo.inventory == "without inventory"{
            }else{
            FTIndicator.showToastMessage("Maximum quantity available is \(productQuantity)")
                return
             }
            }
            //To check if has multiple package
            if product.HalfPrice != "" &&  product.FullPrice != ""{
                selectedService = product
                updateCustomiseSheet(product: product)
                showBottomVw(vw: self.vwBottomSheetCustomise)
                return
            }
        }
        addToCartAPI(  action: "1", product: product,package: "")
       
    }
    @objc func btnMinusAction(sender:UIButton){
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tblVw)
         let indexPath = self.tblVw.indexPathForRow(at:buttonPosition)!
        let cell = self.tblVw.cellForRow(at: indexPath) as! ProductTableCell
        var list : [Productlist]!
        if searchActive{
          //  guard filteredProducts.count > 0 else{ return cell}
            list = filteredProducts
        }else{
          // guard productList.count > 0 else{ return cell}
            list = productList
         }
        let product = list[indexPath.row]
        if Int(cell.lblQuantity.text!) ?? 1 ==  1{
            addToCartAPI(  action: "0", product: product,package: "")
        }else{
            if product.HalfPrice != "" &&  product.FullPrice != ""{
                checkIfMultipleCustomizedPackage(product: product)
                return
            }
            addToCartAPI(  action: "0", product: product,package: "")
        // cell.lblQuantity.text =  String(Int(cell.lblQuantity.text!) ?? 1 - 1)
        }
       
       }
func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard isLodinData == false else{
    cell.setTemplateWithSubviews(isLodinData,viewBackgroundColor: .lightGray)
        return}
    
    var list : [Productlist]!
    if searchActive{
        guard filteredProducts.count > 0 else{ return}
        list = filteredProducts
    }else{
        guard productList.count > 0 else{ return}
        list = productList
    }
        let product = list[indexPath.row]
        if product.ProductMediumImage == ""{
          //  let cell =  (cell as! CellAssignedAsset)
            (cell as! ProductTableCell).imgVwProduct.image = #imageLiteral(resourceName: "imagePlaceholder")
        }else{
            let url = URL(string: product.ProductMediumImage ?? "")
            _ = (cell as! ProductTableCell).imgVwProduct.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))

        }
   }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    
        (cell as! ProductTableCell).imgVwProduct.kf.cancelDownloadTask()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isLodinData == false else{return}
        var list : [Productlist]!
        if searchActive{
            guard filteredProducts.count > 0 else{return}
            list = filteredProducts
        }else{
            guard productList.count > 0 else{ return}
            list = productList
            }
            let product = list[indexPath.row]
        if Singleton.sharedInstance.storeInfo.category == StoreCateType.hostpital && (product.productType == "" || product.productType == "Service" || product.productType == nil){
            
        }else if Singleton.sharedInstance.storeInfo.category == StoreCateType.cabService && (product.productType == "" || product.productType == "Service" || product.productType == nil){
            
        } else{
            if product.productType == "Product"{
            let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailController") as! ProductDetailController
            vc.productDetail = product
                vc.openCart = {
                    self.tabBarController?.selectedIndex = 1
                }
            self.navigationController?.pushViewController(vc, animated: true)
            }else{
                let vc  = self.storyboard?.instantiateViewController(withIdentifier: "ServiceDetailController") as! ServiceDetailController
                vc.productDetail = product
                    vc.openCart = {
                        self.tabBarController?.selectedIndex = 1
                    }
                self.navigationController?.pushViewController(vc, animated: true)
           // FTIndicator.showToastMessage("You can proceed only with product for now, this is a Service")
            }

        }
    }
    //MARK: LOAD MORE IN TABLE
    func loadMore(indexPath : IndexPath){
        if indexPath.row == productList.count - 1 && !pageLoading{ // last cell
            if self.totalCount > productList.count && self.page <= self.totalPage { // more items to fetch
                self.pageLoading = true
                let vW = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  44))
                self.showSpinner(onView :vW)
                // showActivityIndicatory(vw: vW)
                self.tblVw.tableFooterView = vW
                self.tblVw.tableFooterView?.isHidden = false
                self.page += 1
                let jsonEncoder = JSONEncoder()
                do {
                    let jsonData = try jsonEncoder.encode(self.commonFilter)
                    let jsonString = String(data: jsonData, encoding: .utf8)
                    getProductListAPI(storeID: storeID, page: self.page, commonFilter: jsonString!)
                  //  print("JSON String : " + jsonString!)
                   }
                catch {
                }
            }
         }
      }
   }

extension StoreProductsController:UISearchBarDelegate{
    func addToolbarToSearchKeyboard()
       {
        let numberPadToolbar: UIToolbar = UIToolbar()
        numberPadToolbar.isTranslucent = true
        numberPadToolbar.items=[
            UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.cancelAction)),
        ]
        numberPadToolbar.sizeToFit()
        searchBar.inputAccessoryView = numberPadToolbar
        }
    @objc func cancelAction(){
     searchBar.resignFirstResponder()
      }
  //MARK: *****************Filter  Data
    func filterArrayData(text:String){
        filteredProducts = productList.filter({
        $0.ProductName!.range(of: text, options: .caseInsensitive) != nil
        })
        }
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String){
        searchActive = true
        searchBar.setShowsCancelButton(true, animated: true)
        if searchText.count > 0{
        filterArrayData(text: searchText)
        tblVw.reloadData()
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        tblVw.reloadData()
        filteredProducts.removeAll()
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        }
        }
//MARK: - QRScannerCodeDelegate
extension StoreProductsController: QRScannerCodeDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
        print("result:\(result)")
        dismiss(animated: true)
        if result.contains("SKU_"){
        getProductBySkuAPI(sku:result)
       // guard  let url:URL = URL(string:result) else{return}
     
//        if result.contains("bbc.newforceltd.com") || result.contains("BBC_Customer_MW") { //Staging
//            let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
//            let vc1 = tabbar.viewControllers?.first as! StoreProductsController
//            let vc2 = tabbar.viewControllers?[1] as! StoreCartController
//            let vc3 = tabbar.viewControllers?[2] as! OrdersListController
//            vc1.storeID = url.lastPathComponent
//            vc2.storeID = url.lastPathComponent
//            vc3.storeID = url.lastPathComponent
//            print(url.lastPathComponent)
//
//            self.navigationController?.pushViewController(tabbar, animated: true)
        }else{
           FTIndicator.showToastMessage("Invalid Bar Code")
        }
      }
    
    func qrCodeScanningFailedWithError(error: String) {
        print("error:\(error)")
    }
   
}
extension StoreProductsController:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            if type == .openCart{
                self.tabBarController?.selectedIndex = 1
            }else if type == .storeInactive{
            self.navigationController?.popViewController(animated: true)
            }else{
                if Singleton.sharedInstance.cartInfo.cartList.count  > 0{
                    self.addActivity(store_id:Singleton.sharedInstance.storeInfo.storeId ?? "" , status_comment: "Item Added to Cart")
            
            }else{
                self.addActivity(store_id:Singleton.sharedInstance.storeInfo?.storeId ?? "" , status_comment: "Visit")
            }
                self.navigationController?.popViewController(animated: true)
            }
           
        }else{
          //  self.navigationController?.popViewController(animated: true)
        }
      }
    }
class ProductTableCell:UITableViewCell,ShimmeringViewProtocol{
    @IBOutlet weak var imgVwProduct: UIImageView!
    @IBOutlet weak var lblOutOfStock: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatndardPrice: UILabel!
    @IBOutlet weak var lblOfferPrice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!{
        didSet{
            lblQuantity.font = UIFont(name: "Montserrat-SemiBold", size: 13)
        }
    }
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var stackMain: UIStackView!
    @IBOutlet weak var StackPlusMinus: UIStackView!
    @IBOutlet weak var stackVwPrice: UIStackView!
    @IBOutlet weak var lblTDesc: UILabel!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var btnAddToCart: UIButton!
    @IBOutlet weak var btnMinus: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var lblMaincat: UILabel!
    @IBOutlet weak var lblCustomisable: UILabel!
    @IBOutlet var btnDeleteItem : UIButton!
    @IBOutlet var stackView : UIStackView!
    @IBOutlet var lblDoctorPrice : UILabel!
    @IBOutlet var imgIconClock : UIImageView!
    @IBOutlet var lblAppoinmentTime : UILabel!{
        didSet{
            lblAppoinmentTime.font = UIFont(name: "Montserrat-Medium", size: 11)
        }
    }
    @IBOutlet var labelProductNameHospital : UILabel!{
        didSet{
            labelProductNameHospital.font = UIFont(name: "Montserrat-SemiBold", size: 12)
        }
    }
    @IBOutlet weak var labelQuantityWidth: NSLayoutConstraint!
    @IBOutlet weak var packageLabelConstant: UILabel!
    @IBOutlet weak var packageLabel: UILabel!
    
    @IBOutlet weak var packageView: UIView!
    @IBOutlet weak var packageImageView: UIImageView!
    
    @IBOutlet weak var lblProductDes: UILabel!
    
    @IBOutlet var btnReschedule : UIButton!{
        didSet{
            btnReschedule.layer.borderColor = UIColor.systemOrange.cgColor
            btnReschedule.layer.borderWidth = 1
            
        }
    }
    @IBOutlet var btnCancel : UIButton!{
        didSet{
            btnCancel.layer.borderWidth = 1
            btnCancel.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    var shimmeringAnimatedItems: [UIView] {
                 [
                    lblCustomisable,
                    lblMaincat,
                  imgVwProduct,
                    imgIconClock,
                  lblName,
                  lblStatndardPrice,
                  lblOfferPrice,
                  lblQuantity,
                  lblDescription,
                  stackVwPrice,
                  lblTDesc,
                  btnPlus,
                  btnAddToCart,
                  btnMinus,
                  btnDelete,btnDeleteItem
                  ].compactMap{ $0}
                  }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
   
    }
    var btnDeleteItemHander:(()->())?
    @IBAction func btnDeleteItem(_ sender : Any){
        btnDeleteItemHander?()
    }
    var btnRescheduleHandler:(()->())?
    @IBAction func btnRecheduleAction(_ sender : Any){
       btnRescheduleHandler?()
    }
    var btnCancelHandler:(()->())?
    @IBAction func btnCancelAction(_ sender : Any){
       btnCancelHandler?()
    }
}

