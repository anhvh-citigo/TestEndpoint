//
//  AlignTextRow.swift
//  FnB
//
//  Created by cozo on 6/7/18.
//  Copyright © 2018 Citigo. All rights reserved.
//

import UIKit
import Eureka
import SnapKit


public protocol ValueFormConfiguration {
    var textAlign : NSTextAlignment? { get set }
    var titleWidthPercentage : CGFloat? { get set }
}

open class _TextAlignmentCell<T> : Cell<T>, TextFieldCell, UITextFieldDelegate where T:Equatable, T:InputTypeInitiable {
    public var textField: UITextField! { return alignTextField }
    
    lazy var alignTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.textAlignment = .left
        return textField
    }()
    
    lazy var titleLabel:UILabel = {
        var label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    }()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(textField)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        textField?.delegate = nil
        textField?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        
        textField.addTarget(self, action: #selector(TextAlignmentCell.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    open override func update() {
        super.update()
        detailTextLabel?.text = nil
        textLabel?.text = nil
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.delegate = self
        textField.text = row.displayValueFor?(row.value)
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
                textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedStringKey.foregroundColor: color])
            } else {
                textField.placeholder = (row as? FieldRowConformance)?.placeholder
            }
        }
        titleLabel.text = self.row.title
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
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        guard let textValue = textField.text else {
            row.value = nil
            return
        }
        guard let fieldRow = row as? FieldRowConformance, let formatter = fieldRow.formatter else {
            row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
            return
        }
        if fieldRow.useFormatterDuringInput {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? T
                guard var selStartPos = textField.selectedTextRange?.start else { return }
                let oldVal = textField.text
                textField.text = row.displayValueFor?(row.value)
                selStartPos = (formatter as? FormatterProtocol)?.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text) ?? selStartPos
                textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
                return
            }
        } else {
            let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.allocate(capacity: 1))
            let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
            if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                row.value = value.pointee as? T
            } else {
                row.value = textValue.isEmpty ? nil : (T.init(string: textValue) ?? row.value)
            }
        }
    }
    
    //Mark: Helpers
    private func displayValue(useFormatter: Bool) -> String? {
        guard let v = row.value else { return nil }
        if let formatter = (row as? FormatterConformance)?.formatter, useFormatter {
            return textField?.isFirstResponder == true ? formatter.editingString(for: v) : formatter.string(for: v)
        }
        return String(describing: v)
    }
    
    //MARK: TextFieldDelegate
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(of: self)
        if let fieldRowConformance = row as? FormatterConformance, let _ = fieldRowConformance.formatter, fieldRowConformance.useFormatterOnDidBeginEditing ?? fieldRowConformance.useFormatterDuringInput {
            textField.text = displayValue(useFormatter: true)
        } else {
            textField.text = displayValue(useFormatter: false)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(of: self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
        textField.text = displayValue(useFormatter: (row as? FormatterConformance)?.formatter != nil)
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

public class TextAlignmentCell : _TextAlignmentCell<String>, CellType {
    
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

open class _TextAlignmentRow<Cell: CellType>: FormatteableRow<Cell> where Cell: BaseCell, Cell: TextFieldCell {
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
}

public final class TextAlignmentRow:_TextAlignmentRow<TextAlignmentCell>, ValueFormConfiguration, FieldRowConformance,  RowType {
    public var titlePercentage: CGFloat?
    
    public var textFieldPercentage: CGFloat?
    
    public var placeholder: String?
    
    public var placeholderColor: UIColor?
    
    public var textAlign: NSTextAlignment?
    
    public var titleWidthPercentage: CGFloat?
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
