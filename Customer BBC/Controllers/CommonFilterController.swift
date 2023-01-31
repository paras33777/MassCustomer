//
//  CommonFilterController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 30/05/22.
//

import UIKit

class CommonFilterController: UIViewController {
    // MARK: - IBOUTLET
    @IBOutlet weak var collVw: UICollectionView!
    @IBOutlet weak var tblVw: UITableView!
    // MARK: - VARIABLE
    var type = String()
    var storeID = String()
    var selectedFilterIndx = 0
    var filters = [CommonFilter]()
    var applyFilter:((_ filter:[CommonFilter]) -> Void)!
    // MARK: - IBACTION
    @IBAction func btnDoneAction(_ sender: Any) {
        applyFilter(filters)
        self.dismiss(animated: true)
    }
    @IBAction func btnClearAction(_ sender: Any) {
        clearFilterAction()
    }
    //MARK: CLEAR FILTER ACTION
    func clearFilterAction(){
        
        
        for (index,filter )in self.filters.enumerated(){
           
                if !(filter.returnValue!.isEmpty){
                    self.filters[index].filled = false
                }
                self.filters[index].returnValue = ""
            self.filters[index].returnValueArray?.removeAll()
          }
        self.collVw.reloadData()
        //self.tblVW.reloadData()
    
    }
    
    // MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collVw.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        applyFilter(filters)
    }
    //MARK: - GET FILTER
    func getCommonFilterAPI(mainCat:String){
        WebServiceManager.sharedInstance.getCommonFilterAPI(type: "ProductList", store_id: storeID, mainCat: mainCat) { commonFilter, msg, status in
            if status == "1"{
                self.filters[1] = commonFilter![1]
                self.collVw.reloadData()
            }else{
                
            }
           }
          }
        }
extension CommonFilterController :UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        guard filters.count > 0 else{return 0}
        if self.filters[selectedFilterIndx].options!.count > 0{
        return self.filters[selectedFilterIndx].options!.count
        }else{
        return 0
        }
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.filters[selectedFilterIndx].options!.count > 0{
            let filterField = self.filters[selectedFilterIndx].options![indexPath.row]
            switch filterField.type {
            case "multiSelect":
            let cell = tableView.dequeueReusableCell(withIdentifier: "selectLabelField") as! CellFilterTblVW
                cell.lblTitle.text = filterField.name
                if self.filters[selectedFilterIndx].returnValueArray!.contains(filterField.value!){
                    cell.imgSelect.alpha = 1
                }else{
                    cell.imgSelect.alpha = 0
                }
            return cell
            case "singleSelect":
                let cell = tableView.dequeueReusableCell(withIdentifier: "selectLabelField") as! CellFilterTblVW
                    cell.lblTitle.text = filterField.name
                if self.filters[selectedFilterIndx].returnValue! == filterField.value ?? ""{
                        cell.imgSelect.alpha = 1
                    }else{
                        cell.imgSelect.alpha = 0
                    }
                return cell
            default : break
            
            }
           }
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectLabelField") as! CellFilterTblVW
        return cell
       }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let filterField = self.filters[selectedFilterIndx].options![indexPath.row]
        switch filterField.type {
        case "multiSelect":
        if self.filters[selectedFilterIndx].returnValueArray!.contains(filterField.value!){
            let index = self.filters[selectedFilterIndx].returnValueArray?.firstIndex(of: self.filters[selectedFilterIndx].options![indexPath.row].value ?? "")
            self.filters[selectedFilterIndx].returnValueArray?.remove(at: index!)
           let strinValue =  self.filters[selectedFilterIndx].returnValueArray?.joined(separator:",")
            self.filters[selectedFilterIndx].returnValue = strinValue
        }else{
            self.filters[selectedFilterIndx].returnValueArray! += [self.filters[selectedFilterIndx].options![indexPath.row].value ?? ""]
            let strinValue =  self.filters[selectedFilterIndx].returnValueArray?.joined(separator:",")
             self.filters[selectedFilterIndx].returnValue = strinValue
        }
        if self.filters[selectedFilterIndx].name == "Select Main Category"{
        if type == "ProductList"{
            let strinValue =  self.filters[selectedFilterIndx].returnValueArray?.joined(separator:",") ?? ""
            getCommonFilterAPI(mainCat:strinValue)
        }
        }
        case "singleSelect":
            if self.filters[selectedFilterIndx].returnValue!.isEmpty{
            self.filters[selectedFilterIndx].returnValue = self.filters[selectedFilterIndx].options![indexPath.row].value ?? ""
            }else{
                if self.filters[selectedFilterIndx].returnValue != self.filters[selectedFilterIndx].options![indexPath.row].value ?? ""{
                self.filters[selectedFilterIndx].returnValue = self.filters[selectedFilterIndx].options![indexPath.row].value ?? ""
                }else{
                self.filters[selectedFilterIndx].returnValue = ""
                }
            }
        default : break
        }
        checkFilterApplied()
        self.tblVw.reloadData()
        tblVw.deselectRow(at: indexPath, animated: true)
        
     }
      }
extension CommonFilterController :UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.filters.count > 0{
          return  self.filters.count
        }else{
        return 0
        }
      }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CellFilterCollVW
        let filter = self.filters[indexPath.row]
        cell.lblTitle.text = filter.name
        if filter.filled{
            cell.vwFilterApplied.backgroundColor = hexStringToUIColor(hex: Color.red.rawValue)
        }else{
            cell.vwFilterApplied.backgroundColor = UIColor.clear
        }
        if selectedFilterIndx == indexPath.row{
            cell.contentView.backgroundColor = .white
           }else{
            cell.contentView.backgroundColor = hexStringToUIColor(hex: Color.lightGray5.rawValue)
           }
        self.tblVw.reloadData()
        return cell
        }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        self.selectedFilterIndx = indexPath.row
        self.tblVw.reloadData()
        checkFilterApplied()
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = (collectionView.bounds.size.width-20)// 1 // 3 count of rows to show
        let cellWidth = (collectionView.bounds.size.width) // 1 // 2 count of colomn to show
        return CGSize(width: CGFloat(cellWidth), height: CGFloat(cellHeight))
    }
    //MARK: CHECK FILTER IF APPLIED
    func checkFilterApplied(){
       for (index,filter )in self.filters.enumerated(){
              var ifApplied = false
          
                if !(filter.returnValue!.isEmpty){
                    ifApplied = true
                    self.filters[index].filled = ifApplied
                }else{
                    if  ifApplied == false {
                    self.filters[index].filled = ifApplied
                    }
                }
        }
        self.collVw.reloadData()
    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
//    {
//        return 10
//    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
//    {
//        let sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        return sectionInset
//    }
    
}
class CellFilterCollVW: UICollectionViewCell {
    @IBOutlet weak var vwFilterApplied: UIView!
    @IBOutlet weak var lblTitle: UILabel!
   
   }
//MARK: - TABLEVIEW CELL VENDOR FILTER CATEGORY FIELD
class CellFilterTblVW: UITableViewCell {
   
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgSelect: UIImageView!
   
   // var updateFilter : ((_ filter:[VendorFilter]) -> Void)?
   
}
