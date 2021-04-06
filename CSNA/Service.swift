import UIKit
import Algorithms

fileprivate let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("model.json")

class Service {
    private static let shared = Service()
    
    private var model: Model
    
    private var ticker: Timer?
    private var isPaused = true
    
    private init() {
        do {
            let data = try Data(contentsOf: url, options: .mappedIfSafe)
            model = try JSONDecoder().decode(Model.self, from: data)
        } catch {
            model = Model()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopTicker), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTicker), name: UIApplication.willEnterForegroundNotification, object: nil)
        startTicker()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func startTicker() {
        ticker?.invalidate()
        ticker = Timer(timeInterval: 1, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { timer.invalidate(); return }
            self.tickerDidTick()
        })
        RunLoop.current.add(ticker!, forMode: .common)
        
    }
    
    @objc private func stopTicker() {
        ticker?.invalidate()
        ticker = nil
    }

    
    private func tickerDidTick() {
        if isPaused { return }
        model.tick()
        if model.ticks % 10 == 0 { saveModel() }
        NotificationCenter.default.post(Notification(name: Service.tickerDidTickNotification))
    }
    
    private func saveModel() {
        guard let data = try? JSONEncoder().encode(model) else { return }
        try? data.write(to: url, options: .atomicWrite)
    }
    
    
    
    static let tickerDidTickNotification = Notification.Name(rawValue: "tickerDidTickNotification")
    
    static var isPaused: Bool {
        get { return shared.isPaused }
        set { shared.isPaused = newValue }
    }
    
    static var ticks: Int { return shared.model.ticks }
    static var actors: [Actor] { return Array(shared.model.actors).sorted(by: { $0.id > $1.id }) }
    static var terrain: [Terrain] { return Array(shared.model.terrains).sorted(by: { $0.id > $1.id }) }
    static var lastGroups: [[Actor]]  { return shared.model.transactions.last?.map { $0.compactMap { shared.model.getActor($0) } } ?? [] }
    
    static func addActor(gender: HairStyle) {
        let actor = Actor(sex: gender)
        shared.model.add(actor: actor)
        addTransaction(lastGroups + [[actor]])
        shared.saveModel()
    }
    
    static func addTerrain(type: TerrainType) {
        shared.model.add(terrain: Terrain(terrainType: type))
        shared.saveModel()
    }

    static func removeActor(_ actor: Actor) {
        shared.model.remove(actor: actor)
        shared.saveModel()
    }
    
    static func removeTerrain(_ terrain: Terrain) {
        shared.model.remove(terrain: terrain)
        shared.saveModel()
    }

    static func addTransaction(_ actors: [[Actor]]) {
        shared.model.add(transaction: actors, time: ticks)
    }

    static func reset() {
        shared.isPaused = true
        shared.model = Model()
        shared.saveModel()
    }
    
    static func saveModel() {
        shared.saveModel()
    }
    
    static func export(_ type: ExportType, completion: @escaping ((Result<URL, Error>) -> Void)) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let temp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                let url = temp.appendingPathComponent(type.filename)
                guard let data = type.convert(shared.model) else { throw CocoaError.error(.coderInvalidValue) }
                try data.write(to: url)
                DispatchQueue.main.async { completion(.success(url)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}


@objc enum ExportType: Int, CaseIterable {
    case txt, csvGroup, json, csvActor
    
    fileprivate func convert(_ model: Model) -> Data? {
        let values = model.transactions.mapValues({ model.getActorNames($0) }).sorted(by: { $0.key < $1.key })
        switch self {
        case .txt:
            let string = values.map({ "\($0.0): \($0.1)" }).joined(separator: "\n")
            return string.data(using: .utf8)
        case .csvGroup:
            let string = values.map({ "\($0.0),\($0.1.map({ $0.joined(separator: ";") }).joined(separator: ","))" }).joined(separator: "\n")
            return string.data(using: .utf8)
        case .json:
            let dict = values.reduce(into: [:], { $0["\($1.key)"] = $1.value  })
            return try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
        case .csvActor:
            let string = values.flatMap({ el in el.value.flatMap({ $0.combinations(ofCount: 2).map({ "\(el.key),\($0[0]),\($0[1])" }) }) }).joined(separator: "\n")
            return string.data(using: .utf8)
        }
    }
    
    fileprivate var filename: String {
        var name = ISO8601DateFormatter().string(from: Date())
        switch self {
        case .txt: name.append(".txt")
        case .csvGroup, .csvActor: name.append(".csv")
        case .json: name.append(".json")
        }
        return name
    }
    
    var icon: UIImage? {
        switch self {
        case .txt: return UIImage(systemName: "doc.plaintext")
        case .csvGroup, .csvActor: return UIImage(systemName: "chart.bar.doc.horizontal")
        case .json: return UIImage(systemName: "doc.badge.gearshape")
        }
    }
    
    var name: String { return localizedString("export\(rawValue)")}
}
