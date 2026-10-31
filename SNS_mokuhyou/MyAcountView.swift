import SwiftUI

struct MyAcountView: View {
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var userStore: UserStore
    @EnvironmentObject private var postStore: PostStore

    private var myPosts: [Post] {
        guard let userID = authManager.userID else { return [] }
        return postStore.posts.filter { $0.authorID == userID }
    }

    var body: some View {
        ZStack {
            Color(red: 0.88, green: 0.92, blue: 0.98)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 100))
                        .foregroundColor(.red)

                    Text(userStore.currentUser?.userName ?? "読込中…")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)

                    Text("@\(userStore.currentUser?.accountID ?? "")")
                        .foregroundStyle(.secondary)

                    if let bio = userStore.currentUser?.bio, !bio.isEmpty {
                        Text(bio)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Text("自分の投稿：\(myPosts.count)件")
                        .foregroundStyle(.secondary)

                    NavigationLink {
                        ProfileEditView()
                    } label: {
                        Label("プロフィールを編集", systemImage: "pencil")
                    }
                    .buttonStyle(.bordered)

                    VStack(spacing: 12) {
                        NavigationLink {
                            BlockedUsersView()
                        } label: {
                            Label("ブロック管理", systemImage: "person.crop.circle.badge.xmark")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        NavigationLink {
                            TermsOfServiceView()
                        } label: {
                            Label("利用規約・コミュニティルール", systemImage: "doc.text")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        NavigationLink {
                            SupportView()
                        } label: {
                            Label("お問い合わせ・安全", systemImage: "questionmark.circle")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)

                    Divider()
                        .background(Color.black.opacity(0.2))

                    if myPosts.isEmpty {
                        ContentUnavailableView(
                            "自分の投稿はまだありません",
                            systemImage: "person.crop.circle.badge.questionmark"
                        )
                    } else {
                        VStack(spacing: 25) {
                            ForEach(myPosts) { post in
                                ModeratedPostCard(post: post, iconColor: .red)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("マイページ")
        .navigationBarTitleDisplayMode(.inline)
    }
}
