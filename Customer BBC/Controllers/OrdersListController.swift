//
//  OrdersListController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 06/05/22.
//

import UIKit
import UIView_Shimmer

class OrdersListController: UIViewController {
        //MARK: - IBOUTLET
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var lblFilterCount: UILabel!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var vwBgSearchBar: UIView!
    @IBOutlet weak var filterWidth: NSLayoutConstraint!
    //MARK: - VARIABLES
    var totalCount = Int()
    var totalPage = Int()
    var page = 1
    var commonFilter = [CommonFilter]()
    var pageLoading = false
   
        var storeID = String()
        private var isLodinData = true
        private var searchActive = false
        var filteredOrders = [OrderList]()
        var salesOrderList = [OrderList]()
            //MARK: - IBACTIONS
    @IBAction func btnBackAction(_ sender: UIButton) {
        if self.tabBarController != nil{
            let dropDown =  DropdownActionPopUp.init(title: "Are you sure, you want to exit from store",header:"",action: .YesNo,type:.storeExit, sender: self, image: nil,tapDismiss:true)
              dropDown.alertActionVC.delegate = self
        }else{
        self.navigationController?.popViewController(animated: true)
        }
        }
    @IBAction func btnOpenFilter(_ sender: UIButton) {
     let vc = self.storyboard?.instantiateViewController(withIdentifier: "CommonFilterController") as! CommonFilterController
        vc.storeID = storeID
        vc.filters = commonFilter
        vc.type = "OrderList"
        vc.applyFilter = { filter in
            self.commonFilter = filter
            let jsonEncoder = JSONEncoder()
            do {
                let jsonData = try jsonEncoder.encode(self.commonFilter)
                let jsonString = String(data: jsonData, encoding: .utf8)
                self.getOrderListAPI(page: 1, commonFilter: jsonString!)
                print("JSON String : " + jsonString!)
            }
            catch {
            }
            var count = 0
            for item in self.commonFilter {
                if item.returnValue != ""{
                    count += 1
                }else{
//                    count = 0
                }
            }
            print("Filter count -- ",count)
            if count > 0{
                self.lblFilterCount.isHidden = false
                self.lblFilterCount.alpha = 1
                self.lblFilterCount.text = String(count)
            }else{
                self.lblFilterCount.isHidden = true
                self.lblFilterCount.alpha = 0
                self.lblFilterCount.text = ""
            }
        }
        self.navigationController!.present(vc, animated: true)
    }
            //MARK: - VIEW LIFE CYCLE
        override func viewDidLoad() {
            super.viewDidLoad()
            getCommonFilterAPI(mainCat: "")
            getOrderListAPI(page: 1, commonFilter: "")
            updateUI()
            addToolbarToSearchKeyboard()
                    self.lblFilterCount.text = ""
                    if self.lblFilterCount.text == "" {
                        self.lblFilterCount.alpha = 0
                        self.lblFilterCount.isHidden = true
                    }else{
            
                        self.lblFilterCount.alpha = 1
                        self.lblFilterCount.isHidden = false
                    }
         }
    
