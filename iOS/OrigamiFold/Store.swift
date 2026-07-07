import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 30

    @Published var items: [Fold] = []
    @Published var enabledCategories: Set<String> = ["All"]

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("origamifold", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([Fold].self, from: data) else {
            items = Self.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL)
    }

    func canAddMore(isPro: Bool) -> Bool {
        isPro || items.count < Self.freeLimit
    }

    @discardableResult
    func add(_ item: Fold, isPro: Bool) -> Bool {
        guard canAddMore(isPro: isPro) else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: Fold) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(id: UUID) {
        items.removeAll { $0.id == id }
        save()
    }

    static func seedData() -> [Fold] {
        [
            Fold(title: "Crane", paperType: "Washi", difficulty: "Medium"),
            Fold(title: "Lily", paperType: "Kami", difficulty: "Easy"),
            Fold(title: "Dragon", paperType: "Foil", difficulty: "Hard")
        ]
    }
}
