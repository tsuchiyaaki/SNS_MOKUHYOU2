import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var postStore: PostStore

    @State private var searchText = ""
    @State private var selectedScope: SearchScope = .all

    private enum SearchScope: String, CaseIterable, Identifiable {
        case all = "すべて"
        case content = "投稿内容"
        case author = "投稿者"

        var id: Self { self }
    }

    private var searchWords: [String] {
        normalized(searchText)
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)
    }

    private var filteredPosts: [Post] {
        guard !searchWords.isEmpty else { return [] }

        return postStore.posts.filter { post in
            let searchableText: String

            switch selectedScope {
            case .all:
                searchableText = [
                    post.authorName,
                    post.subject,
                    post.change,
                    post.selectedDate,
                    post.selectedChange
                ].joined(separator: " ")
            case .content:
                searchableText = [
                    post.subject,
                    post.change,
                    post.selectedDate,
                    post.selectedChange
                ].joined(separator: " ")
            case .author:
                searchableText = post.authorName
            }

            let normalizedText = normalized(searchableText)
            return searchWords.allSatisfy(normalizedText.contains)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.88, green: 0.92, blue: 0.98)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Picker("検索範囲", selection: $selectedScope) {
                    ForEach(SearchScope.allCases) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                searchContent
            }
            .padding(.top, 8)
        }
        .navigationTitle("投稿を検索")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "例：歩数、3倍、ゲスト"
        )
    }

    @ViewBuilder
    private var searchContent: some View {
        if searchWords.isEmpty {
            Spacer()
            ContentUnavailableView(
                "投稿を検索",
                systemImage: "magnifyingglass",
                description: Text("投稿者名や目標の内容を入力してください")
            )
            Spacer()
        } else if filteredPosts.isEmpty {
            Spacer()
            ContentUnavailableView.search(text: searchText)
            Spacer()
        } else {
            HStack {
                Text("検索結果：\(filteredPosts.count)件")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 20) {
                    ForEach(filteredPosts) { post in
                        FeedCard(post: post, iconColor: .red)
                            .contextMenu {
                                if post.authorID == authManager.userID {
                                    Button(role: .destructive) {
                                        Task {
                                            await postStore.deletePost(post)
                                        }
                                    } label: {
                                        Label("削除", systemImage: "trash")
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
    }

    private func normalized(_ text: String) -> String {
        text.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: .current
        )
    }
}

