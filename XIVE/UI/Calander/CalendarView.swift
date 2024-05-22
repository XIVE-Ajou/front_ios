//
//  CalendarView.swift
//  XIVE
//
//  Created by 나현흠 on 5/1/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate: Date?
    @State private var currentMonth: Date = Date() // 현재 월을 저장하는 상태 변수
    private let daysInWeek = 7
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        return formatter
    }
    
    var body: some View {
        VStack {
            VStack {
                Text(dateFormatter.string(from: currentMonth)) // 현재 월을 표시
                    .font(.title)
                
                Divider()
                
                let days = generateDaysInMonth(for: currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                    ForEach(days, id: \.self) { day in
                        Text("\(day)")
                            .onTapGesture {
                                let startOfMonth = currentMonth.startOfMonth()
                                if let adjustedDate = Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                                    self.selectedDate = adjustedDate
                                }
                            }

                    }
                }
                
                Spacer()
                
                // 이전, 다음 월로 이동하는 버튼 추가
                HStack {
                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    }) {
                        Text("<")
                    }
                    
                    Button(action: {
                        currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    }) {
                        Text(">")
                    }
                }
            }

            // 이벤트 디테일 뷰
            EventDetailView(date: selectedDate ?? Date())
                .frame(height: 200) // 이벤트 디테일 뷰의 높이 고정
                .background(Color.gray.opacity(0.2)) // 배경색 추가
        }
    }
    
    func generateDaysInMonth(for date: Date) -> [Int] {
        let range = Calendar.current.range(of: .day, in: .month, for: date)!
        return Array(range)
    }
}

struct EventDetailView: View {
    var date: Date

    var body: some View {
        VStack {
            Text("Events on \(date, formatter: dateFormatter)")
                .font(.headline)
            Divider()
            Text("Event 1")
            Text("Event 2")
            Text("Event 3")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}

extension Date {
    func startOfMonth() -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
}
