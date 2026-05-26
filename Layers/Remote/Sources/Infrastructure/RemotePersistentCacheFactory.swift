import Foundation
import InnoNetwork
import InnoNetworkPersistentCache

enum RemotePersistentCacheFactory {
    static func make() -> (any ResponseCache)? {
        guard let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }

        let directory = cachesDirectory
            .appendingPathComponent("InnoSample", isDirectory: true)
            .appendingPathComponent("RemoteHTTPCache", isDirectory: true)

        return try? PersistentResponseCache(
            configuration: PersistentResponseCacheConfiguration(
                directoryURL: directory,
                maxBytes: 25 * 1024 * 1024,
                maxEntries: 500
            )
        )
    }
}
