//
//  BottomSelectorController.swift
//  FnB
//
//  Created by cozo on 6/11/18.
//  Copyright © 2018 Citigo. All rights reserved.
//

import UIKit
import Eureka
import SnapKit
import FontAwesomeKit

class FixedOptionsSelectorController<T> : UIViewController, TypedRowControllerType, UITableViewDataSource, UITableViewDelegate where T: Equatable {
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    } ()
    
    let selectionCellIdentifier = "SelectionCell"
    var row: RowOf<T>!
    var data: [T]? {
        return (row as! FixedOptionsRow).options
    }
    
    public var configCell: ((_ cell: UITableViewCell,_ row: RowOf<T>,_ value: T) -> Void)?
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: selectionCellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: selectionCellIdentifier)
            if UIDevice().userInterfaceIdiom == .pad {
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 17)
            } else {
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 17)
            }
            
        }
        let item = data![indexPath.row]
        if let configCell = configCell {
            configCell(cell!, row, item)
        } else {
            print("Config Cell")
            /*
             ...
             }.onPresent({ (_, vc) in
             vc.configCell = {cell, row, value in
             cell.textLabel?.text = value.name() /// option title
             cell.accessoryType = value == row.value ? .checkmark : . none /// selected
             }
             })*/
            
        }
        
        return cell!
    }
    
    var onDismissCallback: ((UIViewController) -> Void)?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func dismissPopup() {
        self.popupController?.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)

        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data![indexPath.row]
        if item == self.row.value {
            self.row.value = nil
        } else {
            self.row.value = item
        }
        self.tableView.reloadData()
        self.dismissPopup()
    }
    
}
