//
//  HomeWidgetExtension.swift
//  HomeWidgetExtension
//
//  Created by 이유진 on 7/3/25.
//

import WidgetKit
import SwiftUI

// MARK: - DummyEventItem Model
struct DummyEventItem: Identifiable {
    let id = UUID()
    let content: String
    let color: Color
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), todoList: ["할 일을\n 추가해보세요 :)"], calendarEvents: [:])
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.ohmo")
        let todoList = decodeTodoList(from: defaults)
        return SimpleEntry(date: Date(), configuration: configuration, todoList: todoList, calendarEvents: [:])
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        let currentDate = Date()
        let defaults = UserDefaults(suiteName: "group.ohmo")

        let todoList = decodeTodoList(from: defaults)
        let parsedEvents = decodeCalendarEvents(from: defaults)

        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, todoList: todoList, calendarEvents: parsedEvents)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

    private func decodeTodoList(from defaults: UserDefaults?) -> [String] {
        guard let jsonString = defaults?.string(forKey: "today_todo"),
              let data = jsonString.data(using: .utf8) else {
            return ["할 일을\n 추가해보세요 :)"]
        }
        
        do {
            let rawArray=try JSONDecoder().decode([String].self,from:data)
            let cleanedArray=rawArray.map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
                .filter{!$0.isEmpty}
            return cleanedArray.isEmpty ? ["할 일을\n 추가해보세요 :)"]:cleanedArray
        } catch {
            print("todoList decoding error:", error)
            return ["할 일을\n 추가해보세요 :)"]
        }
    }

    private func decodeCalendarEvents(from defaults: UserDefaults?) -> [Date: [DummyEventItem]] {
        guard let jsonString = defaults?.string(forKey: "calendar_events"),
              let data = jsonString.data(using: .utf8) else {
            return [:]
        }

        do {
            let decoded = try JSONSerialization.jsonObject(with: data) as? [String: [String]]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")

            var result: [Date: [DummyEventItem]] = [:]
            decoded?.forEach { (key, value) in
                if let date = formatter.date(from: key) {
                    let events = value.map {
                        DummyEventItem(content: $0, color: Color.orange.opacity(0.6))
                    }
                    result[Calendar.current.startOfDay(for: date)] = events
                }
            }
            return result
        } catch {
            print("calendar_events decoding error:", error)
            return [:]
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let todoList: [String]
    let calendarEvents: [Date: [DummyEventItem]]
}

struct HomeWidgetExtensionEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            smallView
        }
    }

    var smallView: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    if entry.todoList.count == 1 && entry.todoList.first?.contains("추가해보세요") == true {
                        Text("할 일을\n추가해보세요 :)")
                            .font(.system(size: 14))
                    } else {
                        ForEach(entry.todoList.prefix(2), id: \.self) { line in
                            Text("● \(line)")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

                Link(destination: URL(string: "ohmoapp://daylog/todo")!) {
                    Image("ohmo")
                        .resizable()
                        .frame(width: 70, height: 70)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomTrailing)
                .padding(4)
            }
        }
    }


    var mediumView: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
      
        return VStack(alignment: .leading, spacing: 8) {
            Text(currentMonthString().uppercased())
                .font(.custom("RubikSprayPaint-Regular", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 5)
      
            HStack(alignment: .top, spacing: 0) {
                ForEach(0..<7) { offset in
                    let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek())!
                    let dayOfMonth = calendar.component(.day, from: date)
                    let isToday = calendar.isDate(date, inSameDayAs: today)
                    let events = entry.calendarEvents[calendar.startOfDay(for: date)] ?? []
                    
                    VStack(spacing: 4) {
                        Text(weekdayLetter(for: date))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text("\(dayOfMonth)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                            .overlay(
                                Group {
                                    if isToday {
                                        Rectangle()
                                            .frame(height: 1)
                                            .offset(y: 8)
                                            .foregroundColor(.black)
                                    }
                                }
                            )
                        
                        if !events.isEmpty || (isToday && !entry.todoList.isEmpty) {
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(events.prefix(2)) { event in
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(event.color)
                                            .frame(width: 6, height: 6)
                                        Text(String(event.content.prefix(10)))
                                            .font(.system(size: 9))
                                            .lineLimit(1)
                                            .foregroundColor(.black)
                                    }
                                }

                                if isToday {
                                    ForEach(entry.todoList.prefix(2), id: \.self) { todo in
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 6, height: 6)
                                            Text(String(todo.prefix(10)))
                                                .font(.system(size: 9))
                                                .lineLimit(1)
                                                .foregroundColor(.black)
                                        }
                                    }
                                }
                            }
                        } else {
                            Spacer()
                                .frame(height: 20)
                        }

                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, 0)
    }

    var largeView: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        let firstOfMonth = calendar.date(from: components)!
        
        let range = calendar.range(of: .day, in: .month, for: now)!
        let lastDay = range.count
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        
        var daysGrid = Array(repeating: 0, count: firstWeekday - 1)
        daysGrid.append(contentsOf: Array(1...lastDay))
        
        while (daysGrid.count % 7) != 0 {
            daysGrid.append(0)
        }
        
        return VStack(alignment: .leading, spacing: 8) {
            Text(currentMonthString().uppercased())
                .font(.custom("RubikSprayPaint-Regular", size: 16))
                .foregroundColor(.black)
                .padding(.bottom, 5)
            
            let weekStart = startOfWeek()
            HStack(spacing: 0) {
                ForEach(0..<7) { offset in
                    let date = calendar.date(byAdding: .day, value: offset, to: weekStart)!
                    Text(weekdayLetter(for: date))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            let rows = daysGrid.chunked(into: 7)
            
            VStack(spacing: 6) {
                ForEach(0..<rows.count, id: \.self) { rowIndex in
                    HStack(spacing: 0) {
                        ForEach(rows[rowIndex], id: \.self) { day in
                            Group {
                                if day == 0 {
                                    VStack {
                                        Text("")
                                        Spacer()
                                            .frame(height: (5 + 2) * 3)
                                    }
                                    .frame(maxWidth: .infinity)
                                } else {
                                    let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
                                    let isToday = calendar.isDate(date, inSameDayAs: today)
                                    let events = entry.calendarEvents[calendar.startOfDay(for: date)] ?? []
                                    
                                    VStack(spacing: 4) {
                                        Text("\(day)")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.black)
                                            .overlay(
                                                Group {
                                                    if isToday {
                                                        Rectangle()
                                                            .frame(height: 1)
                                                            .offset(y: 8)
                                                            .foregroundColor(.black)
                                                    }
                                                }
                                            )
                                        if !events.isEmpty || (isToday && !entry.todoList.isEmpty) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                ForEach(events.prefix(3)) { event in
                                                    HStack(spacing: 3) {
                                                        Circle()
                                                            .fill(event.color)
                                                            .frame(width: 5, height: 5)
                                                        Text(String(event.content.prefix(8)))
                                                            .font(.system(size: 8))
                                                            .lineLimit(1)
                                                            .foregroundColor(.black)
                                                    }
                                                }

                                                if isToday {
                                                    ForEach(entry.todoList.prefix(2), id: \.self) { todo in
                                                        HStack(spacing: 3) {
                                                            Circle()
                                                                .fill(Color.black)
                                                                .frame(width: 5, height: 5)
                                                            Text(String(todo.prefix(8)))
                                                                .font(.system(size: 8))
                                                                .lineLimit(1)
                                                                .foregroundColor(.black)
                                                        }
                                                    }
                                                }
                                            }
                                        } else {
                                            Spacer()
                                                .frame(height: (5 + 2) * 3)
                                        }

                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 0)
        }
        .padding(.horizontal, 0)
    }
    
    
    
    // MARK: - Helper Functions
    func currentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }

    func startOfWeek() -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components)!
    }
    
    func weekdayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

struct HomeWidgetExtension: Widget {
    let kind: String = "HomeWidgetExtension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            HomeWidgetExtensionEntryView(entry: entry)
                .containerBackground(Color.white, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

// Color extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        var chunks: [[Element]] = []
        var start = 0
        while start < self.count {
            let end = Swift.min(start + size, self.count)
            chunks.append(Array(self[start..<end]))
            start += size
        }
        return chunks
    }
}

// MARK: - Preview (미리보기)
#Preview(as: .systemSmall) {
    HomeWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, todoList: ["● 예시 할 일 1", "● 예시 할 일 2"], calendarEvents: [:])
}

#Preview(as: .systemMedium) {
    HomeWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, todoList: ["할 일을 추가해보세요 :)"], calendarEvents: [:])
}

#Preview(as: .systemLarge) {
    HomeWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, todoList: ["한 달 달력 미리보기"], calendarEvents: [:])
}
