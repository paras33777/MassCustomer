//
//  ScheduleCabViewController.swift
//  Customer BBC
//
//  Created by Himanshu on 21/11/22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FTIndicator
import CoreLocation
class ScheduleCabViewController: UIViewController,UITextFieldDelegate, bookedSlot {
    func bookedSlotDone() {
        print("Done")
        addToCartApi()
    }
    
    //MARK: OUTLETS
    @IBOutlet weak var calenderCollectionView: UICollectionView!
    @IBOutlet var lblDate : UILabel!{
        didSet{
            lblDate.text = ""
        }
    }
    @IBOutlet var lblSelectedDate : UILabel!{
        didSet{
            lblSelectedDate.text = ""
        }
    }
    @IBOutlet weak var labelTimeTravel: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet var txtSelectTime : UITextField!
    @IBOutlet var txtFrom : UITextField!
    @IBOutlet var txtTo : UITextField!
    @IBOutlet var btnSeelctDate : UIButton!
    //MARK: VARIABLES
    var locationManager = CLLocationManager()
    var openCart:(() -> Void)!
    var product : Productlist?
    var mainCurrentDate = Date()
    var sele = ""
    var currentSelectedDate = ""
    var selectedDay = ""
    var currentTime = ""
    var totalSquares = [Date]()
    var month = [String]()
    var currentDate = ""
    var selecedindex = 0
    let datePicker = UIDatePicker()
    let datePicker1 = UIDatePicker()
    var fromLat = ""
    var fromLong = ""
    var toLat = ""
    var toLong = ""
    var productId = ""
    var taxiId = ""
    var driverID = ""
    var slotId = ""
    var isFromToField : Bool = false
    var isTimeSelected : Bool = false
    var selectedTime24Hour = ""
    var distanceCalculated = ""
    var timeTaken = ""
    
    lazy var geocoder = CLGeocoder()
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isTimeSelected = false
        txtSelectTime.delegate = self
        txtFrom.delegate = self
        txtTo.delegate = self
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        calenderCollectionView.translatesAutoresizingMaskIntoConstraints = false
        selectedDate = self.getCurrentShortDate()
        self.mainCurrentDate = self.getCurrentShortDate()
        setWeekView()
        self.lblDate.text = Date.getCurrentDates()
        self.lblSelectedDate.text = Date.getCurrentDate()
        self.currentSelectedDate = Date.getCurrentDatesFormat()
        self.selectedDay = Date.getDay()
        self.currentTime = Date.getCurrentTimeFormat()
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
        
