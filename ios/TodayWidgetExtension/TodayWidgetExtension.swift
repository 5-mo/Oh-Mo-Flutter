//
//  TodayWidgetExtension.swift
//  TodayWidgetExtension
//
//  Created by 이유진 on 7/13/25.
//

import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let routineList: [String]
    let todoList: [String]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀", routineList: ["루틴 없음"], todoList: ["투두 없음"])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let defaults = UserDefaults(suiteName: "group.ohmo")
        
        let routineList = loadStringArray(from: defaults, key: "today_routine",defaultValue: ["루틴 없음"])
        let todoList = loadStringArray(from: defaults, key: "today_todo",defaultValue: ["투두 없음"])

        let entry = SimpleEntry(date: Date(), emoji: "😀", routineList: routineList, todoList: todoList)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.ohmo")
        
        let routineList = loadStringArray(from: defaults, key: "today_routine",defaultValue: ["루틴 없음"])
        let todoList = loadStringArray(from: defaults, key: "today_todo",defaultValue: ["투두 없음"])

        var entries: [SimpleEntry] = []
        let currentDate = Date()

        for hourOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀", routineList: routineList, todoList: todoList)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    // JSON 문자열 -> [String] 변환 도우미 함수
    private func loadStringArray(from defaults: UserDefaults?, key: String, defaultValue:[String]) -> [String] {
        guard
            let jsonString = defaults?.string(forKey: key),
            let jsonData = jsonString.data(using: .utf8)
        else {
            return defaultValue
        }
        do {
            let array = try JSONDecoder().decode([String].self, from: jsonData)
            let trimmedArray=array.map{$0.trimmingCharacters(in:.whitespacesAndNewlines)}
                .filter{!$0.isEmpty}
            return trimmedArray.isEmpty ? defaultValue:trimmedArray
        } catch {
            print("Error decoding JSON for key \(key): \(error)")
            return defaultValue
        }
    }
}

struct TodayWidgetExtensionEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .accessoryRectangular:
            rectangularView
        default:
            smallView
        }
    }
    var smallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Routine")
                .font(.custom("RubikSprayPaint-Regular",size:14))
            ForEach(entry.routineList.prefix(2), id: \.self) { line in
                Text("• \(line)")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }

            Divider()
                .padding(.vertical, 8)

            Text("To-do list")
                .font(.custom("RubikSprayPaint-Regular",size:14))
            ForEach(entry.todoList.prefix(2), id: \.self) { line in
                Text("• \(line)")
                    .font(.system(size: 12))
                    .foregroundColor(.black)
            }
        }
        .padding()
    }

    var mediumView: some View {
        HStack(spacing: 0) {
            smallView
                .frame(width: 110, alignment: .leading)
                .offset(x:-15)

            Spacer()

            calendarView
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    var calendarView: some View {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month], from: now)
        let firstOfMonth = calendar.date(from: components)!
        let range = calendar.range(of: .day, in: .month, for: now)!
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)

        var daysGrid = Array(repeating: 0, count: firstWeekday - 1)
        daysGrid.append(contentsOf: Array(1...range.count))
        while daysGrid.count % 7 != 0 {
            daysGrid.append(0)
        }

        let rows = daysGrid.chunked(into: 7)

        return VStack(spacing: 4) {
            Text(monthYearString(from: now))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)

            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            ForEach(rows, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { day in
                        let isToday = (day != 0) && calendar.isDate(now, inSameDayAs: calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!)
                                            
                        Text(day == 0 ? "" : "\(day)")
                                                .font(.system(size: 12))
                                                .fontWeight(isToday ? .bold : .regular)
                                                .foregroundColor(isToday ? .white : .black)
                                                .frame(maxWidth: .infinity, minHeight: 18)
                                                .background(
                                                    Circle()
                                                        .fill(isToday ? Color.gray : Color.clear)
                                                        .frame(width: 19, height: 19)
                                                )
                                        }
                                    }
                                }
                            }
                        }
    
    var rectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // 여기선 투두를 표시하도록 예시
            ForEach(entry.todoList.prefix(3), id: \.self) { item in
                Text("● \(item)")
                    .font(.footnote)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }

    func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct TodayWidgetExtension: Widget {
    let kind: String = "TodayWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TodayWidgetExtensionEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TodayWidgetExtensionEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Today Routine & Todo")
        .description("오늘의 루틴과 투두를 확인하세요.")
        .supportedFamilies([.systemSmall,.systemMedium,.accessoryRectangular])
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

#Preview(as: .systemSmall) {
    TodayWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀", routineList: ["오모 회의", "데이트"], todoList: ["코딩하기", "회의"])
}
