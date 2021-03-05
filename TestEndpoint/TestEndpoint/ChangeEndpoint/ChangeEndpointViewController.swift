//
//  ChangeEndpointViewController.swift
//  FnB
//
//  Created by AnhVH on 05/03/2021.
//  Copyright © 2021 Citigo. All rights reserved.
//

import UIKit
import Eureka
import SVProgressHUD


struct ToolChangeEndpointModel {
    var endpoint = ""
    var method = 1
    var payload = ""
    var repeatTime = 0
    var repeatIntervalSecond = 10
}

enum ToolChangeEndpointMethodType : String, CustomStringConvertible {
    
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
    
    var description : String { return rawValue }
    
    static let allValues = [GET, POST, DELETE, PUT]
    func value() -> Int {
        switch self {
        case .GET:
            return 1
        case .POST:
            return 3
        case .PUT:
            return 4
        case .DELETE:
            return 6
        }
    }
}

class ChangeEndpointViewController: FormViewController {

    let kTagEndpoint = "Tool_Endpoint"
    let kTagMethod = "Tool_Method"
    let kTagPayload = "Tool_Payload"
    let kTagRepeatTime = "Tool_RepeatTime"
    let kTagRepeatTimeIntervalSecond = "Tool_RepeatTimeIntervalSecond"
        
    var toolModel = ToolChangeEndpointModel()
    var toolTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        initializeForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.toolTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configUI() {
        title = "Tool check endpoint"
        let icon = UIImage(named: "ic-close")
        let closeButton = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(onBackButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        
        
        let doneButton = UIBarButtonItem(title: "Xong", style: .plain, target: self, action: #selector(onRequestButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func initializeForm() {
        form
            
            +++ Section()
            
            <<< TextAlignmentRow() {
                $0.tag = kTagEndpoint
                $0.title = "Endpoint"
                $0.placeholder = "http://example.com/api/ping"
            }.onChange {
                self.toolModel.endpoint = $0.value ?? ""
            }
            
            <<< FixedOptionsRow<ToolChangeEndpointMethodType>() {
                $0.tag = kTagMethod
                $0.title = "Method"
                $0.noValueDisplayText = "GET"
                $0.selectorTitle = "Select method"
                $0.options = ToolChangeEndpointMethodType.allValues
                $0.displayValueFor = { (value) in
                    guard let value = value else { return nil }
                    return value.description
                }
                }.onChange {
                    if let type = $0.value?.value() {
                        self.toolModel.method = type
                    } else {
                        self.toolModel.method = 1
                    }
                    $0.reload()
                }.onPresent({ (_, vc) in
                    vc.configCell = { cell, row, value in
                        cell.textLabel?.text = value.rawValue
                        cell.accessoryType = value.value() == row.value?.value() ? .checkmark : . none
                    }
                })
            
            <<< TextAlignmentRow() {
                $0.tag = kTagPayload
                $0.title = "Payload"
                $0.placeholder = "..."
            }.onChange {
                self.toolModel.payload = $0.value ?? ""
            }
            
            <<< AmountRow() {
                $0.tag = kTagRepeatTime
                $0.title = "Multi"
                $0.value = 1
            }.onChange({ [unowned self] (row) in
                self.toolModel.repeatTime = Int(row.value ?? 0)
            })
        
            <<< AmountRow() {
                $0.tag = kTagRepeatTimeIntervalSecond
                $0.title = "Interval (s)"
                $0.value = 10
            }.onChange({ [unowned self] (row) in
                self.toolModel.repeatIntervalSecond = Int(row.value ?? 0)
            })
        
    }
}

//MARK: - Action handler
extension ChangeEndpointViewController {
    @objc func onBackButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func onRequestButtonTapped() {
        if let error = self.form.validate().first {
            SVProgressHUD.showError(withStatus: error.msg)
            return
        }
        
        if self.toolModel.endpoint == "" {
            return
        }
        if self.toolModel.payload == "" {
            return
        }
        
        var multiTimeCounter = 0
        if #available(iOS 10.0, *) {
            SVProgressHUD.show()
            toolTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.toolModel.repeatIntervalSecond), repeats: true) { timer in
                multiTimeCounter += 1
                
                ChangeEndpointService.createRequest(dict: self.toolModel) { (error) in
                    if let err = error {
                        if (err.offline) {
                            SVProgressHUD.showError(withStatus: "Offline")
                        } else {
                            SVProgressHUD.showSuccess(withStatus: "time \(multiTimeCounter) error Code: \(error?.httpCode! ?? 0)")
                        }
                        return
                    }
                    SVProgressHUD.showSuccess(withStatus: "time \(multiTimeCounter) success.")
                }
                
                if multiTimeCounter >= self.toolModel.repeatTime {
                    SVProgressHUD.dismiss()
                    timer.invalidate()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}


extension ChangeEndpointViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 22.0
    }
}
