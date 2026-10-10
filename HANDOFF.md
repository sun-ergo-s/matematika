# Handoff: Matematika pre 3. ročník

Cvičná aplikácia z matematiky pre 3. ročník ZŠ (8-ročné dieťa). Obsah a poradie cvičení nasledujú pracovnú učebnicu (Taktik, Matematika 3, 1. časť). Dieťa výsledok vždy píše samo, nevyberá z možností a, b, c, d.

- **Live:** https://sun-ergo-s.github.io/matematika/
- **Repozitár:** https://github.com/sun-ergo-s/matematika (verejný, vetva `main`)
- **Lokálne:** `C:\apps\matematika`

## Súbory

| Súbor | Účel |
|---|---|
| `index.html` | Celá aplikácia: HTML, CSS aj JS v jednom súbore. Bez buildu a bez závislostí. |
| `manifest.webmanifest` | PWA manifest. Názov na ploche je stále „Násobilka“ (zatiaľ nezmenené), režim standalone, orientácia na výšku. |
| `sw.js` | Service worker, aby aplikácia fungovala offline. |
| `icons/` | Favicon (32, 64), ikony aplikácie (192, 512), maskable ikona (512) a apple-touch-icon (180). Motív: biele „M“ na fialovom pozadí. |
| `tools/make-icons.ps1` | Generátor ikon (System.Drawing). Spúšťa sa cez `powershell -File tools\make-icons.ps1`. |
| `ucebnica.pdf` | Učebnica, z ktorej sa berú témy. Je v `.gitignore`: chránený materiál, 58 MB, repozitár je verejný. |

Jediná externá závislosť je písmo Nunito z Google Fonts. Bez internetu sa použije záložné systémové písmo.

## Obsah aplikácie

Menu je rozdelené do sekcií podľa učebnice. Každá téma má kroky v poradí učenia a posledný krok „Všetko“ (`mix`).

| Téma (`id`) | Strany učebnice (PDF) | Kroky |
|---|---|---|
| Desiatky a jednotky (`dj`) | 3 – Zopakuj si, úloha 3 | Obrázok (tyčinky a kocky → číslo), Rozklad (`38 = ? D 8 J`), Zápis (`3 D 8 J = ?`, aj `2 D 15 J` a `8 J 3 D`) |
| Číselné rady (`rad`) | 4 – Zopakuj si, úloha 8 | Dopredu (±1, 2, 5, 10), Dozadu, Ťažšie (±3, ±4, +5 nie od násobku 5) |
| Úvod do násobenia (`uvod`) | 9–12 | Skupiny (obrázok → súčet → súčin), Sčítanie (`7+7+7 = ?·7`), Výmena (`6·9 = 9·?` a porovnávanie `<, >, =`), 0, 1, 10 |
| Úvod do delenia (`uvdel`) | 13–15 | Rozdeľ (koľko v jednej skupine), Po koľko (koľko skupín), Násobenie (`4·2=8 → 8:4=?`), 0, 1, 10 |
| Násobilka a delilka (`nasob`) | – | Násobenie, Delenie, Všetko (zatiaľ len číslo 2) |

Ďalšia téma v učebnici je **Párne a nepárne číslo** (PDF s. 16). Text PDF sa dá vytiahnuť cez `pypdf` (`PYTHONIOENCODING=utf-8`). Obrázky z PDF sa na tomto počítači nedajú vykresliť, chýba poppler.

## Ako je postavený `index.html`

Obrazovky (`<section>`): `menu` → `home` (obrazovka témy) → `game` → `end`. Prepína sa cez `show(…)`. Okrem nich je tu modálne okno `#resetModal`.

Skript je rozdelený do sekcií označených `// ===== … =====`.

### Témy

Každá téma je objekt (`DJ`, `RADY`, `UVOD`, `UVDEL`, `NASOB`) s poliami:

- `id`, `icon`, `title`, `desc`
- `modes`: `{ id, sym, name, theory? }`, kde posledný je `mix`. `theory()` vráti obsah karty „📘 Zapamätaj si!“ na obrazovke témy.
- `progressive: true`: ako predvolený sa ponúkne prvý krok, ktorý ešte nie je celý zvládnutý. Inak sa použije `defaultMode`.
- `facts`: príklady `{ key, kind, ans, label, solved, … }`.
  - `kind` je id kroku.
  - `label` je krátky text do mriežky „Čo už vieš“.
  - `solved` je celý zápis do zoznamov na konci kola.
  - `input: 'cmp'` znamená odpoveď znakom `<`, `=` alebo `>`. Klávesnica vtedy ukáže znaky namiesto číslic.
