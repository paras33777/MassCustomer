//
//  RecentVisitController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 18/05/22.
//

import UIKit
import UIView_Shimmer
import FTIndicator

class RecentVisitController: UIViewController {
//MARK: - IBOUTLET
    @IBOutlet weak var tblVw: UITableView!
    //MARK: - VARIABLE
    private var isLodinData = true
    var storeList = [StoreList]()
//MARK: - IBACTIONS
    @IBAction func btnBackAction(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
    }
    //MARK: - VIEW LIFE CYCLE
    override func viewDidLoad(){
    super.viewDidLoad()
        UserDefaults.standard.setValue("false", forKey: "is_booking")
    updateUI()
    getUserActivity()
   
    }
    //MARK: - Update UI
    func updateUI(){
        
    }
    //MARK: ************UPDATE NO DATA FOUND
    func updateNoData(message:String){
        if self.storeList.count > 0 {
            self.tblVw.backgroundView = UIView()
        }else{
            let vwNoData = ViewNoData()
            self.tblVw.backgroundView = vwNoData
            vwNoData.imgVw.image = UIImage(named: "noDataFound")
            vwNoData.center.x = self.view.center.x
            vwNoData.center.y =  self.view.center.y
            vwNoData.label.text = message
        }
    }
   //MARK: - Get user Activity
    func getUserActivity(){
        WebServiceManager.sharedInstance.getUserHistoryAPI { storeList, msg, status in
            self.isLodinData = false
            if status == "1"{
            self.storeList = storeList!
                self.tblVw.reloadData()
                self.updateNoData(message: "")
            }else{
                self.storeList = [StoreList]()
                self.updateNoData(message: msg!)
                self.tblVw.reloadData()
            }
        }
    }
}
extension RecentVisitController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard isLodinData == false else{return 5}
        return storeList.count
        }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StoreListTableCell
        guard isLodinData == false else{return cell}
        cell.setTemplateWithSubviews(isLodinData)
        let store = storeList[indexPath.row]
        cell.lblName.text = store.storeName?.capitalized
        cell.lblStatus.text = store.statusComment
        switch store.statusComment{
        case "Visit":
            cell.imgStatus.image = UIImage(named: "visit")
        case "Item Added to Cart":
            cell.imgStatus.image = UIImage(named: "cart")
        case "Order Placed":
            cell.imgStatus.image = UIImage(named: "cart")
        default:break
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard isLodinData == false else{
        cell.setTemplateWithSubviews(isLodinData,viewBackgroundColor: .lightGray)
            return}
        
            let store = storeList[indexPath.row]
            if store.storeImageSmal == ""{
                (cell as! StoreListTableCell).imgVwStore.image = #imageLiteral(resourceName: "imagePlaceholder")
            }else{
                let url:URL = URL(string: store.storeImageSmal!)!
                _ = (cell as! StoreListTableCell).imgVwStore.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imagePlaceholder"))

            }
       }
        func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
            (cell as! StoreListTableCell).imgVwStore.kf.cancelDownloadTask()
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard isLodinData == false else{return}
            
            let store = storeList[indexPath.row]
            self.getStoreInfoAPI(storeID: store.storeId!)
           }
    func getStoreInfoAPI(storeID:String){
    
        WebServiceManager.sharedInstance.getStoreInfoAPI(storeID: storeID, type: "store") {storeInfo, msg, status in
            self.isLodinData = false
            if status == "1"{
                if storeInfo?.settings?.lowercased() == "enable"{
                Singleton.sharedInstance.storeInfo = storeInfo
                    let tabbar = self.storyboard?.instantiateViewController(withIdentifier: "StoreTabController") as! StoreTabController
                    let vc1 = tabbar.viewControllers?.first as! StoreProductsController
                    let vc2 = tabbar.viewControllers?[1] as! StoreCartController
                    let vc3 = tabbar.viewControllers?[2] as! OrdersListController
                    vc1.storeID = storeID
                    vc2.storeID = storeID
                    vc3.storeID = storeID
                    self.navigationController?.pushViewController(tabbar, animated: true)
             
                }else{
                    
                   
                }
              //  FTIndicator.showToastMessage(msg)
             }
          }
        }
    
         }

class StoreListTableCell:UITableViewCell,ShimmeringViewProtocol{
    @IBOutlet weak var imgVwStore: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var imgStatus: UIImageView!
    var shimmeringAnimatedItems: [UIView] {
        [imgVwStore,
         lblName,
         lblStatus,
         imgStatus
        ].compactMap{ $0 }
        
       }
     }
