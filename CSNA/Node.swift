import UIKit

class Node: UIButton {
    
    init(context: UIMenu) {
        super.init(frame: .zero)
        menu = context
        isUserInteractionEnabled = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesCancelled(touches, with: event)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startWiggle() {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.values = [0, -0.05, 0, 0.05, 0]
        animation.duration = 0.4
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "wiggle")
    }

    func stopWiggle() {
        layer.removeAnimation(forKey: "wiggle")
    }
    
}

class ANode: Node {
    
    private let iconView = UIImageView()
    private let nameView = UILabel()
    
    init(image: UIImage?, title: String, location: CGPoint, menu: UIMenu) {
        super.init(context: menu)
        let dim = UIDevice.current.userInterfaceIdiom == .pad ? 50 : 30
        layer.zPosition = 2
        
        iconView.image = image
        iconView.frame.size = CGSize(width: dim, height: dim)

        nameView.text = title
        nameView.font = UIFont.systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? UIFont.systemFontSize : UIFont.smallSystemFontSize)
        nameView.textAlignment = .center
        nameView.sizeToFit()

        frame.size = CGSize(width: max(iconView.frame.width, nameView.frame.width), height: iconView.frame.height + nameView.frame.height)
        
        addSubview(iconView)
        nameView.center = CGPoint(x: bounds.width*0.5, y: iconView.center.y + iconView.bounds.height*0.5 + nameView.bounds.height*0.5)
        addSubview(nameView)
        
        center = location

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TNode: Node {
    
    private let iconView = UIImageView()
    
    init(icon: String, scale: CGFloat, location: CGPoint, menu: UIMenu) {
        super.init(context: menu)
        let config = UIImage.SymbolConfiguration(pointSize: UIFont.labelFontSize*scale, weight: .thin)
        guard let image = UIImage(systemName: icon)?.applyingSymbolConfiguration(config) else { return }
        
        frame.size = image.size
        
        layer.zPosition = 0
    
        iconView.image = image
        iconView.frame.size = image.size
        iconView.tintColor = UIColor.systemGray2
        addSubview(iconView)
        
        center = location
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class LNode: UIView {
    static let name = "LineNode"
    
    let firstNode: ANode
    let secondNode: ANode
    private let shapeLayer = CAShapeLayer()
    
    init(_ node1: ANode, _ node2: ANode) {
        firstNode = node1
        secondNode = node2
        super.init(frame: .zero)
        
        layer.zPosition = 1

        shapeLayer.strokeColor = UIColor.systemGray4.cgColor
        shapeLayer.lineWidth = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 4
        
        layer.addSublayer(shapeLayer)
        updatePath()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        shapeLayer.strokeColor = UIColor.systemGray4.cgColor
    }
    
    func updatePath() {
        let bezier = UIBezierPath()
        bezier.move(to: firstNode.center)
        bezier.addLine(to: secondNode.center)
        shapeLayer.path = bezier.cgPath
    }
    
    func contains(_ node: ANode) -> Bool {
        return firstNode == node || secondNode == node
    }
    
    func contains(where block: ((ANode) -> Bool)) -> Bool {
        return block(firstNode) || block(secondNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

