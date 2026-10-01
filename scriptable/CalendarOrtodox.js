// Calendar Ortodox – widget pentru Scriptable (iPhone)
// Arată următoarea sărbătoare cu cruce roșie (stil nou, Biserica Ortodoxă Română).
// Atinge widget-ul ca să vezi lista completă a anului.

// ===== Sărbători cu dată fixă: [lună, zi, nume] =====
const FIXE = [
  [1, 1, "Tăierea împrejur a Domnului; Sf. Vasile cel Mare"],
  [1, 6, "Botezul Domnului (Boboteaza)"],
  [1, 7, "Soborul Sf. Ioan Botezătorul"],
  [1, 30, "Sfinții Trei Ierarhi: Vasile, Grigorie și Ioan"],
  [2, 2, "Întâmpinarea Domnului"],
  [2, 24, "Întâia și a doua aflare a capului Sf. Ioan Botezătorul"],
  [3, 9, "Sfinții 40 de Mucenici din Sevastia"],
  [3, 25, "Buna Vestire"],
  // 23 aprilie (Sf. Gheorghe) se calculează separat, mai jos.
  [5, 8, "Sf. Apostol și Evanghelist Ioan"],
  [5, 21, "Sf. Împărați Constantin și Elena"],
  [6, 24, "Nașterea Sf. Ioan Botezătorul (Sânzienele)"],
  [6, 29, "Sf. Apostoli Petru și Pavel"],
  [7, 20, "Sf. Proroc Ilie Tesviteanul"],
  [8, 6, "Schimbarea la Față a Domnului"],
  [8, 15, "Adormirea Maicii Domnului"],
  [8, 29, "Tăierea capului Sf. Ioan Botezătorul"],
  [9, 8, "Nașterea Maicii Domnului"],
  [9, 14, "Înălțarea Sfintei Cruci"],
  [9, 26, "Mutarea Sf. Apostol și Evanghelist Ioan"],
  [10, 1, "Acoperământul Maicii Domnului"],
  [10, 14, "Sf. Cuvioasă Parascheva"],
  [10, 26, "Sf. Mare Mucenic Dimitrie, Izvorâtorul de mir"],
  [10, 27, "Sf. Cuvios Dimitrie cel Nou, ocrotitorul Bucureștilor"],
  [11, 8, "Soborul Sf. Arhangheli Mihail și Gavriil"],
  [11, 13, "Sf. Ioan Gură de Aur"],
  [11, 21, "Intrarea în Biserică a Maicii Domnului"],
  [11, 30, "Sf. Apostol Andrei, ocrotitorul României"],
  [12, 6, "Sf. Ierarh Nicolae"],
  [12, 25, "Nașterea Domnului (Crăciunul)"],
  [12, 26, "Soborul Maicii Domnului"],
  [12, 27, "Sf. Arhidiacon Ștefan"],
];

// ===== Sărbători legate de Paști: [zile față de Paști, nume] =====
const MOBILE = [
  [-7, "Intrarea Domnului în Ierusalim (Floriile)"],
  [-2, "Vinerea Mare"],
  [0, "Învierea Domnului (Sfintele Paști)"],
  [1, "A doua zi de Paști"],
  [5, "Izvorul Tămăduirii"],
  [39, "Înălțarea Domnului"],
  [49, "Pogorârea Sfântului Duh (Rusaliile)"],
  [50, "Sfânta Treime (a doua zi de Rusalii)"],
];

const ROSU = "#c0141a";
const LUNI = ["ianuarie", "februarie", "martie", "aprilie", "mai", "iunie", "iulie",
  "august", "septembrie", "octombrie", "noiembrie", "decembrie"];
const ZILE = ["duminică", "luni", "marți", "miercuri", "joi", "vineri", "sâmbătă"];

function zi(an, luna, z) { return new Date(an, luna - 1, z); }
function plusZile(d, n) { return new Date(d.getFullYear(), d.getMonth(), d.getDate() + n); }
function inceputZi(d) { return new Date(d.getFullYear(), d.getMonth(), d.getDate()); }

// Paștele ortodox: calcul iulian + 13 zile (valabil 1900–2099).
function pasti(an) {
  const a = an % 4, b = an % 7, c = an % 19;
  const d = (19 * c + 15) % 30;
  const e = (2 * a + 4 * b - d + 34) % 7;
  const luna = Math.floor((d + e + 114) / 31);
  const z = ((d + e + 114) % 31) + 1;
  return plusZile(zi(an, luna, z), 13);
}

function sarbatori(an) {
  const map = new Map();
  const adauga = (data, nume) => {
    const k = data.getTime();
    if (!map.has(k)) map.set(k, { data, nume: [] });
    map.get(k).nume.push(nume);
  };
  for (const [l, z, nume] of FIXE) adauga(zi(an, l, z), nume);
  const p = pasti(an);
  for (const [n, nume] of MOBILE) adauga(plusZile(p, n), nume);
  // Dacă 23 aprilie cade înainte de Paști, Sf. Gheorghe se prăznuiește a doua zi de Paști.
  const gheorghe = zi(an, 4, 23);
  adauga(gheorghe <= p ? plusZile(p, 1) : gheorghe, "Sf. Mare Mucenic Gheorghe");
  return [...map.values()]
    .map(s => ({ data: s.data, nume: s.nume.join("; ") }))
    .sort((x, y) => x.data - y.data);
}

