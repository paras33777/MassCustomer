//
//  ServiceDetailController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 09/06/22.
//

import UIKit
import UIView_Shimmer
import FTIndicator

class ServiceDetailController: UIViewController {
    // MARK: - IBOUTLET
    @IBOutlet weak var lblOutofStock: UILabel!
    @IBOutlet weak var imgVwProduct: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var btnAddCart: UIButton!
    @IBOutlet weak var lblDescrip: UILabel!
    @IBOutlet weak var stackQytyPrice: UIStackView!
    @IBOutlet weak var lblStandardPrice: UILabel!
    @IBOutlet weak var lblOfferPrice: UILabel!
    @IBOutlet weak var imgeVwFullCheck: UIImageView!
    @IBOutlet weak var imgeVwHalfCheck: UIImageView!
    @IBOutlet weak var lblFullAmt: UILabel!
    @IBOutlet weak var lblHalfAmt: UILabel!
    // MARK: - VARIABLE
    var fromMainScanner = false
    var openCart:(() -> Void)!
    var productDetail : Productlist!
    var updateProductList:((_ storeID:String) -> Void)!
    var package = String()
    // MARK: - IBACTION
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
    
    @IBAction func btnAddToCartAction(_ sender: UIButton) {
        
        if sender.currentTitle == "Add to order"{
            if package == "" && productDetail.HalfPrice != "" &&  productDetail.FullPrice != ""{
                FTIndicator.showToastMessage("Please select item quantity")
            }else{
                addToCartAPI(  action: "1", product: productDetail, package: package)
                btnAddCart.setTitle("Go to cart", for: .normal)
            }
        }else{
            if self.openCart != nil{
                self.openCart()
            }else{
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: StoreTabController.self) {
                        let vc = controller as! StoreTabController
                        vc.selectedIndex = 1
                        break
                    }
                }
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnbackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad(){
        super.viewDidLoad()
        setProductImage()
        updateUI()
    }
    //MARK: - SET Product image
    func setProductImage(){
        
        if let url:URL = URL(string:productDetail.ProductImage ?? ""){
            imgVwProduct.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
        }
    }
    //MARK: - UPDATE UI
    func updateUI(){
        if self.fromMainScanner {
            
        }else{
            if Singleton.sharedInstance.storeInfo.storeId != productDetail.StoreId{
                let dropDown =  DropdownActionPopUp.init(title: "Are you sure you want to change \(Singleton.sharedInstance.storeInfo.storeName ?? "") to \(productDetail.StoreName ?? "") ",header:"",action: .YesNo,type:.changeStore, sender: self, image: nil,tapDismiss:true)
                
                dropDown.alertActionVC.delegate = self
            }
        }
        
        btnAddCart.setTitle("Add to order", for: .normal)
        lblProductName.text = productDetail.ProductName?.capitalized
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        if  productDetail.HalfPrice != "" &&  productDetail.FullPrice != ""{
            stackQytyPrice.subviews[0].isHidden = true
            stackQytyPrice.subviews[1].isHidden = false
            stackQytyPrice.subviews[2].isHidden = false
            lblFullAmt.text = "\(currencySymbol ?? "") \(productDetail.FullPrice ?? "")"
            lblHalfAmt.text = "\(currencySymbol ?? "") \(productDetail.HalfPrice ?? "")"
        }else{
            stackQytyPrice.subviews[0].isHidden = false
            stackQytyPrice.subviews[1].isHidden = true
            stackQytyPrice.subviews[2].isHidden = true
            if productDetail.HalfPrice != "" {
                lblOfferPrice.text = "\(currencySymbol ?? "") \(productDetail.HalfPrice ?? "")"
            }else{
                lblOfferPrice.text = "\(currencySymbol ?? "") \(productDetail.FullPrice ?? "")"
            }
        }
        lblDescrip.text = productDetail.ProductSHORTDESCRIPTION
        
    }
    //MARK: - GET CART API
    func getCartAPI(){
        WebServiceManager.sharedInstance.getCartAPI(store_id: self.productDetail.StoreId ?? "") { cartInfo, productList, msg, status in
            if status == "1"{
                Singleton.sharedInstance.cartInfo.cartList = productList!
                Singleton.sharedInstance.cartInfo.cartDetail = cartInfo!
            }else{
                Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
            }
        }
    }
    //MARK: - ADD TO CART API
    func addToCartAPI(action:String,product:Productlist,package:String){
        let storeInfo = Singleton.sharedInstance.storeInfo
        showIndicator()
        var offerPrice = String()
        if package.lowercased() == "half"{
            offerPrice = product.HalfPrice ?? ""
        }else if package.lowercased() == "full"{
            offerPrice = product.FullPrice ?? ""
        }else{
            offerPrice = product.ProductOfferPrice ?? ""
        }
        WebServiceManager.sharedInstance.addToCartAPI(store_id: product.StoreId ?? "", productID: product.ProductId ?? "", qty: "1", action: action, offerPrice: offerPrice ,payment_method:storeInfo?.paymentMethod ?? "", vertical:storeInfo?.category ?? "", store_type:storeInfo?.storeType ?? "", inventory:Singleton.sharedInstance.storeInfo.inventory ?? "", package_type:package) {msg, status in
            self.hideIndicator()
            if status == "1"{
                self.btnAddCart.setTitle("Go to cart", for: .normal)
                let cartList = Singleton.sharedInstance.cartInfo.cartList
                if cartList.contains(where: {$0.ProductId == product.ProductId ?? "" && $0.Package == product.Package ?? "" }){ // Check if Id and Package Same
                    guard  let index =  cartList.firstIndex(where:{$0.ProductId == product.ProductId ?? "" && $0.Package == product.Package ?? ""}) else{return}
                    if action == "0"{
                        let qty:Int = Int(cartList[index].itemUnits ?? "1") ?? 1
                        Singleton.sharedInstance.cartInfo.cartList[index].itemUnits  = String(qty - 1)
                    }else{
                        let qty = Int(cartList[index].itemUnits ?? "1") ?? 1
                        Singleton.sharedInstance.cartInfo.cartList[index].itemUnits = String(qty + 1)
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
}
extension ServiceDetailController:DropdownActionDelegate{
    func dropdownActionBool(yesClicked: Bool, type: DropdownActionType) {
        if yesClicked{
            self.updateProductList(productDetail.StoreId ?? "")
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}
//extension ProductDetailController: ShimmeringViewProtocol{
//    var shimmeringAnimatedItems: [UIView]{
//        [imgVwProduct,
//        lblProductName,
//        lblStandardPrice,
//        lblOfferPrice,
//        lblQuantity,
//        btnAddCart,
//         lblDescrip].compactMap({$0})
//    }
//}
