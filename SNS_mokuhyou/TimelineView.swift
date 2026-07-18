import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query(sort: \Post.createdAt, order: .reverse) var posts: [Post]

    @State private var showNewPost = false   // 投稿画面を出すかどうか

    @Environment(\.modelContext) var context   // 構造体の上のほうに追加

    func deletePost(_ post: Post) {
        context.delete(post)   // 削除する
    }
    var body: some View {
        NavigationStack{
            ZStack {
                Color(red: 0.88, green: 0.92, blue: 0.98)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        NavigationLink{
                            MyAcountView(userdata: UserData(id: "1", userName: "T.A", accountID: "a"))
                        } label: {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 50))
                                .foregroundColor(Color.red)
                                .padding(.trailing, 20)
                        }
                    }
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 25) {
                            ForEach(posts) { post in
                                FeedCard(post: post, iconColor: .red,Userdata: UserData(id: "1", userName: "1", accountID: "1"))
                                    .contextMenu {                 // 長押しでメニューを出す
                                        Button(role: .destructive) {
                                            deletePost(post)
                                        } label: {
                                            Label("削除", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    Spacer()
                }
                
                @Environment(\.modelContext) var context   // 構造体の上のほうに追加
                
                
                // 「＋」ボタン
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showNewPost = true        // 押したら投稿画面を出す
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 30))
                                .foregroundColor(.black)
                                .frame(width: 70, height: 70)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 35)
                        .padding(.bottom, 95)
                    }
                }
            }
            // 投稿画面をシート（下からせり出す画面）で表示する
            .sheet(isPresented: $showNewPost) {
                NewPostView()
            }
        }
    }
}
#Preview {
    TimelineView()
        .modelContainer(for: Post.self, inMemory: true)
}
