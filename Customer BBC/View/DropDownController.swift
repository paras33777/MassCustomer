//
//  DropDownController.swift
//  Newforce
//
//  Created by Apple on 25/07/19.
//  Copyright © 2019 Newforce Ltd. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FTIndicator

//MARK: step 1 Add Protocol here
protocol DropDownDelegate: AnyObject {
    func returnSelectedValue(_ value: DropDownModel?,dataType:DataType)
}
class DropDownController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    //MARK:************IBOUTLETS
    weak var delegate: DropDownDelegate?
    @IBOutlet weak var stackButtons: UIStackView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var collView: UICollectionView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionHeight: NSLayoutConstraint!
    //MARK:************VARIABLES
    var searchText = String()
    var dataType : DataType?
    var dropdownType : DropdownType?
    var dataList = [DropDownModel]()
    var lastIndex: Int!
    var filteredData = [DropDownModel]()
    var searchActive = false
    var noAdminlbl = UILabel()
    //MARK: ************IBACTIONS
    @IBAction func btnCancelAction(_ sender: UIButton) {
        delegate?.returnSelectedValue(DropDownModel.init(id: "", name: ""), dataType: dataType!)
        
        self.dismiss(animated: true)
    }
    @IBAction func btnDoneAction(_ sender: UIButton) {
        
    }
    //MARK: ************VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSearchBarPlaceholder()
        searchBar.delegate = self
        tblView.tableFooterView = UIView()
        tblView.register(UINib(nibName: "CellDropView", bundle: nil), forCellReuseIdentifier: "cell")
        collView.register(UINib(nibName: "CellCollDropView", bundle: nil), forCellWithReuseIdentifier: "cell")
        stackButtons.subviews[1].isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        setKeyboard()
        setData()
     
    }
    override func viewWillDisappear(_ animated: Bool) {
    }
    func updateSearchBarPlaceholder(){
        if #available(iOS 13.0, *) {
            searchBar[keyPath: \.searchTextField].font = UIFont.init(name: "Montserrat-Medium", size: 14)!
        } else {
            let textFieldInsideUISearchBar = searchBar.value(forKey: "searchField") as? UITextField
            let placeholderLabel       = textFieldInsideUISearchBar?.value(forKey: "placeholderLabel") as? UILabel
            placeholderLabel?.font     = UIFont.init(name: "Montserrat-Medium", size: 14)!
    }
    }
    //MARK: *****************LABEL NO DATA FOUND
    func noDataFoundLabel(hidden:Bool){
        let label = UILabel(frame: tblView.bounds)
        label.text = "No data found"
        label.textAlignment = .center
        label.font = UIFont.init(name: "Montserrat-Regular", size: 14)!
        // print(hidden)
        if hidden == true{
            self.tblView.backgroundView = UIView()
        }else{
            tblView.backgroundView = UIView(frame: tblView.bounds)
            tblView.backgroundView?.addSubview(label)
        }
    }
    //MARK:*************Toolbar on keyboard
    func addToolbarOnKeyPad()
    {
        let numberPadToolbar: UIToolbar = UIToolbar()
        
        numberPadToolbar.isTranslucent = true
        numberPadToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            //  UIBarButtonItem(title: "Custom", style: .done, target: self, action: #selector(self.customAction)),
            //    UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.doneAction)),
        ]
        
        numberPadToolbar.sizeToFit()
        
        searchBar.inputAccessoryView = numberPadToolbar
    }
    
    @objc func cancelAction()
    {
        searchBar.resignFirstResponder()
    }
    
    @objc func customAction()
    {
        searchBar.resignFirstResponder()
    }
    
    @objc func doneAction()
    {
        showIndicator()
        searchBar.resignFirstResponder()
    }
    //MARK:****************** SET DATA
    func setKeyboard(){
//        if dropdownType == .expanceID{
//            self.searchBar.keyboardType = .numberPad
//        }else{
//            self.searchBar.keyboardType = .default
//        }
    }
    //MARK:****************** SET DATA
    func setData(){
        lastIndex = nil
        searchActive = false
        self.noDataFoundLabel(hidden: true)
        self.tblView.allowsMultipleSelection = false
        switch dropdownType {
        case .defaultType:
            self.searchBarHeight.constant = 0
            self.collectionHeight.constant = 0
        case .apiGetSearch:
            self.searchBarHeight.constant = 44
            self.collectionHeight.constant = 0
            getApiData()
        default:break
        }
       
        
//        switch dataType {
//        case .serviceGroup:
//            self.dataList.removeAll()
//            self.tblView.reloadData()
//            searchBar.becomeFirstResponder()
//            searchBar.text = ""
//            self.searchBarHeight.constant = 44
//            self.collectionHeight.constant = 0
//         //   getCountryCode()
//
//        case .none:
//            self.searchBarHeight.constant = 0
//            self.collectionHeight.constant = 0
//          //  self.dataList = Singleton.sharedInstance.attachmentType!
//            self.tblView.reloadData()
//
//        default:
//            self.searchBarHeight.constant = 0
//            self.collectionHeight.constant = 0
//            self.tblView.reloadData()
//        }
    }
    //MARK: *****************LABEL ADMIN FOUND
    func noAdminLabel(hidden:Bool){
        noAdminlbl.frame =  collView.bounds
        noAdminlbl.text = "No admin selected"
        noAdminlbl.textAlignment = .center
        noAdminlbl.font = UIFont.init(name: "Calibri", size: 15 )
        // print(hidden)
        if hidden == true{
            noAdminlbl.text = ""
            self.tblView.backgroundView = UIView()
        }else{
            collView.backgroundView = UIView(frame: collView.bounds)
            collView.backgroundView?.addSubview(noAdminlbl)
        }
    }
    //MARK: *****************Filter  Data
    func filterArrayData(text:String){
        //  print("texttttt\(text)")
        filteredData = dataList.filter( {
            $0.name!.range(of: text, options: .caseInsensitive) != nil
        })
    }
    //MARK: ****************GET SUGGESIONS
    func getSugessionsApi(text:String){
        switch dataType {
        case.serviceGroup:
            print("")
          //  searchAdmin(text: text)
        default:
            break
        }
        }
    //MARK: ****************GET API Data
    func getApiData(){
        switch dataType {
        case.countryCode:
            getCountryCode()
        default:
            break
        }
        }
    //MARK: ***************SEARCH BAR DELEGATE
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        if  dataType == .serviceGroup{
            getSugessionsApi(text: self.searchText)
        }
        searchBar.resignFirstResponder()
        
    }
    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String){
        //print(searchText)
        searchActive = true
        self.searchText = searchText
        if searchText.count > 0{
            if  dropdownType == .defaultType || dropdownType == .apiGetSearch {
                filterArrayData(text: searchText)
                tblView.reloadData()
                tblView.delaysContentTouches = false
            }else  if  dropdownType == .apiSuggesionSearch {
                searchActive = false
                if searchText.count > 2{
                    getSugessionsApi(text: self.searchText)
                    tblView.delaysContentTouches = false
                }
            }else{
                dataList.removeAll()
                tblView.reloadData()
            }
        }
        
    }
    //MARK: SEARCH THROTTLE
    @objc func reload(){
        guard let searchText = searchBar.text else { return }
        self.getSugessionsApi(text: searchText)
    }
    //MARK: ****************TABLEVIEW DATASOURCE AND DELEGATE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if searchActive{
                if filteredData.count > 0{
                    noDataFoundLabel(hidden: true)
                    return filteredData.count
                }else{
                    noDataFoundLabel(hidden: false)
                    return 0
                }
            }else{
                if dataList.count > 0{
                    return dataList.count
                }else{
                    return 0
                }
            }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellDropDown
        if lastIndex == indexPath.row{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        if searchActive == true{
            cell.lblTitle.text =  filteredData[indexPath.row].name
        }else{
            cell.lblTitle.text =  dataList[indexPath.row].name
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastIndex = indexPath.row
        var selectedValue : DropDownModel!
        if searchActive == true{
            selectedValue = filteredData[indexPath.row]
        }else{
            selectedValue = dataList[indexPath.row]
        }
        delegate?.returnSelectedValue(selectedValue, dataType: dataType!)
        self.dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
       
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
//extension DropDownController :UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if selectedAdmins.count > 0{
//            noAdminLabel(hidden: true)
//            return selectedAdmins.count
//        }else{
//            noAdminLabel(hidden: false)
//            return 0
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CellCollDropDown
//        self.btnOkay.string = adminString
//        self.btnOkay.adminsString = adminEmails
//        cell.lblTitle.text = selectedAdmins[indexPath.row].aDMINEMAIL
//        cell.lblInitial.text = String(selectedAdmins[indexPath.row].aDMINEMAIL.prefix(1)).capitalized
//        cell.lblInitial.layer.shadowRadius = 15
//        cell.vwBack.layer.cornerRadius = 15
//        cell.vwBack.layer.borderColor = hexStringToUIColor(hex: Color.blackApp.rawValue).cgColor
//        cell.vwBack.layer.borderWidth = 1
//        return cell
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
//        selectedAdmins.remove(at: indexPath.row)
//        adminString = usersNames()
//        adminEmails = usersEmails()
//        self.btnOkay.string = adminString
//        self.btnOkay.adminsString = adminEmails
//        collView.reloadData()
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 150, height: 30)
//    }
//}
//MARK: *********EXTENTION  GET API DATA
extension DropDownController{
    func getCountryCode(){
//        WebServiceManager.sharedInstance.getCountryCodeAPI { mobileCodes, msg, status in
//            if status == "1"{
//                self.noDataFoundLabel(hidden: true)
//                self.dataList = mobileCodes!
//                self.tblView.reloadData()
//            }else{
//
//                self.dataList.removeAll()
//                self.noDataFoundLabel(hidden: false)
//                self.tblView.reloadData()
//            }
//        }
    }
 
}
//MARK:****************CELL TABLE*******

class CellDropDown:UITableViewCell{
    
    @IBOutlet var lblTitle:UILabel!
    
}
//protocol CellCollDropDownDelegate: AnyObject {
//    func ClearAction(cell:CellCollDropDown)
//}
//class CellCollDropDown:UICollectionViewCell,UITextDropDelegate{
//    let wsManager = WebserviceManager()
//    weak var delegate: CellCollDropDownDelegate?
//    @IBOutlet weak var lblInitial: UILabel!
//    @IBOutlet var lblTitle:UILabel!
//    @IBOutlet weak var vwBack: UIView!
//    @IBOutlet weak var lblPlaceholder: UILabel!
//    @IBOutlet weak var txtFieldTo: UITextField!
//    @IBOutlet weak var txtFieldCc: UITextField!
//    @IBOutlet weak var btnClear: UIButton!
//    @IBOutlet weak var widthBtnClear: NSLayoutConstraint!
//    @IBAction func txtChangedAction(_ sender: UITextField) {
//        print(sender.text!)
//        if sender.text!.count > 2{
//            searchAdmin(text: sender.text!, tag: sender.tag, leaveID: Singleton.sharedInstance.leaveID)
//            if sender.tag == 200{
//                Singleton.sharedInstance.recipientsType = .emailCc
//            }else{
//                Singleton.sharedInstance.recipientsType = .emailTo
//            }
//        }else{
//            NotificationCenter.default.post(name: Notification.Name("Dismisslist"), object: nil)
//        }
//    }
//    @IBAction func btnClearAction(_ sender: UIButton) {
//        delegate?.ClearAction(cell: self)
//    }
//    override func prepareForReuse() {
//        super.prepareForReuse()
//    }
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        NotificationCenter.default.addObserver(self,selector: #selector(self.clearText(notification:)),name: NSNotification.Name(rawValue: "clearText"),object: nil)
//    }
//    @objc func clearText(notification:Notification){
//        if self.txtFieldTo != nil{
//            self.txtFieldTo.text = ""
//        }
//        if self.txtFieldCc != nil{
//            self.txtFieldCc.text = ""
//        }
//    }
//    func textDroppableView(_ textDroppableView: UIView & UITextDroppable, proposalForDrop drop: UITextDropRequest) -> UITextDropProposal {
//        return UITextDropProposal(operation: .cancel)
//    }
//    //MARK: ***************SEARCH ADMIN
//    func searchAdmin(text:String,tag:Int,leaveID:String){
//        wsManager.adminSearcApi(keyboard:text,suggesion: "1",leaveID: leaveID, adminId: ""){ (usersData, msg, status) in
//            if status == "1"{
//                //  print(msg,status,usersData?.count)
//                Singleton.sharedInstance.adminList = usersData!
//                //  NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil, userInfo: ["Renish":"Dadhaniya"]
//                NotificationCenter.default.post(name: Notification.Name("AdminListFounded"), object: nil)
//                //   self.noDataFoundLabel(hidden: true)
//                //  self.tblView.reloadData()
//            }else{
//                Singleton.sharedInstance.adminList = [NewforceCat]()
//                //  self.tblView.reloadData()
//                //  self.noDataFoundLabel(hidden: false)
//            }
//        }
//    }
//
//
//}

