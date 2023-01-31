//
//  ScheduleAppoinmentVC.swift
//  Customer BBC
//
//  Created by Lakshay on 28/10/22.
//

import UIKit
import FTIndicator
var selectedDate = Date()
protocol callBackForAddToCart{
    func callBack(products : Productlist?)
}
protocol RescheduleBack{
    func callBackForReschdule()
}
class ScheduleAppoinmentVC: UIViewController /*, bookedSlot */  {
    //    func bookedSlotDone() {
    //        self.addToCartApi()
    //
    //    }
    
    //MARK: OUTLETS
    @IBOutlet weak var calenderCollectionView: UICollectionView!
    @IBOutlet var colAvailableTime : UICollectionView!
    @IBOutlet var lblDate : UILabel!{
        didSet{
            lblDate.text = ""
        }
    }
    @IBOutlet var lblTitleMain : UILabel!
    @IBOutlet var lblSelectedDate : UILabel!{
        didSet{
            lblSelectedDate.text = ""
        }
    }
    @IBOutlet var btnBookAppoinment : UIButton!
    //MARK: VARIABLES
    var delegateReschedule : RescheduleBack?
    var openCart:(() -> Void)!
    var product : Productlist?
    var allDateArray = [Date]()
    var totalSquares = [Date]()
    var selecedindex = 0
    var delegate : callBackForAddToCart?
    var isSelectedCheckbox : Bool = false
    var currentSelectedDate = ""
    var month = [String]()
    var doctorId = ""
    var selectedDay = ""
    var avaialableIndex = -1
    var productId = ""
    var availableSlot : SlotTimeData?
    var timeArray = [String]()
    var startTimes = ""
    var endTimes = ""
    var currentTime = ""
    var room_id = ""
    var slotStartTime = ""
    var slotEndTime = ""
    var slotId = ""
    var currentDate = ""
    var appoinmentDate = ""
    var appoinmentTime = ""
    var orderId = ""
    var slot_id = ""
    var paymentMethod = ""
    var previousDate = ""
    var doctorName = ""
    var userName = ""
    var iscomingFromReschedule : Bool = false
    var mainCurrentDate = Date()
    var sele = ""
    var slectedSlotDate = ""
    var isSelectingForRechedule : Bool = false
    var appoinmentSelected = [String]()
    
