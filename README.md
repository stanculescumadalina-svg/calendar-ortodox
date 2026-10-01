# Calendar Ortodox ✝

Aplicație simplă pentru iPhone cu sărbătorile cu **cruce roșie** din calendarul ortodox
(stil nou, Biserica Ortodoxă Română) și un **widget** care arată următoarea sărbătoare
direct pe ecranul telefonului.

- Aplicația: lista sărbătorilor pe luni, cu săgeți pentru anul anterior/următor.
- Widget pe ecranul principal (mic și mediu) și pe ecranul de blocare.
- Funcționează complet offline – Paștele și sărbătorile mobile se calculează automat pentru orice an.

## Instalare pe iPhone

Ai nevoie de un Mac cu **Xcode** (gratuit din App Store) și un cablu pentru telefon.

1. Deschide `CalendarOrtodox.xcodeproj` în Xcode.
2. Click pe proiect (stânga sus) → tab-ul **Signing & Capabilities**.
   Pentru **ambele** ținte (`CalendarOrtodox` și `SarbatoareWidgetExtension`) alege la **Team**
   contul tău Apple (Add Account… dacă nu apare).
   Dacă Xcode spune că identificatorul e folosit deja, schimbă `ro.calendarortodox.app`
   cu ceva unic (ex. `ro.numeletau.calendar`) și widget-ul în `ro.numeletau.calendar.widget`.
3. Conectează iPhone-ul, alege-l sus în bara Xcode și apasă ▶︎ (Run).
4. Pe telefon: **Setări → General → VPN și gestionare dispozitiv** → ai încredere în dezvoltator.
   (Pe iOS 16+ trebuie activat și **Setări → Confidențialitate → Mod dezvoltator**.)
5. Ține apăsat pe ecranul principal → **+** → caută „Calendar Ortodox” → adaugă widget-ul.

> Cu un cont Apple gratuit aplicația expiră după 7 zile și trebuie reinstalată din Xcode
> (pasul 3). Cu un cont Apple Developer plătit ține un an.

## Modificarea listei de sărbători

Totul este în `Shared/Sarbatori.swift`:
- `fixe` – sărbătorile cu dată fixă (lună, zi, nume);
- `mobile` – sărbătorile legate de Paști (număr de zile față de Paști);
- Sf. Gheorghe se mută automat în a doua zi de Paști când 23 aprilie cade înainte de Paști.
