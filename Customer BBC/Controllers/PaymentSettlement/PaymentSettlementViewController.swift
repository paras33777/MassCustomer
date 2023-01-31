//
//  PaymentSettlementViewController.swift
//  Customer BBC
//
//  Created by Prashant Kumar on 07/12/22.
//

import UIKit

class PaymentSettlementViewController: UIViewController {
    @IBOutlet weak var dataTableview: UITableView!
    var arr : [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataTableview.dataSource = self
        self.dataTableview.delegate = self
        self.dataTableview.reloadData()

        // Do any additional setup after loading the view.
    }
    
    @objc func settleMentButtonPressed(sender:UIButton){
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PaymentSettlementViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count + 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettlementPaymentRowTableViewCell", for: indexPath) as? SettlementPaymentRowTableViewCell else { return UITableViewCell.init() }
        cell.titleLabel.text = "total"
        cell.descriptionLabel.text = "2323424"
        if  indexPath.row == self.arr.count{
            cell.titleLabel.font =  UIFont().MontserratBold(size: 17.0)
            cell.titleLabel.font =  UIFont().MontserratBold(size: 17.0)
        }else{
            cell.titleLabel.font =  UIFont().MontserratRegular(size: 15.0)
            cell.descriptionLabel.font =  UIFont().MontserratMedium(size: 15.0)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SettlementPaymentFooterTableViewCell") as? SettlementPaymentFooterTableViewCell else { return UITableViewCell.init() }
        cell.settleMentButton.addTarget(self, action: #selector(settleMentButtonPressed(sender: )), for: .touchUpInside)
        return cell
    }
    
}
