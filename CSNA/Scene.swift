import SpriteKit

@objc protocol SceneTransactionDelegate: class {
    @objc optional func scene(_ scene: Scene, didChange groups: [Set<ANode>])
    @objc optional func scene(aNodesFor scene: Scene) -> [Set<ANode>]
    @objc optional func scene(tNodesFor scene: Scene) -> [TNode]
    @objc optional func scene(_ scene: Scene, node: Node, didMoveTo location: CGPoint)
    @objc optional func scene(_ scene: Scene, showContextMenuFor node: Node)
}

class Scene: SKScene {
    
    var isEditing = false { didSet { editingDidChange() } }

    private var selectedNode: Node?
    private var lastLocation: CGPoint?
    private var distanceTraveled = CGFloat(0)
    
    private let proximityDistance = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(150) : CGFloat(75)
    private let clickDistance = CGFloat(5)
    private let feedback = UISelectionFeedbackGenerator()
    private var groups: [Set<ANode>] = []
    
    private var actorNodes: [ANode] { return children.filter({ $0.name == ANode.name }).compactMap({ $0 as? ANode }) }
    private var terrainNodes: [TNode] { return children.filter({ $0.name == TNode.name }).compactMap({ $0 as? TNode }) }
    private var lineNodes: [LNode] { return children.filter({ $0.name == LNode.name }).compactMap({ $0 as? LNode }) }
    
    weak var delegate: SceneTransactionDelegate?
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        backgroundColor = UIColor.systemBackground
        scaleMode = .resizeFill
    }
   
    func traitCollectionsDidChange(to traitCollections: UITraitCollection) {
        backgroundColor = UIColor.systemBackground
        actorNodes.forEach({ $0.traitCollectionsDidChange(to: traitCollections) })
        terrainNodes.forEach({ $0.traitCollectionsDidChange(to: traitCollections) })
        lineNodes.forEach({ $0.traitCollectionsDidChange(to: traitCollections) })
    }
    
    func reloadNodes() {
        removeAllChildren()
        groups = transactionDelegate?.scene?(aNodesFor: self) ?? []
        groups.flatMap({ $0 }).forEach({ addChild($0) })
        transactionDelegate?.scene?(tNodesFor: self).forEach({ addChild($0) })
        actorNodes.forEach { updateConnections($0, haptics: false) }
        editingDidChange()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: self) else { return }
        guard let node = nodes(at: location).last as? Node else { return }
        if !isEditing && node is ANode { node.startWiggle() }
        selectedNode = node
        lastLocation = location
        distanceTraveled = 0
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        moveNode(with: touches.first)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        moveNode(with: touches.first)
        openContextIfNeeded()
        commitMove()
        selectedNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        moveNode(with: touches.first)
        openContextIfNeeded()
        commitMove()
        selectedNode = nil
    }
    
    private func moveNode(with touch: UITouch?) {
        guard let location = touch?.location(in: self) else { return }
        guard let node = selectedNode else { return }
        guard let last = lastLocation else { return }
        distanceTraveled += location.distance(to: last)
        lastLocation = location
        if node is ANode && isEditing { return }
        if node is TNode && !isEditing { return }
        let x = min(max(25, location.x), size.width-25)
        let y = min(max(40, location.y), size.height-25)
        node.position = CGPoint(x: x, y: y)
        if let node = node as? ANode { updateConnections(node) }
    }
    
    private func updateConnections(_ node: ANode, haptics: Bool = true) {
        let connections = lineNodes.filter { $0.contains(node) }
        let closeNodes = actorNodes.filter({ $0 != node }).filter({ $0.position.distance(to: node.position) < proximityDistance })
        
        let toRemove = connections.filter { !$0.contains(where: closeNodes.contains) }
        let toUpdate = connections.filter { $0.contains(where: closeNodes.contains) }
        let toAdd = closeNodes.filter { node in !connections.contains(where: { $0.contains(node) }) }
        
        if (!toRemove.isEmpty || !toAdd.isEmpty) && haptics {
            feedback.selectionChanged()
        }
        
        toRemove.forEach { $0.removeFromParent() }
        toUpdate.forEach { $0.updatePath() }
        toAdd.forEach { addChild(LNode($0, node)) }
    }
    
    private func commitMove() {
        guard let node = selectedNode else { return }
        
        let proximities = actorNodes.map { first in actorNodes.filter { second in first.position.distance(to: second.position) < proximityDistance } }
        let newGroups = proximities.reduce(into: [], { $0 = $1.mergeOne($0) }).map { Set($0) }

        if Set(groups) != Set(newGroups) {
            transactionDelegate?.scene?(self, didChange: newGroups)
            groups = newGroups
        }
        
        if node is ANode { node.stopWiggle() }
        transactionDelegate?.scene?(self, node: node, didMoveTo: node.position)
    }
    
    private func openContextIfNeeded() {
        guard isEditing else { return }
        guard let node = selectedNode else { return }
        guard distanceTraveled < clickDistance else { return }
        transactionDelegate?.scene?(self, showContextMenuFor: node)
    }
    
    private func editingDidChange() {
        if isEditing {
            selectedNode = nil
            terrainNodes.forEach({ $0.startWiggle() })
            lineNodes.forEach(({ $0.isHidden = true }))
        } else {
            terrainNodes.forEach({ $0.stopWiggle() })
            lineNodes.forEach(({ $0.isHidden = false }))
        }
    }
}

