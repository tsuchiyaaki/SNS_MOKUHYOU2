import SwiftUI

struct FeedCard: View {

    let post: Post                 // Post データを受け取る
    let iconColor: Color
    let Userdata : UserData 
    var body: some View {

        

        VStack(alignment: .leading, spacing: 20) {

            HStack {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                    .foregroundColor(iconColor)

                
                Text(Userdata.userName)       
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)

                Spacer()
            }
            HStack{
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
                        .overlay(
                            Text(post.subject)    // 「一日の歩数」→ post.subject
                                .font(.system(size: 30, weight: .bold))
                        )
                    Text("が")
                        .font(.title)
                    Spacer()
                }

                HStack {
                    Spacer()
                    Capsule()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 250, height: 80)
                        .overlay(
                            Text(post.change)     // 「3倍」→ post.change
                                .font(.system(size: 32, weight: .bold))
                        )
                    Spacer()
                }

                HStack {
                    Spacer()
                    Text(post.selectedchange)
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
    // Preview用のサンプル投稿を渡す
    FeedCard(
        post: Post(subject: "一日の歩数", change: "3倍", selectedDate: "a",selectedchange: "a"),
        iconColor: .red,Userdata: UserData(id: "1", userName: "T.A", accountID: "1")
    )
}
