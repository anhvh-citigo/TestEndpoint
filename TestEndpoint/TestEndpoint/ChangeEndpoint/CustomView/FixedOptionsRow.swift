//
//  LeftPushRow.swift
//  FnB
//
//  Created by cozo on 6/7/18.
//  Copyright © 2018 Citigo. All rights reserved.
//

import UIKit
import SnapKit
import Eureka
import STPopup
import IQKeyboardManagerSwift



public final class FixedOptionsRow<T: Equatable> : _FixedOptionsRow<T>, RowType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

class _FixedOptionsRow<T: Equatable>: OptionsRow<LeftPushSelectorCell<T>>, PresenterRowType, ValueFormConfiguration  {
    
    
    var presentationMode: PresentationMode<FixedOptionsSelectorController<T>>?
    var onPresentCallback: ((FormViewController, FixedOptionsSelectorController<T>) -> Void)?
    
    typealias ProviderType = FixedOptionsSelectorController<T>
    
    var popup: STPopupController?
    var textAlign: NSTextAlignment?
    
    var titleWidthPercentage: CGFloat?
    
    required init(tag: String?) {
        super.init(tag: tag)
        textAlign = .left
        let controller = FixedOptionsSelectorController<T>(nibName: nil, bundle: nil)
        let screenWidth = UIScreen.main.bounds.width
        controller.contentSizeInPopup = CGSize(width: screenWidth, height:  UIScreen.main.bounds.height - 345)
        popup = STPopupController(rootViewController: controller)
        popup?.style = .bottomSheet
        popup?.backgroundView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPopup)))
        presentationMode = PresentationMode.show(controllerProvider: ControllerProvider.callback { return controller }, onDismiss: { (vc) in
            vc.popupController?.dismiss()
        })
        
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            popup?.present(in:self.cell.formViewController()!)
            
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
    
    @objc func dismissPopup() {
        popup?.dismiss()
    }
}


open class LeftPushSelectorCell<T> : Cell<T>, CellType where T: Equatable{
    public var textAlign: NSTextAlignment?
    
    public var titleWidthPercentage: CGFloat?
    public var valueTextColor: UIColor = .black
    
    lazy var valueLabel:UILabel = {
        var label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        label.shouldHideToolbarPlaceholder = true
        label.clipsToBounds = true
        return label
        
    } ()
    
    lazy var titleLabel:UILabel = {
        var label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .left
        return label
    } ()
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(titleLabel)
        self.addSubview(valueLabel)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        updateConstraints()
    }
   
    
    open override func update() {
        super.update()

        tintColor = .blue
        accessoryType = .disclosureIndicator
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .none : .default
        detailTextLabel?.text = nil
        textLabel?.text = nil
        titleLabel.textAlignment = (self.row as? ValueFormConfiguration)?.textAlign ?? .left
        titleLabel.text = row.title
        if let detail = row.displayValueFor?(row.value) {
            valueLabel.text = detail
            valueLabel.textColor = valueTextColor
        } else {
            valueLabel.text = (row as? NoValueDisplayTextConformance)?.noValueDisplayText
            valueLabel.textColor = .gray
        }
    }
    
    
    open override func updateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.width.equalToSuperview().multipliedBy((row as? ValueFormConfiguration)?.titleWidthPercentage ?? 0.35)
        }
        
        valueLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(self.contentView).offset(0)
            make.top.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.leading.equalTo(titleLabel.snp.trailing)
        }
        
        
        super.updateConstraints()
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
}

