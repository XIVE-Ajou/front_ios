import SwiftUI
import Kingfisher

struct Day: Identifiable {
    var id: UUID = .init()
    var shortSymbol: String
    var date: Date
    var events: [ContentCard] = []
    var ignored: Bool = false
}

extension Date {
    static var currentMonth: Date {
        let calendar = Calendar.current
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.month, .year], from: .now)) else {
            return .now
        }
        return currentMonth
    }
}

extension View {
    func extractDates(_ month: Date, ticketData: [[String: Any]]) -> [Day] {
        var days: [Day] = []
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.locale = Locale(identifier: "ko_KR")
        
        guard let range = calendar.range(of: .day, in: .month, for: month)?.compactMap({ value -> Date? in
            return calendar.date(byAdding: .day, value: value - 1, to: month)
        }) else {
            return days
        }
        
        let firstWeekDay = calendar.component(.weekday, from: range.first!)
        
        for index in Array(0..<firstWeekDay - 1).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -index - 1, to: range.first!) else { return days }
            let shortSymbol = formatter.string(from: date)
            
            days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
        }
        
        range.forEach { date in
            let shortSymbol = formatter.string(from: date)
            let matchingEvents = ticketData.filter { ticket in
                guard let startDate = ticket["startDate"] as? String else { return false }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let ticketDate = formatter.date(from: startDate)
                return calendar.isDate(ticketDate ?? date, inSameDayAs: date)
            }
            
            let events = matchingEvents.compactMap { ticket -> ContentCard? in
                guard let ticketId = ticket["ticketId"] as? Int,
                      let eventName = ticket["eventName"] as? String,
                      let eventType = ticket["eventType"] as? String,
                      let eventPlace = ticket["eventPlace"] as? String,
                      let startDate = ticket["startDate"] as? String,
                      let endDate = ticket["endDate"] as? String,
                      let eventImageUrl = ticket["eventImageUrl"] as? String else {
                    return nil
                }
                return ContentCard(id: ticketId, title: eventType, subtitle: eventName, location: eventPlace, dateRange: "\(startDate) ~ \(endDate)", imageName: eventImageUrl)
            }
            
            days.append(.init(shortSymbol: shortSymbol, date: date, events: events))
        }
        
        let lastWeekDay = 7 - calendar.component(.weekday, from: range.last!)
        
        if (lastWeekDay > 0) {
            for index in 0..<lastWeekDay {
                guard let date = calendar.date(byAdding: .day, value: index + 1, to: range.last!) else { return days }
                let shortSymbol = formatter.string(from: date)
                
                days.append(.init(shortSymbol: shortSymbol, date: date, ignored: true))
            }
        }
        
        return days
    }
}

struct CalendarViewView: View {
    @State private var selectedMonth: Date = .currentMonth
    @State private var selectedDate: Date? = nil
    @State private var ticketData: [[String: Any]] = []
    @State private var showTicketDetail: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var safeArea: EdgeInsets
    
