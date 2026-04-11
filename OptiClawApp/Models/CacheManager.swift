import Foundation

final class CacheManager {
    
    // MARK: - Shared Instance
    static let shared = CacheManager()
    
    // MARK: - Properties
    private let cacheQueue = DispatchQueue(label: "com.cacheManager.queue", attributes: .concurrent)
    private var cache: [String: CachedValue] = [:]
    
    // File URL for saving the cache to disk
    private let cacheFileURL: URL = {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("CacheManager.cache")
    }()
    
    // MARK: - Initializer
    private init() {
        // Load cache from disk when the app launches
        loadCacheFromDisk()
    }
    
    // MARK: - Public Methods
    func set<T: Codable>(key: String, value: T, expiry: TimeInterval = 0) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            let expiryDate = expiry > 0 ? Date().addingTimeInterval(expiry) : .distantFuture
            self.cache[key] = CachedValue(value: value, expiry: expiryDate)
            // Save the updated cache to disk
            self.saveCacheToDisk()
        }
    }
    
    func get<T: Codable>(key: String) -> T? {
        return cacheQueue.sync { [weak self] in
            guard let self = self,
                  let cachedValue = self.cache[key],
                  cachedValue.expiry > Date() else {
                // Remove expired or invalid entries from the cache.
                self?.cache.removeValue(forKey: key)
                self?.saveCacheToDisk()
                return nil
            }
            return cachedValue.getValue() // No need to force-cast here as the method already returns `T?`
        }
    }
    
    func removeExpiredEntries() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.cache = self.cache.filter { $0.value.expiry > Date() }
            // Save the updated cache to disk
            self.saveCacheToDisk()
        }
    }
    
    func remove(key: String) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.cache.removeValue(forKey: key)
            // Save the updated cache to disk
            self.saveCacheToDisk()
        }
    }
    
    // MARK: - Private Methods
    
    /// Saves the current cache to disk.
    private func saveCacheToDisk() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            do {
                // Encode the cache to Data
                let data = try JSONEncoder().encode(self.cache)
                // Write the data to the cache file
                try data.write(to: self.cacheFileURL, options: .atomic)
            } catch {
                print("Failed to save cache to disk: \(error)")
            }
        }
    }
    
    /// Loads the cache from disk.
    private func loadCacheFromDisk() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            do {
                // Read the data from the cache file
                let data = try Data(contentsOf: self.cacheFileURL)
                // Decode the data into the cache dictionary
                let decodedCache = try JSONDecoder().decode([String: CachedValue].self, from: data)
                // Filter out expired entries
                self.cache = decodedCache.filter { $0.value.expiry > Date() }
            } catch {
                print("Failed to load cache from disk: \(error)")
            }
        }
    }
    
    // MARK: - CachedValue Enum
    
    /// Represents a cached value with an expiry date.
    private enum CachedValue: Codable {
        case string(String, expiry: Date)
        case int(Int, expiry: Date)
        case double(Double, expiry: Date)
        case bool(Bool, expiry: Date)
        case data(Data, expiry: Date)
        case dictionary([String: String], expiry: Date)
        case codable(Data, expiry: Date) // For generic Codable types
        
        var value: Any {
            switch self {
            case .string(let value, _):
                return value
            case .int(let value, _):
                return value
            case .double(let value, _):
                return value
            case .bool(let value, _):
                return value
            case .data(let value, _):
                return value
            case .dictionary(let value, _):
                return value
            case .codable(let data, _):
                return data
            }
        }
        
        var expiry: Date {
            switch self {
            case .string(_, let expiry),
                    .int(_, let expiry),
                    .double(_, let expiry),
                    .bool(_, let expiry),
                    .data(_, let expiry),
                    .dictionary(_, let expiry),
                    .codable(_, let expiry):
                return expiry
            }
        }
        
        init<T: Codable>(value: T, expiry: Date) {
            if let stringValue = value as? String {
                self = .string(stringValue, expiry: expiry)
            } else if let intValue = value as? Int {
                self = .int(intValue, expiry: expiry)
            } else if let doubleValue = value as? Double {
                self = .double(doubleValue, expiry: expiry)
            } else if let boolValue = value as? Bool {
                self = .bool(boolValue, expiry: expiry)
            } else if let dataValue = value as? Data {
                self = .data(dataValue, expiry: expiry)
            } else if let dictionaryValue = value as? [String: String] {
                self = .dictionary(dictionaryValue, expiry: expiry)
            } else {
                // For generic Codable types, encode to Data
                let data = try! JSONEncoder().encode(value)
                self = .codable(data, expiry: expiry)
            }
        }
        
        func getValue<T: Codable>() -> T? {
            switch self {
            case .string(let value, _):
                return value as? T
            case .int(let value, _):
                return value as? T
            case .double(let value, _):
                return value as? T
            case .bool(let value, _):
                return value as? T
            case .data(let value, _):
                return value as? T
            case .dictionary(let value, _):
                return value as? T
            case .codable(let data, _):
                return try? JSONDecoder().decode(T.self, from: data)
            }
        }
    }
}
