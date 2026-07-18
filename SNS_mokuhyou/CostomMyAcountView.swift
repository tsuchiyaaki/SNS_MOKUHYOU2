//
//  CostomMyAcountView.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/04.
//
import SwiftUI

struct CostomMyAcountView :View{
     
    @State private var name = "T.A"
    @State private var bio = ""
    @State private var birthDate = Date()
    
    var body: some View {
        VStack {
            
            // 上のバー
            HStack {
                
                Spacer()
                
                Text("Title")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button {
                    // 保存処理
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)
            .frame(height: 130)
            
         
            
            // プロフィール画像エリア
            HStack {
                Image(systemName: "person.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                    .padding(.leading, 28)
                
                Spacer()
            }
            .frame(height: 80)
            
            Divider()
            
            // 名前
            HStack {
                Text("名前")
                    .font(.title3)
                    .bold()
                    .frame(width: 120, alignment: .leading)
                
                TextField("", text: $name)
                    .font(.system(size: 34, weight: .bold))
            }
            .padding(.horizontal, 40)
            .frame(height: 70)
            
            Divider()
            
            // 自己紹介
            HStack(alignment: .top) {
                Text("自己紹介")
                    .font(.title3)
                    .bold()
                    .frame(width: 120, alignment: .leading)
                
                TextField("", text: $bio, axis: .vertical)
                    .font(.title3)
            }
            .padding(.horizontal, 40)
            .padding(.top, 25)
            .frame(height: 140)
            
            Divider()
            
            // 生年月日
            HStack {
                Text("生年月日")
                    .font(.title3)
                    .bold()
                    .frame(width: 150, alignment: .leading)
                
                DatePicker(
                    "",
                    selection: $birthDate,
                    displayedComponents: .date
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .frame(height: 90)
            
            Spacer()
        }
        .background(Color.white)
    }
}
    
#Preview {
    CostomMyAcountView()
}