    @State private var contentCards: [ContentCard] = []
    @State private var filteredContentCards: [ContentCard] = []
    @State private var isShowDeleteAlert = false
    @State private var cardToDelete: ContentCard?
    @State private var monthDates: [Day] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    CalendarView()
                        .fixedSize(horizontal: false, vertical: true) // CalendarView 고정
                    Divider()
                        .background(Color("XIVE_SettingDivider"))
                        .frame(height: 7)
                }
                VStack(spacing: 0) {
                    if showTicketDetail {
                        CardView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                    }
                    ScrollView(.vertical) {
                        VStack(spacing: 15) {
                            Spacer() // Fill the space in the ScrollView
                        }
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure ScrollView fills the space
                    }
                    .scrollIndicators(.hidden)
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
            .navigationBarTitle("캘린더", displayMode: .inline)
            .navigationBarItems(leading: backButton)
            .onAppear {
                checkTickets(for: selectedMonth)
            }
            .onChange(of: selectedDate) { newDate in
                filterContentCards(for: newDate)
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $isShowDeleteAlert) {
            Alert(
                title: Text("삭제 확인"),
                message: Text("이 항목을 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    if let card = cardToDelete {
                        deleteCard(card)
                    }
                },
                secondaryButton: .cancel {
                    cardToDelete = nil
                }
            )
        }
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image("back_arrow")
                Text(" ")
            }
        }
    }
    
    private func checkTickets(for month: Date) {
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
                    print("Fetched ticket data: \(ticketData)") // 로그로 출력
                    DispatchQueue.main.async {
                        self.ticketData = ticketData
                        self.contentCards = ticketData.compactMap { ticket in
                            guard let ticketId = ticket["ticketId"] as? Int,
                                  let eventName = ticket["eventName"] as? String,
                                  let eventType = ticket["eventType"] as? String,
                                  let eventPlace = ticket["eventPlace"] as? String,
                                  let startDate = ticket["startDate"] as? String,
                                  let endDate = ticket["endDate"] as? String,
                                  let eventImageUrl = ticket["eventImageUrl"] as? String else {
                                return nil
                            }
                            return ContentCard(id: ticketId, title: eventType, subtitle: eventName, location: eventPlace, dateRange: "\(startDate) ~ \(endDate)", imageName: eventImageUrl)
                        }
                        self.monthDates = extractDates(selectedMonth, ticketData: ticketData)
                        self.filterContentCards(for: self.selectedDate)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.ticketData = []
                        self.showTicketDetail = false
                        self.monthDates = extractDates(selectedMonth, ticketData: ticketData)
                        self.filterContentCards(for: self.selectedDate)
                    }
                    print("No tickets available")
                }
            } catch {
                DispatchQueue.main.async {
                    self.ticketData = []
                    self.showTicketDetail = false
                    self.monthDates = extractDates(selectedMonth, ticketData: ticketData)
                    self.filterContentCards(for: self.selectedDate)
                }
                print("Failed to parse JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    private func deleteCard(_ card: ContentCard) {
        guard let requestUrl = URL(string: "https://1626edc1e3c68daf037d9f7108dbe7ebd4464974.xiveapple.store/api/tickets/\(card.id)") else { return }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "DELETE"
        
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
                print("Error deleting ticket: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.contentCards.removeAll { $0.id == card.id }
                self.cardToDelete = nil
                self.checkTickets(for: self.selectedMonth)
            }
        }.resume()
    }
    
    private func filterContentCards(for date: Date?) {
        guard let date = date else {
            self.filteredContentCards = []
            self.showTicketDetail = false
            return
        }
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.filteredContentCards = contentCards.filter { card in
            guard let startDate = ticketData.first(where: { $0["ticketId"] as? Int == card.id })?["startDate"] as? String,
                  let ticketDate = formatter.date(from: startDate) else { return false }
            return calendar.isDate(ticketDate, inSameDayAs: date)
        }
        self.showTicketDetail = !self.filteredContentCards.isEmpty
    }
    
    @ViewBuilder
    func CardView() -> some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 3)
            
            if let selectedDate = selectedDate {
                Text("\(selectedDate, formatter: dateFormatter)")
                    .font(.headline)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                
                Divider()
            }
            
            List {
                ForEach(filteredContentCards) { card in
                    contentCardView(card: card)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                cardToDelete = card
                                isShowDeleteAlert.toggle()
                            } label: {
                                Label("삭제", systemImage: "trash.circle")
                            }
                            .tint(.red)
                        }
                }
            }
            .listStyle(PlainListStyle())
            .frame(height: 250) // Adjust the height as needed
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .edgesIgnoringSafeArea(.all)
    }
    
    @ViewBuilder
    func contentCardView(card: ContentCard) -> some View {
        HStack() {
            KFImage(URL(string: card.imageName))
                .resizable()
                .frame(width: 60, height: 80)
                .padding(.leading, 0)
            
            VStack(alignment: .leading, spacing: 6, content: {
                Text(card.title)
                    .font(.system(size: 12))
                    .foregroundColor(.purple)
                Text(card.subtitle)
                    .bold()
                Text(card.location)
                    .font(.system(size: 14))
                Text(card.dateRange)
                    .font(.system(size: 14))
            })
            .padding(.leading, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(.black)
        .padding(.horizontal, 0)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func CalendarView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(year)년")
                    .font(.system(size: 25, weight: .bold))
                
                Text(currentMonth)
                    .font(.system(size: 25, weight: .bold))
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        if canDecrementMonth() {
                            monthUpdate(false)
                            selectedDate = nil
                            checkTickets(for: selectedMonth)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                    .frame(width: 28, height: 36)
                    .contentShape(Rectangle())
                    
                    Button(action: {
                        if canIncrementMonth() {
                            monthUpdate(true)
                            selectedDate = nil
                            checkTickets(for: selectedMonth)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            )
                    }
                    .frame(width: 28, height: 36)
                    .contentShape(Rectangle())
                }
                .font(.title3)
                .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: calendarTitleViewHeight)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(["일", "월", "화", "수", "목", "금", "토"], id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(dayColor(for: symbol))
                    }
                }
                .frame(height: weekLabelHeight, alignment: .bottom)
                
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 0), count: 7), spacing: 0) {
                    ForEach(monthDates) { day in
                        VStack {
                            ZStack(alignment: .bottomTrailing) {
                                if let imageName = day.events.first?.imageName {
                                    KFImage(URL(string: imageName))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 42, height: 58)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.purple, lineWidth: 2)
                                                .frame(width: 42, height: 58)
                                                .opacity(Calendar.current.isDate(day.date, inSameDayAs: selectedDate ?? Date.distantPast) ? 1 : 0)
                                        )
                                    if day.events.count > 1 {
                                        ZStack {
                                            Color.purple
                                                .frame(width: 20, height: 20)
                                            Text("\(day.events.count)")
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                        }
                                        .offset(x: -2, y: -2)
                                    }
                                } else {
                                    Text(day.shortSymbol)
                                        .foregroundColor(Calendar.current.isDate(day.date, inSameDayAs: selectedDate ?? Date.distantPast) ? .white : day.ignored ? .gray : .black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 20)
                                        .padding()
                                        .background(
                                            Calendar.current.isDate(day.date, inSameDayAs: selectedDate ?? Date.distantPast) ?
                                            Circle().fill(Color.purple).frame(width: 40, height: 40) : nil
                                        )
                                }
                            }
                        }
                        .frame(height: 60)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDate = day.date
                        }
                    }
                }
                .frame(height: calendarGridHeight, alignment: .top)
                .contentShape(Rectangle())
                .clipped()
            }
        }
        .foregroundColor(.black)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .background(Color.white)
    }
    
    func dayColor(for day: String) -> Color {
        let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
        let dayIndex = weekdays.firstIndex(of: day) ?? 0
        let selectedDayIndex = Calendar.current.component(.weekday, from: selectedDate ?? Date.distantPast) - 1
        return dayIndex == selectedDayIndex ? .purple : .secondary
    }
    
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: selectedMonth)
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
    
    func canIncrementMonth() -> Bool {
        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) else { return false }
        return nextMonth <= Date()
    }
    
    func canDecrementMonth() -> Bool {
        let calendar = Calendar.current
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) else { return false }
        return calendar.component(.year, from: previousMonth) == calendar.component(.year, from: selectedMonth)
    }
    
    func monthUpdate(_ increment: Bool = true) {
        let calendar = Calendar.current
        guard let month = calendar.date(byAdding: .month, value: increment ? 1 : -1, to: selectedMonth) else { return }
        selectedMonth = month
    }
    
    var currentMonth: String {
        return format("MMMM")
    }
    
    var year: String {
        return format("YYYY")
    }
    
    var calendarHeight: CGFloat {
        return calendarTitleViewHeight + weekLabelHeight + calendarGridHeight + topPadding + bottomPadding
    }
    
    var calendarTitleViewHeight: CGFloat {
        return 75.0
    }
    
    var weekLabelHeight: CGFloat {
        return 30.0
    }
    
    var calendarGridHeight: CGFloat {
        return CGFloat(monthDates.count / 7) * 60
    }
    
    var horizontalPadding: CGFloat {
        return 15.0
    }
    
    var topPadding: CGFloat {
        return 15.0
    }
    
    var bottomPadding: CGFloat {
        return 5.0
    }
}

struct ContentCard: Identifiable {
    var id: Int
    var title: String
    var subtitle: String
    var location: String
    var dateRange: String
    var imageName: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarViewView(safeArea: EdgeInsets())
    }
}

