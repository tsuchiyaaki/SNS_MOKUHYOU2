//
//  ContentView.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/05/23.
//
import SwiftUI

struct TimelineView: View {
    var body: some View {
        ZStack {
            Color(red: 0.88, green: 0.92, blue: 0.98)
                .ignoresSafeArea()

            VStack(spacing: 20) {

               
                HStack {
                    Spacer()

                    Button{
                        
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 50))
                            .foregroundColor(Color.red)
                            .padding(.trailing, 20)
                    }
                }

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 25) {

                        FeedCard(
                            name: "T.A",
                            iconColor: .red
                        )

                        FeedCard(
                            name: "ひらけー",
                            iconColor: .black
                        )
                    }
                    .padding(.horizontal)
                }

                Spacer()

               
              
            }

         
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Button {

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
    }
    
}





#Preview {
TimelineView()
}
