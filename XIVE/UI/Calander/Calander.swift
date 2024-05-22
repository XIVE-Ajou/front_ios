//
//  Calander.swift
//  XIVE
//
//  Created by 나현흠 on 5/3/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var showingSheet = false
    @State private var currentMonth: Date = Date() // 현재 월을 저장하는 상태 변수
    private let daysInWeek = 7
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text(dateFormatter.string(from: currentMonth)) // 현재 월을 표시
                    .font(.title)
                
                Divider()
                
                let days = generateDaysInMonth(for: currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                    ForEach(days, id: \.self) { day in
                        Text("\(day)")
                            .onTapGesture {
                                self.selectedDate = Calendar.current.date(byAdding: .day, value: day - 1, to: currentMonth.startOfMonth())
                                self.showingSheet = true
                            }
                    }
                }
                
                Spacer()
                
                // 이전, 다음 월로 이동하는 버튼 추가
                HStack {
                    Button(action: {
                        self.currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }) {
                        Text("<")
                    }
                    
                    Button(action: {
                        self.currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }) {
                        Text(">")
                    }
                }
            }
            .navigationTitle("XIVE 캘린더")
            .sheet(isPresented: $showingSheet) {
                EventDetailView(date: selectedDate ?? Date())
            }
        }
    }
    
    func generateDaysInMonth(for date: Date) -> [Int] {
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return Array(range)
    }
}

struct EventDetailView: View {
    var date: Date
    var events = ["이벤트 1", "이벤트 2", "이벤트 3"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(events, id: \.self) { event in
                    Text(event)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("이벤트 목록")
        }
    }
    
    func delete(at offsets: IndexSet) {
        events.remove(atOffsets: offsets)
    }
}

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
