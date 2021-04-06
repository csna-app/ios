import UIKit

extension UIColor {
    convenience init(hex: String) {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let hashtag = trimmed.replacingOccurrences(of: "#", with: "")
        let str = hashtag.uppercased()
        
        var (r, g, b, a) = (CGFloat(0), CGFloat(0), CGFloat(0), CGFloat(1))
        
        var colorRep: UInt64 = 0
        Scanner(string: str).scanHexInt64(&colorRep)
        
        if str.count == 3 {
            r = CGFloat((colorRep & 0xF00) >> 8) / 15
            g = CGFloat((colorRep & 0x0F0) >> 4) / 15
            b = CGFloat(colorRep & 0x00F) / 15
        } else if str.count == 4 {
            r = CGFloat((colorRep & 0xF000) >> 12) / 15
            g = CGFloat((colorRep & 0x0F00) >> 8) / 15
            b = CGFloat((colorRep & 0x00F0) >> 4) / 15
            a = CGFloat(colorRep & 0x000F) / 15
        } else if str.count == 6 {
            r = CGFloat((colorRep & 0xFF0000) >> 16) / 255
            g = CGFloat((colorRep & 0x00FF00) >> 8) / 255
            b = CGFloat(colorRep & 0x0000FF) / 255
        } else if str.count == 8 {
            r = CGFloat((colorRep & 0xFF000000) >> 24) / 255
            g = CGFloat((colorRep & 0x00FF0000) >> 16) / 255
            b = CGFloat((colorRep & 0x0000FF00) >> 8) / 255
            a = CGFloat(colorRep & 0x000000FF) / 255
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    func darken(by factor: CGFloat) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        return UIColor(red: r - factor, green: g - factor, blue: b - factor, alpha: a)
    }
}

extension UIImage {
    convenience init?(circle color: UIColor, diameter: CGFloat = 36) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            context.cgContext.setFillColor(color.cgColor)
            let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
            context.cgContext.fillEllipse(in: rect)
        }
        guard let cg = image.cgImage else { return nil }
        self.init(cgImage: cg)
    }
}

extension UIImage {
    
    convenience init?(hairStyle: HairStyle, hairColor: HairColor, skinColor: SkinColor? = nil, shirtColor: ShirtColor? = nil, size: CGFloat = 50) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            context.cgContext.setLineWidth(0.01*size)
            context.cgContext.setStrokeColor(UIColor.black.cgColor)
            
            if let skinColor = skinColor?.color, let head1Path = Styles["headPart1"], let head2Path = Styles["headPart2"] {
                context.cgContext.setFillColor(skinColor.cgColor)
                let head1 = UIBezierPath(from: head1Path, scale: size)
                context.cgContext.addPath(head1.cgPath)
                context.cgContext.drawPath(using: .fill)

                context.cgContext.setFillColor(skinColor.darken(by: 0.1).cgColor)
                let head2 = UIBezierPath(from: head2Path, scale: size)
                context.cgContext.addPath(head2.cgPath)
                context.cgContext.drawPath(using: .fill)
            }

            if let shirtColor = shirtColor?.color, let shirtPath = Styles["shirt"] {
                context.cgContext.setFillColor(shirtColor.cgColor)
                let shirt = UIBezierPath(from: shirtPath, scale: size)
                context.cgContext.addPath(shirt.cgPath)
                context.cgContext.drawPath(using: .fill)
            }
            
            if let stylePath1 = Styles["style\(hairStyle.rawValue)"] {
                context.cgContext.setFillColor(hairColor.color.cgColor)
                let hair1 = UIBezierPath(from: stylePath1, scale: size)
                context.cgContext.addPath(hair1.cgPath)
                context.cgContext.drawPath(using: .fillStroke)
            }
 
            if let stylePath2 = Styles["style\(hairStyle.rawValue)part2"] {
                context.cgContext.setFillColor(hairColor.color.darken(by: 0.1).cgColor)
                let hair2 = UIBezierPath(from: stylePath2, scale: size)
                context.cgContext.addPath(hair2.cgPath)
                context.cgContext.drawPath(using: .fillStroke)
            }

        }
        guard let cg = image.cgImage else { return nil }
        self.init(cgImage: cg)
    }
}

extension UIBezierPath {
    
    convenience init(from string: String, scale: CGFloat = 1) {
        self.init()
        var svg = string
        
        while !svg.isEmpty {
            let instruction = svg.removeFirst()
            let end = svg.firstIndex(where: { $0.isLetter }) ?? svg.endIndex
            let range = svg.startIndex..<end
            let params = parameterExtract(String(svg[range])).map({ $0 * scale })
            switch instruction {
            case "m": params.chunked(into: 2).forEach { move(to: rel(x: $0[0], y: $0[1])) }
            case "M": params.chunked(into: 2).forEach { move(to: abs(x: $0[0], y: $0[1])) }
            case "z", "Z": close()
            case "l": params.chunked(into: 2).forEach { addLine(to: rel(x: $0[0], y: $0[1])) }
            case "L": params.chunked(into: 2).forEach { addLine(to: abs(x: $0[0], y: $0[1])) }
            case "h": params.chunked(into: 1).forEach { addLine(to: rel(x: $0[0])) }
            case "H": params.chunked(into: 1).forEach { addLine(to: abs(x: $0[0])) }
            case "v": params.chunked(into: 1).forEach { addLine(to: rel(y: $0[0])) }
            case "V": params.chunked(into: 1).forEach { addLine(to: abs(y: $0[0])) }
            case "c": params.chunked(into: 6).forEach { addCurve(to: rel(x: $0[4], y: $0[5]), controlPoint1: rel(x: $0[0], y: $0[1]), controlPoint2: rel(x: $0[2], y: $0[3])) }
            case "C": params.chunked(into: 6).forEach { addCurve(to: abs(x: $0[4], y: $0[5]), controlPoint1: abs(x: $0[0], y: $0[1]), controlPoint2: abs(x: $0[2], y: $0[3])) }
            default: break
            }
            svg.removeSubrange(range)
        }
    }
    
    private func abs(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
        return CGPoint(x: x ?? currentPoint.x, y: y ?? currentPoint.y)
    }
    
    private func rel(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
        return CGPoint(x: currentPoint.x + (x ?? 0), y: currentPoint.y + (y ?? 0))
    }
    
    
    private func parameterExtract(_ string: String) -> [CGFloat] {
        var parameters: [CGFloat] = []
        var current = ""
        for character in string {
            if character == "," || character == "-" || character == " " || (character == "." && current.contains(".")) {
                if let float = Float(current) { parameters.append(CGFloat(float)) }
                current = ""
                if character == "," || character == " " { continue }
            }
            current.append(character)
        }
        if let float = Float(current) { parameters.append(CGFloat(float)) }
        
        return parameters
    }
    
}

let Styles: [String: String] = {
    guard let url = Bundle.main.url(forResource: "Styles", withExtension: "json") else { return [:] }
    guard let data = try? Data(contentsOf: url) else { return [:] }
    guard let styles = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else { return [:] }
    return styles
}()


