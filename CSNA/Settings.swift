//
//  Settings.swift
//  CSNA
//
//  Created by Wilhelm Thieme on 07/11/2020.
//

import UIKit

@objc protocol SettingsDelegate: class {
    @objc optional func settings(didPressReset settings: Settings)
    @objc optional func settings(_ settings: Settings, didPressExportWith options: ExportType)
    @objc optional func settings(didEditSettings settings: Settings)
    @objc optional func settings(didPressBack settings: Settings)
}

enum SettingsType {
    case main, detail
}

fileprivate let collectionReuse = "SettingsCollectionReuse"
fileprivate let tableReuse = "SettingsTableReuse"

class Settings: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, SettingsDelegate {
    
    weak var delegate: SettingsDelegate?
    
    private let selectedActor: Actor?
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let backButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let collectionViewCell = UITableViewCell(style: .default, reuseIdentifier: "CollectionCell")
    private let textField = UITextField()
    private let textFieldCell = UITableViewCell(style: .default, reuseIdentifier: "TextCell")
    private var collectionViewHeight: NSLayoutConstraint!
    
    private var childController: UIViewController?
    
    init(detail actor: Actor? = nil) {
        self.selectedActor = actor
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .popover
        preferredContentSize = CGSize(width: 360, height: 540)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.systemGroupedBackground
        
        collectionViewCell.selectionStyle = .none
        collectionViewCell.contentView.isUserInteractionEnabled = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: collectionReuse)
        collectionViewCell.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: collectionViewCell.leadingAnchor, constant: 8).activate()
        collectionView.trailingAnchor.constraint(equalTo: collectionViewCell.trailingAnchor, constant: -8).activate()
        collectionView.topAnchor.constraint(equalTo: collectionViewCell.topAnchor, constant: 8).activate()
        collectionView.bottomAnchor.constraint(equalTo: collectionViewCell.bottomAnchor, constant: -8).activate()
        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 50).activate(.defaultHigh)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.tintColor = UIColor.accentColor
        backButton.isHidden = selectedActor == nil
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        view.addSubview(backButton)
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        backButton.heightAnchor.constraint(equalToConstant: selectedActor == nil ? 0 : 55).activate()
        backButton.widthAnchor.constraint(equalToConstant: 55).activate()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: tableReuse)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: selectedActor == nil ? 16 : .leastNormalMagnitude))
        view.addSubview(tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor).activate()
        
        
        textFieldCell.selectionStyle = .none
        textFieldCell.contentView.isUserInteractionEnabled = false
        
        textField.text = selectedActor?.name
        textField.placeholder = String(localizedString("unisexNames").split(separator: ",").randomElement() ?? "")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor.secondarySystemBackground
        textField.layer.cornerRadius = 8
        textField.layer.cornerCurve = .continuous
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        textField.delegate = self
        textFieldCell.addSubview(textField)
        textField.leadingAnchor.constraint(equalTo: textFieldCell.leadingAnchor, constant: 8).activate()
        textField.trailingAnchor.constraint(equalTo: textFieldCell.trailingAnchor, constant: -8).activate()
        textField.topAnchor.constraint(equalTo: textFieldCell.topAnchor, constant: 8).activate()
        textField.bottomAnchor.constraint(equalTo: textFieldCell.bottomAnchor, constant: -8).activate()
        textField.heightAnchor.constraint(equalToConstant: 55).activate(.defaultHigh)

        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if collectionViewHeight.constant == collectionView.collectionViewLayout.collectionViewContentSize.height { return }
        collectionViewHeight.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        tableView.reloadData()
    }
    
    func push(controller: UIViewController?, animated: Bool) {
        if let oldController = childController {
            oldController.willMove(toParent: nil)
            oldController.view.removeFromSuperview()
            oldController.removeFromParent()
            childController = nil
        }
        
        if let newController = controller {
            view.addSubview(newController.view)
            newController.view.frame = view.frame
            addChild(newController)
            newController.didMove(toParent: self)
            childController = newController
        }
        
        if animated {
            UIView.transition(with: view, duration: 0.5, options: [.curveEaseInOut, .transitionCrossDissolve], animations: nil, completion: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedActor == nil ? 3 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedActor == nil {
            if section == 0 { return 2 }
            if section == 1 { return ExportType.allCases.count }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return section == numberOfSections(in: tableView)-1 ? localizedString("copyright") : nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedActor == nil {
            if indexPath == IndexPath(row: 0, section: 0) { return collectionViewCell }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableReuse) else { return UITableViewCell() }
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = indexPath.section == 2 ? UIColor.systemRed : UIColor.label
            switch indexPath.section {
            case 0: cell.textLabel?.text = localizedString("add")
            case 1: cell.textLabel?.text = localizedString("export\(ExportType.allCases[indexPath.row].rawValue)")
            case 2: cell.textLabel?.text = localizedString("reset")
            default: break
            }
            return cell
        } else {
            if indexPath == IndexPath(row: 0, section: 0) { return textFieldCell }
            if indexPath == IndexPath(row: 0, section: 2) { return collectionViewCell }
            guard let cell = tableView.dequeueReusableCell(withIdentifier: tableReuse) else { return UITableViewCell() }
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = UIColor.systemRed
            cell.textLabel?.text = localizedString("remove")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let actor = selectedActor {
            Service.removeActor(actor)
            delegate?.settings?(didPressBack: self)
            delegate?.settings?(didEditSettings: self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        } else {
            
            if indexPath == IndexPath(row: 0, section: 0) { return }
            
            switch indexPath.section {
            case 0:
                Service.addActor()
                collectionView.reloadData()
                tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                delegate?.settings?(didEditSettings: self)
            case 1: delegate?.settings?(self, didPressExportWith: ExportType.allCases[indexPath.row])
            case 2: delegate?.settings?(didPressReset: self)
            default: break
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedActor == nil ? Service.actors.count : Icon.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionReuse, for: indexPath)
        if let cell = cell as? CollectionViewCell {
            if let actor = selectedActor {
                cell.icon = Icon.allCases[indexPath.row]
                cell.name = nil
                cell.bordered = Icon.allCases[indexPath.row] == actor.icon
            } else {
                cell.icon = Service.actors[indexPath.row].icon
                cell.name = Service.actors[indexPath.row].name
                cell.bordered = false
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let actor = selectedActor {
            actor.icon = Icon.allCases[indexPath.row]
            collectionView.reloadData()
            Service.saveModel()
            delegate?.settings?(didEditSettings: self)
        } else {
            let controller = Settings(detail: Service.actors[indexPath.row])
            controller.delegate = self
            push(controller: controller, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let totalSpace = flow.sectionInset.left + flow.sectionInset.right + (flow.minimumInteritemSpacing * CGFloat(3 - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(3))
        return CGSize(width: size, height: size)
    }
    
    @objc private func backButtonPressed() {
        delegate?.settings?(didPressBack: self)
    }
    
    func settings(didPressBack settings: Settings) {
        push(controller: nil, animated: true)
        collectionView.reloadData()
    }
    
    func settings(didEditSettings settings: Settings) {
        delegate?.settings?(didEditSettings: settings)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let actor = selectedActor {
            actor.name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            collectionView.reloadData()
            Service.saveModel()
            delegate?.settings?(didEditSettings: self)
        }
    }
    
}

fileprivate class CollectionViewCell: UICollectionViewCell {
    
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.textAlignment = .center
        iconLabel.font = UIFont.systemFont(ofSize: UIFont.labelFontSize * 3)
        contentView.addSubview(iconLabel)
        iconLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).activate()
        iconLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).activate()
        iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8).activate()
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubview(nameLabel)
        nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).activate()
        nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).activate()
        nameLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 0).activate()
        nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).activate()
    }
    
    var icon: Icon? {
        get { return Icon(rawValue: iconLabel.text ?? "") }
        set { iconLabel.text = newValue?.rawValue }
    }
    
    var name: String? {
        get { return nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    var bordered: Bool {
        set { layer.borderWidth = newValue ? 2 : 0 }
        get { return layer.borderWidth == 2}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
