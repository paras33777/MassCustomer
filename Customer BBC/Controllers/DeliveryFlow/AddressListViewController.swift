//
//  AddressListViewController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 14/11/22.
//

import UIKit

//  MARK: - TABLEVIEW CELL CLASS
class AddressListTableviewCell: UITableViewCell{
    //    MARK: - OUTLETS
    @IBOutlet weak var labelDefault: UIView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonDefault: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    @IBOutlet weak var labelPhoneNumber: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var buttonSelectUnselect: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    
}

class AddressListViewController: UIViewController {

//    MARK: - OUTLETS
    @IBOutlet weak var tableviewAddress: UITableView!
    
//    MARK: - VARIABLES
    var addressList = [AddressListData]()
    var selectedIndex:Int? = nil
    
//    MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableviewAddress.delegate = self
        self.tableviewAddress.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool) {
        self.getDeliveryAddressApi(user_id:Singleton.sharedInstance.userInfo.userId ?? "")
    }
//    MARK: - BUTTON ACTION
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addAddressButtonAction(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
//    MARK: -  ALL FUNCTIONS
    
//MARK: ****************GET DELIVERY ADDRESS LIST API**************************
    func getDeliveryAddressApi(user_id:String){
        WebServiceManager.sharedInstance.getAddressList(user_id: user_id){addressList, msg, status in
            if status == "1"{
                self.addressList = addressList!
                self.tableviewAddress.reloadData()
                self.updateNoData(message: "")
            }else{
                self.addressList = [AddressListData]()
                self.updateNoData(message: msg!)
                self.tableviewAddress.reloadData()
            }
        }
            
        }
    
    
//MARK: ****************DELETE DELIVERY ADDRESS API**************************
    func removeDeliveryAddressApi(user_id:String, addressId: String){
        WebServiceManager.sharedInstance.removeAddressFromList(user_id:user_id,addressId: addressId) {msg, status  in
            if status == "1"{
                self.getDeliveryAddressApi(user_id:Singleton.sharedInstance.userInfo.userId ?? "")
            }else{
                self.updateNoData(message: msg!)
                self.tableviewAddress.reloadData()
            }
        }
    }
    
    
//MARK: ****************UPDATE DELIVERY ADDRESS API**************************
    func updateDefaultAddressApi(user_id:String, addressId: String, defaultAddress: String){
        WebServiceManager.sharedInstance.updateDefaiultAddress(addressId: addressId, user_id: user_id, defaultAddress: defaultAddress){msg, status  in
            if status == "1"{
                self.getDeliveryAddressApi(user_id:Singleton.sharedInstance.userInfo.userId ?? "")
          
            }else{
                self.updateNoData(message: msg!)
                self.tableviewAddress.reloadData()
            }
        }
    }
    
// MARK:    ************UPDATE NO DATA FOUND**********************
    func updateNoData(message:String){
        if self.addressList.count > 0 {
            self.tableviewAddress.backgroundView = UIView()
        }else{
            let vwNoData = ViewNoData()
            self.tableviewAddress.backgroundView = vwNoData
            vwNoData.imgVw.image = UIImage(named: "noDataFound")
            vwNoData.center.x = self.view.center.x
            vwNoData.center.y =  self.view.center.y
            vwNoData.label.text = message
        }
    }
    
    @objc func selectUnselectButtonAction(_ sender: UIButton){
        self.selectedIndex = sender.tag
        self.tableviewAddress.reloadData()
    }
    
    @objc func deleteButtonAction(_ sender: UIButton){
        self.removeDeliveryAddressApi(user_id:Singleton.sharedInstance.userInfo.userId ?? "", addressId: self.addressList[sender.tag].Id ?? "")
    }
    
    @objc func selectButtonDefault(_ sender: UIButton){
        self.updateDefaultAddressApi(user_id: Singleton.sharedInstance.userInfo.userId ?? "", addressId: self.addressList[sender.tag].Id ?? "", defaultAddress: "1")
        
    }
    
    @objc func editButtonAction(_ sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        vc.addressList = self.addressList
        vc.come = "edit"
        vc.indexId = sender.tag
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


//     MARK: - TABLEVIEW EXTENSION
extension AddressListViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressList.count  
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableviewAddress.dequeueReusableCell(withIdentifier: "AddressListTableviewCell", for: indexPath) as! AddressListTableviewCell
        cell.labelName.text = self.addressList[indexPath.row].deliveryName ?? ""
        cell.labelLocation.text = "\(self.addressList[indexPath.row].deliveryHouseNo ?? "") \(self.addressList[indexPath.row].deliveryLandmark ?? "") \(self.addressList[indexPath.row].deliveryCity ?? "") \(self.addressList[indexPath.row].deliveryState ?? "") \(self.addressList[indexPath.row].deliveryCountry ?? "") \(self.addressList[indexPath.row].deliveryPincode ?? "")"
        cell.labelPhoneNumber.text = "+\(self.addressList[indexPath.row].deliveryCountryCode ?? "") \(self.addressList[indexPath.row].deliveryPhoneNumber ?? "")"
        if self.addressList[indexPath.row].defaultAddress ?? "" == "0"{
            cell.labelDefault.isHidden = true
            cell.buttonDefault.isSelected = false
        }else{
            cell.labelDefault.isHidden = false
            cell.buttonDefault.isSelected = true
        }
        if self.selectedIndex == indexPath.row{
            cell.buttonSelectUnselect.isSelected = true
        }else{
            cell.buttonSelectUnselect.isSelected = false
        }
        cell.buttonSelectUnselect.tag = indexPath.row
        cell.buttonSelectUnselect.addTarget(self, action: #selector(selectUnselectButtonAction), for: .touchUpInside)
       
        cell.buttonDefault.tag = indexPath.row
        cell.buttonDefault.addTarget(self, action: #selector(selectButtonDefault), for: .touchUpInside)
       
        cell.buttonDelete.tag = indexPath.row
        cell.buttonDelete.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        
        cell.buttonEdit.tag = indexPath.row
        cell.buttonEdit.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
      
    return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }


}
