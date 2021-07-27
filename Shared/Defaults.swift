import Defaults

enum ListingLayout: String, CaseIterable, Identifiable, Defaults.Serializable {
    case list, cells

    var id: String {
        rawValue
    }

    var name: String {
        switch self {
        case .list:
            return "List"
        case .cells:
            return "Cells"
        }
    }
}

extension Defaults.Keys {
    #if os(tvOS)
        static let layout = Key<ListingLayout>("listingLayout", default: .cells)
    #endif
    static let searchQuery = Key<String>("searchQuery", default: "")

    static let searchSortOrder = Key<SearchQuery.SortOrder>("searchSortOrder", default: .relevance)
    static let searchDate = Key<SearchQuery.Date?>("searchDate")
    static let searchDuration = Key<SearchQuery.Duration?>("searchDuration")

    static let selectedPlaylistID = Key<String?>("selectedPlaylistID")
    static let showingAddToPlaylist = Key<Bool>("showingAddToPlaylist", default: false)
    static let videoIDToAddToPlaylist = Key<String?>("videoIDToAddToPlaylist")
}