    var arr = [String]()
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        calenderCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colAvailableTime.delegate = self
        colAvailableTime.dataSource = self
        colAvailableTime.translatesAutoresizingMaskIntoConstraints = false
        selectedDate = self.getCurrentShortDate()
        self.mainCurrentDate = self.getCurrentShortDate()
        setWeekView()
        self.lblDate.text = Date.getCurrentDates()
        self.lblSelectedDate.text = Date.getCurrentDate()
        self.currentSelectedDate = Date.getCurrentDatesFormat()
        self.selectedDay = Date.getDay()
        self.currentTime = Date.getCurrentTimeFormat()
        print("Selected Dates------> ",self.currentSelectedDate,doctorId,productId,currentTime)
        getDoctorAvailabilityAPI()
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = .right
        self.calenderCollectionView.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeLeft.direction = .left
        self.calenderCollectionView.addGestureRecognizer(swipeLeft)
        let myDate = Date()
        let format = DateFormatter()
        format.dateFormat = "dd/MM/yyyy"
        let resultString = format.string(from: myDate)
        currentDate = resultString
        if iscomingFromReschedule == true{
            self.lblTitleMain.text = "Reschedule"
            btnBookAppoinment.setTitle("Reschedule Appointment", for: .normal)
        }else{
            self.lblTitleMain.text = "Schedule"
            btnBookAppoinment.setTitle("Book Appointment", for: .normal)
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidLayoutSubviews() {
        setUpCollectionView()
        setUpAppoinmentTimeCollectionView()
    }
    //MARK: COLLECTIONVIEW SETUP
    fileprivate func setUpCollectionView(){
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.scrollDirection = .horizontal
        
        
        collectionFlowLayout.itemSize = CGSize(width: (calenderCollectionView.frame.size.width - 2) / 7 , height:(calenderCollectionView.frame.size.height - 2) )
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.minimumInteritemSpacing = 0
        collectionFlowLayout.minimumLineSpacing = 0
        calenderCollectionView!.collectionViewLayout = collectionFlowLayout
        calenderCollectionView.setCollectionViewLayout(collectionFlowLayout, animated: false)
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
    }
    fileprivate func setUpAppoinmentTimeCollectionView(){
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.scrollDirection = .vertical
        collectionFlowLayout.itemSize = CGSize(width: (colAvailableTime.frame.size.width - 2) / 3 , height: 60 )
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.minimumInteritemSpacing = 0
        collectionFlowLayout.minimumLineSpacing = 0
        colAvailableTime!.collectionViewLayout = collectionFlowLayout
        colAvailableTime.setCollectionViewLayout(collectionFlowLayout, animated: false)
        colAvailableTime.delegate = self
        colAvailableTime.dataSource = self
    }
    func getCurrentShortDate() -> Date {
        var todaysDate = NSDate()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss ssZZZ"
        var dd = dateFormatter.string(from: todaysDate as Date)
        var DateInFormat = dateFormatter.date(from: dd)!
        
        return DateInFormat
    }
    
    func setWeekView(){
        totalSquares.removeAll()
        var current = CalendarHelper().sundayForDate(date: selectedDate)
        let nextSunday = CalendarHelper().addDays(date: current, days: 7)
        while (current < nextSunday){
            totalSquares.append(current)
            current = CalendarHelper().addDays(date: current, days: 1)
        }
        if totalSquares.contains(self.mainCurrentDate){
            self.sele = "current"
        }else{
            self.sele = ""
        }
        self.month.removeAll()
        for id in totalSquares{
            month.append(CalendarHelper().monthString1(date: id))
        }
        calenderCollectionView.reloadData()
    }
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .left:
                print("Swiped left")
                selectedDate = CalendarHelper().addDays(date: selectedDate, days: 7)
                
                setWeekView()
                let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeRight.direction = .right
                self.calenderCollectionView.addGestureRecognizer(swipeRight)
                
                let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                swipeLeft.direction = .left
                self.calenderCollectionView.addGestureRecognizer(swipeLeft)
            case .right:
                print("Swiped right -- >",selectedDate)
                if self.totalSquares.contains(self.mainCurrentDate){
                    
                }else{
                    selectedDate = CalendarHelper().addDays(date: selectedDate, days: -7)
                    
                    setWeekView()
                    let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                    swipeRight.direction = .right
                    
                    self.calenderCollectionView.addGestureRecognizer(swipeRight)
                    
                    let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
                    swipeLeft.direction = .left
                    self.calenderCollectionView.addGestureRecognizer(swipeLeft)
                }
                
            default:
                break
            }
        }
    }
    //MARK: BUTTON ACTION
    @IBAction func btnBackAction(_ sender : Any){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnBookAppoinment(_ sender : Any){
        if iscomingFromReschedule == true{
            if slotStartTime == ""{
                FTIndicator.showToastMessage("Please select slot time")
            }else{
                getRescheduleAppoinmentAPI()
                
            }
            
            
        }else{
            if slotStartTime == ""{
                FTIndicator.showToastMessage("Please select slot time")
            }else{
                getBookAppoinmentAPI()
            }
        }
        
        
    }
    
    func getMinutesDifferenceFromTwoDates(start: Date, end: Date) -> Int{
        let diff = Int(end.timeIntervalSince1970 - start.timeIntervalSince1970)
        let hours = diff / 3600
        let minutes = hours * 60
        //         print("Hours and minutes -----> ",diff ,hours , minutes)
        
        return minutes
    }
    func findsecond(s_date:String,e_date:String) -> Int {
        //set date formate
        
        let Dateformatter = DateFormatter()
        
        Dateformatter.dateFormat = "HH:mm a"
        
        //convert string to date
        
        let dateold = Dateformatter.date(from: s_date ?? "")
        let datenew = Dateformatter.date(from: e_date ?? "")
        //use default datecomponents with two dates
        let calendar1 = Calendar.current
        let components = calendar1.dateComponents([.second], from: dateold ?? Date(), to: datenew ?? Date())
        let seconds = components.second
        print("Seconds: \(seconds)")
        return seconds!
        
    }
    //MARK: - GET FILTER FOR PRODUCTS
    func getDoctorAvailabilityAPI(){
        self.showIndicator()
        WebServiceManager.sharedInstance.getAvailabilityTimeAPI(date: self.currentSelectedDate, store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", doctor_Id: doctorId, user_id: Singleton.sharedInstance.userInfo.userId ?? "", service_Id: productId, day: selectedDay, vertical: "hospital" ){ SlotTime, msg, status in
            self.hideIndicator()
            if status == "1"{
                self.availableSlot = SlotTime
                self.timeArray.removeAll()
                self.arr.removeAll()
                self.appoinmentSelected.removeAll()
                for item in self.availableSlot?.BookedSlot ?? []{
                    let time = item.startTime
                    if time == nil || time == ""{
                        //                                self.appoinmentSelected.append("00:00")
                    }else{
                        let total = time?.components(separatedBy: ":")
                        let value1 = "\(total?[0] ?? ""):\(total?[1] ?? "")"
                        print("Booked slots ---> ",value1,self.startTimes)
                        self.appoinmentSelected.append(value1)
                        
                    }
                }
                for i in self.availableSlot?.DocAvailSlot ?? []{
                    //                    let starttime  = i.startTime?.convertDatetring_TopreferredFormat(currentFormat: "hh:mm:ss", toFormat: "HH:mm")
                    if i.startTime == "" || i.startTime == nil{
                        
                    }else{
                        let starttime  = i.startTime?.components(separatedBy: ":")
                        let st = "\(starttime?[0] ?? ""):\(starttime?[1] ?? "")"
                        self.startTimes = st
                        
                    }
                    if i.endTime == "" || i.endTime == nil{
                        
                    }else{
                        let endtime = i.endTime?.components(separatedBy: ":")
                        let et = "\(endtime?[0] ?? ""):\(endtime?[1] ?? "")"
                        self.endTimes = et
                    }
                    self.timeArray.append(self.startTimes)
                    if self.appoinmentSelected.contains(self.startTimes){
                        self.arr.append(self.startTimes)
                    }else{
                        self.arr.append("00:00")
                    }
                    
                    
                    //                    self.startTimes = i.startTime?.convertDatetring_TopreferredFormat(currentFormat: "hh:mm:ss", toFormat: "HH:mm ") ?? ""
                    
                    //                    self.timeArray.append(self.startTimes)
                    let df1 = DateFormatter()
                    df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                    df1.dateFormat = "HH:mm"
                    let start_time = df1.date(from: self.startTimes)
                    
                    
                    let end_time = df1.date(from: self.endTimes)
                    
                    print("Start Time ************ \(start_time) ********* \(self.startTimes) ********** End Time *****\(end_time) *****")
                    
                    let minutes =  self.getMinutesDifferenceFromTwoDates(start: start_time!, end: end_time!)
                    let slot = minutes / 30
                    print("Time slot for object ----",slot)
                    let slot1 = String(slot)
                    if slot1.contains("-") == true{
                        
                    }else{
                        
                        for i in 0..<slot{
                            let df1 = DateFormatter()
                            df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                            df1.dateFormat = "HH:mm"
                            let start_time = df1.date(from: self.startTimes)
                            
                            let addingTime = start_time?.addingTimeInterval(30 * 60)
                            df1.dateFormat = "HH:mm"
                            self.startTimes = df1.string(from: addingTime!)
                            self.timeArray.append(self.startTimes)
                            
                            if self.appoinmentSelected.contains(self.startTimes){
                                self.arr.append(self.startTimes)
                            }else{
                                self.arr.append("00:00")
                            }
                            
                            
                            print("Start Time ---===---==--==- \(self.timeArray)====\(self.arr)")
                            
                        }
                    }
                    
                    print("Booked time ===> ",self.arr.count,self.arr,self.timeArray.count,self.appoinmentSelected.count,self.appoinmentSelected)
                    print("Start and end time --->",self.timeArray.count, self.timeArray )
                    
                }
                self.timeArray.removeLast()
                self.colAvailableTime.reloadData()
            }else{
                self.timeArray.removeAll()
                self.arr.removeAll()
                self.appoinmentSelected.removeAll()
                self.colAvailableTime.reloadData()
            }
        }
        
    }
    
    //MARK: RESCHEDULE SLOT API
    func getRescheduleAppoinmentAPI(){
        self.showIndicator()
        WebServiceManager.sharedInstance.RescheduleAppoinmentAPI(store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", room_id: room_id, slot_start_time: slotStartTime, previous_date: previousDate, slot_date: self.currentSelectedDate, user_name: userName, vertical: "hospital", slot_end_time: slotEndTime, doctor_id: doctorId, user_id: Singleton.sharedInstance.userInfo.userId ?? "", slot_id: slot_id, service_id: productId, doctor_name: doctorName, order_id: orderId, payment_method: paymentMethod, status: "rescheduled") {  msg, status in
            //            self.slotId = slot_id ?? ""
            self.hideIndicator()
            if status == "1"{
                if let del = self.delegateReschedule{
                    
                    self.navigationController?.popViewController(animated: true)
                    del.callBackForReschdule()
                }
                
            }else{
                
            }
        }
        
        
    }
    
    
    
    //MARK: BOOK APPOINMENT API
    func getBookAppoinmentAPI(){
        self.showIndicator()
        WebServiceManager.sharedInstance.BookAppoinmentAPI(slot_date: self.currentSelectedDate, store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", doctor_Id: doctorId, user_id: Singleton.sharedInstance.userInfo.userId ?? "", service_Id: productId, slot_start_time: slotStartTime, slot_end_time: slotEndTime, room_id: room_id, vertical: "hospital"){ slot_id, msg, status in
            self.slotId = slot_id ?? ""
            self.hideIndicator()
            if status == "1"{
                //                if Singleton.sharedInstance.storeInfo?.AppointmentConfirmation ?? "" == "enable"{
                //
                //                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppoinmentBookedVC") as! AppoinmentBookedVC
                //                    vc.delegate = self
                //                    vc.modalPresentationStyle = .overCurrentContext
                //                    self.present(vc, animated: true, completion: nil)
                //                }else{
                self.addToCartApi()
                //                }
            }else{
                
            }
        }
    }
    //MARK: ADD TO CART API
    func addToCartApi(){
        self.showIndicator()
        UserDefaults.standard.setValue(self.slotStartTime, forKey: "slot_time")
        UserDefaults.standard.setValue(self.doctorId, forKey: "doctor_id")
        UserDefaults.standard.setValue(self.slotId, forKey: "slot_id")
        UserDefaults.standard.setValue(self.currentSelectedDate, forKey: "slot_date")
        UserDefaults.standard.setValue(self.room_id, forKey: "room_id")
        UserDefaults.standard.setValue("true", forKey: "is_booking")
        
        
        Singleton.sharedInstance.isFromSlotBooking = true
        WebServiceManager.sharedInstance.AddToCartAppoinment(store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", product_offer_price: product?.ProductOfferPrice ?? "", user_id: Singleton.sharedInstance.userInfo.userId ?? "", product_id: productId, qty: "1", action: "1", vertical: "hospital", store_type: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", package_type: product?.packageType ?? "", payment_method: Singleton.sharedInstance.storeInfo.paymentMethod ?? ""){ slot_id, msg, status in
            self.hideIndicator()
            
            if status == "1"{
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
            }else{
                
            }
        }
    }
}
//MARK: Collection View Cell
class calenderAppoinmentCell : UICollectionViewCell{
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var labelDate: UILabel!
}
class availableTimeCell : UICollectionViewCell{
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var mainView : UIView!
}
//MARK: Collection View Delegate And Data Source -
extension ScheduleAppoinmentVC: UICollectionViewDelegate, UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == calenderCollectionView{
            return totalSquares.count
        }else{
            return timeArray.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calenderCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calenderAppoinmentCell", for: indexPath) as! calenderAppoinmentCell
            
            let date = totalSquares[indexPath.item]
            cell.labelDate.text = String(CalendarHelper().dayOfMonth(date: date))
            cell.labelMonth.text = month[indexPath.row]//CalendarHelper().monthString1(date: selectedDate)
            cell.labelDay.text = CalendarHelper().monthString2(date: date)
            
            if self.sele == "current"{
                if totalSquares[indexPath.item] == self.mainCurrentDate{
                    self.selecedindex = indexPath.item
                    cell.labelDate.textColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                    cell.viewDate.layer.borderColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                    cell.viewDate.layer.borderWidth = 1
                    print("Colord Date",date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM, yyyy"
                    let datefrom = dateFormatter.string(from: date)
                    self.lblSelectedDate.text = datefrom
                    dateFormatter.dateFormat = "MMM yyyy"
                    let datefrom1 = dateFormatter.string(from: date)
                    self.lblDate.text = datefrom1
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let datestring1 = dateFormatter.string(from: totalSquares[self.selecedindex])
                    dateFormatter.dateFormat = "E"
                    self.selectedDay = dateFormatter.string(from: totalSquares[self.selecedindex])
                    self.currentSelectedDate = datestring1
                    getDoctorAvailabilityAPI()
                    
                }else{
                    cell.labelDate.textColor = .black
                    cell.viewDate.layer.borderColor = UIColor.clear.cgColor
                }
            }else{
                if(date == selectedDate){
                    self.selecedindex = indexPath.item
                    cell.labelDate.textColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                    cell.viewDate.layer.borderColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                    cell.viewDate.layer.borderWidth = 1
                    print("Colord Date",date)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM, yyyy"
                    let datefrom = dateFormatter.string(from: date)
                    self.lblSelectedDate.text = datefrom
                    dateFormatter.dateFormat = "MMM yyyy"
                    let datefrom1 = dateFormatter.string(from: date)
                    self.lblDate.text = datefrom1
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let datestring1 = dateFormatter.string(from: totalSquares[self.selecedindex])
                    dateFormatter.dateFormat = "E"
                    self.selectedDay = dateFormatter.string(from: totalSquares[self.selecedindex])
                    self.currentSelectedDate = datestring1
                    //                if currentSelectedDate < currentDate{
                    //                    cell.labelDate.textColor = .black
                    //                    cell.viewDate.layer.borderColor = UIColor.clear.cgColor
                    //                }else{
                    //                    cell.labelDate.textColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                    //                    cell.viewDate.layer.borderColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                    //                    getDoctorAvailabilityAPI()
                    //                }
                    
                    getDoctorAvailabilityAPI()
                    
                    
                    
                }else{
                    cell.labelDate.textColor = .black
                    cell.viewDate.layer.borderColor = UIColor.clear.cgColor
                }
                
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "availableTimeCell", for: indexPath) as! availableTimeCell
            cell.mainView.layer.cornerRadius = 5
            cell.lblTime.text = timeArray[indexPath.row]
            
            let df1 = DateFormatter()
            df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            df1.dateFormat = "dd/MM/yyyy"
            let start_time = df1.date(from: self.currentSelectedDate)
            df1.dateFormat = "dd/MM/yyyy"
            let start_time1 = df1.date(from: Date.getCurrentDatesFormat())
            print("Current date  ----> ", start_time,start_time1)
            
            
            
            if start_time == start_time1{
                let time = availableSlot?.MyBookedSlot?.first?.startTime ?? ""
                var value = ""
                if time == "" || time == nil{
                    
                }else{
                    let timese = time.components(separatedBy: ":")
                    let value1 = "\(timese[0]):\(timese[1])"
                    value = value1
                    print("Value time for selected --> ",value,timeArray[indexPath.row])
                }
                print("starttime")
                if iscomingFromReschedule == true{
                    if timeArray[indexPath.row] < currentTime{
                        if value == timeArray[indexPath.row]{
                            
                            
                            //                        print("Value time for selected --> ",value,timeArray[indexPath.row])
                            cell.mainView.backgroundColor = hexStringToUIColor(hex: "#FCEDED")
                            cell.lblTime.textColor = .systemRed
                            if #available(iOS 13.0, *) {
                                cell.mainView.layer.borderColor = UIColor.systemGray5.cgColor
                            } else {
                                // Fallback on earlier versions
                            }
                            cell.mainView.layer.borderWidth = 1
                        }else{
                            
                            if #available(iOS 13.0, *) {
                                cell.mainView.backgroundColor = .systemGray6
                            } else {
                                // Fallback on earlier versions
                            }
                            cell.mainView.layer.borderColor = UIColor.clear.cgColor
                            cell.mainView.layer.borderWidth = 0
                            cell.lblTime.textColor = .lightGray
                        }
                        
                    }else{
                        if value == timeArray[indexPath.row]{
                            //                            if isSelectingForRechedule == true{
                            //                                if avaialableIndex == indexPath.row{
                            //                                    cell.mainView.backgroundColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                            //                                    cell.lblTime.textColor = .white
                            //                                }else{
                            //                                    if #available(iOS 13.0, *) {
                            //                                        cell.mainView.backgroundColor = .systemGray6
                            //                                        cell.lblTime.textColor = .black
                            //                                    } else {
                            //                                        // Fallback on earlier versions
                            //                                    }
                            //                                }
                            //                            }else{
                            cell.mainView.backgroundColor = hexStringToUIColor(hex: "#FCEDED")
                            cell.lblTime.textColor = .systemRed
                            if #available(iOS 13.0, *) {
                                cell.mainView.layer.borderColor = UIColor.systemGray5.cgColor
                            } else {
                                // Fallback on earlier versions
                            }
                            cell.mainView.layer.borderWidth = 1
                            //                            }
                            
                        }else{
                            if self.slectedSlotDate != currentSelectedDate{
                                if arr[indexPath.row] == timeArray[indexPath.row]{
                                    if #available(iOS 13.0, *) {
                                        cell.mainView.backgroundColor = .systemGray6
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                    cell.mainView.layer.borderWidth = 0
                                    cell.lblTime.textColor = .lightGray
                                }else{
                                    if #available(iOS 13.0, *) {
                                        cell.mainView.backgroundColor = .systemGray6
                                        cell.lblTime.textColor = .black
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                                
                            }else{
                                if avaialableIndex == indexPath.row{
                                    cell.mainView.backgroundColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                                    cell.lblTime.textColor = .white
                                }else{
                                    if arr[indexPath.row] == timeArray[indexPath.row]{
                                        if #available(iOS 13.0, *) {
                                            cell.mainView.backgroundColor = .systemGray6
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                        cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                        cell.mainView.layer.borderWidth = 0
                                        cell.lblTime.textColor = .lightGray
                                    }else{
                                        if #available(iOS 13.0, *) {
                                            cell.mainView.backgroundColor = .systemGray6
                                            cell.lblTime.textColor = .black
                                        } else {
                                            // Fallback on earlier versions
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                }else{
                    
                    
                    
                    if currentTime > timeArray[indexPath.row]{
                        
                        
                        if #available(iOS 13.0, *) {
                            cell.mainView.backgroundColor = .systemGray6
                        } else {
                            // Fallback on earlier versions
                        }
                        cell.lblTime.textColor = .lightGray
                        
                        
                        
                    }else{
                        if self.slectedSlotDate != currentSelectedDate{
                            if arr[indexPath.row] == timeArray[indexPath.row]{
                                if #available(iOS 13.0, *) {
                                    cell.mainView.backgroundColor = .systemGray6
                                } else {
                                    // Fallback on earlier versions
                                }
                                cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                cell.mainView.layer.borderWidth = 0
                                cell.lblTime.textColor = .lightGray
                            }else{
                                if #available(iOS 13.0, *) {
                                    cell.mainView.backgroundColor = .systemGray6
                                    cell.lblTime.textColor = .black
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                            
                            
                        }else{
                            if avaialableIndex == indexPath.row{
                                cell.mainView.backgroundColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                                cell.lblTime.textColor = .white
                            }else{
                                if arr[indexPath.row] == timeArray[indexPath.row]{
                                    if #available(iOS 13.0, *) {
                                        cell.mainView.backgroundColor = .systemGray6
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                    cell.mainView.layer.borderWidth = 0
                                    cell.lblTime.textColor = .lightGray
                                }else{
                                    if #available(iOS 13.0, *) {
                                        cell.mainView.backgroundColor = .systemGray6
                                        cell.lblTime.textColor = .black
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                                
                            }
                        }
                        
                        
                    }
                }
                
                
            } else if start_time1 ?? Date() > start_time ?? Date(){
                let time = availableSlot?.MyBookedSlot?.first?.startTime ?? ""
                var value = ""
                if time == "" || time == nil{
                    
                }else{
                    let timese = time.components(separatedBy: ":")
                    let value1 = "\(timese[0]):\(timese[1])"
                    value = value1
                    print("Value time for selected --> ",value,timeArray[indexPath.row])
                }
                print("starttime")
                if iscomingFromReschedule == true{
                    
                    if value == timeArray[indexPath.row]{
                        //                        print("Value time for selected --> ",value,timeArray[indexPath.row])
                        cell.mainView.backgroundColor = hexStringToUIColor(hex: "#FCEDED")
                        cell.lblTime.textColor = .systemRed
                        if #available(iOS 13.0, *) {
                            cell.mainView.layer.borderColor = UIColor.systemGray5.cgColor
                        } else {
                            // Fallback on earlier versions
                        }
                        cell.mainView.layer.borderWidth = 1
                    }else{
                        if #available(iOS 13.0, *) {
                            cell.mainView.backgroundColor = .systemGray6
                        } else {
                            // Fallback on earlier versions
                        }
                        cell.mainView.layer.borderColor = UIColor.clear.cgColor
                        cell.mainView.layer.borderWidth = 0
                        cell.lblTime.textColor = .lightGray
                    }
                    
                    
                }else{
                    //                    if timeArray[indexPath.row] < currentTime{
                    if #available(iOS 13.0, *) {
                        cell.mainView.backgroundColor = .systemGray6
                    } else {
                        // Fallback on earlier versions
                    }
                    cell.lblTime.textColor = .lightGray
                    
                }
            }else{
                let time = availableSlot?.MyBookedSlot?.first?.startTime ?? ""
                var value = ""
                if time == "" || time == nil{
                    
                }else{
                    let timese = time.components(separatedBy: ":")
                    let value1 = "\(timese[0]):\(timese[1])"
                    value = value1
                    print("Value time for selected --> ",value,timeArray[indexPath.row])
                }
                print("starttime")
                if iscomingFromReschedule == true{
                    
                    if value == timeArray[indexPath.row]{
                        //                        if isSelectingForRechedule == true{
                        //                            if avaialableIndex == indexPath.row{
                        //                                cell.mainView.backgroundColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                        //                                cell.lblTime.textColor = .white
                        //                            }else{
                        //                                if #available(iOS 13.0, *) {
                        //                                    cell.mainView.backgroundColor = .systemGray6
                        //                                    cell.lblTime.textColor = .black
                        //                                } else {
                        //                                    // Fallback on earlier versions
                        //                                }
                        //                            }
                        //                        }else{
                        
                        cell.mainView.backgroundColor = hexStringToUIColor(hex: "#FCEDED")
                        cell.lblTime.textColor = .systemRed
                        if #available(iOS 13.0, *) {
                            cell.mainView.layer.borderColor = UIColor.systemGray5.cgColor
                        } else {
                            // Fallback on earlier versions
                        }
                        cell.mainView.layer.borderWidth = 1
                        //                        }
                        
                    }else{
                        if self.slectedSlotDate != currentSelectedDate{
                            if arr[indexPath.row] == timeArray[indexPath.row]{
                                if #available(iOS 13.0, *) {
                                    cell.mainView.backgroundColor = .systemGray6
                                } else {
                                    // Fallback on earlier versions
                                }
                                cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                cell.mainView.layer.borderWidth = 0
                                cell.lblTime.textColor = .lightGray
                            }else{
                                if #available(iOS 13.0, *) {
                                    cell.mainView.backgroundColor = .systemGray6
                                    cell.lblTime.textColor = .black
                                } else {
                                }
                            }
                        }else{
                            if avaialableIndex == indexPath.row{
                                cell.mainView.backgroundColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                                cell.lblTime.textColor = .white
                            }else{
                                if arr[indexPath.row] == timeArray[indexPath.row]{
                                    if #available(iOS 13.0, *) {
                                        cell.mainView.backgroundColor = .systemGray6
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                    cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                    cell.mainView.layer.borderWidth = 0
                                    cell.lblTime.textColor = .lightGray
                                }else{
                                    if #available(iOS 13.0, *) {
                                        cell.mainView.backgroundColor = .systemGray6
                                        cell.lblTime.textColor = .black
                                    } else {
                                        // Fallback on earlier versions
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    
                    //                    }
                }else{
                    if self.slectedSlotDate != currentSelectedDate{
                        if arr[indexPath.row] == timeArray[indexPath.row]{
                            if #available(iOS 13.0, *) {
                                cell.mainView.backgroundColor = .systemGray6
                            } else {
                                // Fallback on earlier versions
                            }
                            cell.mainView.layer.borderColor = UIColor.clear.cgColor
                            cell.mainView.layer.borderWidth = 0
                            cell.lblTime.textColor = .lightGray
                        }else{
                            if #available(iOS 13.0, *) {
                                cell.mainView.backgroundColor = .systemGray6
                                cell.lblTime.textColor = .black
                            } else {
                            }
                        }
                        
                        
                        
                        //                        print("Booked slots ---> ",appoinmentSelected.count, timeArray.count, appoinmentSelected)
                        
                        
                    }else{
                        
                        if avaialableIndex == indexPath.row{
                            cell.mainView.backgroundColor = #colorLiteral(red: 0.6988685727, green: 0.152430594, blue: 0.1421948671, alpha: 1)
                            cell.lblTime.textColor = .white
                        }else{
                            if arr[indexPath.row] == timeArray[indexPath.row]{
                                if #available(iOS 13.0, *) {
                                    cell.mainView.backgroundColor = .systemGray6
                                } else {
                                    // Fallback on earlier versions
                                }
                                cell.mainView.layer.borderColor = UIColor.clear.cgColor
                                cell.mainView.layer.borderWidth = 0
                                cell.lblTime.textColor = .lightGray
                            }else{
                                if #available(iOS 13.0, *) {
                                    cell.mainView.backgroundColor = .systemGray6
                                    cell.lblTime.textColor = .black
                                } else {
                                    // Fallback on earlier versions
                                }
                            }
                            
                        }
                    }
                    
                    //                    }
                }
                
                
            }
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.sele = ""
        if collectionView == calenderCollectionView{
            self.selecedindex = indexPath.row
            
            if totalSquares[self.selecedindex] < self.mainCurrentDate{
                
            }else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM yyyy"
                let datestring = dateFormatter.string(from: totalSquares[self.selecedindex])
                
                self.lblDate.text = datestring
                dateFormatter.dateFormat = "dd MMM, yyyy"
                self.lblSelectedDate.text = dateFormatter.string(from: totalSquares[self.selecedindex])
                selectedDate = totalSquares[self.selecedindex]
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let datestring1 = dateFormatter.string(from: totalSquares[self.selecedindex])
                self.currentSelectedDate = datestring1
                dateFormatter.dateFormat = "E"
                self.selectedDay = dateFormatter.string(from: totalSquares[self.selecedindex])
                print("Selected Dates------> ",self.currentSelectedDate,selectedDay)
                
                self.calenderCollectionView.reloadData()
            }
            
            // let date = convertdatess(dates: selectedDate)
            // let day = convertday(dates: selectedDate)
        }else{
            let time = availableSlot?.MyBookedSlot?.first?.startTime ?? ""
            var value = ""
            if time == "" || time == nil{
                
            }else{
                let timese = time.components(separatedBy: ":")
                let value1 = "\(timese[0]):\(timese[1])"
                value = value1
                print("Value time for selected --> ",value,timeArray[indexPath.row])
            }
            
            let df1 = DateFormatter()
            df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            df1.dateFormat = "dd/MM/yyyy"
            let start_time = df1.date(from: self.currentSelectedDate)
            df1.dateFormat = "dd/MM/yyyy"
            let start_time1 = df1.date(from: Date.getCurrentDatesFormat())
            print("Current date  ----> ", start_time,start_time1)
            
            if start_time == start_time1{
                if iscomingFromReschedule == true{
                    if timeArray[indexPath.row] < currentTime{
                        print("Time Selected")
                        FTIndicator.showToastMessage("Please select active time")
                    }else{
                        if arr[indexPath.row] == timeArray[indexPath.row]{
                            FTIndicator.showToastMessage("Slot already booked")
                        }else{
                            if value == timeArray[indexPath.row]{
                                FTIndicator.showToastMessage("Slot already booked")
                            }else{
                                self.slotStartTime = timeArray[indexPath.row]
                                let df1 = DateFormatter()
                                // df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                df1.dateFormat = "HH:mm"
                                let start_time = df1.date(from: self.slotStartTime)
                                
                                let addingTime = start_time?.addingTimeInterval(30 * 60)
                                df1.dateFormat = "HH:mm"
                                self.slotEndTime = df1.string(from: addingTime!)
                                
                                avaialableIndex = indexPath.row
                                self.slectedSlotDate = currentSelectedDate
                                colAvailableTime.reloadData()
                            }
                        }
                        
                    }
                }else{
                    if timeArray[indexPath.row] < currentTime{
                        print("Time Selected")
                        FTIndicator.showToastMessage("Please select active time")
                    }else{
                        if arr[indexPath.row] == timeArray[indexPath.row]{
                            FTIndicator.showToastMessage("Slot already booked")
                        }else{
                            self.slotStartTime = timeArray[indexPath.row]
                            let df1 = DateFormatter()
                            // df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                            df1.dateFormat = "HH:mm"
                            let start_time = df1.date(from: self.slotStartTime)
                            
                            let addingTime = start_time?.addingTimeInterval(30 * 60)
                            df1.dateFormat = "HH:mm"
                            self.slotEndTime = df1.string(from: addingTime!)
                            
                            avaialableIndex = indexPath.row
                            self.slectedSlotDate = currentSelectedDate
                            colAvailableTime.reloadData()
                        }
                        
                    }
                }
            } else
            if start_time1 ?? Date() > start_time ?? Date(){
                
                if iscomingFromReschedule == true{
                    FTIndicator.showToastMessage("Please select active time")
                }else{
                    FTIndicator.showToastMessage("Please select active time")
                }
                
            }else{
                if iscomingFromReschedule == true{
                    if arr[indexPath.row] == timeArray[indexPath.row]{
                        FTIndicator.showToastMessage("Slot already booked")
                    }else{
                        if value == timeArray[indexPath.row]{
                            FTIndicator.showToastMessage("Slot already booked")
                        }else{
                            self.slotStartTime = timeArray[indexPath.row]
                            let df1 = DateFormatter()
                            // df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                            df1.dateFormat = "HH:mm"
                            let start_time = df1.date(from: self.slotStartTime)
                            
                            let addingTime = start_time?.addingTimeInterval(30 * 60)
                            df1.dateFormat = "HH:mm"
                            self.slotEndTime = df1.string(from: addingTime!)
                            
                            avaialableIndex = indexPath.row
                            self.slectedSlotDate = currentSelectedDate
                            colAvailableTime.reloadData()
                        }
                    }
                    
                    
                }else{
                    if arr[indexPath.row] == timeArray[indexPath.row]{
                        FTIndicator.showToastMessage("Slot already booked")
                    }else{
                        self.slotStartTime = timeArray[indexPath.row]
                        let df1 = DateFormatter()
                        // df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        df1.dateFormat = "HH:mm"
                        let start_time = df1.date(from: self.slotStartTime)
                        let addingTime = start_time?.addingTimeInterval(30 * 60)
                        df1.dateFormat = "HH:mm"
                        self.slotEndTime = df1.string(from: addingTime!)
                        avaialableIndex = indexPath.row
                        self.slectedSlotDate = currentSelectedDate
                        colAvailableTime.reloadData()
                    }
                }
            }
        }
    }
}
extension Date {
    static func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        return dateFormatter.string(from: Date())
    }
    static func getCurrentDates() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        return dateFormatter.string(from: Date())
    }
    static func getCurrentDatesFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }
    static func getCurrentTimeFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: Date())
    }
    static func getDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: Date())
    }
}
extension String {
    
    func convertDatetring_TopreferredFormat(currentFormat: String, toFormat : String) ->  String {
        let dateFormator = DateFormatter()
        dateFormator.dateFormat = currentFormat
        let resultDate = dateFormator.date(from: self)
        dateFormator.dateFormat = toFormat
        return dateFormator.string(from: resultDate ?? Date())
    }
    
}
