//
//  AmountTextField.swift
//  FnB
//
//  Created by tungnd on 9/25/17.
//  Copyright © 2017 Citigo. All rights reserved.
//

import UIKit
import NumPad
import FontAwesomeKit

class AmountTextField: UITextField {
    
    var maxInputLenght = 12
    var numberFormatter: NumberFormatter!
    var valueChangedBlock: ((_ amount: Double)-> Void)?
    
    var showDotKey: Bool = false {
        didSet {
            guard let subview = inputView?.subviews else { return }
            for view in subview {
                guard let collectionview = view as? UICollectionView else { continue }
                collectionview.reloadData()
                break
            }
        }
    }
    
    var maxValue: Double = 100 {
        didSet {
            if showDotKey {
                numberFormatter = maxValue > 100 ? Formatter.quantiyFormatter : Formatter.ratioFormatter
            } else {
                numberFormatter = Formatter.priceFormatter
            }
        }
    }
    
    var amountValue: Double = 0 {
        didSet {
            if amountValue != oldValue {
                text = numberFormatter.string(from: NSNumber(value: amountValue))
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }
    
    func setUpView() {
        let width = UIScreen.main.bounds.width
        let numberPad = NumPad(frame: CGRect(x: 0, y: 0, width: width, height: width * 0.6))
        inputView = numberPad
        numberPad.dataSource = self
        numberPad.delegate = self
        maxValue = Double.greatestFiniteMagnitude
        formatText()
        clearButtonMode = .never
        rightViewMode = .whileEditing
        
        let buttonsize = bounds.height * 0.5
        let icon = FAKIonIcons.closeCircledIcon(withSize: buttonsize)!
        icon.setAttributes([NSAttributedStringKey.foregroundColor : UIColor(white: 0.7, alpha: 0.9)])
        let clear = UIButton(frame: CGRect(x: 0, y: 0, width: buttonsize * 1.2, height: buttonsize))
        clear.setImage(icon.image(with: CGSize(width: buttonsize, height: buttonsize)), for: .normal)
        clear.addTarget(self, action: #selector(onClearButtonTapped), for: .touchUpInside)
        rightView = clear
        rightView?.contentMode = .center
    }
    
    @objc func onClearButtonTapped() {
        if amountValue == 0 {
            return
        }
        
        amountValue = 0
        text = "0"
        
        guard let block = valueChangedBlock else {
            return
        }
        
        block(0)
    }
    
    func formatText() {
        let number = NSNumber(value: amountValue)
        if showDotKey {
            if maxValue > 100 {
                text = number.quantityString
            } else {
                text = number.ratioString
            }
        } else {
            text = number.priceString
        }
    }
    
    func positionToText(position: Position) -> String? {
        switch position {
        case (3, 0):
            return showDotKey ? "." : "000"
        case (3, 1):
            return "0"
        case (3, 2):
            return nil
        default:
            return "\((3 * position.row + position.column) + 1)"
        }
    }
}

extension AmountTextField: NumPadDataSource {
    func numPad(_ numPad: NumPad, numberOfColumnsInRow row: Row) -> Int {
        return 3
    }
    
    func numberOfRowsInNumPad(_ numPad: NumPad) -> Int {
        return 4
    }
    
    func numPad(_ numPad: NumPad, itemAtPosition position: Position) -> Item {
        var item = Item()
        if let text = positionToText(position: position) {
            item.title = text
            item.font = UIFont.systemFont(ofSize: 17)
        } else {
            item.title = FAKIonIcons.backspaceOutlineIcon(withSize: 25).characterCode()
            item.font = FAKIonIcons.iconFont(withSize: 25)
        }
        item.selectedBackgroundColor = UIColor(white: 0.9, alpha: 1)
        item.titleColor = UIColor(white: 0.2, alpha: 1)
        return item
    }
}

extension AmountTextField: NumPadDelegate {
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {
        var text = self.text?.replacingOccurrences(of: ",", with: "") ?? ""
        if text.length > maxInputLenght && position != (3, 2) {
            return
        }
        
        if position == (3, 2) {
            if text.length > 1 {
                text = text.substring(to: text.index(text.startIndex, offsetBy: text.length - 1))
            } else {
                text = "0"
            }
        } else {
            let string = positionToText(position: position)!
            if canAppendText(string: string, inText: text) {
                text += string
                if text.length > maxInputLenght {
                    text = text.substring(to: text.index(text.startIndex, offsetBy: maxInputLenght + 1))
                }
            }
        }
        if let amount = numberFormatter.number(from: text)?.doubleValue {
            if amountValue != amount {
                amountValue = amount
                self.text = numberFormatter.string(from: NSNumber(value: amount))
                if let block = valueChangedBlock {
                    block(amountValue)
                }
            } else {
                self.text = text
            }
        }
    }
    
    func canAppendText(string: String, inText: String) -> Bool {
        if showDotKey {
            if maxValue < amountValue {
                return false
            }
            
            if let index = inText.firstIndex(of: ".") {
                return !((string == ".") || inText.length - index > numberFormatter.maximumFractionDigits)
            }
            
            return amountValue > 0 || numberFormatter.number(from: string) != nil || string == "." || inText.length == numberFormatter.maximumFractionDigits
        }
        return amountValue > 0 || (numberFormatter.number(from: string)?.boolValue)!
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        if action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        if action == #selector(UIResponderStandardEditActions.select(_:)) {
            return false
        }
        if action == #selector(UIResponderStandardEditActions.selectAll(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
