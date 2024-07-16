//
//  HomeView.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
//

import SwiftUI
import CoreNFC
import Kingfisher
import WebKit

struct HomeView: View {
    @State private var navigateToCalendar = false
    @State private var navigateToSetting = false
    @State private var showTicketDetail = false
    @State private var showAlert = false
    @State private var nfcButtonOffset: CGFloat = 0.0
    @Environment(\.colorScheme) var colorScheme
    @State private var tickets: [Ticket] = []
    @ObservedObject private var nfcViewModel = NFCViewModel()
    
    var body: some View {
        Group {
            if !tickets.isEmpty {
                TicketDetailView(tickets: tickets)
            } else {
                contentView
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light) // 라이트 모드로 고정
        .onAppear {
            // API 호출을 통해 티켓 데이터 확인
            checkTickets()
        }
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
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // HomeView가 활성화될 때마다 티켓 데이터를 확인합니다.
            checkTickets()
        }
    }
    
    private var contentView: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    setupNavigationBar(safeArea: geometry.safeAreaInsets)
                    
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
                    
                    NavigationLink(destination: TicketDetailView(tickets: tickets), isActive: $showTicketDetail) {
                        EmptyView()
                    }
                }
                .background(Color.white) // 배경색을 흰색으로 고정
                .navigationBarBackButtonHidden(true)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func refreshTicketData() {
        // Refresh ticket data by calling API again
        checkTickets()
    }
    
    @ViewBuilder
    private func setupNavigationBar(safeArea: EdgeInsets) -> some View {
        HStack {
            Button(action: {
                self.navigateToSetting = true
            }) {
                Image("Setting")
                    .padding(.leading, 25)
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
                Image("Calender")
                    .padding(.trailing, 25)
            }
            .background(
                NavigationLink(destination: CalendarViewView(safeArea: safeArea).ignoresSafeArea(.container, edges: .top), isActive: $navigateToCalendar) {
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
            .offset(y: nfcButtonOffset) // 애니메이션을 위한 오프셋 추가
        }
    }
    
    private func checkTickets() {
        guard let requestUrl = URL(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/tickets") else { return }
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
                        self.tickets = ticketData.compactMap { data in
                            guard let eventWebUrl = data["eventWebUrl"] as? String,
                                  let eventImageUrl = data["eventImageUrl"] as? String else {
                                return nil
                            }
                            return Ticket(eventWebUrl: eventWebUrl, eventImageUrl: eventImageUrl)
                        }
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
    @State private var selectedIndex = 0
    
    @ObservedObject private var nfcViewModel = NFCViewModel()
    var tickets: [Ticket]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    VStack(spacing: 0) {
                        setupNavigationBar(safeArea: geometry.safeAreaInsets)
                            .background(Color.white) // 상단바 배경 색상 추가
                            .frame(height: 56)
                        Spacer()
                    }
                    .zIndex(1) // 상단바를 최상단에 위치하도록 설정
                    
                    VStack(spacing: 0) {
                        Spacer()
                        TabView(selection: $selectedIndex) {
                            ForEach(tickets.indices, id: \.self) { index in
                                NavigationLink(destination: MyWebView(urlToLoad: tickets[index].eventWebUrl)) {
                                    KFImage(URL(string: tickets[index].eventImageUrl))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 400, height: 400)
                                        .cornerRadius(20) // 모서리 둥글게 처리
                                        .shadow(color: .gray, radius: 20, x: 0, y: 10)
                                        .padding(.top, 100)
                                }
                                .padding(20)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // 내장 인디케이터 숨기기
                        
                        TicketViewIndicator(currentPage: selectedIndex, total: tickets.count) // 인디케이터 수정
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
                    nfcViewModel.urlDetected = { url in
                        self.handleURL(url)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .preferredColorScheme(.light) // 라이트 모드로 고정
        }
    }
    
    @ViewBuilder
    private func setupNavigationBar(safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    self.navigateToSetting = true
                }) {
                    Image("Setting")
                        .padding(.leading, 25)
                }
                .background(
                    NavigationLink(destination: SettingView(), isActive: $navigateToSetting) {
                        EmptyView()
                    }
                    .hidden()
                )
                
                Spacer()
                
                Image("XIVE_textLogo_small")
                
                Spacer()
                
                Button(action: {
                    self.navigateToCalendar = true
                }) {
                    Image("Calender")
                        .padding(.trailing, 25)
                }
                .background(
                    NavigationLink(destination: CalendarViewView(safeArea: safeArea).ignoresSafeArea(.container, edges: .top), isActive: $navigateToCalendar) {
                        EmptyView()
                    }
                    .hidden()
                )
            }
            .padding()
            Divider().background(Color.secondary) // 구분선 추가
                .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // 상단바 배경 색상 추가
        .navigationBarBackButtonHidden(true)
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
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func handleURL(_ url: String) {
        // URL 처리 및 서버 전송
        nfcViewModel.sendToServer(url: url)
    }
}

// 인디케이터 컴포넌트 수정
struct TicketViewIndicator: View {
    let currentPage: Int
    let total: Int
    
    var body: some View {
        HStack {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .frame(width: currentPage == index ? 40 : 15, height: 10)
                    .foregroundColor(currentPage == index ? .purple : .gray) // .XIVE_Purple 사용 불가능한 경우 기본 색상으로 변경
            }
        }
    }
}

struct Ticket: Identifiable {
    let id = UUID()
    let eventWebUrl: String
    let eventImageUrl: String
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct TicketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TicketDetailView(tickets: [
            Ticket(eventWebUrl: "https://example.com", eventImageUrl: "https://via.placeholder.com/400"),
            Ticket(eventWebUrl: "https://example.com", eventImageUrl: "https://via.placeholder.com/400")
        ])
    }
}

