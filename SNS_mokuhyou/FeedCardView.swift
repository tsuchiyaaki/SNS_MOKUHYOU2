import SwiftUI

struct FeedCard: View {
    let post: Post
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                    .foregroundColor(iconColor)

                Text(post.authorName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                Spacer()
            }

            HStack {
                Text(post.selectedDate)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("から")
            }

            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 250, height: 80)
                        .overlay {
                            Text(post.subject)
                                .font(.system(size: 30, weight: .bold))
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .padding()
                        }
                    Text("が")
                        .font(.title)
                    Spacer()
                }

                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 250, height: 80)
                        .overlay {
                            Text(post.change)
                                .font(.system(size: 32, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .padding()
                        }
                    Spacer()
                }

                HStack {
                    Spacer()
                    Text(post.selectedChange)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}

#Preview {
    FeedCard(
        post: Post(
            id: "preview",
            authorName: "T.A",
            subject: "一日の歩数",
            change: "3倍",
            selectedDate: "一週間",
            selectedChange: "増えた",
            authorID: "preview-user"
        ),
        iconColor: .red
    )
    .padding()
    .background(Color(red: 0.88, green: 0.92, blue: 0.98))
}
