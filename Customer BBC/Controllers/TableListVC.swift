//
//  TableListVC.swift
//  Customer BBC
//
//  Created by Lakshay on 03/11/22.
//

import UIKit
protocol tableListBack{
    func tableListCallBack(ids : [String],numbers : [String])
}
class TableListVC: UIViewController {
    //MARK: OUTLET
    @IBOutlet weak var btnDone: UIButton!{
        didSet{
            btnDone.alpha = 0
        }
    }
    
    @IBOutlet var tblList : UITableView!{
        didSet{
            tblList.alpha = 0
        }
    }
    //MARK: VARIABLE
    var storeId = ""
    var ids = [String]()
    var tableNumber = [String]()
    var arrTableList : [TRCListData]?
    var delegate : tableListBack?
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllTable()
    }
    //MARK: BUTTON ACTION
    @IBAction func btnDoneAction(_ sender : Any){
        if let del = delegate{
            self.dismiss(animated: false)
            del.tableListCallBack(ids: ids, numbers: tableNumber)
        }
        print("Table IDS ---->",ids)
        print("Table Number ----->",tableNumber)
    }
    @IBAction func btnDismissAction(_ sender : Any){
        self.dismiss(animated: true)
    }
    func getAllTable(){
        self.showIndicator()
        WebServiceManager.sharedInstance.getAllTableList(store_id: storeId, page: "1"){ TRCList, msg, status in
            self.hideIndicator()
            if status == "1"{
                self.arrTableList = TRCList
                self.tblList.alpha = 1
                self.tblList.reloadData()
              
                if self.arrTableList?.count ?? 0 == 0{
                    self.btnDone.alpha = 0
                }else{
                    self.btnDone.alpha = 1
                    
                }
            }else{
                self.tblList.alpha = 1
                self.tblList.reloadData()
                self.btnDone.alpha = 0
            }
        }
    }

}
    //MARK: TABLEIVIEW CELL
class tableListingCell : UITableViewCell{
    @IBOutlet var lblTableNumber : UILabel!
    @IBOutlet var btnCheckBox : UIButton!
    @IBOutlet var lblFloor : UILabel!
    @IBOutlet var lblLocation : UILabel!
    @IBOutlet var imgCheck : UIImageView!
    var selectedTableNumber = false
    var btnCheckBoxHandler:(()->())?
    @IBAction func btnCheckBoxAction(_ sender : Any){
        btnCheckBoxHandler?()
    }
}
 
//MARK: TABLEVIEW DELEGATE AND DATASOURCE
extension TableListVC : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrTableList?.count ?? 0 == 0{
            tblList.setEmptyMessage1("No list found")
            
        }else{
            tblList.restore()
        }
        return arrTableList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblList.dequeueReusableCell(withIdentifier: "tableListingCell", for: indexPath)as! tableListingCell
        cell.lblFloor.text = "Floor:\(arrTableList?[indexPath.row].floor ?? "")"
        cell.lblLocation.text = "Location:\(arrTableList?[indexPath.row].location ?? "")"
        cell.lblTableNumber.text = "Table Number:\(arrTableList?[indexPath.row].number ?? "")"
        cell.imgCheck.image = UIImage(named: "unselect")
        for index in ids{
            if index == "\(self.arrTableList?[indexPath.row].id ?? "")"{
                cell.selectedTableNumber = true
                cell.imgCheck.image = UIImage(named: "Tick")
            }
        }
        if cell.selectedTableNumber == false{
            cell.imgCheck.image = UIImage(named: "unselect")
        }else{
            cell.imgCheck.image = UIImage(named: "Tick")
        }
        cell.btnCheckBoxHandler = {
            cell.btnCheckBox.tintColor = UIColor.clear
            cell.btnCheckBox.isSelected = !cell.btnCheckBox.isSelected
            if cell.btnCheckBox.isSelected == true{
                self.ids.append("\(self.arrTableList?[indexPath.row].id ?? "")")
                self.tableNumber.append("\(self.arrTableList?[indexPath.row].number ?? "")")
                
                cell.selectedTableNumber = true
                cell.imgCheck.image = UIImage(named: "Tick")
            }else{
                
                for index in self.ids{
                    if index == "\(self.arrTableList?[indexPath.row].id ?? "")"{
                        let indexOfA = self.ids.firstIndex(of: index) // 0
                        self.ids.remove(at: indexOfA ?? 0)
                    }
                }
                for index in self.tableNumber{
                    if index == "\(self.arrTableList?[indexPath.row].number ?? "")"{
                        let indexOfA = self.tableNumber.firstIndex(of: index) // 0
                        self.tableNumber.remove(at: indexOfA ?? 0)
                    }
                }
                cell.selectedTableNumber = false
                cell.imgCheck.image = UIImage(named: "unselect")
            }
        }
        return cell
    }
    
  
}
