import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private init() {}
    
    func save<T: Codable>(_ object: T, to fileName: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            try data.write(to: url)
            print("Data saved to \(fileName).")
        } catch {
            print("Failed to save data: \(error.localizedDescription)")
        }
    }
    
    func load<T: Codable>(_ fileName: String, as type: T.Type) -> T? {
        let decoder = JSONDecoder()
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: url)
            let object = try decoder.decode(type, from: data)
            print("Data loaded from \(fileName).")
            return object
        } catch {
            print("Failed to load data: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