- `view(f)`: zadanie `{ prompt?, pic?, formula?, parts: [html | ANS], size? }`.
  - `ANS` označuje miesto políčka s odpoveďou.
  - `size` je `'mid'` alebo `'seq'` (menšie písmo).
- `hint(f)`: pomôcka `{ text, node }`.
- `trophy(mode)`: voliteľný nadpis pri zvládnutí všetkého. Ak vráti `null`, použije sa všeobecný text.

Poradie v menu určuje `SECTIONS`.

**Kľúče príkladov musia byť jedinečné naprieč témami.** Násobilka má pôvodné kľúče (`2·7`, `14:7`), aby sa zachoval starý pokrok. Nové témy majú predpony `dj:`, `rad:`, `un:` a `ud:`.

Pomocné kreslenie:

- `dotGroups(count, size)`: skupiny guličiek. Prázdna skupina je prázdny tanier.
- `blocks(d, j, labels)`: tyčinky (desiatky) a kocky (jednotky). Pri viac ako 9 kockách je 10 z nich v rámčeku „10 J = 1 D“.
- `looseDots(n, cols)`: ešte nerozdelené guličky.
- `shareSetup(n, k)`: guličky → k prázdnych tanierov.
- `theory(rows)`: poskladá kartu teórie.
- `sum(c, v)`: súčet „7 + 7 + 7“.

### Uložený pokrok

Je v `localStorage` pod `STORE_KEY = 'matematika.stats.v1'` ako `{ [key]: { seen, streak, weak, hints, lastHint } }`. Pre všetky témy je spoločný.

`record(key, result)`, kde `result` je jedno z:

- `'ok'`: správne na prvý pokus bez pomôcky, `streak++`.
- `'hint'`: správne, ale s pomôckou. Vynuluje `streak`, ale príklad sa neoznačí ako `weak`.
- `'bad'`: chyba. Vynuluje `streak` a nastaví `weak = true`.

`levelOf(key)` vráti úroveň: `new` (sivá) → `weak` (červená) → `mastered` (zelená, `streak >= 3`) → inak `learning` (žltá). **Prah 3 správnych odpovedí po sebe je výslovné rozhodnutie používateľa.**

„Vymazať pamäť“ je v menu a maže pokrok všetkých tém.

### Výber úloh

`pickSession(topic, mode)`, `SESSION_LEN = 10`:

1. Nezvládnuté príklady (`weak`, potom `learning`, potom `new`) majú v kole isté miesto.
2. Aspoň `MIN_REVIEW = 2` miesta dostanú zvládnuté príklady na opakovanie, ak nejaké sú.
3. Zvyšok kola doplnia zvládnuté príklady a nakoniec sa celé kolo zamieša.

### Priebeh kola

- **Prvá chyba:** odpoveď sa zatrasie, zobrazí sa „Skús to ešte raz“ a automaticky sa ukáže pomôcka.
- **Druhá chyba:** zobrazí sa správny výsledok. Príklad sa zaznamená ako `bad` a na koniec kola sa pridá ešte raz, ale len raz. Opakované príklady sa nezapočítavajú do hviezdičiek ani do štatistík.
- **Pomôcka:** ak ju dieťa otvorí samo tlačidlom 💡, správna odpoveď dá 💡 namiesto ⭐ a zaznamená sa ako `'hint'`. Pomôcka zobrazená automaticky po chybe sa ako `'hint'` nepočíta.

### Zvuk a vstup

- **Zvuk:** `beep(freqs, dur, vol)` cez WebAudio, bez zvukových súborov. Tlačidlo 🔊 prepína `soundOn`.
- **Vstup:**
  - klávesnica na obrazovke (`.key[data-k]`, číslice majú triedu `num`, znaky `<`, `=`, `>` triedu `sym`),
  - fyzická klávesnica: číslice, `<`, `>`, `=`, Backspace/Delete, Enter/medzerník.
  - Odpoveď má najviac 3 číslice.

## Rozloženie

Kontrolovať na 360×740 px, teda na malom telefóne:

- Políčko s odpoveďou nemá padať na nový riadok. Dlhé súčty patria do `formula` nad políčko.
- Klávesnica musí byť celá viditeľná bez posúvania, kým nie je otvorená pomôcka.

