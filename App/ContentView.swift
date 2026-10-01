import SwiftUI

struct ContentView: View {
    @State private var an = CalendarOrtodox.calendar.component(.year, from: .now)

    private let rosu = Color(red: 0.75, green: 0.08, blue: 0.10)

    var body: some View {
        NavigationStack {
            List {
                Section {
                    UrmatoareaCard(sarbatoare: CalendarOrtodox.urmatoarea(), rosu: rosu)
                        .listRowInsets(EdgeInsets())
                }

                ForEach(lunile) { grup in
                    Section(numeLuna(grup.luna)) {
                        ForEach(grup.sarbatori) { s in
                            Rand(sarbatoare: s, rosu: rosu)
                        }
                    }
                }
            }
            .navigationTitle("Sărbători \(String(an))")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { an -= 1 } label: { Image(systemName: "chevron.left") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { an += 1 } label: { Image(systemName: "chevron.right") }
                }
            }
        }
        .tint(rosu)
    }

    private struct GrupLuna: Identifiable {
        let luna: Int
        let sarbatori: [Sarbatoare]
        var id: Int { luna }
    }

    private var lunile: [GrupLuna] {
        let grupate = Dictionary(grouping: CalendarOrtodox.sarbatori(an)) {
            CalendarOrtodox.calendar.component(.month, from: $0.data)
        }
        return grupate.keys.sorted().map { GrupLuna(luna: $0, sarbatori: grupate[$0]!) }
    }

    private func numeLuna(_ luna: Int) -> String {
        CalendarOrtodox.calendar.standaloneMonthSymbols[luna - 1].capitalized
    }
}

private struct UrmatoareaCard: View {
    let sarbatoare: Sarbatoare
    let rosu: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("URMĂTOAREA SĂRBĂTOARE")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
            Text(CalendarOrtodox.textZile(CalendarOrtodox.zilePana(sarbatoare)))
                .font(.largeTitle.bold())
            Text(sarbatoare.nume)
                .font(.title3.weight(.semibold))
            Text(CalendarOrtodox.dataText(sarbatoare.data, cuAn: true))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(rosu.gradient)
    }
}

private struct Rand: View {
    let sarbatoare: Sarbatoare
    let rosu: Color

    var body: some View {
        let azi = CalendarOrtodox.calendar.startOfDay(for: .now)
        let trecuta = sarbatoare.data < azi
        let esteAzi = sarbatoare.data == azi

        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Text(CalendarOrtodox.calendar.component(.day, from: sarbatoare.data), format: .number)
                    .font(.title2.bold())
                Text(ziSaptamana)
                    .font(.caption2)
                    .textCase(.uppercase)
            }
            .frame(width: 44)
            .foregroundStyle(rosu)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "cross.fill").font(.caption).foregroundStyle(rosu)
                    if esteAzi {
                        Text("ASTĂZI").font(.caption.bold()).foregroundStyle(rosu)
                    }
                }
                Text(sarbatoare.nume)
                    .font(.body.weight(esteAzi ? .bold : .regular))
            }
        }
        .padding(.vertical, 4)
        .opacity(trecuta ? 0.45 : 1)
    }

    private var ziSaptamana: String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ro_RO")
        f.dateFormat = "EEE"
        return f.string(from: sarbatoare.data)
    }
}

#Preview {
    ContentView()
}
