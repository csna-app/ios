import SpriteKit

class Controller: UIViewController, SceneTransactionDelegate {

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var addButton: UIButton!
    @IBOutlet private weak var editButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var mainView: SKView!
    private let scene = Scene()
    
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
        let shareMenu = UIMenu(title: "", children: shareItems)

        shareButton.menu = shareMenu
        shareButton.showsMenuAsPrimaryAction = true
        
        let actorImage = UIImage(systemName: "person.crop.circle.badge.plus")
        let addActor = UIAction(title: localizedString("addActor"), image: actorImage, handler: { [weak self] _ in self?.addActor()  })
        let terrainImage = UIImage(systemName: "apps.iphone.badge.plus")
        let terrainItems = TerrainType.allCases.map({ e in UIAction(title: e.localized, image: UIImage(systemName: e.icon), handler: { [weak self] _ in self?.addTerrain(e) }) })
        let addTerrain = UIMenu(title: localizedString("addTerrain"), image: terrainImage, children: terrainItems)
        let addMenu = UIMenu(title: "", children: [addActor, addTerrain])
        
        addButton.menu = addMenu
        addButton.showsMenuAsPrimaryAction = true

        scene.transactionDelegate = self
        mainView.presentScene(scene)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if scene.size == mainView.frame.size { return }
        scene.size = mainView.frame.size
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        scene.traitCollectionsDidChange(to: traitCollection)
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
    
    private func addActor() {
        Service.addActor()
        scene.reloadNodes()
    }
    
    private func addTerrain(_ type: TerrainType) {
        Service.addTerrain(type: type)
        scene.reloadNodes()
        if !scene.isEditing { editButtonPressed() }
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
            actor.centerX = Float(location.x / scene.size.width)
            actor.centerY = Float(location.y / scene.size.height)
        }
        if let terrain = tNodes.first(where: { $0.value == node })?.key {
            terrain.centerX = Float(location.x / scene.size.width)
            terrain.centerY = Float(location.y / scene.size.height)
        }
        Service.saveModel()
    }
    
    func scene(aNodesFor scene: Scene) -> [Set<ANode>] {
        aNodes = [:]
        
        for actor in Service.actors {
            let x = CGFloat(actor.centerX) * scene.size.width
            let y = CGFloat(actor.centerY) * scene.size.height
            aNodes[actor] = ANode(icon: actor.icon.rawValue, title: actor.name, location: CGPoint(x: x, y: y))
        }
        
        return Service.lastGroups.map({ Set($0.compactMap({ aNodes[$0] })) })
    }
    
    func scene(tNodesFor scene: Scene) -> [TNode] {
        tNodes = [:]
        
        for terrain in Service.terrain {
            let x = CGFloat(terrain.centerX) * scene.size.width
            let y = CGFloat(terrain.centerY) * scene.size.height
            tNodes[terrain] = TNode(icon: terrain.type.icon, scale: CGFloat(terrain.scale.rawValue), location: CGPoint(x: x, y: y))
        }
        
        return tNodes.map({ $0.value })
    }
    
    func scene(_ scene: Scene, showContextMenuFor node: Node) {
        if let actor = aNodes.first(where: { $0.value == node })?.key {
            node.
        }
        if let terrain = tNodes.first(where: { $0.value == node })?.key {
            terrain.scale = .huge
            scene.reloadNodes()
        }
        print(node)
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

