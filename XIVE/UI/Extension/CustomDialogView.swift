//
//  CustomDialogView.swift
//  XIVE
//
//  Created by 나현흠 on 5/19/24.
//

import Foundation
import SwiftUI

struct CustomDialog: View {
    @Binding var isActive: Bool
    @Binding var shouldNavigateToLogin: Bool

    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> ()
    @State private var offset: CGFloat = 1000

    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.5)
                .onTapGesture {
                    close()
                }

            VStack {
                Text(title)
                    .font(.title2)
                    .bold()
                    
                    .padding(.bottom, 5)
                    .tracking(-0.02)
                    .font(.system(size: 18))

                Text(message)
                    .font(.body)
                    .tracking(-0.02)
                    .padding(.bottom, 20)
                    .font(.system(size: 14))

                HStack(spacing: 0) {
                    Button {
                        // "떠나기" 버튼 로직
                        UserDefaults.standard.set(false, forKey: "isLoggedIn")
                        isActive = false
                        shouldNavigateToLogin = true
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.XIVE_SettingDivider)

                            Text("떠나기")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding()
                                .tracking(-0.02)
                        }
                        .padding()
                    }
                    .frame(width: 160)
                
                    .frame(height: 44)

                    Button {
                        action()
                        close()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.XIVE_Purple) // Replace with your custom color

                            Text(buttonTitle)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding()
                                .tracking(-0.02)
                        }
                        .padding()
                    }
                    .frame(width: 160)
                    .frame(height: 44)
                }

            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: 307)
            .frame(height: 160)
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
//            .overlay(alignment: .topTrailing) {
//                Button {
//                    close()
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.title2)
//                        .fontWeight(.medium)
//                }
//                .tint(.black)
//                .padding()
//            }
            .shadow(radius: 20)
            .padding(30)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        }
        .ignoresSafeArea()
    }

    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isActive = false
        }
    }
}

struct CustomDialog_Previews: PreviewProvider {
    static var previews: some View {
        CustomDialog(isActive: .constant(true), shouldNavigateToLogin: .constant(false), title: "로그아웃 하시겠어요?", message: "언제나 여기서 기다리고 있을게요 😢", buttonTitle: "머무르기", action: {})
    }
}

