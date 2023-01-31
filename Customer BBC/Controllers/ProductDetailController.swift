//
//  ProductDetailController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 10/05/22.
//

import UIKit
import UIView_Shimmer
import FTIndicator

class ProductDetailController: UIViewController {
    // MARK: - IBOUTLET
    @IBOutlet weak var stackPriceQty: UIStackView!
    @IBOutlet weak var lblOutofStock: UILabel!
    @IBOutlet weak var imgVwProduct: UIImageView!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblStandardPrice: UILabel!
    @IBOutlet weak var lblOfferPrice: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnAddCart: UIButton!
    @IBOutlet weak var lblDescrip: UILabel!
    @IBOutlet weak var stackVwPrice: UIStackView!
    
    @IBOutlet weak var stackPackOf: UIStackView!
    @IBOutlet weak var packOfLabel: UILabel!
    @IBOutlet weak var packUnitLabel: UILabel!
    
    
    // MARK: - VARIABLE
    var fromMainScanner = false
    var openCart:(() -> Void)!
    var productDetail : Productlist!
    
    //    var productDetailAll : ProductDetail!
    
    var updateProductList:((_ storeID:String) -> Void)!
    // MARK: - IBACTION
    @IBAction func btnMinusAction(_ sender: UIButton){
        if Int(lblQuantity.text!) ?? 1 ==  1{
        }else{
            // cell.lblQuantity.text =  String(Int(cell.lblQuantity.text!) ?? 1 - 1)
            addToCartAPI(  action: "0", product: self.productDetail)
        }
        
    }
    @IBAction func btnAddToCartAction(_ sender: UIButton) {
        if sender.currentTitle == "Add to order"{
            addToCartAPI(  action: "1", product: productDetail)
            btnAddCart.setTitle("Go to cart", for: .normal)
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
    @IBAction func btnPlusAction(_ sender: UIButton){
        
        if Int(lblQuantity.text!) ?? 1 < Int(productDetail.ProductQuantity ?? "1") ?? 1{
            // cell.lblQuantity.text =  String(Int(cell.lblQuantity.text!) ?? 1 + 1)
        }else{
            if productDetail.productType?.uppercased() == "PRODUCT"{
                if Singleton.sharedInstance.storeInfo.inventory == "without inventory"{
                    
                }else{
                    FTIndicator.showToastMessage("Product maximum quantity available is \(productDetail.ProductQuantity ?? "")")
                    return
                }
            }
        }
        addToCartAPI(  action: "1", product: productDetail)
        
    }
    @IBAction func btnbackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setProductImage()
        self.updateUI()
        // self.geProductDetailsByID(productId: self.productDetail.ProductId ?? "")
    }
    /*  func geProductDetailsByID(productId:String){
     WebServiceManager.sharedInstance.getProductDetailsById(product_id: productId) {list1,msg, status in
     if status == "1"{
     self.productDetailAll = list1
     self.setProductImage()
     self.updateUI()
     }else{
     FTIndicator.showToastMessage(msg)
     }
     }
     }*/
    //MARK: - SET Product image
    func setProductImage(){
        
        if let url:URL = URL(string:productDetail.ProductImage ?? ""){
            imgVwProduct.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))
        }
    }
    //MARK: - UPDATE UI
    func updateUI(){
        
        if self.productDetail.package_status == "1"{
            self.stackPackOf.isHidden = false
            self.packUnitLabel.text = (productDetail.product_unit ?? "") + " * " + (productDetail.package_quantity ?? "")
        }else{
            self.stackPackOf.isHidden = true
        }
        
        
        if self.fromMainScanner {
            
        }else{
            if Singleton.sharedInstance.storeInfo.storeId != productDetail.StoreId{
                let dropDown =  DropdownActionPopUp.init(title: "Are you sure you want to change the current store?",header:"",action: .YesNo,type:.changeStore, sender: self, image: nil,tapDismiss:true)
                //  let dropDown =  DropdownActionPopUp.init(title: "Are you sure you want to change \(Singleton.sharedInstance.storeInfo.storeName ?? "") to \(productDetail.StoreName ?? "") ",header:"",action: .YesNo,type:.changeStore, sender: self, image: nil)
                
                dropDown.alertActionVC.delegate = self
            }
        }
        btnAddCart.setTitle("Add to order", for: .normal)
        lblProductName.text = productDetail.ProductName?.capitalized
        let currencySymbol = Singleton.sharedInstance.storeInfo.currencySymbol
        lblOfferPrice.text = "\(currencySymbol ?? "") \(productDetail.ProductOfferPrice!)"
        lblStandardPrice.attributedText = "\(currencySymbol ?? "") \(productDetail.ProductPrice!)".strikeThrough()
        if Double(productDetail.ProductOfferPrice!) == Double(productDetail.ProductPrice!){
            stackVwPrice.subviews[0].isHidden = true
        }else{
            stackVwPrice.subviews[0].isHidden = false
        }
        lblQuantity.text = "1"
        lblDescrip.text = productDetail.ProductSHORTDESCRIPTION
        if productDetail.productType?.uppercased() == "PRODUCT"{
            if Singleton.sharedInstance.storeInfo.inventory == "without inventory"{
                lblOutofStock.alpha = 0
                btnAddCart.alpha = 1
                
            }else{
                if Int(productDetail.ProductQuantity ?? "0") == 0{ // when item out of stock
                    //   stackPriceQty.subviews[1].isHidden = true
                    lblOutofStock.alpha = 1
                    btnAddCart.alpha = 0
                }else if productDetail.ProductQuantity ?? "" == ""{
                    
                    // stackPriceQty.subviews[1].isHidden = false
                    lblOutofStock.alpha = 1
                    btnAddCart.alpha = 0
                }else{
                    lblOutofStock.alpha = 0
                    btnAddCart.alpha = 1
                }
                
            }
        }else{
            lblOutofStock.alpha = 0
            btnAddCart.alpha = 1
            
        }
        
        
        
        
        let cartList = Singleton.sharedInstance.cartInfo.cartList
        
        if cartList.contains(where: {$0.ProductId == productDetail.ProductId}){
            guard  let index = cartList.firstIndex(where:{$0.ProductId == productDetail.ProductId}) else{return}
            lblQuantity.text = cartList[index].itemUnits
            //  btnAddCart.setTitle("Go to cart", for: .normal)
        }
    }
    //MARK: - ADD TO CART API
    func addToCartAPI(action:String,product:Productlist){
        let storeInfo = Singleton.sharedInstance.storeInfo
        var package  = String()
        if product.productType == "Product"{
            package = ""
        }
        showIndicator()
        WebServiceManager.sharedInstance.addToCartAPI(store_id: product.StoreId ?? "", productID: product.ProductId ?? "", qty: "1", action: action, offerPrice: product.ProductOfferPrice ?? "",payment_method:storeInfo?.paymentMethod ?? "", vertical:storeInfo?.category ?? "", store_type:storeInfo?.storeType ?? "", inventory:Singleton.sharedInstance.storeInfo.inventory ?? "", package_type:package) {msg, status in
            self.hideIndicator()
            if status == "1"{
                let cartList = Singleton.sharedInstance.cartInfo.cartList
                if cartList.contains(where: {$0.ProductId == product.ProductId ?? ""}){ // To Update Quantity as per ITEM
                    guard  let index =  cartList.firstIndex(where:{$0.ProductId == product.ProductId ?? ""}) else{return}
                    if action == "0"{
                        let qty:Int = Int(cartList[index].itemUnits ?? "1") ?? 1
                        Singleton.sharedInstance.cartInfo.cartList[index].itemUnits  = String(qty - 1)
                    }else{
                        let qty = Int(cartList[index].itemUnits ?? "1") ?? 1
                        Singleton.sharedInstance.cartInfo.cartList[index].itemUnits  = String(qty + 1)
                    }
                    self.lblQuantity.text = cartList[index].itemUnits
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
    //MARK: - GET CART API
    func getCartAPI(){
        WebServiceManager.sharedInstance.getCartAPI(store_id: productDetail.StoreId ?? "") { cartInfo, productList, msg, status in
            
            if status == "1"{
                
                Singleton.sharedInstance.cartInfo.cartList = productList!
                Singleton.sharedInstance.cartInfo.cartDetail = cartInfo!
                
            }else{
                
                Singleton.sharedInstance.cartInfo.cartList = [Productlist]()
                Singleton.sharedInstance.cartInfo.cartDetail = Cartinfo.init(totalQty: "")
            }
        }
    }
}
extension ProductDetailController:DropdownActionDelegate{
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
