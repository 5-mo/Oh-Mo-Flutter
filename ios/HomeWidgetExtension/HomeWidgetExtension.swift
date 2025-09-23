import WidgetKit
import SwiftUI

// MARK: - Models
struct DummyEventItem: Identifiable {
    let id = UUID()
    let content: String
    let color: String
}

struct TodoItem: Identifiable {
    let id = UUID()
    let content: String
    let colorType: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let todoList: [String]
    let calendarEvents: [Date: [DummyEventItem]]
    let weeklyTodos: [Date: [TodoItem]]
}

// MARK: - Provider
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), todoList: ["할 일을\n 추가해보세요 :)"], calendarEvents: [:], weeklyTodos: [:])
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.ohmo")
        let todoList = decodeTodoList(from: defaults)
        let calendarEvents = decodeCalendarEvents(from: defaults)
        let weeklyTodos = decodeCalendarTodos(from: defaults)
        return SimpleEntry(date: Date(), configuration: configuration, todoList: todoList, calendarEvents: calendarEvents, weeklyTodos: weeklyTodos)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        let startOfToday = Calendar.current.startOfDay(for: currentDate)
        let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
        
        let entry = createTimeLineEntry(for: currentDate, configuration: configuration)
        
        return Timeline(entries: [entry], policy: .after(startOfTomorrow))
    }
    
    private func createTimeLineEntry(for date: Date, configuration: ConfigurationAppIntent) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: "group.ohmo")
        
        let todoList = decodeTodoList(from: defaults)
        let calendarEvents = decodeCalendarEvents(from: defaults)
        let weeklyTodos = decodeCalendarTodos(from: defaults)
        
        return SimpleEntry(date: date, configuration: configuration, todoList: todoList, calendarEvents: calendarEvents, weeklyTodos: weeklyTodos)
    }
    
    private func decodeTodoList(from defaults: UserDefaults?) -> [String] {
        guard let jsonString = defaults?.string(forKey: "today_todo"),
              let data = jsonString.data(using: .utf8) else {
            return ["할 일을\n 추가해보세요 :)"]
        }
        
        do {
            let items = try JSONDecoder().decode([String].self, from: data)
            return items.isEmpty ? ["할 일을 추가해보세요 :)"] : items
        } catch {
            print("todoList decoding error:", error)
            return ["할 일을\n 추가해보세요 :)"]
        }
    }
    
    private func decodeCalendarTodos(from defaults: UserDefaults?) -> [Date: [TodoItem]] {
        guard let jsonString = defaults?.string(forKey: "calendar_todos"),
              let data = jsonString.data(using: .utf8) else {
            return [:]
        }
        
        do {
            let decoded = try JSONSerialization.jsonObject(with: data) as? [String: [[String: Any]]]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            
            var result: [Date: [TodoItem]] = [:]
            
            decoded?.forEach { (key, value) in
                if let date = formatter.date(from: key) {
                    let todoItems = value.compactMap { itemDict -> TodoItem? in
                        guard let content = itemDict["content"] as? String,
                              let colorType = itemDict["colorType"] as? String else {
                            return nil
                        }
                        return TodoItem(content: content, colorType: colorType)
                    }
                    result[Calendar.current.startOfDay(for: date)] = todoItems
                }
            }
            return result
        } catch {
            print("weekly_todos decoding error:", error)
            return [:]
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
                        DummyEventItem(content: $0, color: "realRed")
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

// MARK: - Views
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
    
    // MARK: - Color Helper
    private func colorForType(_ typeName: String) -> Color {
        switch typeName {
        case "pinkLight": return Color(hex: "FFABAB")
        case "peachLight": return Color(hex: "FFC5AB")
        case "yellowLight": return Color(hex: "FFE0AB")
        case "paleYellow": return Color(hex: "FFF2AB")
        case "lightYellowGreen": return Color(hex: "4C89BB")
        case "aquaGreen": return Color(hex: "ABFFDB")
        case "skyBlue": return Color(hex: "7BF7FB")
        case "realRed": return Color(hex: "E43500")
        case "paleBlue": return Color(hex: "ABCFFF")
        case "lavender": return Color(hex: "B3ABFF")
        case "lightLavender": return Color(hex: "F0ABFF")
        case "softPink": return Color(hex: "FFABD6")
        case "dustyRose": return Color(hex: "D0878B")
        case "mutedPurple": return Color(hex: "766F85")
        case "oliveYellow": return Color(hex: "C1BC6C")
        case "mintGreen": return Color(hex: "9CF191")
        case "blueViolet": return Color(hex: "7076F0")
        case "deepPink": return Color(hex: "BF248B")
        case "cherryRed": return Color(hex: "C53C6A")
        case "softBlue": return Color(hex: "ADD3C9")
        case "oliveGreen": return Color(hex: "9DAA93")
        case "seaGreen": return Color(hex: "61BAAB")
        case "magentaPurple": return Color(hex: "842595")
        case "darkRed": return Color(hex: "750D0D")
        case "palePink": return Color(hex: "FFE2E2")
        case "softPurple": return Color(hex: "DCD1E8")
        case "darkBlue": return Color(hex: "3C3F73")
        case "goldenYellow": return Color(hex: "E1A967")
        case "forestGreen": return Color(hex: "48604E")
        case "sandBrown": return Color(hex: "D7A88F")
        default: return Color.black
        }
    }
    
    // MARK: - Widget Views
    var smallView: some View {
        let todosForToday = entry.todoList

        return GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    if todosForToday.isEmpty || (todosForToday.count == 1 && todosForToday.first?.contains("추가해보세요") == true) {
                        Text("할 일을\n추가해보세요 :)")
                            .font(.system(size: 14))
                    } else {
                        ForEach(todosForToday.prefix(4), id: \.self) { todoContent in
                            Text("● \(todoContent)")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .offset(x:25, y: 20)
            }
        }
    }
    
    private func DayView(for date: Date, entry: Provider.Entry) -> some View {
        let calendar = Calendar.current
        let dayKey = calendar.startOfDay(for: date)
        
        let events = entry.calendarEvents[dayKey] ?? []
        let todosForDay = entry.weeklyTodos[dayKey] ?? []
        
        let isToday = calendar.isDateInToday(date)
        let dayOfMonth = calendar.component(.day, from: date)
        
        return VStack(spacing: 4) {
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
            
            VStack(alignment: .leading, spacing: 2) {
                let eventItems = events.map { (content: $0.content, color: colorForType($0.color)) }
                let todoItems = todosForDay.map { (content: $0.content, color: colorForType($0.colorType)) }
                let combinedItems = eventItems + todoItems

                ForEach(Array(combinedItems.prefix(4)), id: \.content) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 6, height: 6)
                        Text(String(item.content.prefix(10)))
                            .font(.system(size: 9))
                            .lineLimit(1)
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40, alignment: .top)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }
    
    var mediumView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(currentMonthString().uppercased())
                .font(.custom("RubikSprayPaint-Regular", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 5)
            
            HStack(alignment: .top, spacing: 8) {
                ForEach(0..<7) { offset in
                    let calendar = Calendar.current
                    let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek())!
                    DayView(for: date, entry: entry)
                }
            }
        }
        .padding(.horizontal, 0)
    }
    
    private func CalendarDayView(for day: Int, in month: Date, isToday: Bool, entry: Provider.Entry) -> some View {
        let calendar = Calendar.current
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
        
        let events = entry.calendarEvents[calendar.startOfDay(for: date)] ?? []
        let todos = entry.weeklyTodos[calendar.startOfDay(for: date)] ?? []
        
        let combinedItems = events.map { (content: $0.content, color: colorForType($0.color)) } +
                            todos.map { (content: $0.content, color: colorForType($0.colorType)) }

        return VStack(spacing: 4) {
            Text("\(day)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.black)
                .padding(4)
                .overlay(
                        Group {
                            if isToday {
                                Rectangle()
                                    .frame(height: 1)
                                    .offset(y: 6)
                                    .foregroundColor(.black)
                            }
                        }
                    )

            VStack(alignment: .leading, spacing: 2) {
                ForEach(Array(combinedItems.prefix(2)), id: \.content) { item in
                    HStack(spacing: 3) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 5, height: 5)
                        Text(item.content)
                            .font(.system(size: 9))
                            .lineLimit(1)
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(height: 20, alignment: .top)
            Spacer(minLength: 0)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var largeView: some View {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
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
        
        let columns = Array(repeating: GridItem(.flexible()), count: 7)

        return VStack(alignment: .leading, spacing: 8) {
            Text(currentMonthString().uppercased())
                .font(.custom("RubikSprayPaint-Regular", size: 16))
                .foregroundColor(.black)
            
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: columns, spacing: 6) {
                ForEach(daysGrid, id: \.self) { day in
                    if day == 0 {
                        Rectangle().fill(Color.clear)
                    } else {
                        let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
                        let isToday = calendar.isDate(date, inSameDayAs: today)
                        
                        CalendarDayView(for: day, in: now, isToday: isToday, entry: entry)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Date Helpers
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

// MARK: - Widget Definition
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

// MARK: - Extensions
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

// MARK: - Preview
#Preview(as: .systemSmall) {
    HomeWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, todoList: ["● 예시 할 일 1", "● 예시 할 일 2"], calendarEvents: [:], weeklyTodos: [:])
}

#Preview(as: .systemMedium) {
    HomeWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, todoList: ["할 일을 추가해보세요 :)"], calendarEvents: [:], weeklyTodos: [:])
}

#Preview(as: .systemLarge) {
    HomeWidgetExtension()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, todoList: ["한 달 달력 미리보기"], calendarEvents: [:], weeklyTodos: [:])
}
