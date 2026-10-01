import SwiftUI
import WidgetKit

struct Intrare: TimelineEntry {
    let date: Date
    let sarbatori: [Sarbatoare]
}

struct Furnizor: TimelineProvider {
    func placeholder(in context: Context) -> Intrare { intrare(.now) }

    func getSnapshot(in context: Context, completion: @escaping (Intrare) -> Void) {
        completion(intrare(.now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Intrare>) -> Void) {
        // O intrare pentru fiecare dintre următoarele 7 zile, la miezul nopții,
        // ca widget-ul să fie corect chiar dacă iOS nu îl reîmprospătează imediat.
        let azi = CalendarOrtodox.calendar.startOfDay(for: .now)
        let intrari = (0..<7).map { i in
            intrare(CalendarOrtodox.calendar.date(byAdding: .day, value: i, to: azi)!)
        }
        let urmatoarea = CalendarOrtodox.calendar.date(byAdding: .day, value: 1, to: azi)!
        completion(Timeline(entries: intrari, policy: .after(urmatoarea)))
    }

    private func intrare(_ data: Date) -> Intrare {
        Intrare(date: data, sarbatori: CalendarOrtodox.urmatoarele(3, de: data))
    }
}

private let rosu = Color(red: 0.75, green: 0.08, blue: 0.10)

struct SarbatoareWidgetView: View {
    @Environment(\.widgetFamily) private var familie
    let intrare: Intrare

    private var prima: Sarbatoare { intrare.sarbatori[0] }
    private var zile: String {
        CalendarOrtodox.textZile(CalendarOrtodox.zilePana(prima, de: intrare.date))
    }

    var body: some View {
        switch familie {
        case .accessoryInline:
            Text("✝ \(zile): \(prima.nume)")
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text("✝ \(zile)").font(.headline).widgetAccentable()
                Text(prima.nume).font(.caption).lineLimit(2)
            }
        case .systemMedium:
            HStack(alignment: .top, spacing: 14) {
                principal
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Apoi").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    ForEach(intrare.sarbatori.dropFirst()) { s in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(CalendarOrtodox.dataText(s.data))
                                .font(.caption2).foregroundStyle(rosu)
                            Text(s.nume).font(.caption).lineLimit(2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        default:
            principal
        }
    }

    private var principal: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "cross.fill")
                Text(zile)
            }
            .font(.subheadline.bold())
            .foregroundStyle(rosu)

            Text(prima.nume)
                .font(.headline)
                .lineLimit(4)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 0)

            Text(CalendarOrtodox.dataText(prima.data))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SarbatoareWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SarbatoareWidget", provider: Furnizor()) { intrare in
            SarbatoareWidgetView(intrare: intrare)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Următoarea sărbătoare")
        .description("Următoarea sărbătoare cu cruce roșie.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

@main
struct SarbatoareWidgetBundle: WidgetBundle {
    var body: some Widget {
        SarbatoareWidget()
    }
}

#Preview(as: .systemSmall) {
    SarbatoareWidget()
} timeline: {
    Intrare(date: .now, sarbatori: CalendarOrtodox.urmatoarele(3))
}
