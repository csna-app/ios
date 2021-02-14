import UIKit

@objc protocol SceneDelegate: class {
    @objc optional func scene(_ scene: Scene, didChange groups: [Set<ANode>])
    @objc optional func scene(aNodesFor scene: Scene) -> [Set<ANode>]
    @objc optional func scene(tNodesFor scene: Scene) -> [TNode]
    @objc optional func scene(_ scene: Scene, node: Node, didMoveTo location: CGPoint)
}

class Scene: UIView {
    
    var isEditing = false { didSet { editingDidChange() } }

    private var selectedNode: Node?
    
    private let proximityDistance = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(150) : CGFloat(75)
    private let clickDistance = CGFloat(5)
    private let feedback = UISelectionFeedbackGenerator()
    private var groups: [Set<ANode>] = []
    
    private var actorNodes: [ANode] { return subviews.compactMap({ $0 as? ANode }) }
    private var terrainNodes: [TNode] { return subviews.compactMap({ $0 as? TNode }) }
    private var lineNodes: [LNode] { return subviews.compactMap({ $0 as? LNode }) }
    
    @IBOutlet weak var delegate: SceneDelegate?
    
    //TODO: bug when rotating if line is at max range it sometimes dissapears
    
    func reloadNodes() {
        subviews.forEach({ $0.removeFromSuperview() })
        groups = delegate?.scene?(aNodesFor: self) ?? []
        groups.flatMap({ $0 }).forEach({ addSubview($0) })
        delegate?.scene?(tNodesFor: self).forEach({ insertSubview($0, at: 0) })
        actorNodes.forEach { updateConnections($0, haptics: false) }
        editingDidChange()
    }
    
    private func nodes(at location: CGPoint) -> [UIView] {
        return subviews.filter({ $0.frame.contains(location) })
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: self) else { return }
        guard let node = nodes(at: location).last as? Node else { return }
        if !isEditing && node is ANode { node.startWiggle() }
        selectedNode = node
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        moveNode(with: touches.first)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        moveNode(with: touches.first)
        commitMove()
        selectedNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        moveNode(with: touches.first)
        commitMove()
        selectedNode = nil
    }
    
    private func moveNode(with touch: UITouch?) {
        guard let location = touch?.location(in: self) else { return }
        guard let node = selectedNode else { return }
        if node is ANode && isEditing { return }
        if node is TNode && !isEditing { return }
        let x = min(max(node.frame.width*0.5, location.x), bounds.size.width-node.frame.width*0.5)
        let y = min(max(node.frame.height*0.5, location.y), bounds.size.height-node.frame.height*0.5)
        node.center = CGPoint(x: x, y: y)
        if let node = node as? ANode { updateConnections(node) }
        node.setNeedsLayout()
    }
    
    private func updateConnections(_ node: ANode, haptics: Bool = true) {
        let connections = lineNodes.filter { $0.contains(node) }
        let closeNodes = actorNodes.filter({ $0 != node }).filter({ $0.center.distance(to: node.center) < proximityDistance })
        
        let toRemove = connections.filter { !$0.contains(where: closeNodes.contains) }
        let toUpdate = connections.filter { $0.contains(where: closeNodes.contains) }
        let toAdd = closeNodes.filter { node in !connections.contains(where: { $0.contains(node) }) }
        
        if (!toRemove.isEmpty || !toAdd.isEmpty) && haptics {
            feedback.selectionChanged()
        }
        
        toRemove.forEach { $0.removeFromSuperview() }
        toUpdate.forEach { $0.updatePath() }
        toAdd.forEach { addSubview(LNode($0, node)) }
    }
    
    private func commitMove() {
        guard let node = selectedNode else { return }
        
        let proximities = actorNodes.map { first in actorNodes.filter { second in first.center.distance(to: second.center) < proximityDistance } }
        let newGroups = proximities.reduce(into: [], { $0 = $1.mergeOne($0) }).map { Set($0) }

        if Set(groups) != Set(newGroups) {
            delegate?.scene?(self, didChange: newGroups)
            groups = newGroups
        }
        
        if node is ANode { node.stopWiggle() }
        delegate?.scene?(self, node: node, didMoveTo: node.center)
    }
    
    private func editingDidChange() {
        let wiggleNodes = actorNodes + terrainNodes
        if isEditing {
            selectedNode = nil
            wiggleNodes.forEach({ $0.startWiggle() })
            lineNodes.forEach(({ $0.isHidden = true }))
            wiggleNodes.forEach({ $0.isUserInteractionEnabled = true })
        } else {
            wiggleNodes.forEach({ $0.stopWiggle() })
            lineNodes.forEach(({ $0.isHidden = false }))
            wiggleNodes.forEach({ $0.isUserInteractionEnabled = false })
        }
    }
}

