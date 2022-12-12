import Cache
import Foundation
import Logging
import SwiftyJSON

struct FeedCacheModel: CacheModel {
    static let shared = FeedCacheModel()
    static let limit = 30
    let logger = Logger(label: "stream.yattee.cache.feed")

    static let diskConfig = DiskConfig(name: "feed")
    static let memoryConfig = MemoryConfig()

    let storage = try? Storage<String, JSON>(
        diskConfig: Self.diskConfig,
        memoryConfig: Self.memoryConfig,
        transformer: BaseCacheModel.jsonTransformer
    )

    func storeFeed(account: Account, videos: [Video]) {
        let date = iso8601DateFormatter.string(from: Date())
        logger.info("caching feed \(account.feedCacheKey) -- \(date)")
        let feedTimeObject: JSON = ["date": date]
        let videosObject: JSON = ["videos": videos.prefix(Self.limit).map { $0.json.object }]
        try? storage?.setObject(feedTimeObject, forKey: feedTimeCacheKey(account.feedCacheKey))
        try? storage?.setObject(videosObject, forKey: account.feedCacheKey)
    }

    func retrieveFeed(account: Account) -> [Video] {
        logger.info("retrieving cache for \(account.feedCacheKey)")

        if let json = try? storage?.object(forKey: account.feedCacheKey),
           let videos = json.dictionaryValue["videos"]
        {
            return videos.arrayValue.map { Video.from($0) }
        }

        return []
    }

    func getFeedTime(account: Account) -> Date? {
        if let json = try? storage?.object(forKey: feedTimeCacheKey(account.feedCacheKey)),
           let string = json.dictionaryValue["date"]?.string,
           let date = iso8601DateFormatter.date(from: string)
        {
            return date
        }

        return nil
    }

    private func feedTimeCacheKey(_ feedCacheKey: String) -> String {
        "\(feedCacheKey)-feedTime"
    }
}