        txtSelectTime.attributedPlaceholder = NSAttributedString(string: "Select", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() == .authorizedAlways) {
            currentLoc = locationManager.location
            print(currentLoc.coordinate.latitude)
            print(currentLoc.coordinate.longitude)
            let location = CLLocation(latitude: currentLoc.coordinate.latitude, longitude: currentLoc.coordinate.longitude)
            location.fetchCityAndCountry { city, country, error in
                guard let city = city, let country = country, error == nil else { return }
                print(city + ", " + country)
                self.txtFrom.text = "\(city),\(country)"
                self.fromLat = "\(currentLoc.coordinate.latitude)"
                self.fromLong = "\(currentLoc.coordinate.longitude)"
            }
        }
    }
    override func viewDidLayoutSubviews() {
        setUpCollectionView()
        
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
    func getCurrentShortDate() -> Date {
        var todaysDate = NSDate()
        var dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss ssZZZ"
        var dd = dateFormatter.string(from: todaysDate as Date)
        var DateInFormat = dateFormatter.date(from: dd)!
        
        return DateInFormat
    }
    //MARK: TEXTFIELD DELEGATE
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtSelectTime{
            let df1 = DateFormatter()
            df1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            df1.dateFormat = "dd/MM/yyyy"
            let start_time = df1.date(from: self.currentSelectedDate)
            df1.dateFormat = "dd/MM/yyyy"
            let start_time1 = df1.date(from: Date.getCurrentDatesFormat())
            print("Current date  ----> ", start_time,start_time1)
            if start_time == start_time1{
                showDatePicker()
            }else if start_time1 ?? Date() > start_time ?? Date(){
                showDatePicker1()
            }else{
                showDatePicker1()
            }
            
            
            
            
            
            
            
        }else if textField == txtFrom{
            self.isFromToField = false
            self.view.endEditing(true)
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }else if textField == txtTo {
            self.isFromToField = true
            self.view.endEditing(true)
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            present(autocompleteController, animated: true, completion: nil)
        }
        return true
    }
    func showDatePicker(){
        datePicker.datePickerMode = .time
        
        datePicker.minimumDate = Date()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }else{
            //  datePicker.preferredDatePickerStyle = .wheels
        }
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //           let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: true)
        
        txtSelectTime.inputAccessoryView = toolbar
        txtSelectTime.inputView = datePicker
        
    }
    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.selectedTime24Hour = formatter.string(from: datePicker.date)
        
        formatter.dateFormat = "hh:mm a"
        txtSelectTime.text = formatter.string(from: datePicker.date)
        self.isTimeSelected = true
        //            self.startDate = datePicker.date
        self.view.endEditing(true)
        
    }
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    func showDatePicker1(){
        datePicker1.datePickerMode = .time
        
        if #available(iOS 13.4, *) {
            datePicker1.preferredDatePickerStyle = .wheels
        }else{
            //  datePicker.preferredDatePickerStyle = .wheels
        }
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker1));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        //           let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker1));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: true)
        
        txtSelectTime.inputAccessoryView = toolbar
        txtSelectTime.inputView = datePicker1
        
    }
    @objc func donedatePicker1(){
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        self.selectedTime24Hour = formatter.string(from: datePicker1.date)
        
        formatter.dateFormat = "hh:mm a"
        txtSelectTime.text = formatter.string(from: datePicker1.date)
        self.isTimeSelected = true
        //            self.startDate = datePicker.date
        self.view.endEditing(true)
        
    }
    @objc func cancelDatePicker1(){
        self.view.endEditing(true)
    }
    
    
    func drawMap1(startDestination : String, EndDestination : String) {
        
        let str = "https://maps.googleapis.com/maps/api/directions/json?origin=\(startDestination)&destination=\(EndDestination)&key=\("AIzaSyCXFE2L51SoEqRmcoYFRS-QJZI1BsShLY4")"
        print(str)
        var semaphore = DispatchSemaphore (value: 0)
        let url = URL(string: str.replacingOccurrences(of: " ", with: "%20"))
        var request = URLRequest(url: url!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            let body = String(data: data, encoding: .utf8)!
            guard let json = body  as? String else { return }
            
            let dict = self.convertToDictionary(text: json) as? [String: Any]
            let route = dict?["routes"] as? [[String:Any]]
            if route?.count == 0{
                FTIndicator.showToastMessage("Please select another location")
                DispatchQueue.main.async {
                    self.txtFrom.text = ""
                    self.txtTo.text = ""
                    self.distanceCalculated = ""
                    self.timeTaken = ""
                    self.labelDistance.text = ""
                    self.labelTimeTravel.text = ""
                }
                
            }else{
                let legs = route?[0]["legs"] as? [[String:Any]]
                let distance = legs?[0]["distance"] as! [String:Any]
                let distanceText = distance["text"] as? String ?? ""
                self.distanceCalculated = distanceText
                DispatchQueue.main.async {
                    self.labelDistance.text = "Distance: \(self.distanceCalculated)"
                }
                let duration = legs?[0]["duration"] as! [String:Any]
                let durationText = duration["text"] as? String ?? ""
                self.timeTaken = durationText
                DispatchQueue.main.async {
                    self.labelTimeTravel.text = "Duration: \(self.timeTaken)"
                }
                
                print("Routes data response=========>>>>>>",route)
            }
            
            
            print(String(data: data, encoding: .utf8)!)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
    }
    
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
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
    @IBAction func btnSelectTime(_ sender : Any){
        showDatePicker()
    }
    @IBAction func btnSubmitAction(_ sender : Any){
        if isTimeSelected == false{
            FTIndicator.showToastMessage("Please select pick up time")
        }else if txtTo.text == ""{
            FTIndicator.showToastMessage("Please select destination")
        }else{
            bookCabSlotAPI()
        }
        
        
        
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60)
    }
    //MARK: BOOK APPOINMENT API
    func bookCabSlotAPI(){
        self.showIndicator()
        WebServiceManager.sharedInstance.bookCabSlotAPI(slot_start_time: self.selectedTime24Hour, store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", driver_id: driverID, slot_date: self.currentSelectedDate, vertical: Singleton.sharedInstance.storeInfo.category ?? "", to_address: txtTo.text!, from_latitude: fromLat, to_longitude: toLong, user_id: Singleton.sharedInstance.userInfo.userId ?? "", from_longitude: fromLong, service_id: productId, taxi_id: taxiId, to_latitude: toLat, from_address: txtFrom.text!){ slot_id, msg, status in
            self.slotId = slot_id ?? ""
            self.hideIndicator()
            if status == "1"{
                self.addToCartApi()
                //                let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppoinmentBookedVC") as! AppoinmentBookedVC
                //                vc.delegate = self
                //                vc.modalPresentationStyle = .overCurrentContext
                //                self.present(vc, animated: true, completion: nil)
            }else{
                
            }
        }
    }
    //MARK: ADD TO CART API
    func addToCartApi(){
        self.showIndicator()
        UserDefaults.standard.setValue(self.txtSelectTime.text!, forKey: "slot_time")
        UserDefaults.standard.setValue(self.driverID, forKey: "driverID")
        UserDefaults.standard.setValue(self.slotId, forKey: "slot_id")
        UserDefaults.standard.setValue(self.slotId, forKey: "taxi_id")
        UserDefaults.standard.setValue(self.currentSelectedDate, forKey: "slot_date")
        //        UserDefaults.standard.setValue(self.room_id, forKey: "room_id")
        UserDefaults.standard.setValue("true", forKey: "is_booking")
        //
        //        let myLocation = CLLocation(latitude: Double(fromLat) ?? 0.0, longitude: Double(fromLong) ?? 0.0)
        //
        //        //My buddy's location
        //        let myBuddysLocation = CLLocation(latitude:  Double(toLat) ?? 0.0, longitude:  Double(toLong) ?? 0.0)
        
        //Measuring my distance to my buddy's (in km)
        
        let distance = self.distanceCalculated.replacingOccurrences(of: "km", with: "")
        let distance1 = distance.replacingOccurrences(of: " ", with: "")
        let finalDistance = distance1.replacingOccurrences(of: ",", with: "")
        
        //Display the result in km
        //  print(String(format: "The distance to my buddy is %.01fkm", distance))
        //        Singleton.sharedInstance.isFromSlotBooking = true
        WebServiceManager.sharedInstance.AddToCartAppoinment(store_id: Singleton.sharedInstance.storeInfo.storeId ?? "", product_offer_price: product?.ProductOfferPrice ?? "", user_id: Singleton.sharedInstance.userInfo.userId ?? "", product_id: productId, qty: "\(finalDistance)", action: "1", vertical: Singleton.sharedInstance.storeInfo.category ?? "", store_type: Singleton.sharedInstance.storeInfo.storeType ?? "", inventory: Singleton.sharedInstance.storeInfo.inventory ?? "", package_type: product?.packageType ?? "", payment_method: Singleton.sharedInstance.storeInfo.paymentMethod ?? ""){ slot_id, msg, status in
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
class calenderCabBookingCell : UICollectionViewCell{
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelDay: UILabel!
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var labelDate: UILabel!
}
//MARK: COLLECTIONVIEW DELEGATE AND DATASOURCE
extension ScheduleCabViewController : UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calenderCabBookingCell", for: indexPath) as! calenderCabBookingCell
        
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
                
            }else{
                cell.labelDate.textColor = .black
                cell.viewDate.layer.borderColor = UIColor.clear.cgColor
            }
            
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.sele = ""
        self.selecedindex = indexPath.row
        self.txtSelectTime.text = ""
        self.isTimeSelected = false
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
            self.view.endEditing(true)
            self.calenderCollectionView.reloadData()
        }
        
        // let date = convertdatess(dates: selectedDate)
        // let day = convertday(dates: selectedDate)
    }
    
}
//MARK: GOOGLE PLACES DELEGATE
extension ScheduleCabViewController : GMSAutocompleteViewControllerDelegate{
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(String(describing: place.name))")
        print("Place ID: \(String(describing: place.placeID))")
        print("Place attributions: \(String(describing: place.attributions))")
        if isFromToField == true{
            if txtFrom.text == place.name {
                FTIndicator.showToastMessage("Choose different location")
            }else{
                txtTo.text =  "\(place.name ?? "")"
                toLat = "\(place.coordinate.latitude)"
                toLong = "\(place.coordinate.longitude)"
                self.drawMap1(startDestination: self.txtFrom.text ?? "", EndDestination: self.txtTo.text ?? "")
                
                //                let myLocation = CLLocation(latitude: Double(fromLat) ?? 0.0, longitude: Double(fromLong) ?? 0.0)
                //
                //                //My buddy's location
                //                let myBuddysLocation = CLLocation(latitude:  Double(toLat) ?? 0.0, longitude:  Double(toLong) ?? 0.0)
                //
                //                //Measuring my distance to my buddy's (in km)
                //                let distance = myLocation.distance(from: myBuddysLocation) / 1000
                //
                //                //Display the result in km
                //                print(String(format: "The distance to my buddy is %.01fkm", distance))
                ////                labelDistance.text = "Distance: \(Int(distance)) KM"
                //
                //                let time = distance / 50
                //                let totalTime = time
                //
                //                let totalTimeInSec = totalTime * 3600
                //                let finalTime = self.secondsToHoursMinutesSeconds(Int(totalTimeInSec))
                //
                //                print("Duration: \(finalTime)")
                //                let (h, m, s) = secondsToHoursMinutesSeconds1(seconds: totalTimeInSec)
                //                if Int(h/24) > 0{
                //                  //  labelTimeTravel.text = "Duration: \(Int(h/24)) day,\(Int(h) - Int(h/24) * 24)hours"
                //                }else if h != 0{
                //                    if m == 0{
                //                        labelTimeTravel.text = "Duration: \(h) hours"
                //                    }else{
                //                        labelTimeTravel.text = "Duration: \(h) hours \(m) minutes"
                //                    }
                //                }else{
                //                    labelTimeTravel.text = "Duration: \(m) minutes"
                //                }
            }
        }else{
            if txtTo.text == place.name {
                FTIndicator.showToastMessage("Choose different location")
            }else{
                txtFrom.text =  "\(place.name ?? "")"
                fromLat = "\(place.coordinate.latitude)"
                fromLong = "\(place.coordinate.longitude)"
            }
        }
        print("LAtitude and longitude from --",fromLat,fromLong)
        print("LAtitude and longitude to --",toLat,toLong)
        print(place.coordinate.longitude)
        
        
        //let lat = Double(self.saveLocationData?.body[iseslected].p_latitude ?? "")
        //let long = Double(self.saveLocationData?.body[iseslected].p_longitude ?? "")
        //        self.drawMap(SourceCordinate: CLLocationCoordinate2D(latitude: Double(fromLat) ?? 0.0, longitude: Double(fromLong) ?? 0.0), destinationcordinate: CLLocationCoordinate2D(latitude:  Double(toLat) ?? 0.0 , longitude: Double(toLong) ?? 0.0 ))
        
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - Map View
    func secondsToHoursMinutesSeconds1(seconds: Double) -> (Int, Int, Int) {
        let (hr,  minf) = modf(seconds / 3600)
        let (min, secf) = modf(60 * minf)
        return (Int(hr), Int(min), 60 * Int(secf))
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
        
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
