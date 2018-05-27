# Data

Zdroj dat o pražském tržním řádu je volně dostupné PDF, případně [word dokument](Na%C5%99%C3%ADzen%C3%AD%20%C4%8D.%2013-2016%20Sb.%20hl.%20m.%20Prahy.doc)

## Extrakce dat a informací

Data jsou extrahována z originálního dokumentu do csv [trzni rad - trzni rad.csv](trznirad%20-%20trznirad.csv). Pro lokalizaci tržních míst bylo nutné z nestrukturovaného textu extrahovat vlastnosti , které jasně určují polohu. Extrahované vlastnosti jsou: 

- Ulice
- číslo popisné a číslo orientační
- číslo parcely
- název katastrálního území

Problémy, které z toho plynuly převážně z manuálního "nekontrolovaného" zápisu do původního dokumentu. Orientační a Popisná čísla jsou zapisovaná bez ohledu na pořadí, pokud je uvedena ulice, tak občas číslo domu chybí. Občas je uveden roh ulic, občas oblast ohraničená ulicemi. Místy je uvedeno číslo parcely bez uvedení příslušného katastárlního území.

Pro extrakci bylo použito krosreferencování textu se seznamem pražskýc ulic a seznamem katastrálních území. Z toho vyplynuly obtíže s názvy ulic jako "Hlavní", "U kostela". Stejný text se totiž vyskytuje i jinak v textu.
