//
//  ExFont.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 07/12/22.
//

import Foundation
import UIKit
extension UIFont {
    func MontserratBold(size:CGFloat)-> UIFont{
        return UIFont.init(name: "Montserrat-Bold", size: size) ?? UIFont.init()
    }
    func MontserratRegular(size:CGFloat)-> UIFont{
        return UIFont.init(name: "Montserrat-Regular", size: size) ?? UIFont.init()
    }
    func MontserratMedium(size:CGFloat)-> UIFont{
        return UIFont.init(name: "Montserrat-Medium", size: size) ?? UIFont.init()
    }
    func MontserratSemiBold(size:CGFloat)-> UIFont{
        return UIFont.init(name: "Montserrat-SemiBold", size: size) ?? UIFont.init()
    }
    func MontserratThin(size:CGFloat)-> UIFont{
        return UIFont.init(name: "Montserrat-Thin", size: size) ?? UIFont.init()
    }
    
    
}
