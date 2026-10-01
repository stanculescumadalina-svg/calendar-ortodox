import Foundation

/// O sărbătoare cu cruce roșie, la o dată concretă.
struct Sarbatoare: Identifiable, Hashable {
    let data: Date
    let nume: String

    var id: Date { data }
}

/// Calendarul ortodox (stil nou, Biserica Ortodoxă Română) – doar sărbătorile cu cruce roșie.
enum CalendarOrtodox {

    static var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        c.locale = Locale(identifier: "ro_RO")
        return c
    }()

    // MARK: Sărbători cu dată fixă (lună, zi, nume)

    static let fixe: [(Int, Int, String)] = [
        (1, 1, "Tăierea împrejur a Domnului; Sf. Vasile cel Mare"),
        (1, 6, "Botezul Domnului (Boboteaza)"),
        (1, 7, "Soborul Sf. Ioan Botezătorul"),
        (1, 30, "Sfinții Trei Ierarhi: Vasile, Grigorie și Ioan"),
        (2, 2, "Întâmpinarea Domnului"),
        (2, 24, "Întâia și a doua aflare a capului Sf. Ioan Botezătorul"),
        (3, 9, "Sfinții 40 de Mucenici din Sevastia"),
        (3, 25, "Buna Vestire"),
        // 23 aprilie (Sf. Gheorghe) se calculează separat – vezi mai jos.
        (5, 8, "Sf. Apostol și Evanghelist Ioan"),
        (5, 21, "Sf. Împărați Constantin și Elena"),
        (6, 24, "Nașterea Sf. Ioan Botezătorul (Sânzienele)"),
        (6, 29, "Sf. Apostoli Petru și Pavel"),
        (7, 20, "Sf. Proroc Ilie Tesviteanul"),
        (8, 6, "Schimbarea la Față a Domnului"),
        (8, 15, "Adormirea Maicii Domnului"),
        (8, 29, "Tăierea capului Sf. Ioan Botezătorul"),
        (9, 8, "Nașterea Maicii Domnului"),
        (9, 14, "Înălțarea Sfintei Cruci"),
        (9, 26, "Mutarea Sf. Apostol și Evanghelist Ioan"),
        (10, 1, "Acoperământul Maicii Domnului"),
        (10, 14, "Sf. Cuvioasă Parascheva"),
        (10, 26, "Sf. Mare Mucenic Dimitrie, Izvorâtorul de mir"),
        (10, 27, "Sf. Cuvios Dimitrie cel Nou, ocrotitorul Bucureștilor"),
        (11, 8, "Soborul Sf. Arhangheli Mihail și Gavriil"),
        (11, 13, "Sf. Ioan Gură de Aur"),
        (11, 21, "Intrarea în Biserică a Maicii Domnului"),
        (11, 30, "Sf. Apostol Andrei, ocrotitorul României"),
        (12, 6, "Sf. Ierarh Nicolae"),
        (12, 25, "Nașterea Domnului (Crăciunul)"),
        (12, 26, "Soborul Maicii Domnului"),
        (12, 27, "Sf. Arhidiacon Ștefan"),
    ]

    // MARK: Sărbători cu dată schimbătoare (zile față de Paști, nume)

    static let mobile: [(Int, String)] = [
        (-7, "Intrarea Domnului în Ierusalim (Floriile)"),
        (-2, "Vinerea Mare"),
        (0, "Învierea Domnului (Sfintele Paști)"),
        (1, "A doua zi de Paști"),
        (5, "Izvorul Tămăduirii"),
        (39, "Înălțarea Domnului"),
        (49, "Pogorârea Sfântului Duh (Rusaliile)"),
        (50, "Sfânta Treime (a doua zi de Rusalii)"),
    ]

    static let sfGheorghe = "Sf. Mare Mucenic Gheorghe"

    /// Paștele ortodox (calcul iulian, convertit în calendarul gregorian; valabil 1900–2099).
    static func pasti(_ an: Int) -> Date {
        let a = an % 4, b = an % 7, c = an % 19
        let d = (19 * c + 15) % 30
        let e = (2 * a + 4 * b - d + 34) % 7
        let luna = (d + e + 114) / 31
        let ziua = (d + e + 114) % 31 + 1
        let iulian = zi(an, luna, ziua)
        return calendar.date(byAdding: .day, value: 13, to: iulian)!
    }

    /// Toate sărbătorile cu cruce roșie dintr-un an, sortate.
    static func sarbatori(_ an: Int) -> [Sarbatoare] {
        var dupaZi: [Date: [String]] = [:]
        func adauga(_ data: Date, _ nume: String) { dupaZi[data, default: []].append(nume) }

        for (l, z, nume) in fixe { adauga(zi(an, l, z), nume) }

        let p = pasti(an)
        for (offset, nume) in mobile {
            adauga(calendar.date(byAdding: .day, value: offset, to: p)!, nume)
        }

        // Dacă 23 aprilie cade înainte de Paști (sau chiar de Paști), se prăznuiește a doua zi de Paști.
        let gheorghe = zi(an, 4, 23)
        if gheorghe <= p {
            adauga(calendar.date(byAdding: .day, value: 1, to: p)!, sfGheorghe)
        } else {
            adauga(gheorghe, sfGheorghe)
        }

        return dupaZi
            .map { Sarbatoare(data: $0.key, nume: $0.value.joined(separator: "; ")) }
            .sorted { $0.data < $1.data }
    }

    /// Următoarele `cate` sărbători începând cu ziua `de la` (inclusiv).
    static func urmatoarele(_ cate: Int, de la: Date = .now) -> [Sarbatoare] {
        let azi = calendar.startOfDay(for: la)
        let an = calendar.component(.year, from: azi)
        return (sarbatori(an) + sarbatori(an + 1))
            .filter { $0.data >= azi }
            .prefix(cate)
            .map { $0 }
    }

    static func urmatoarea(de la: Date = .now) -> Sarbatoare {
        urmatoarele(1, de: la)[0]
    }

    /// Câte zile mai sunt de azi până la sărbătoare (0 = azi).
    static func zilePana(_ s: Sarbatoare, de la: Date = .now) -> Int {
        calendar.dateComponents([.day], from: calendar.startOfDay(for: la), to: s.data).day ?? 0
    }

    static func textZile(_ zile: Int) -> String {
        switch zile {
        case 0: return "Astăzi"
        case 1: return "Mâine"
        default:
            // În română: „20 de zile”, „101 zile”, „120 de zile”.
            let rest = zile % 100
            return rest == 0 || rest >= 20 ? "Peste \(zile) de zile" : "Peste \(zile) zile"
        }
    }

    static func dataText(_ d: Date, cuAn: Bool = false) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ro_RO")
        f.calendar = calendar
        f.dateFormat = cuAn ? "EEEE, d MMMM yyyy" : "EEEE, d MMMM"
        return f.string(from: d)
    }

    static func zi(_ an: Int, _ luna: Int, _ zi: Int) -> Date {
        calendar.date(from: DateComponents(year: an, month: luna, day: zi))!
    }
}
