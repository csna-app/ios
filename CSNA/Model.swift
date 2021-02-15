import UIKit

class Model: NSObject, Codable {
    private(set) var ticks: Int
    private(set) var actors: Set<Actor>
    private(set) var terrains: Set<Terrain>
    private var removedActors: Set<Actor>
    private(set) var transactions: [Int: [[String]]]
    
    override init() {
        ticks = 0
        actors = [Actor(CGPoint(x: 0.35, y: 0.65)), Actor(CGPoint(x: 0.5, y: 0.8)), Actor(CGPoint(x: 0.65, y: 0.65)), Actor(CGPoint(x: 0.65, y: 0.35)), Actor(CGPoint(x: 0.5, y: 0.2)), Actor(CGPoint(x: 0.35, y: 0.35))]
        terrains = []
        transactions = [0: actors.map { [$0.id] }]
        removedActors = []
    }
    
    func tick() {
        ticks += 1
    }
    
    func add(terrain: Terrain) {
        terrains.insert(terrain)
    }
    
    func add(actor: Actor) {
        actors.insert(actor)
    }
    
    func remove(actor: Actor) {
        guard actors.contains(actor) else { return }
        actors.remove(actor)
        removedActors.insert(actor)
    }
    
    func remove(terrain: Terrain) {
        terrains.remove(terrain)
    }
    
    func add(transaction groups: [[Actor]], time: Int) {
        transactions[time] = groups.map { $0.map { $0.id } }
    }
    
    func getActor(_ id: String) -> Actor? { return actors.first { $0.id == id } ?? removedActors.first { $0.id == id } ?? nil }
    func getActorNames(_ id: [[String]]) -> [[String]] { return id.map { $0.compactMap { getActor($0)?.name } } }
}

class Actor: NSObject, Codable {
    static func == (lhs: Actor, rhs: Actor) -> Bool { return lhs.id == rhs.id }
    override var description: String { return "\(name)" }
    
    let id: String
    var skinColor: SkinColor
    var hairColor: HairColor
    var shirtColor: ShirtColor
    var hairStyle: HairStyle
    var name: String
    var centerX: Float
    var centerY: Float
    
    var image: UIImage? { return UIImage(hairStyle: hairStyle, hairColor: hairColor, skinColor: skinColor, shirtColor: shirtColor) }
    
    init(sex: HairStyle? = nil, _ position: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        id = UUID().uuidString
        skinColor = SkinColor.allCases.randomElement() ?? .silk
        hairColor = HairColor.allCases.randomElement() ?? .auburn
        shirtColor = ShirtColor.allCases.randomElement() ?? .black
        hairStyle = sex ?? HairStyle.allCases.randomElement() ?? .one
        name = String(localizedString("unisexNames").split(separator: ",").randomElement() ?? "")
        centerX = Float(position.x)
        centerY = Float(position.y)
    }
    
}

enum SkinColor: Int, Codable, CaseIterable {
    case silk, lumber, peach, eggshell, spice, sienna, oak, clay, coffee
    
    var color: UIColor {
        switch self {
        case .silk: return UIColor(hex: "#ffe2c9")
        case .eggshell: return UIColor(hex: "#e4bdad")
        case .lumber: return UIColor(hex: "#ffd6c5")
        case .peach: return UIColor(hex: "#ffcba3")
        case .spice: return UIColor(hex: "#e7b38d")
        case .sienna: return UIColor(hex: "#d8905f")
        case .oak: return UIColor(hex: "#be794a")
        case .clay: return UIColor(hex: "#88513a")
        case .coffee: return UIColor(hex: "#733e26")
        }
    }
    
    var localized: String { return localizedString("skin\(rawValue)") }
}

enum HairColor: Int, Codable, CaseIterable {
    case ebony, chocolate, cinnamon, hazelnut, chesnut, pecan, ginger, blonde, sand, apricot, fire, auburn, copper, walnut, mist, silver, platinum, onyx
    
