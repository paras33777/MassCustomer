//
//  TableSelectionVC.swift
//  Customer BBC
//
//  Created by Lakshay on 03/11/22.
//

import UIKit
import FTIndicator
protocol tableSelectionBack{
    func tableSelectionCallBack(ids : [String], numbers : [String], isFromTable : String)
}
protocol skipTableSelection{
    func skipTableSelectionData()
}
protocol scanningBack{
    func scanningCallBack(tableNumber : String,tableID : String)
}
class TableSelectionVC: UIViewController, tableListBack {
    func tableListCallBack(ids: [String], numbers: [String]) {
        if let del = delegate{
            self.navigationController?.popViewController(animated: false)
            del.tableSelectionCallBack(ids: ids, numbers: numbers, isFromTable: "1")
            
        }
    }
    
    //MARK: OUTLET
    
    @IBOutlet var topView : UIView!{
        didSet{
            topView.layer.borderWidth = 1
            if #available(iOS 13.0, *) {
                topView.layer.borderColor = UIColor.systemGray4.cgColor
            } else {
                // Fallback on earlier versions
            }
        }
    }
    //MARK: VARIABLE
    var storeID = ""
    var delegate : tableSelectionBack?
    var skipDelegate : skipTableSelection?
    var scanDelegate : scanningBack?
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()

    }
//MARK: BUTTON ACTION
    @IBAction func btnSkipAction(_ sender : Any){
        if let del = skipDelegate{
            self.navigationController?.popViewController(animated: false)
            del.skipTableSelectionData()
        }
    }
    @IBAction func btnScannerAction(_ sender : Any){
        let scanner = self.storyboard?.instantiateViewController(withIdentifier: "QRCodeScannerController") as! QRCodeScannerController
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
    }
    @IBAction func btnSelectTable(_ sender : Any){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TableListVC") as! TableListVC
        vc.modalPresentationStyle = .overCurrentContext
        vc.storeId = storeID
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func btnBackAction(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
}
extension TableSelectionVC: QRScannerCodeDelegate {
    func qrCodeScanningDidCompleteWithResult(result: String) {
        print("result:\(result)")
        
        
        dismiss(animated: true)
        
        
        let value = result.split(separator: "/")
        if value[2].contains("Table"){
            print("Table")
            let split = value[2].split(separator: "_")
            let id = split[1]
            
            getTRCStoreId(barID: String(id))
        }else{
            let id = value[2]
            getTRCStoreId(barID: String(id))
        }
        
     
        

        
        }
    func getTRCStoreId(barID : String){
        print("ID ----",barID)
        WebServiceManager.sharedInstance.getTRCStoreId(barcodeId: barID){storeInfo, msg, status in
            if status == "1"{
                if storeInfo?.trcStatus == "Inactive"{
                    FTIndicator.showToastMessage("Table is inactive")
                }else{
                    if let del = self.scanDelegate{
                        self.navigationController?.popViewController(animated: false)
                        del.scanningCallBack(tableNumber: storeInfo?.trcNumbers ?? "", tableID: storeInfo?.trcId ?? "")
                    }
//                    let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
//                    let vc1 = tabbar.viewControllers?.first as! StoreProductsController
//                    let vc2 = tabbar.viewControllers?[1] as! StoreCartController
//                    let vc3 = tabbar.viewControllers?[2] as! OrdersListController
//                    vc1.fromQRCodeScan = true
//                    vc1.tableNumber = storeInfo?.trcNumbers ?? ""
//                    vc2.tblNumbers = storeInfo?.trcNumbers ?? ""
//                    vc1.storeID = storeInfo?.storeId ?? ""
//                    vc2.storeID = storeInfo?.storeId ?? ""
//                    vc3.storeID = storeInfo?.storeId ?? ""
//                    print(storeInfo?.storeId ?? "")
//                    self.addActivity(store_id: storeInfo?.storeId ?? "", status_comment: "Visit")
//                    self.navigationController?.pushViewController(tabbar, animated: true)
                }
               
              //  FTIndicator.showToastMessage(msg)
             }else{
                 FTIndicator.showToastMessage("Invalid QR")
             }
          }

    }
    func qrCodeScanningFailedWithError(error: String) {
        print("error:\(error)")
    }
}