    override func viewWillAppear(_ animated: Bool) {
        getOrderListAPI(page: 1, commonFilter: "")
//        self.lblFilterCount.text = ""
//        if self.lblFilterCount.text == "" {
//            self.lblFilterCount.alpha = 0
//            self.lblFilterCount.isHidden = true
//        }else{
//     
//            self.lblFilterCount.alpha = 1
//            self.lblFilterCount.isHidden = false
//        }
    }
        //MARK: - UPDATE UI
        func updateUI(){
            lblFilterCount.layer.borderColor = hexStringToUIColor(hex: Color.red.rawValue).cgColor
            lblFilterCount.layer.borderWidth = 1
            lblFilterCount.alpha = 0
            self.tblVw.tableFooterView = UIView()
            self.tblVw.estimatedRowHeight = 140
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
        //MARK: ************UPDATE NO DATA FOUND
        func updateNoData(message:String){
            if self.salesOrderList.count > 0 {
                self.tblVw.backgroundView = UIView()
            }else{
                let vwNoData = ViewNoData()
                vwNoData.imgVw.image = UIImage(named: "noDataFound")
                self.tblVw.backgroundView = vwNoData
                vwNoData.center.x = self.view.center.x
                vwNoData.center.y =  self.view.center.y
                vwNoData.label.text = message
            }
        }
    //MARK: - GET FILTER FOR ORDERLIST
    func getCommonFilterAPI(mainCat:String){
        WebServiceManager.sharedInstance.getCommonFilterAPI(type: "OrderList", store_id: storeID, mainCat: mainCat) { commonFilter, msg, status in
            if status == "1"{
                self.commonFilter = commonFilter!
            }else{
                
            }
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
        //MARK: - GET SALES ORDER LIST API
    func getOrderListAPI(page:Int,commonFilter:String){
        WebServiceManager.sharedInstance.getStoreOrderList(page: String(page), commonFilter: commonFilter) { ordersList, totalPage, totalCount, msg, status in
            if page == 1{
                self.page = 1
                }
                self.isLodinData = false
            self.tblVw.tableFooterView = nil
                if status == "1"{
                    
                        self.totalCount = totalCount!
                        self.totalPage = totalPage!
                        if self.pageLoading == true && page > 1{
                        self.pageLoading = false
                        self.salesOrderList += ordersList!
                        }else{
                            self.salesOrderList = ordersList!
                        }
               
                        
                        self.btnFilter.alpha = 1
                        self.filterWidth.constant = 44
                        self.lblFilterCount.alpha = 1
                    
                        self.updateNoData(message: "")
                        self.tblVw.reloadData()
                 }else{
//                    self.salesOrderList = [OrderList]()
//                    self.updateNoData(message:msg!)
                    self.tblVw.reloadData()
                }
        }
    }
}
    extension OrdersListController:UITableViewDelegate,UITableViewDataSource{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard isLodinData == false else{return 5}
            if searchActive{
                return filteredOrders.count
            }else{
            return salesOrderList.count
            }
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SalesOrderTableCell
            cell.selectionStyle = .none
            guard isLodinData == false else{return cell}
            var list : OrderList!
            if searchActive{
                guard filteredOrders.count > 0 else{ return cell}
                list = filteredOrders[indexPath.row]
            }else{
                guard salesOrderList.count > 0 else{ return cell}
                list = salesOrderList[indexPath.row]
            }
          //  cell.lblOrderID.attributedText = getAttrbText(simpleText: list.orderId!, text: "Order ID: \(list.orderId!)")
            cell.lblOrderID.text = list.orderId ?? ""
            cell.lbldate.text = "\(list.orderdate!) \(list.orderTime!)"
          //  cell.lblAmount.text  = "\(list?.storeType ?? ""): \(list.Products!)"
            
            
            let currencySymbol = list.currencySymbol
            if list.paymentMethod  ?? "" == ""{
                cell.lblPaymentMethod.text  = "\(currencySymbol ?? "") \(list.totalAmount!)"
            }else{
            cell.lblPaymentMethod.text  = "\(list.paymentMethod!): \(currencySymbol ?? "") \(list.totalAmount!)"
            }
            if list.order_type == ""{
                cell.orderTypeLabel.text = ""
            }else{
                cell.orderTypeLabel.text = list.order_type ?? ""
            }
         //   cell.lblCustomerName.text = "\(list?.category ?? ""): \(list.storeName ?? "")"
           
            let attrs1 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Bold", size: 15.0), NSAttributedString.Key.foregroundColor : UIColor.black]

            let attrs2 = [NSAttributedString.Key.font : UIFont.init(name: "Montserrat-Regular", size: 15.0), NSAttributedString.Key.foregroundColor : UIColor.darkGray]

            let attributedString1 = NSMutableAttributedString(string:"\(list?.category ?? ""): " , attributes:attrs1)

            let attributedString2 = NSMutableAttributedString(string:list.storeName ?? "", attributes:attrs2)
            
            let attributedStringAmount1 = NSMutableAttributedString(string:"\(list?.storeType ?? ""): " , attributes:attrs1)
            
            let attributedStringAmount2 = NSMutableAttributedString(string:list?.Products ?? "" , attributes:attrs2)

            attributedString1.append(attributedString2)
            attributedStringAmount1.append(attributedStringAmount2)
            cell.lblCustomerName.attributedText = attributedString1
            cell.lblAmount.attributedText = attributedStringAmount1

            cell.lblStatus.text = list.status
            cell.lblMobile.text = list.userMobile
            cell.lblQuantity.attributedText = getAttrbText(simpleText: list.unit!, text: "Qty: \(list.unit!)")
          
            cell.lblProductsName.attributedText = getAttrbText(simpleText: list.Products!, text: "Product: \(list.Products!)")

//            if list.status == "Complete"{
//            cell.lblStatus.textColor = hexStringToUIColor(hex: Color.greenApproved.rawValue)
//            }else if list.status == "Pending" {
//            cell.lblStatus.textColor = hexStringToUIColor(hex: Color.pending.rawValue)
//            }else{
//            cell.lblStatus.textColor = hexStringToUIColor(hex: Color.red_error.rawValue)
//           }
            
             if list.status ?? "" == "Complete" || list.status ?? "" == "Completed"{
                // cell.btnDownload.alpha = 0
                 cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.greenApproved.rawValue)
            }else if list.status ?? "" == "Pending" {
                //   cell.btnDownload.alpha = 1
                cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
            }else if list.status ?? "".lowercased() == "Prepared"{
                //  cell.btnDownload.alpha = 0
                cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.prepared.rawValue)
            }else if list.status ?? "".lowercased() == "Preparing"{
                //  cell.btnDownload.alpha = 0
                cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.preparing.rawValue)
            }else if list.status ?? "".lowercased() == "Rejected" || list.status ?? "".lowercased() == "Decline"{
                //  cell.btnDownload.alpha = 0
                cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.cancel.rawValue)
            }else if  list.status ?? "".lowercased() == "Cancel" || list.status ?? "".lowercased() == "Cancelled"{
                    //  cell.btnDownload.alpha = 0
                    cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.cancel.rawValue)
                
            }else{
                cell.lblStatus.textColor = hexStringToUIColor(hex: ColorOrderDetail.pending.rawValue)
            }
            
            
            switch list.storeType{
            case "Product":
            cell.imgVW.image = UIImage(named:"store")
            case "Service":
                if list.category?.uppercased() == "SALOON"{
            cell.imgVW.image = UIImage(named:"salon")
                }else if list.category?.lowercased() == StoreCateType.restaurant{
            cell.imgVW.image = UIImage(named:"ic_restaurant")
                }else  if list.category?.lowercased() == StoreCateType.hostpital{
                    cell.imgVW.image = UIImage(named:"hospitalimage")
                }else if list.category?.lowercased() == StoreCateType.cabService{
                    cell.imgVW.image = UIImage(named:"ic_cab_icon")
                }else if list.category?.lowercased() == StoreCateType.diagnostic{
                    cell.imgVW.image = UIImage(named:"diagonstic")
                }
//            case "hospital":
               
            default:break
            }
            loadMore(indexPath: indexPath)
            return cell
            }
        
        
      
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//            return UITableView.automaticDimension
            return 120
        }
        func getAttrbText(simpleText:String,text:String) -> NSMutableAttributedString{
                let range = (text as NSString).range(of: String(text))
                let range1 = (text as NSString).range(of: String(simpleText))
        
                let attribute = NSMutableAttributedString.init(string: text)
                attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Montserrat-SemiBold", size: 13)!, range: range)
                attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.init(name: "Montserrat-Regular", size: 13)!, range: range1)
                return attribute
            }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if isLodinData == false{
                var list = [OrderList]()
              
                    if searchActive{
                        list = filteredOrders
                     }else{
                        list = salesOrderList
                     }
                    
                    let order = list[indexPath.row]
                if order.order_batch_id == "" {
                    if order.category == StoreCateType.cabService{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CabOrderDetailVC") as! CabOrderDetailVC
                        vc.ordedrDetail = order
                        vc.orderType = order.order_type ?? ""
                        vc.productType = order.product_type 
//                        vc.category = order.category ?? ""
//                        vc.storeID = order.storeId ?? ""
                        print("Order Batch ID -----> ",order.order_batch_id)
                        vc.updateOrderList = {
                            let jsonEncoder = JSONEncoder()
                            do {
                                let jsonData = try jsonEncoder.encode(self.commonFilter)
                                let jsonString = String(data: jsonData, encoding: .utf8)
                                self.getOrderListAPI(page: self.page, commonFilter: jsonString!)
                                print("JSON String : " + jsonString!)
                            }
                            catch {
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailController") as! OrderDetailController
                        vc.ordedrDetail = order
                        vc.orderType = order.order_type ?? ""
                        vc.category = order.category ?? ""
                        vc.storeID = order.storeId ?? ""
                        vc.productType = order.product_type
                        print("Order Batch ID -----> ",order.order_batch_id)
                        vc.updateOrderList = {
                            let jsonEncoder = JSONEncoder()
                            do {
                                let jsonData = try jsonEncoder.encode(self.commonFilter)
                                let jsonString = String(data: jsonData, encoding: .utf8)
                                self.getOrderListAPI(page: self.page, commonFilter: jsonString!)
                                print("JSON String : " + jsonString!)
                            }
                            catch {
                            }
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                }else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "OrderBatchDetailVC") as! OrderBatchDetailVC
                    vc.ordedrDetail = order
                    vc.orderType = order.order_type ?? ""
                    vc.category = order.category ?? ""
                     vc.orderBatchId = order.order_batch_id
                    vc.productType = order.product_type
                     print("Order Batch ID -----> ",order.order_batch_id)
                    vc.updateOrderList = {
                        let jsonEncoder = JSONEncoder()
                        do {
                            let jsonData = try jsonEncoder.encode(self.commonFilter)
                            let jsonString = String(data: jsonData, encoding: .utf8)
                            self.getOrderListAPI(page: self.page, commonFilter: jsonString!)
                            print("JSON String : " + jsonString!)
                        }
                        catch {
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                  
            }else{
                
            }
           
            
         }
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard isLodinData == true else{
                cell.setTemplateWithSubviews(isLodinData)
                return}
            cell.setTemplateWithSubviews(isLodinData,viewBackgroundColor: .lightGray)
           }

        //MARK: LOAD MORE IN TABLE
        func loadMore(indexPath : IndexPath){
            if indexPath.row == salesOrderList.count - 1 && !pageLoading{ // last cell
                if self.totalCount  > salesOrderList.count && self.page <= self.totalPage  { // more items to fetch
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
                        getOrderListAPI(page: self.page, commonFilter: jsonString!)
                        print("JSON String : " + jsonString!)
                    }
                    catch {
                    }
                   
                   
                }
            }
        }
    }
    extension OrdersListController:UISearchBarDelegate{
        func addToolbarToSearchKeyboard()
        {
            let numberPadToolbar: UIToolbar = UIToolbar()
            numberPadToolbar.isTranslucent = true
            numberPadToolbar.items=[
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.cancelAction)),
            ]
            numberPadToolbar.sizeToFit()
            searchBar.inputAccessoryView = numberPadToolbar
         }
        @objc func cancelAction()
        {
            searchBar.resignFirstResponder()
        }
        //MARK: *****************Filter  Data
        func filterArrayData(text:String){
            filteredOrders = salesOrderList.filter( {
            $0.orderId!.range(of: text, options: .caseInsensitive) != nil ||   $0.storeName!.range(of: text, options: .caseInsensitive) != nil
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
            filteredOrders.removeAll()
            searchBar.text = ""
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.resignFirstResponder()
            
        }
    }
    class SalesOrderTableCell:UITableViewCell,ShimmeringViewProtocol{
        @IBOutlet weak var imgVW: UIImageView!
        @IBOutlet weak var lblOrderID: UILabel!
        @IBOutlet weak var lbldate: UILabel!
        @IBOutlet weak var lblAmount: UILabel!
        @IBOutlet weak var lblCustomerName: UILabel!
        @IBOutlet weak var lblStatus: UILabel!
        @IBOutlet weak var lblMobile: UILabel!
        @IBOutlet weak var lblQuantity: UILabel!
        @IBOutlet weak var lblProductsName: UILabel!
        @IBOutlet weak var lblPaymentMethod: UILabel!
        @IBOutlet weak var orderTypeLabel: UILabel!
//        {
//            didSet{
//                orderTypeLabel.text = ""
//            }
//        }
        var shimmeringAnimatedItems: [UIView] {
               [
                imgVW,
                lblOrderID,
                lblCustomerName,
                lbldate,
                lblAmount,
                lblStatus,
                lblMobile,
                lblQuantity,
                lblProductsName,
                lblPaymentMethod
               ]
           }
        }
extension OrdersListController:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            self.navigationController?.popViewController(animated: true)
        }else{
          //  self.navigationController?.popViewController(animated: true)
        }
      }
    }
