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
    @StateObject private var nfcViewModel = NFCViewModel()
    
    var body: some View {
        Group {
            if !tickets.isEmpty {
                TicketDetailView(tickets: tickets)
            } else {
                contentView
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
        .onAppear {
            checkTickets()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NFCSessionEnded"))) { _ in
            refreshTicketData()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            if !NFCReaderSession.readingAvailable {
                refreshTicketData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
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
                    
                    VStack {
                        Text("Add +")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color.XIVE_Purple)
                            .padding(.top, 50)
                        
                        Text("Smart ticket")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Text("스마트 티켓을 등록해주세요")
                        .font(.subheadline)
                        .padding(.top, 15)
                    Spacer()
                    
                    setupNFCButton()
                    
                    NavigationLink(destination: TicketDetailView(tickets: tickets), isActive: $showTicketDetail) {
                        EmptyView()
                    }
                }
                .background(Color.white)
                .navigationBarBackButtonHidden(true)
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func refreshTicketData() {
        checkTickets()
    }
    
    @ViewBuilder
    private func setupNavigationBar(safeArea: EdgeInsets) -> some View {
        HStack {
            Button(action: {
                self.navigateToSetting = true
            }) {
                Image("Setting")
                    .padding(.leading, 12)
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
                    .padding(.trailing, 12)
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
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: 10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: -10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: 10, y: -10)
                    .shadow(color: .gray.opacity(0.25), radius: 5, x: -10, y: 10)
                    .padding(.bottom, 20)
                    .padding(.trailing, 15)
            }
            .offset(y: nfcButtonOffset)
        }
    }
    
    private func checkTickets() {
        guard let requestUrl = URL(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/tickets") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "GET"
        
        guard let accessToken = UserDefaults.standard.string(forKey: "User_AccessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "User_RefreshToken") else {
            print("AccessToken 또는 RefreshToken을 찾을 수 없습니다.")
            return
        }
        
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
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let ticketData = json["data"] as? [[String: Any]], !ticketData.isEmpty {
                    DispatchQueue.main.async {
                        self.tickets = ticketData.compactMap { data in
                            guard let eventWebUrl = data["eventWebUrl"] as? String,
                                  let eventImageUrl = data["eventImageUrl"] as? String,
                                  let eventId = data["eventId"] as? Int,
                                  let ticketId = data["ticketId"] as? Int else {
                                return nil
                            }
                            return Ticket(eventWebUrl: eventWebUrl, eventImageUrl: eventImageUrl, eventId: eventId, ticketId: ticketId)
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
    @State private var timer: Timer? = nil
    @State private var autoScrollEnabled = false  // 자동 스크롤 활성화 상태
    
    @StateObject private var nfcViewModel = NFCViewModel()
    var tickets: [Ticket]
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    VStack(spacing: 0) {
                        setupNavigationBar(safeArea: geometry.safeAreaInsets)
                            .background(Color.white)
                            .frame(height: 56)
                        Spacer()
                    }
                    .zIndex(1)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        TabView(selection: $selectedIndex) {
                            ForEach(tickets.indices, id: \.self) { index in
                                NavigationLink(destination: MyWebView(urlToLoad: tickets[index].eventWebUrl, eventID: "\(tickets[index].eventId)", ticketID: "\(tickets[index].ticketId)")) {
                                    KFImage(URL(string: tickets[index].eventImageUrl))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 400, height: 400)
                                        .cornerRadius(20)
                                        .shadow(color: .gray, radius: 20, x: 0, y: 2)
                                        .padding(.top, 150)
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .onAppear {
                            if autoScrollEnabled {
                                startTimer()
                            }
                        }
                        .onDisappear {
                            stopTimer()
                        }

                        TicketViewIndicator(currentPage: selectedIndex, total: tickets.count)
                            .padding(.bottom, 50)

                        Spacer()
                        
                        setupNFCButton()
                            .padding(.trailing, 0)
                    }

                    .background(
                        Image("Sogroup_Blur")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    )
                    .ignoresSafeArea(edges: .bottom)
                    .zIndex(0)
                }
                .background(Color.white)
                .onAppear {
                    nfcViewModel.urlDetected = { url in
                        self.handleURL(url)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .preferredColorScheme(.light)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation {
                selectedIndex = (selectedIndex + 1) % tickets.count
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @ViewBuilder
    private func setupNavigationBar(safeArea: EdgeInsets) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    self.navigateToSetting = true
                }) {
                    Image("Setting")
                        .padding(.leading, 12)
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
                        .padding(.trailing, 12)
                }
                .background(
                    NavigationLink(destination: CalendarViewView(safeArea: safeArea).ignoresSafeArea(.container, edges: .top), isActive: $navigateToCalendar) {
                        EmptyView()
                    }
                    .hidden()
                )
            }
            .padding()
            Divider().background(Color.secondary)
                .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
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
        nfcViewModel.handleDetectedURL(url: url)
    }
}

struct TicketViewIndicator: View {
    let currentPage: Int
    let total: Int
    
    var body: some View {
        HStack {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .frame(width: currentPage == index ? 10 : 10, height: 10)
                    .foregroundColor(currentPage == index ? .XIVE_Purple : .gray)
            }
        }
    }
}

struct Ticket: Identifiable {
    let id = UUID()
    let eventWebUrl: String
    let eventImageUrl: String
    let eventId: Int
    let ticketId: Int
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct TicketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TicketDetailView(tickets: [
            Ticket(eventWebUrl: "https://example.com", eventImageUrl: "https://via.placeholder.com/400", eventId: 1, ticketId: 1),
            Ticket(eventWebUrl: "https://example.com", eventImageUrl: "https://via.placeholder.com/400", eventId: 2, ticketId: 2)
        ])
    }
}
