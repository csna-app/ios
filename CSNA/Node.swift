import SpriteKit

class Node: SKNode {
    
    func startWiggle() {
        let wiggleIn = SKAction.rotate(byAngle: -0.05, duration: 0.1)
        let wiggleMid = SKAction.rotate(byAngle: 0.1, duration: 0.2)
        let wiggleOut = SKAction.rotate(byAngle: -0.05, duration: 0.1)
        let wiggle = SKAction.sequence([wiggleIn, wiggleMid, wiggleOut])
        
        run(SKAction.repeatForever(wiggle), withKey: "wiggle")
    }
    
    func stopWiggle() {
        zRotation = 0
        removeAction(forKey: "wiggle")
    }
    
}

class ANode: Node {
    static let name = "ActorNode"
    
    private let iconNode = SKLabelNode(fontNamed: "Helvetica")
    private let nameNode = SKLabelNode(fontNamed: "Helvetica")
    
    init(icon: String, title: String, location: CGPoint) {
        super.init()
        name = ANode.name
        
        position = location
        zPosition = 2
        
        iconNode.text = icon
        iconNode.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.labelFontSize * 3 : UIFont.labelFontSize
        iconNode.verticalAlignmentMode = .center
        iconNode.horizontalAlignmentMode = .center
        iconNode.position = CGPoint(x: 0, y: 0)
        addChild(iconNode)

        nameNode.text = title
        nameNode.fontColor = UIColor.label
        nameNode.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.systemFontSize : UIFont.smallSystemFontSize
        nameNode.verticalAlignmentMode = .center
        nameNode.horizontalAlignmentMode = .center
        nameNode.position = CGPoint(x: 0, y: UIDevice.current.userInterfaceIdiom == .pad ? -35 : -15)
        addChild(nameNode)

    }
    
    func traitCollectionsDidChange(to traitCollections: UITraitCollection) {
        nameNode.fontColor = UIColor.label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TNode: Node {
    static let name = "TerrainNode"
    
    private let iconNode = SKSpriteNode()
    
    init(icon: String, scale: CGFloat, location: CGPoint) {
        super.init()
        name = TNode.name
        
        position = location
        zPosition = 0
        
        let config = UIImage.SymbolConfiguration(pointSize: UIFont.labelFontSize*scale, weight: .thin)
        guard let image = UIImage(systemName: icon)?.applyingSymbolConfiguration(config) else { return }
        let texture = SKTexture(image: image).applying(CIFilter(name: "CIColorInvert")!)
        iconNode.texture = texture
        iconNode.position = CGPoint(x: 0, y: 0)
        iconNode.colorBlendFactor = 1
        iconNode.color = .systemGray2
        iconNode.size = CGSize(width: image.size.width, height: image.size.height)
        addChild(iconNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func traitCollectionsDidChange(to traitCollections: UITraitCollection) {
        iconNode.color = UIColor.systemGray2
    }
    
}

class LNode: SKShapeNode {
    static let name = "LineNode"
    
    let firstNode: ANode
    let secondNode: ANode
    
    init(_ node1: ANode, _ node2: ANode) {
        firstNode = node1
        secondNode = node2
        super.init()
        name = LNode.name
        zPosition = 1
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
    
    func contains(_ node: ANode) -> Bool {
        return firstNode == node || secondNode == node
    }
    
    func contains(where block: ((ANode) -> Bool)) -> Bool {
        return block(firstNode) || block(secondNode)
    }
    
    func traitCollectionsDidChange(to traitCollections: UITraitCollection) {
        strokeColor = UIColor.systemGray4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

