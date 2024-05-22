//
//  TicketDetailView.swift
//  XIVE
//
//  Created by 나현흠 on 5/10/24.
//
//import SwiftUI
//
//struct TicketDetailView: View {
//    @State private var navigateToCalendar = false
//    @State private var navigateToSetting = false
//    @State private var showTicketDetail = false
//    @State private var nfcButtonOffset: CGFloat = 0.0
//    @ObservedObject private var nfcViewModel = NFCViewModel()
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                VStack(spacing: 0){
//                    setupNavigationBar()
//                        .background(Color.white) // 상단바 배경 색상 추가
//                        .frame(height: 56)
//                    Spacer()
//                }
//                .zIndex(1) // 상단바를 최상단에 위치하도록 설정
//                
//                VStack(spacing: 0){
//                    Spacer()
//                    NavigationLink(destination:
//                                    MyWebView(urlToLoad: "https://xive.co.kr/frida")
//                        .edgesIgnoringSafeArea(.all)
//                    ){
//                        Image("real_frida") // 티켓 이미지
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 400, height: 400)
//                            .cornerRadius(20) // 모서리 둥글게 처리
//                            .shadow(color: .gray, radius: 20, x: 0, y: 10)
//                            .padding(.top, 50)
//                    }
//                    .padding(20)
//
//                    TicketViewIndicator(currentPage: 0, total: 1) // 인디케이터 수정
//                        .padding(.bottom)
//                    
//                    Spacer()
//                    
//                    setupNFCButton() // 하단 NFC 버튼 설정
//                        .padding(.trailing, 20)
//                    
//                    NavigationLink(destination: TicketDetailView(), isActive: $showTicketDetail) {
//                        EmptyView()
//                    }
//                }
//                .background(
//                    Image("real_frida")
//                        .resizable()
//                        .scaledToFill()
//                        .blur(radius: 5)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 배경을 VStack 꽉 채우도록 설정
//                )
//                .ignoresSafeArea(edges: .bottom) // 하단 Safe Area 무시
//                .zIndex(0) // 배경과 콘텐츠를 상단바 아래에 위치하도록 설정
//            }
//            .background(Color.white) // 전체 배경을 흰색으로 설정
//            .onAppear {
//                // 애니메이션 타이머 설정
//                Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
//                    withAnimation(.easeInOut(duration: 2.0)) {
//                        nfcButtonOffset = (nfcButtonOffset == 0) ? -50 : 0
//                    }
//                }
//
//                nfcViewModel.urlDetected = { url in
//                    self.handleURL(url)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//        .preferredColorScheme(.light) // 라이트 모드로 고정
//    }
//    
//    @ViewBuilder
//    private func setupNavigationBar() -> some View {
//        VStack(spacing: 0) {
//            HStack {
//                Button(action: {
//                    self.navigateToSetting = true
//                }) {
//                    Image("Setting")
//                        .padding(.leading, 25)
//                }
//                .background(
//                    NavigationLink(destination: SettingView(), isActive: $navigateToSetting) {
//                        EmptyView()
//                    }
//                        .hidden()
//                )
//                
//                Spacer()
//                
//                Image("XIVE_textLogo_small")
//                
//                Spacer()
//                
//                Text("           ")
//                
////                Button(action: {
////                    self.navigateToCalendar = true
////                }) {
////                    Image("Calender")
////                        .padding(.trailing, 25)
////                }
////                .background(
////                    NavigationLink(destination: CalendarView(), isActive: $navigateToCalendar) {
////                        EmptyView()
////                    }
////                        .hidden()
////                )
//            }
//            .padding()
//            Divider().background(Color.secondary) // 구분선 추가
//            .background(Color.white)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.white) // 상단바 배경 색상 추가
//    }
//    
//    @ViewBuilder
//    private func setupNFCButton() -> some View {
//        HStack {
//            Spacer()
//            Button(action: {
//                nfcViewModel.beginScanning()
//            }) {
//                Image("Subtract")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 80, height: 80)
//                    .clipShape(Circle())
//                    // Adding shadows in different directions
//                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: 10)
//                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: -10)
//                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: -10)
//                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: 10)
//                    .padding(.bottom, 20)
//                    .padding(.trailing, 15)
//            }
//            .offset(y: nfcButtonOffset) // 애니메이션을 위한 오프셋 추가
//        }
//    }
//    
//    private func handleURL(_ url: String) {
//        // URL 처리 및 서버 전송
//        nfcViewModel.sendToServer(url: url)
//    }
//}
//
//// 인디케이터 컴포넌트 수정
//struct TicketViewIndicator: View {
//    let currentPage: Int
//    let total: Int
//    
//    var body: some View {
//        HStack {
//            ForEach(0..<total, id: \.self) { index in
//                Capsule()
//                    .frame(width: currentPage == index ? 40 : 15, height: 10)
//                    .foregroundColor(currentPage == index ? .purple : .gray) // .XIVE_Purple 사용 불가능한 경우 기본 색상으로 변경
//            }
//        }
//    }
//}
//
//struct TicketDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TicketDetailView()
//    }
//}
