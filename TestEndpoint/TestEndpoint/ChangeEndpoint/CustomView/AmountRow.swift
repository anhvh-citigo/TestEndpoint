//
//  AmountRow.swift
//  FnB
//
//  Created by cozo on 6/13/18.
//  Copyright © 2018 Citigo. All rights reserved.
//

import UIKit
import Eureka

open class _AmountCell : Cell<Double>,  TextFieldCell, UITextFieldDelegate {
    public var textField: UITextField! { return amountTextField }
    
    lazy var amountTextField: AmountTextField = {
        let textField = AmountTextField()
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textAlignment = .left
        
        return textField
    } ()
    
    lazy var titleLabel:UILabel = {
        var label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    } ()
    
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    deinit {
        textField?.delegate = nil
        textField?.removeTarget(self, action: nil, for: .allEvents)
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        amountTextField.amountValue = row.value ?? 0
        self.amountTextField.valueChangedBlock = { amount in
            self.row.value = amount
        }
    }
    
    open override func update() {
        super.update()
        detailTextLabel?.text = nil
        textLabel?.text = nil
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.isEnabled = !row.isDisabled
        textField.textColor = row.isDisabled ? .gray : .black
        textField.font = .preferredFont(forTextStyle: .body)
        if let alginment = (row as? ValueFormConfiguration)?.textAlign {
            textField.textAlignment = alginment
        } else {
            textField.textAlignment = .left
        }
        if let placeholder = (row as? FieldRowConformance)?.placeholder {
            if let color = (row as? FieldRowConformance)?.placeholderColor {
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: color])
            } else {
                textField.placeholder = (row as? FieldRowConformance)?.placeholder
            }
        }
        titleLabel.text = self.row.title
        amountTextField.amountValue = row.value ?? 0
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && textField?.canBecomeFirstResponder == true
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return textField?.resignFirstResponder() ?? true
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let obj = object as AnyObject?
        
        if let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey],
            ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) &&
                (changeType as? NSNumber)?.uintValue == NSKeyValueChange.setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    
    open override func updateConstraints() {
        
        super.updateConstraints()
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.width.equalToSuperview().multipliedBy((row as? ValueFormConfiguration)?.titleWidthPercentage ?? 0.35)
        }
        
        textField.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalTo(titleLabel.snp.trailing)
        }
        self.layoutIfNeeded()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInput(textField, shouldChangeCharactersInRange:range, replacementString:string, cell: self) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
}

public class AmountCell : _AmountCell, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func setup() {
        super.setup()
        textField?.autocorrectionType = .no
        textField?.autocapitalizationType = .none
        textField?.keyboardType = .default
    }
    
}

open class _AmountRow<Cell: CellType>: FormatteableRow<Cell> where Cell: BaseCell, Cell: TextFieldCell {
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
}

public final class AmountRow:_AmountRow<AmountCell>, ValueFormConfiguration, FieldRowConformance,  RowType {
    public var titlePercentage: CGFloat?
    
    
    
    ///
    public var textFieldPercentage: CGFloat?
    
    public var placeholder: String?
    
    public var placeholderColor: UIColor?
    
    public var textAlign: NSTextAlignment?
    
    public var titleWidthPercentage: CGFloat?
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
