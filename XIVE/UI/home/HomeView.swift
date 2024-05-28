//
//  HomeView.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import SwiftUI
import CoreNFC

struct HomeView: View {
    @State private var navigateToCalendar = false
    @State private var navigateToSetting = false
    @State private var showTicketDetail = false
    @State private var showAlert = false
    @State private var nfcButtonOffset: CGFloat = 0.0
    @Environment(\.colorScheme) var colorScheme
    @State private var ticketData: [[String: Any]] = []
    @ObservedObject private var nfcViewModel = NFCViewModel()
    
    var body: some View {
        TicketDetailView(ticketData: ticketData, eventWebUrl: nfcViewModel.eventWebUrl)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NFCSessionEnded"))) { _ in
                // NFC 세션 종료 시 화면 리프레시
                refreshTicketData()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // 앱이 비활성 상태로 전환될 때 NFC 상태를 확인하여 리프레시합니다.
                if !NFCReaderSession.readingAvailable {
                    refreshTicketData()
                }
            }
    }
    
    private var contentView: some View {
        NavigationView {
            VStack(spacing: 0) {
                setupNavigationBar()
                
                Spacer()
                
                Image("Add_Ticket")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .shadow(color: .gray, radius: 20, x: 0, y: 10)
                    .padding(.top, 50)
                    .tracking(-0.02)
                
                VStack {
                    Text("Add +")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.XIVE_Purple)
                        .padding(.top, 50)
                        .tracking(-0.02)
                    
                    Text("Smart ticket")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .tracking(-0.02)
                }
                
                Text("스마트 티켓을 등록해주세요")
                    .font(.subheadline)
                    .padding(.top, 15)
                    .tracking(-0.02)
                Spacer()
                
                setupNFCButton()
                
                NavigationLink(destination: TicketDetailView(ticketData: ticketData, eventWebUrl: nfcViewModel.eventWebUrl), isActive: $showTicketDetail) {
                    EmptyView()
                }
            }
            .background(Color.white) // 배경색을 흰색으로 고정
        }
    }
    
    private func refreshTicketData() {
        // Refresh ticket data by calling API again
        checkTickets()
    }
    
    @ViewBuilder
    private func setupNavigationBar() -> some View {
        HStack {
            Button(action: {
                self.navigateToSetting = true
            }) {
                Image("Setting")
            }
            .background(
                NavigationLink(destination: SettingView(), isActive: $navigateToSetting) {
                    EmptyView()
                }
                    .hidden()
            )
            
            Spacer()
            
            Image("XIVE_textLogo_small")
                .frame(alignment: .center)
            
            Spacer()
            
            Text("      ")
        }
        .padding()
        .background(VStack {
            Spacer()
            Divider().background(Color.secondary)
        })
    }
    
    @ViewBuilder
    private func setupNFCButton() -> some View {
        HStack {
            Spacer()
            Button(action: {
                nfcViewModel.beginScanning()
            }) {
                Image("Subtract")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                // Adding shadows in different directions
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: 10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: -10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: -10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: 10)
                    .padding(.bottom, 20)
                    .padding(.trailing, 15)
            }
            .offset(y: nfcButtonOffset) // 애니메이션을 위한 오프셋 추가
        }
    }
    
    private func checkTickets() {
        guard let requestUrl = URL(string: "https://api.xive.co.kr/api/tickets") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        // UserDefaults에서 AccessToken과 RefreshToken 읽기
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            return
        }
        
        // 헤더에 AccessToken과 RefreshToken 추가
        request.setValue(accessToken, forHTTPHeaderField: "AccessToken")
        request.setValue(refreshToken, forHTTPHeaderField: "RefreshToken")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching tickets: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                // 서버 응답을 JSON 형식으로 변환
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let ticketData = json["data"] as? [[String: Any]], !ticketData.isEmpty {
                    DispatchQueue.main.async {
                        self.ticketData = ticketData
                        self.showTicketDetail = true
                    }
                } else {
                    print("No tickets available")
                }
            } catch {
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct TicketDetailView: View {
    @State private var navigateToCalendar = false
    @State private var navigateToSetting = false
    
    @ObservedObject private var nfcViewModel = NFCViewModel()
    var ticketData: [[String: Any]]
    var eventWebUrl: String? // Add this property
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0){
                    setupNavigationBar()
                        .background(Color.white) // 상단바 배경 색상 추가
                        .frame(height: 56)
                    Spacer()
                }
                .zIndex(1) // 상단바를 최상단에 위치하도록 설정
                
                VStack(spacing: 0){
                    Spacer()
                    NavigationLink(destination:
                                    MyWebView(urlToLoad: eventWebUrl ?? "https://xive.co.kr/fromUs") // Use the eventWebUrl here
                        .edgesIgnoringSafeArea(.all)
                    ){
                        
                        Image("FromUs_Poster")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 400, height: 400)
                            .cornerRadius(20) // 모서리 둥글게 처리
                            .shadow(color: .gray, radius: 20, x: 0, y: 10)
                            .padding(.top, 100)
                    }
                    .padding(20)
                    
                    TicketViewIndicator(currentPage: 0, total: 1) // 인디케이터 수정
                        .padding(.bottom)
                    
                    Spacer()
                    
                    setupNFCButton() // 하단 NFC 버튼 설정
                        .padding(.trailing, 20)
                }
                .background(
                    Image("FromUs_Blur")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // 배경을 VStack 꽉 채우도록 설정
                    
                    
                )
                .ignoresSafeArea(edges: .bottom) // 하단 Safe Area 무시
                .zIndex(0) // 배경과 콘텐츠를 상단바 아래에 위치하도록 설정
            }
            .background(Color.white) // 전체 배경을 흰색으로 설정
            .onAppear {
                // 애니메이션 타이머 설정
                nfcViewModel.urlToLoad = self.eventWebUrl
                Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                    withAnimation(Animation.easeInOut(duration: 1)) {
                        // 애니메이션 효과를 추가한 상태 업데이트
                    }
                }
            }
        }
        .navigationBarHidden(true) // 네비게이션 바 숨기기
    }
    
    @ViewBuilder
    private func setupNavigationBar() -> some View {
        HStack {
            Button(action: {
                self.navigateToSetting = true
            }) {
                Image("Setting")
            }
            .background(
                NavigationLink(destination: SettingView(), isActive: $navigateToSetting) {
                    EmptyView()
                }
                    .hidden()
            )
            
            Spacer()
            
            Image("XIVE_textLogo_small")
                .frame(alignment: .center)
            
            Spacer()
            
            Button(action: {
                self.navigateToCalendar = true
            }) {
                Image("Calendar")
            }
            .background(
                NavigationLink(destination: CalendarView(), isActive: $navigateToCalendar) {
                    EmptyView()
                }
                    .hidden()
            )
        }
        .padding()
        .background(VStack {
            Spacer()
            Divider().background(Color.secondary)
        })
    }
    
    @ViewBuilder
    private func setupNFCButton() -> some View {
        HStack {
            Spacer()
            Button(action: {
                nfcViewModel.beginScanning()
            }) {
                Image("Subtract")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                // Adding shadows in different directions
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: 10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: -10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: -10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: 10)
                    .padding(.bottom, 20)
                    .padding(.trailing, 15)
            }
            .offset(y: 0)
        }
    }
}

struct TicketViewIndicator: View {
    let currentPage: Int
    let total: Int
    
    var body: some View {
        HStack {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.XIVE_Purple : Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.5 : 1.0)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
}