function urmatoarele(cate, de = new Date()) {
  const azi = inceputZi(de);
  const an = azi.getFullYear();
  return sarbatori(an).concat(sarbatori(an + 1)).filter(s => s.data >= azi).slice(0, cate);
}

function zilePana(s, de = new Date()) {
  return Math.round((s.data - inceputZi(de)) / 86400000);
}

function textZile(n) {
  if (n === 0) return "Astăzi";
  if (n === 1) return "Mâine";
  const rest = n % 100;
  return rest === 0 || rest >= 20 ? `Peste ${n} de zile` : `Peste ${n} zile`;
}

function dataText(d, cuAn = false) {
  const t = `${ZILE[d.getDay()]}, ${d.getDate()} ${LUNI[d.getMonth()]}`;
  return cuAn ? `${t} ${d.getFullYear()}` : t;
}

// ===== Widget =====
function creeazaWidget(familie) {
  const lista = urmatoarele(3);
  const prima = lista[0];
  const zile = textZile(zilePana(prima));
  const w = new ListWidget();
  w.refreshAfterDate = plusZile(new Date(), 1); // se actualizează după miezul nopții

  if (familie === "accessoryInline") {
    w.addText(`✝ ${zile}: ${prima.nume}`);
    return w;
  }
  if (familie === "accessoryRectangular" || familie === "accessoryCircular") {
    const t1 = w.addText(`✝ ${zile}`);
    t1.font = Font.boldSystemFont(14);
    const t2 = w.addText(prima.nume);
    t2.font = Font.systemFont(12);
    t2.lineLimit = 2;
    return w;
  }

  w.backgroundColor = Color.dynamic(new Color("#ffffff"), new Color("#1c1c1e"));
  w.setPadding(14, 14, 14, 14);
  const rosu = new Color(ROSU);
  const secundar = Color.dynamic(new Color("#6e6e73"), new Color("#a1a1a6"));

  const sus = w.addStack();
  sus.layoutHorizontally();
  sus.topAlignContent();
  const stanga = sus.addStack();
  stanga.layoutVertically();

  const z = stanga.addText(`✝ ${zile}`);
  z.font = Font.boldSystemFont(15);
  z.textColor = rosu;
  stanga.addSpacer(4);
  const n = stanga.addText(prima.nume);
  n.font = Font.boldSystemFont(familie === "small" ? 16 : 17);
  n.lineLimit = 4;
  n.minimumScaleFactor = 0.7;
  stanga.addSpacer();
  const d = stanga.addText(dataText(prima.data));
  d.font = Font.systemFont(12);
  d.textColor = secundar;

  if (familie !== "small") {
    sus.addSpacer(14);
    const dreapta = sus.addStack();
    dreapta.layoutVertically();
    const apoi = dreapta.addText("Apoi");
    apoi.font = Font.semiboldSystemFont(12);
    apoi.textColor = secundar;
    for (const s of lista.slice(1)) {
      dreapta.addSpacer(6);
      const dt = dreapta.addText(dataText(s.data));
      dt.font = Font.systemFont(11);
      dt.textColor = rosu;
      const nm = dreapta.addText(s.nume);
      nm.font = Font.systemFont(12);
      nm.lineLimit = 2;
    }
    dreapta.addSpacer();
  }
  return w;
}

// ===== Lista anului (când atingi widget-ul sau rulezi scriptul) =====
async function arataLista() {
  const azi = inceputZi(new Date());
  const an = azi.getFullYear();
  const t = new UITable();
  t.showSeparators = true;

  const prima = urmatoarele(1)[0];
  const cap = new UITableRow();
  cap.height = 90;
  cap.backgroundColor = new Color(ROSU);
  const c = cap.addText(`✝ ${textZile(zilePana(prima))}: ${prima.nume}`, dataText(prima.data, true));
  c.titleColor = Color.white();
  c.subtitleColor = Color.white();
  c.titleFont = Font.boldSystemFont(17);
  t.addRow(cap);

  for (const a of [an, an + 1]) {
    const h = new UITableRow();
    h.isHeader = true;
    h.addText(`Sărbători ${a}`).titleFont = Font.boldSystemFont(20);
    t.addRow(h);
    for (const s of sarbatori(a)) {
      const r = new UITableRow();
      r.height = 60;
      const cel = r.addText(s.nume, dataText(s.data));
      cel.subtitleColor = new Color(ROSU);
      if (s.data < azi) {
        cel.titleColor = Color.gray();
        cel.subtitleColor = Color.gray();
      }
      if (s.data.getTime() === azi.getTime()) cel.titleFont = Font.boldSystemFont(16);
      t.addRow(r);
    }
  }
  await t.present();
}

if (typeof config !== "undefined") {
  if (config.runsInWidget) {
    Script.setWidget(creeazaWidget(config.widgetFamily));
    Script.complete();
  } else {
    arataLista().then(() => Script.complete());
  }
} else if (typeof module !== "undefined") {
  module.exports = { sarbatori, urmatoarele, pasti, textZile, dataText, zilePana };
}
