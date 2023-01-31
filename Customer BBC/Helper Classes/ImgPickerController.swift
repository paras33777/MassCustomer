//
//  ImgPickerController.swift
//  Singering
//
//  Created by Sekhon Technologies on 18/08/17.
//  Copyright © 2017 Sekhon Technologies. All rights reserved.
//

import UIKit
class ImgPickerController: UIImagePickerController {
    static let shared = ImgPickerController()
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var imagePickedBlock: ((UIImage,String) -> Void)?
    var name: String?
  //  var namePickedBlock: ((String) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            currentVC.present(myPickerController, animated: true, completion: nil)
        }
    }
    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: "Add Photo !", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height, width: 0, height:0 )
        actionSheet.popoverPresentationController?.permittedArrowDirections = []
        vc.present(actionSheet, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
     CameraHandler.shared.showActionSheet(vc: self)
     CameraHandler.shared.imagePickedBlock = { (image) in
     ------ get your image here --------
     }    }
    */

}
extension ImgPickerController: PKCCropDelegate{
    //return Crop Image & Original Image
    func pkcCropImage(_ image: UIImage?, originalImage: UIImage?) {
        if let image = image{
      //  Singleton.sharedInstance.image = image
            self.imagePickedBlock?(image, name ?? "")
        }
     
    }
    
    //If crop is canceled
    func pkcCropCancel(_ viewController: PKCCropViewController) {
      //  viewController.navigationController?.popViewController(animated: true)
        viewController.dismiss(animated: true, completion: nil)
    }
    
    //Successful crop
    func pkcCropComplete(_ viewController: PKCCropViewController) {
        if viewController.tag == 0{
            viewController.navigationController?.popViewController(animated: true)
            
        }else{
            viewController.dismiss(animated: true, completion: nil)
        }
    }
}
extension ImgPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
    if let image = info[UIImagePickerController.InfoKey.originalImage]! as? UIImage{
         ///   self.imagePickedBlock?(image)
            let imageUrl          = info[UIImagePickerController.InfoKey.imageURL] as? NSURL
            let imageName         = imageUrl?.lastPathComponent
            name = imageName
            print(name)
          //  self.namePickedBlock?(imageName!)
            let cropVC = PKCCropViewController(image, tag: 1)
            cropVC.delegate = self
            PKCCropHelper.shared.degressBeforeImage = #imageLiteral(resourceName: "pkc_crop_rotate_left")
            PKCCropHelper.shared.degressAfterImage = #imageLiteral(resourceName: "pkc_crop_rotate_right")
            picker.pushViewController(cropVC, animated: true)
        }else{
            print("Something went wrong")
        }
     //   currentVC.dismiss(animated: true, completion: nil)
    }
}
