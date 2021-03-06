//
//  PatternView.swift
//  Gomble
//
//  Created by mobileworld on 8/26/20.
//  Copyright © 2020 Haley Huynh. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable
class PatternView: BaseView {
    
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate:BaseViewController?
    var viewHeight:CGFloat = 280
    let cellID = "patternView";
    var onHightChanged : ((CGFloat)->Void)?
    var patternData:[JSON] = [] {
        didSet {
            tableView.reloadData()
            tableView.layoutIfNeeded()
            if patternData.count == 0 {
                emptyView.isHidden = false
                dataView.isHidden = true
            }
            else {
                emptyView.isHidden = true
                dataView.isHidden = false
                self.tableViewHeight.constant = 130 * CGFloat(self.patternData.count)
                self.tableView.setNeedsUpdateConstraints()
                self.tableView.layoutIfNeeded()
//                tableView.alwaysBounceVertical = false
                viewHeight = CGFloat(tableViewHeight.constant + 120)
                if (onHightChanged != nil) {
                    onHightChanged!(viewHeight)
                }
            }
            tableView.layoutIfNeeded()
        }
    }
    override func setNibName() {
        nibName = "PatternView"
    }
    override func initView() {
        tableView.register(UINib(nibName: "PatternCell", bundle: nil), forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        getData()
    }
    func getData(){
        var param = [String:String]()
        param["techpack_id"] = Globals.techpackID
        APIManager.getPattern(param: param) { json in
            if json["success"].boolValue {
                self.patternData = json["res"].arrayValue
                self.tableView.reloadData()
            }
            else {
                self.makeToast(json["message"].stringValue)
            }
        }
    }
    @IBAction func onAddPattern(_ sender: Any) {
        delegate?.openDialog(id: "add_pattern", completion: {
            self.getData()
        })
    }
}
extension PatternView:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patternData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PatternCell = tableView.dequeueReusableCell(withIdentifier: cellID) as! PatternCell
        cell.selectionStyle = .none
        
        let data = patternData[indexPath.row]
        
        cell.titleLabel.text = data["title"].stringValue
        cell.descriptionLabel.text = data["description"].stringValue
        let imageUrl = APIManager.fullPatternPath(name: data["image"].stringValue)
        cell.patternImageView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "test_pattern.png"))
        cell.onDeleteClicked(){
            print("deleted")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
}

