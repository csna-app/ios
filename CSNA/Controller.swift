import UIKit

class Controller: UIViewController, SceneDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var scene: Scene!
    private var alert: UIAlertController?
    
    private var aMenu: UIMenu!
    private var tMenu: UIMenu!
    
    private var aNodes: [Actor: ANode] = [:]
    private var tNodes: [Terrain: TNode] = [:]
    
    init() {
        super.init(nibName: "View", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let shareItems = ExportType.allCases.map({ e in UIAction(title: e.name, image: e.icon, handler: { [weak self] _ in self?.export(with: e)  }) })
        let shareItem = UIMenu(title: "", image: nil, options: .displayInline, children: shareItems)
        let resetItem = UIAction(title: localizedString("reset"), image: UIImage(systemName: "xmark.square"), attributes: .destructive, handler: { [weak self] _ in self?.askToReset() })
        shareButton.menu = UIMenu(title: "", children: [shareItem, resetItem])
        shareButton.showsMenuAsPrimaryAction = true
        
        let actorImage = UIImage(systemName: "person.crop.circle.badge.plus")
        let actorItems = HairStyle.allCases.map({ e in UIAction(title: e.localized, image: e.image, handler: { [weak self] _ in self?.addActor(e) }) })
        let addActor = UIMenu(title: localizedString("addActor"), image: actorImage, children: actorItems)
        let terrainImage = UIImage(systemName: "apps.iphone.badge.plus")
        let terrainItems = TerrainType.allCases.map({ e in UIAction(title: e.localized, image: UIImage(systemName: e.icon), handler: { [weak self] _ in self?.addTerrain(e) }) })
        let addTerrain = UIMenu(title: localizedString("addTerrain"), image: terrainImage, children: terrainItems)
        
        addButton.menu = UIMenu(title: "", children: [addActor, addTerrain])
        addButton.showsMenuAsPrimaryAction = true
        
        
        let removeItem = UIAction(title: localizedString("remove"), image: UIImage(systemName: "trash.slash"), attributes: .destructive, handler: { [weak self] a in self?.removeNode(a.sender) })
        
        let typeItems = TerrainType.allCases.map({ e in UIAction(title: e.localized, image: UIImage(systemName: e.icon), handler: { [weak self] a in self?.editNode(a.sender, type: e) }) })
        let typeItem = UIMenu(title: localizedString("type"), image: UIImage(systemName: "apps.iphone"), children: typeItems)
        let sizeItems = TerrainSize.allCases.map({ e in UIAction(title: e.localized, image: UIImage(systemName: e.icon), handler: { [weak self] a in self?.editNode(a.sender, size: e) }) })
        let sizeItem = UIMenu(title: localizedString("size"), image: UIImage(systemName: "aspectratio"), children: sizeItems)
        
        let skinItems = SkinColor.allCases.map({ e in UIAction(title: e.localized, image: UIImage(circle: e.color), handler: { [weak self] a in self?.editNode(a.sender, skin: e) }) })
        let skinItem = UIMenu(title: localizedString("skin"), image: UIImage(systemName: "face.dashed"), children: skinItems)
        let styleItems = HairStyle.allCases.map({ e in UIAction(title: e.localized, image: e.image, handler: { [weak self] a in self?.editNode(a.sender, gender: e) }) })
        let styleItem = UIMenu(title: localizedString("style"), image: UIImage(systemName: "scissors"), children: styleItems)
        let hairItems = HairColor.allCases.map({ e in UIAction(title: e.localized, image: UIImage(circle: e.color), handler: { [weak self] a in self?.editNode(a.sender, hair: e) }) })
        let hairItem = UIMenu(title: localizedString("hair"), image: UIImage(systemName: "paintbrush.pointed"), children: hairItems)
        let shirtItems = ShirtColor.allCases.map({ e in UIAction(title: e.localized, image: UIImage(circle: e.color), handler: { [weak self] a in self?.editNode(a.sender, shirt: e) }) })
        let shirtItem = UIMenu(title: localizedString("shirt"), image: UIImage(systemName: "paintbrush"), children: shirtItems)
        let nameItem = UIAction(title: localizedString("name"), image: UIImage(systemName: "signature"), handler: { [weak self] a in self?.editName(a.sender) })
        
        aMenu = UIMenu(title: "", children: [nameItem, skinItem, styleItem, hairItem, shirtItem, removeItem])
        tMenu = UIMenu(title: "", children: [typeItem, sizeItem, removeItem])
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scene.reloadNodes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startListening()
        NotificationCenter.default.addObserver(self, selector: #selector(stopListening), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startListening), name: UIApplication.didBecomeActiveNotification, object: nil)
     
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func startListening() {
        NotificationCenter.default.addObserver(self, selector: #selector(tickerDidTick), name: Service.tickerDidTickNotification, object: nil)
        tickerDidTick()
    }
    
    @objc private func stopListening() {
        NotificationCenter.default.removeObserver(self, name: Service.tickerDidTickNotification, object: nil)
        Service.isPaused = true
        pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    @objc private func tickerDidTick() {
        titleLabel.text = formattedTime(Service.ticks)
    }
    
    @IBAction private func editButtonPressed() {
        if !Service.isPaused { pauseButtonPressed() }
        scene.isEditing = !scene.isEditing
        editButton.setImage(UIImage(systemName: scene.isEditing ? "pencil.slash" : "pencil"), for: .normal)
    }
    
    @IBAction private func pauseButtonPressed() {
        if scene.isEditing { editButtonPressed() }
        Service.isPaused = !Service.isPaused
        pauseButton.setImage(UIImage(systemName: Service.isPaused ? "play.fill" : "pause.fill"), for: .normal)
    }
    
    private func askToReset() {
        let alert = UIAlertController(title: localizedString("reset"), message: localizedString("resetMessage"), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localizedString("ok"), style: .destructive, handler: { [weak self] _ in self?.reset() }))
        alert.addAction(UIAlertAction(title: localizedString("cancel"), style: .cancel, handler: nil))
        alert.view.tintColor = UIColor(named: "AccentColor")
        present(alert, animated: true, completion: nil)
    }
    
    private func reset() {
        pauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        Service.reset()
        scene.reloadNodes()
        tickerDidTick()
    }
    
    private func addActor(_ gender: HairStyle) {
        Service.addActor(gender: gender)
        scene.reloadNodes()
    }
    
    private func addTerrain(_ type: TerrainType) {
        Service.addTerrain(type: type)
        scene.reloadNodes()
        if !scene.isEditing { editButtonPressed() }
    }
    
    private func removeNode(_ sender: Any?) {
        guard let node = sender as? NSObject else { return }
        if let actor = aNodes.first(where: { $0.value == node })?.key {
            Service.removeActor(actor)
        }
        if let terrain = tNodes.first(where: { $0.value == node })?.key {
            Service.removeTerrain(terrain)
        }
        Service.saveModel()
        scene.reloadNodes()
    }
    
    private func editNode(_ sender: Any?, type: TerrainType? = nil, size: TerrainSize? = nil, shirt: ShirtColor? = nil, hair: HairColor? = nil, skin: SkinColor? = nil, gender: HairStyle? = nil) {
        guard let node = sender as? NSObject else { return }
        if let actor = aNodes.first(where: { $0.value == node })?.key {
            if let gender = gender { actor.hairStyle = gender }
            if let skin = skin { actor.skinColor = skin }
            if let hair = hair { actor.hairColor = hair }
            if let shirt = shirt { actor.shirtColor = shirt }
        }
        if let terrain = tNodes.first(where: { $0.value == node })?.key {
            if let type = type { terrain.type = type }
            if let size = size { terrain.scale = size }
        }
        Service.saveModel()
        scene.reloadNodes()
    }
    
    private func editName(_ sender: Any?) {
        guard let node = sender as? NSObject else { return }
        guard let actor = aNodes.first(where: { $0.value == node })?.key else { return }
        
        alert = UIAlertController(title: localizedString("name"), message: nil, preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: localizedString("ok"), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let name = self.alert?.textFields?[0].text else { return }
            actor.name = name
            Service.saveModel()
            self.scene.reloadNodes()
        }))
        alert?.addAction(UIAlertAction(title: localizedString("cancel"), style: .cancel, handler: nil))
        alert?.addTextField { [weak self] (textField) in
            guard let self = self else { return }
            textField.placeholder = localizedString("name")
            textField.text = actor.name
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange), for: .editingChanged)
            textField.autocapitalizationType = .sentences
            self.alertTextFieldDidChange()
        }
        alert?.view.tintColor = UIColor(named: "AccentColor")
        present(alert!, animated: true, completion: nil)
    }
    
    @objc private func alertTextFieldDidChange() {
        alert?.actions[0].isEnabled = (alert?.textFields?[0].text?.count ?? 0) > 0
    }
    
    private func export(with options: ExportType) {
        startLoading()
        Service.export(options) { [self] result in
            switch result {
            case .success(let url):
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activity.popoverPresentationController?.sourceView = shareButton
                present(activity, animated: true, completion: { [self] in stopLoading() })
            case .failure(let error):
                let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: localizedString("ok"), style: .cancel, handler: nil))
                present(alert, animated: true, completion: { [self] in stopLoading() })
            }
        }
    }
    
    func scene(_ scene: Scene, didChange groups: [Set<ANode>]) {
        let actors = groups.map({ $0.compactMap({ first in aNodes.first(where: { second in first == second.value })?.key }) })
        Service.addTransaction(actors)
        Service.saveModel()
    }
    
    func scene(_ scene: Scene, node: Node, didMoveTo location: CGPoint) {
        if let actor = aNodes.first(where: { $0.value == node })?.key {
            actor.centerX = Float(location.x / scene.bounds.width)
            actor.centerY = Float(location.y / scene.bounds.height)
        }
        if let terrain = tNodes.first(where: { $0.value == node })?.key {
            terrain.centerX = Float(location.x / scene.bounds.width)
            terrain.centerY = Float(location.y / scene.bounds.height)
        }
        Service.saveModel()
    }
    
    func scene(aNodesFor scene: Scene) -> [Set<ANode>] {
        aNodes = [:]
        
        for actor in Service.actors {
            let x = CGFloat(actor.centerX) * scene.bounds.width
            let y = CGFloat(actor.centerY) * scene.bounds.height
            aNodes[actor] = ANode(image: actor.image, title: actor.name, location: CGPoint(x: x, y: y), menu: aMenu)
        }
        
        return Service.lastGroups.map({ Set($0.compactMap({ aNodes[$0] })) })
    }
    
    func scene(tNodesFor scene: Scene) -> [TNode] {
        tNodes = [:]
        
        for terrain in Service.terrain {
            let x = CGFloat(terrain.centerX) * scene.bounds.width
            let y = CGFloat(terrain.centerY) * scene.bounds.height
            tNodes[terrain] = TNode(icon: terrain.type.icon, scale: CGFloat(terrain.scale.scale), location: CGPoint(x: x, y: y), menu: tMenu)
        }
        
        return tNodes.map({ $0.value })
    }
    
    private func startLoading() {
        activityIndicator.startAnimating()
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
                shareButton.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) { [self] in
                activityIndicator.alpha = 1
            }
        }
    }
    
    private func stopLoading() {
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [.calculationModeCubic]) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) { [self] in
                activityIndicator.alpha = 0
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) { [self] in
                shareButton.alpha = 1
            }
        } completion: { [self] _ in
            activityIndicator.stopAnimating()
        }
        
    }

}

