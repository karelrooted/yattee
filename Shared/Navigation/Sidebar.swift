import SwiftUI

struct Sidebar: View {
    @EnvironmentObject<AccountsModel> private var accounts
    @EnvironmentObject<NavigationModel> private var navigation

    var body: some View {
        ScrollViewReader { scrollView in
            List {
                mainNavigationLinks

                AppSidebarRecents()
                    .id("recentlyOpened")

                if accounts.signedIn {
                    AppSidebarSubscriptions()
                    AppSidebarPlaylists()
                }
            }
            .onChange(of: navigation.sidebarSectionChanged) { _ in
                scrollScrollViewToItem(scrollView: scrollView, for: navigation.tabSelection)
            }
            .listStyle(.sidebar)
        }
    }

    var mainNavigationLinks: some View {
        Section("Videos") {
            NavigationLink(destination: LazyView(WatchNowView()), tag: TabSelection.watchNow, selection: $navigation.tabSelection) {
                Label("Watch Now", systemImage: "play.circle")
                    .accessibility(label: Text("Watch Now"))
            }

            if accounts.signedIn {
                NavigationLink(destination: LazyView(SubscriptionsView()), tag: TabSelection.subscriptions, selection: $navigation.tabSelection) {
                    Label("Subscriptions", systemImage: "star.circle")
                        .accessibility(label: Text("Subscriptions"))
                }
            }

            NavigationLink(destination: LazyView(PopularView()), tag: TabSelection.popular, selection: $navigation.tabSelection) {
                Label("Popular", systemImage: "chart.bar")
                    .accessibility(label: Text("Popular"))
            }

            NavigationLink(destination: LazyView(TrendingView()), tag: TabSelection.trending, selection: $navigation.tabSelection) {
                Label("Trending", systemImage: "chart.line.uptrend.xyaxis")
                    .accessibility(label: Text("Trending"))
            }

            NavigationLink(destination: LazyView(SearchView()), tag: TabSelection.search, selection: $navigation.tabSelection) {
                Label("Search", systemImage: "magnifyingglass")
                    .accessibility(label: Text("Search"))
            }
            .keyboardShortcut("f")
        }
    }

    func scrollScrollViewToItem(scrollView: ScrollViewProxy, for selection: TabSelection) {
        if case .recentlyOpened = selection {
            scrollView.scrollTo("recentlyOpened")
        } else if case let .playlist(id) = selection {
            scrollView.scrollTo(id)
        }
    }
}