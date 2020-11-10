//
//  View.swift
//  CSNA
//
//  Created by Wilhelm Thieme on 06/11/2020.
//

import SpriteKit

@objc protocol SceneTransactionDelegate: class {
    @objc optional func scene(_ scene: Scene, didChange groups: [[Actor]])
}

fileprivate let actorNodeName = "ActorNode"
fileprivate let lineNodeName = "LineNode"

class Scene: SKScene {

    private var selectedNode: Node?
    
    private let proximityDistance = UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(150) : CGFloat(75)
    private let feedback = UISelectionFeedbackGenerator()
    private var groups: [Set<Node>] = []
    
    private var actorNodes: [Node] { return children.filter({ $0.name == actorNodeName }).compactMap({ $0 as? Node }) }
    private var lineNodes: [Line] { return children.filter({ $0.name == lineNodeName }).compactMap({ $0 as? Line }) }
    
    weak var transactionDelegate: SceneTransactionDelegate?
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        backgroundColor = UIColor.systemBackground
        scaleMode = .resizeFill
    }
    
   
    func traitCollectionsDidChange(to traitCollections: UITraitCollection) {
        backgroundColor = UIColor.systemBackground
    }

    private func addActors() {
        Service.actors.forEach { addChild(Node(actor: $0, parentSize: size)) }
        groups = Service.lastGroups.map { Set($0.compactMap { actor in actorNodes.first(where: { $0.actor == actor }) }) }
        actorNodes.forEach { updateConnections($0, haptics: false) }
    }
    
    func reloadActors() {
        removeAllChildren()
        addActors()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let location = touches.first?.location(in: self) else { return }
        guard let node = nodes(at: location).last as? Node else { return }
        guard node.name == actorNodeName else { return }
        selectedNode = node
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        moveNode(with: touches.first)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        moveNode(with: touches.first)
        commitGroups()
        Service.saveModel()
        selectedNode = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        moveNode(with: touches.first)
        commitGroups()
        Service.saveModel()
        selectedNode = nil
    }
    
    
    private func moveNode(with touch: UITouch?) {
        guard let location = touch?.location(in: self) else { return }
        guard let node = selectedNode else { return }
        let x = min(max(25, location.x), size.width-25)
        let y = min(max(40, location.y), size.height-25)
        node.position = CGPoint(x: x, y: y)
        node.actor.centerX = Float(x / frame.width)
        node.actor.centerY = Float(y / frame.height)
        updateConnections(node)
    }
    
    private func updateConnections(_ node: Node, haptics: Bool = true) {
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
        toAdd.forEach { addChild(Line($0, node)) }
    }
    
    private func commitGroups() {
        let proximities = actorNodes.map { first in actorNodes.filter { second in first.position.distance(to: second.position) < proximityDistance } }
        let newGroups = proximities.reduce(into: [], { $0 = $1.mergeOne($0) }).map { Set($0) }

        if Set(groups) != Set(newGroups) {
            transactionDelegate?.scene?(self, didChange: newGroups.map({ $0.map { $0.actor } }))
            groups = newGroups
        }
    }
    
}


fileprivate class Node: SKNode {
    
    private let iconNode = SKLabelNode(fontNamed: "Helvetica")
    private let nameNode = SKLabelNode(fontNamed: "Helvetica")
    
    let actor: Actor
    
    init(actor: Actor, parentSize: CGSize) {
        self.actor = actor
        super.init()
        name = "ActorNode"
        
        let x = CGFloat(actor.centerX) * parentSize.width
        let y = CGFloat(actor.centerY) * parentSize.height
        position = CGPoint(x: x, y: y)
        zPosition = 1
        
        iconNode.text = actor.icon.rawValue
        iconNode.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.labelFontSize * 3 : UIFont.labelFontSize
        iconNode.verticalAlignmentMode = .center
        iconNode.horizontalAlignmentMode = .center
        iconNode.position = CGPoint(x: 0, y: 0)
        addChild(iconNode)

        nameNode.text = actor.name
        nameNode.fontColor = UIColor.label
        nameNode.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.systemFontSize : UIFont.smallSystemFontSize
        nameNode.verticalAlignmentMode = .center
        nameNode.horizontalAlignmentMode = .center
        nameNode.position = CGPoint(x: 0, y: UIDevice.current.userInterfaceIdiom == .pad ? -35 : -15)
        addChild(nameNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class Line: SKShapeNode {
    
    let firstNode: Node
    let secondNode: Node
    
    init(_ node1: Node, _ node2: Node) {
        firstNode = node1
        secondNode = node2
        super.init()
        name = lineNodeName
        strokeColor = UIColor.systemGray4
        lineWidth = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 4
        
        updatePath()
    }
    
    func updatePath() {
        let bezier = UIBezierPath()
        bezier.move(to: firstNode.position)
        bezier.addLine(to: secondNode.position)
        path = bezier.cgPath
    }
    
    func contains(_ node: Node) -> Bool {
        return firstNode == node || secondNode == node
    }
    
    func contains(where block: ((Node) -> Bool)) -> Bool {
        return block(firstNode) || block(secondNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

