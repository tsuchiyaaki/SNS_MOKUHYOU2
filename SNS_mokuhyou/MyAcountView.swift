import SwiftUI
import SwiftData

struct MyAcountView: View {
    private let userName: String = "T.A"

    // 保存された投稿を新しい順に読み込む
    @Query(sort: \Post.createdAt, order: .reverse) var posts: [Post]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.88, green: 0.92, blue: 0.98)
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Button {
                            } label: {
                                Image(systemName: "pencil.line")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.9))
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .padding(.horizontal, 30)
                        }
                        VStack {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 100))
                                .foregroundColor(.red)
                            Text(userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }

                        Divider()
                            .background(Color.black.opacity(0.2))

                        VStack(spacing: 25) {
                            // 保存された投稿を並べる
                            ForEach(posts) { post in
                                FeedCard(post: post, iconColor: .red)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    MyAcountView()
        .modelContainer(for: Post.self, inMemory: true)
}