    var color: UIColor {
        switch self {
        case .ebony: return UIColor(hex: "#282c34")
        case .chocolate: return UIColor(hex: "#3c1321")
        case .cinnamon: return UIColor(hex: "#805b48")
        case .hazelnut: return UIColor(hex: "#8f6553")
        case .chesnut: return UIColor(hex: "#b6834f")
        case .pecan: return UIColor(hex: "#a68966")
        case .ginger: return UIColor(hex: "#97653c")
        case .blonde: return UIColor(hex: "#d1b094")
        case .sand: return UIColor(hex: "#fde38d")
        case .apricot: return UIColor(hex: "#f8b878")
        case .fire: return UIColor(hex: "#c25133")
        case .auburn: return UIColor(hex: "#a15843")
        case .copper: return UIColor(hex: "#73372d")
        case .walnut: return UIColor(hex: "#d5c6b7")
        case .mist: return UIColor(hex: "#bdc8bc")
        case .silver: return UIColor(hex: "#b5b5bd")
        case .platinum: return UIColor(hex: "#e0dccb")
        case .onyx: return UIColor(hex: "#000000")
        }
    }
    
    var localized: String { return localizedString("hair\(rawValue)") }
}

enum ShirtColor: Int, Codable, CaseIterable {
    case blue, green, indigo, orange, pink, purple, red, teal, yellow, white, black
    
    var color: UIColor {
        switch self {
        case .blue: return UIColor(hex: "#0a84ff")
        case .green: return UIColor(hex: "#30d158")
        case .indigo: return UIColor(hex: "#5e5ce6")
        case .orange: return UIColor(hex: "#ff9f0a")
        case .pink: return UIColor(hex: "#ff375f")
        case .purple: return UIColor(hex: "#bf5af2")
        case .red: return UIColor(hex: "#ff453a")
        case .teal: return UIColor(hex: "#64d2ff")
        case .yellow: return UIColor(hex: "#ffd60a")
        case .white: return UIColor(hex: "#e5e5ea")
        case .black: return UIColor(hex: "#2c2c2e")
        }
    }
    
    var localized: String { return localizedString("shirt\(rawValue)") }
}

enum HairStyle: Int, Codable, CaseIterable {
    case one, two, three, four, five, six, seven, eight, nine, ten, eleven, twelve, thriteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen, twenty, twentyone, twentytwo, twentythree, twentyfour, twentyfive, twentysix, twentyseven, twentyeight, twentynine, thirty, thirtyone
    
    var image: UIImage? { return UIImage(hairStyle: self, hairColor: .onyx) }
    var localized: String { return localizedString("style\(rawValue)") }
}


class Terrain: NSObject, Codable {
    let id: String
    var type: TerrainType
    var centerX: Float
    var centerY: Float
    var scale: TerrainSize
    
    init(terrainType: TerrainType, _ position: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        id = UUID().uuidString
        centerX = Float(position.x)
        centerY = Float(position.y)
        type = terrainType
        scale = .small
    }
}

enum TerrainSize: Int, Codable, CaseIterable {
    case tiny, small, medium, large, huge, extreme
    
    var icon: String {
        switch self {
        case .tiny: return "0.circle"
        case .small: return "1.circle"
        case .medium: return "2.circle"
        case .large: return "3.circle"
        case .huge: return "4.circle"
        case .extreme: return "5.circle"
        }
    }
    
    var scale: Int { rawValue*2 + 4 }
    var localized: String { return localizedString("size\(rawValue)") }
}

enum TerrainType: Int, Codable, CaseIterable {
    case bookcase, wardrobe, building, temple, bed, tv, computer, radio, guitars, game, paint, rectangle, circle
    
    var icon: String {
        switch self {
        case .bookcase: return "books.vertical"
        case .wardrobe: return "tablecells"
        case .building: return "building.2"
        case .temple: return "building.columns"
        case .bed: return "bed.double"
        case .tv: return "tv"
        case .computer: return "desktopcomputer"
        case .radio: return "radio"
        case .guitars: return "guitars"
        case .game: return "gamecontroller"
        case .paint: return "paintpalette"
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        }
    }
    
    var localized: String { return localizedString("terrain\(rawValue)")}
}
