//
//  ErrorView.swift
//  XIVE
//
//  Created by 나현흠 on 5/22/24.
//

import SwiftUI

struct ErrorView: View {
    @State private var navigateToSetting = false
    @State private var showTicketDetail = false
    @State private var showAlert = false
    @State private var nfcButtonOffset: CGFloat = 0.0
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var nfcViewModel = NFCViewModel()
    @State private var ticketData: [[String: Any]] = []

    var body: some View {
        ErrorView
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light) // 라이트 모드로 고정
    }

    private var ErrorView: some View {
        NavigationView {
            VStack(spacing: 0) {
                setupNavigationBar()
                    .padding(.bottom, 130)

                Image("Warning_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 115, height: 90)
                    .padding(.top, 10)
                    .tracking(-0.02)
                
                VStack {
                    Text("현재 접속이 원활하지 않아요.")
                        .font(.system(size: 22))
                        .padding(.top, 20)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                        .tracking(-0.02)
                    Text("          ")
                        .font(.system(size: 10))

                    Text("일시적인 오류로 서비스에 접속할 수 없습니다. \n 잠시 후 다시 시도해주세요.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .tracking(-0.02)
                        .foregroundColor(.gray)
                }
                
                submitButton
                    .padding(.top, 40)
                VStack{
                    NavigationLink(destination: OneToOneView()) {
                        Text("다시 시도")
                            .tracking(-0.02)
                            .underline()
                            .foregroundStyle(Color.XIVE_Purple)
                    }
                    .padding(25)
                    .multilineTextAlignment(.center)
                }
                
                Spacer()
                
            }
            .background(Color.white) // 배경색을 흰색으로 고정
        }
    }
    
    @ViewBuilder
    private func setupNavigationBar() -> some View {
        HStack {
            Button(action: {
                self.navigateToSetting = true
            }) {
                Image("back_arrow")
            }
            .background(
                NavigationLink(destination: SettingView(), isActive: $navigateToSetting) {
                    EmptyView()
                }
                .hidden()
            )
            .frame(alignment: .leading)
            
            Spacer()
            
            Text("      ")

            
            Spacer()
            
            Text("      ")
        }
        .padding()
        .background(VStack {
            Spacer()
            Divider().background(Color.secondary)
        })
    }
    
    private var submitButton: some View {
        NavigationLink(destination: HomeView()) {
            Button("홈으로 돌아가기") {
            }
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(Color.black)
            .cornerRadius(10)
            .padding(.horizontal, 40)
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
