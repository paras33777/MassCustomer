//
//  StorTabController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 06/05/22.
//

import UIKit

class StoreTabController: UITabBarController {
    //MARK: - IBOUTLET
    //MARK: - VARIABLE
    // var storeID = String()
    //MARK: - IBACTIONS
    //MARK: - VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        updateUI()
        //        if let vc = self.viewControllers![1] as? StoreProductsController{
        //            vc.storeID = storeID
        //        }
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        //  updateTabBarAppearance()
    }
    
    //MARK: - UPDATE UI
    func updateUI(){
        if #available(iOS 13, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage(named: "shadowBGTab")!
            appearance.shadowColor = .clear
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.shadowImage = UIImage(named: "shadowBGTab")!
            self.tabBar.backgroundImage = UIImage()
        }
        self.tabBar.tintColor = hexStringToUIColor(hex: Color.red.rawValue)
        self.tabBar.unselectedItemTintColor = hexStringToUIColor(hex: Color.lightGrey.rawValue)
    }
    
}

extension StoreTabController: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //  updateTabBarAppearance()
        //                     if viewController.isKind(of: StoreProductsController.self){
        //                        let vc = viewController as!  StoreProductsController
        //                         vc.storeID = storeID
        //                     }
    }
    func updateTabBarAppearance() {
        self.tabBar.tintColor = .red
        let unselectedLabelFont =  UIFont.init(name: "Montserrat-Regular", size: 14.0)!
        let selectedLabelFont = UIFont.init(name: "Montserrat-Medium", size: 14.0)!
        let labelColor = hexStringToUIColor(hex: Color.logoBlue.rawValue)
        // let selectedIconColor = hexStringToUIColor(hex: Color.logoBlue.rawValue)
        
        viewControllers?.forEach {
            let isSelected = $0 == self.selectedViewController
            let selectedFont = isSelected ? selectedLabelFont : unselectedLabelFont
            $0.tabBarItem.setTitleTextAttributes([.font: selectedFont, .foregroundColor: labelColor], for: .normal)
            
        }
    }
}