Pomáhajú pri tom media queries `max-width: 380px` a `max-height: 820px`.

## PWA a service worker

- `sw.js` načítava vlastné súbory najprv zo siete a pri výpadku z cache, takže úpravy sa prejavia hneď. Google Fonts berie najprv z cache.
- Názov cache je `matematika-v1`. Pri pridaní nového statického súboru ho doplňte do `FILES`. Ak ide o zásadnú zmenu, zvýšte verziu cache.
- Service worker sa registruje len cez http(s), pri otvorení cez `file://` nie.
- Na iPhone má aplikácia pridaná na plochu vlastné úložisko, oddelené od Safari. Ikona na ploche sa po zmene neaktualizuje sama.

## Lokálny vývoj

```powershell
python -m http.server 8080 --bind 127.0.0.1 --directory C:\apps\matematika
# potom http://localhost:8080/
```

Kontrola syntaxe JS (v Bash):

```bash
sed -n '/<script>/,/<\/script>/p' index.html | sed '1d;$d' > "$TEMP/check.js" && node --check "$TEMP/check.js"
```

Na kontrolu celej aplikácie v prehliadači sa osvedčil `puppeteer-core` s nainštalovaným Chrome (`C:/Program Files/Google/Chrome/Application/chrome.exe`). Test prejde všetky témy a kroky, odpovedá správne aj nesprávne, otvára pomôcky a kontroluje vodorovné pretečenie, zalomenie políčka a viditeľnosť klávesnice. Globálne premenné ako `TOPICS`, `current` a `press` sú dostupné cez `page.evaluate`.

## Nasadenie

- **GitHub CLI** je nainštalované, ale **nie je v PATH v Bashi**. Volá sa cez `& "$env:ProgramFiles\GitHub CLI\gh.exe"` v PowerShelli.
- **Prihlásenie:** prihlásený je účet `sun-ergo-s`. Už prebehlo `gh auth setup-git`, takže `git push` funguje bez ďalšieho prihlasovania.
- **GitHub Pages:** zostavujú sa z vetvy `main` a koreňa `/`. Push na `main` stránku nasadí za 1 až 2 minúty. Stav overíte cez `gh api repos/sun-ergo-s/matematika/pages/builds/latest --jq '.status,.commit'`.
- **Commit:** správy sú po slovensky a končia riadkom `Co-Authored-By` podľa inštrukcií harnessu.

## Preferencie používateľa

- Komunikácia prebieha po slovensky.
- **Na GitHub (live) pushovať až na výslovný pokyn.** Používateľ hovorí napríklad „nahraj na GitHub“ alebo „pushni live“.
- **Nové témy:**
  - Držať sa konceptov a postupu učenia z učebnice. Postup je predmet → obrázok → zápis.
  - Ku každému kroku patrí teória „Zapamätaj si!“.
  - Výsledné cvičenie (napríklad násobilka) ide až po úvodných krokoch.
- **Texty v UI:**
  - Píšu sa rodovo neutrálne, napríklad „Máš 8 z 10 hviezdičiek“, nie „získala si“.
  - Používa sa školský zápis `·` a `:`.
  - Tón je pre deti: veľké tlačidlá a povzbudenie.
- **Žiadne natívne `alert` ani `confirm`.** Potvrdenia sa robia ako vlastné modálne okná v štýle aplikácie (vzor je `#resetModal`).
- **Hlasový syntetizátor (TTS) pri správnej odpovedi používateľ odmietol.** Nepridávať ho.
- Výsledok vždy píše dieťa samo. Žiadne možnosti a, b, c, d. Znaky `< = >` pri porovnávaní sú výnimka, lebo ide o úlohu z učebnice.

## Možné ďalšie kroky (zatiaľ nezadané)

- Ďalšie témy z učebnice: Párne a nepárne číslo (PDF s. 16) a ďalej.
- Pridať ďalšie čísla násobilky (3, 4, …) cez `TABLES`. Pri viacerých číslach treba skontrolovať veľkosť kola a text trofeje.
- Premenovať aplikáciu v manifeste a v `apple-mobile-web-app-title` z „Násobilka“ na „Matematika“.
- Export a import pokroku do súboru, prípadne synchronizácia medzi zariadeniami. Pokrok je teraz len v `localStorage` jedného prehliadača.
