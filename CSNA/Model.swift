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
    override var description: String { return "\(name)\(icon.rawValue)" }
    
    let id: String
    var icon: Icon
    var name: String
    var centerX: Float
    var centerY: Float
    
    
    init(_ position: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        id = UUID().uuidString
        icon = Icon.allCases.randomElement() ?? .a0
        name = String(localizedString("unisexNames").split(separator: ",").randomElement() ?? "")
        centerX = Float(position.x)
        centerY = Float(position.y)
    }
    
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

enum TerrainSize: Float, Codable, CaseIterable {
    case tiny = 2, small = 4, medium = 6, large = 8, huge = 10, extreme = 12
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

enum Icon: String, Codable, CaseIterable  {
    case a0 = "👶", a1 = "🧒", a2 = "👦", a3 = "👧", a4 = "🧑", a5 = "👨", a6 = "👩", a7 = "🧑‍🦱", a8 = "👨‍🦱", a9 = "👩‍🦱", a10 = "🧑‍🦰", a11 = "👨‍🦰", a12 = "👩‍🦰", a13 = "👱", a14 = "👱‍♂️", a15 = "👱‍♀️", a16 = "🧑‍🦳", a17 = "👩‍🦳", a18 = "👨‍🦳", a19 = "👨‍🦲", a20 = "🧑‍🦲", a21 = "👩‍🦲", a22 = "🧔", a23 = "🧓", a24 = "👴", a25 = "👵"
    case b0 = "👶🏻", b1 = "🧒🏻", b2 = "👦🏻", b3 = "👧🏻", b4 = "🧑🏻", b5 = "👨🏻", b6 = "👩🏻", b7 = "🧑🏻‍🦱", b8 = "👨🏻‍🦱", b9 = "👩🏻‍🦱", b10 = "🧑🏻‍🦰", b11 = "👨🏻‍🦰", b12 = "👩🏻‍🦰", b13 = "👱🏻", b14 = "👱🏻‍♂️", b15 = "👱🏻‍♀️", b16 = "🧑🏻‍🦳", b17 = "👩🏻‍🦳", b18 = "👨🏻‍🦳", b19 = "🧑🏻‍🦲", b20 = "👨🏻‍🦲", b21 = "👩🏻‍🦲", b22 = "🧔🏻", b23 = "🧓🏻", b24 = "👴🏻", b25 = "👵🏻"
    case c0 = "👶🏼", c1 = "🧒🏼", c2 = "👦🏼", c3 = "👧🏼", c4 = "🧑🏼", c5 = "👨🏼", c6 = "👩🏼", c7 = "🧑🏼‍🦱", c8 = "👨🏼‍🦱", c9 = "👩🏼‍🦱", c10 = "🧑🏼‍🦰", c11 = "👨🏼‍🦰", c12 = "👩🏼‍🦰", c13 = "👱🏼", c14 = "👱🏼‍♂️", c15 = "👱🏼‍♀️", c16 = "🧑🏼‍🦳", c17 = "👩🏼‍🦳", c18 = "👨🏼‍🦳", c19 = "🧑🏼‍🦲", c20 = "👨🏼‍🦲", c21 = "👩🏼‍🦲", c22 = "🧔🏼", c23 = "🧓🏼", c24 = "👴🏼", c25 = "👵🏼"
    case d0 = "👶🏽", d1 = "🧒🏽", d2 = "👦🏽", d3 = "👧🏽", d4 = "🧑🏽", d5 = "👨🏽", d6 = "👩🏽", d7 = "🧑🏽‍🦱", d8 = "👨🏽‍🦱", d9 = "👩🏽‍🦱", d10 = "🧑🏽‍🦰", d11 = "👨🏽‍🦰", d12 = "👩🏽‍🦰", d13 = "👱🏽", d14 = "👱🏽‍♂️", d15 = "👱🏽‍♀️", d16 = "🧑🏽‍🦳", d17 = "👩🏽‍🦳", d18 = "👨🏽‍🦳", d19 = "🧑🏽‍🦲", d20 = "👨🏽‍🦲", d21 = "👩🏽‍🦲", d22 = "🧔🏽", d23 = "🧓🏽", d24 = "👴🏽", d25 = "👵🏽"
    case e0 = "👶🏾", e1 = "🧒🏾", e2 = "👦🏾", e3 = "👧🏾", e4 = "🧑🏾", e5 = "👨🏾", e6 = "👩🏾", e7 = "🧑🏾‍🦱", e8 = "👨🏾‍🦱", e9 = "👩🏾‍🦱", e10 = "🧑🏾‍🦰", e11 = "👨🏾‍🦰", e12 = "👩🏾‍🦰", e13 = "👱🏾", e14 = "👱🏾‍♂️", e15 = "👱🏾‍♀️", e16 = "🧑🏾‍🦳", e17 = "👩🏾‍🦳", e18 = "👨🏾‍🦳", e19 = "🧑🏾‍🦲", e20 = "👨🏾‍🦲", e21 = "👩🏾‍🦲", e22 = "🧔🏾", e23 = "🧓🏾", e24 = "👴🏾", e25 = "👵🏾"
    case f0 = "👶🏿", f1 = "🧒🏿", f2 = "👦🏿", f3 = "👧🏿", f4 = "🧑🏿", f5 = "👨🏿", f6 = "👩🏿", f7 = "🧑🏿‍🦱", f8 = "👨🏿‍🦱", f9 = "👩🏿‍🦱", f10 = "🧑🏿‍🦰", f11 = "👨🏿‍🦰", f12 = "👩🏿‍🦰", f13 = "👱🏿", f14 = "👱🏿‍♂️", f15 = "👱🏿‍♀️", f16 = "🧑🏿‍🦳", f17 = "👩🏿‍🦳", f18 = "👨🏿‍🦳", f19 = "🧑🏿‍🦲", f20 = "👨🏿‍🦲", f21 = "👩🏿‍🦲", f22 = "🧔🏿", f23 = "🧓🏿", f24 = "👴🏿", f25 = "👵🏿"
}
