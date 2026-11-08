# Prompt pour Claude Design — vérifier que rien ne manque

À coller dans le projet Claude Design « Thème Omarchy » (celui qui contient les maquettes Hanko / Signal). Joindre `docs/ETAT.md`.

---

Voici l'état actuel de l'implémentation du thème Hanko (ex-Signal) dans Omarchy 4, dans le fichier ETAT.md joint. Tout ce qui est marqué ✅ tourne sur une machine Omarchy réelle.

Parcours **toutes** les maquettes et fiches du projet (directions, thème et écrans, suite Signal/Hanko 11a à 11f, écran de veille, charte du logo, formats 16:10 / 21:9 / double écran, fiches de `specs/`) et donne-moi :

1. **La liste complète des éléments que tu avais prévus et qui n'apparaissent pas dans ETAT.md**, même petits (couleur d'un état, une marge, un son, une icône, un comportement au survol…). Pour chacun : la maquette ou la section où il se trouve, et une phrase qui décrit précisément le résultat attendu.
2. **Les éléments marqués 🟡 ou ⬜ dans ETAT.md** que tu considères indispensables pour une version 1.0, et ceux qui peuvent attendre.
3. **Ce qui a changé depuis les maquettes** et doit être reporté dedans : le nom est passé de SIGNAL à HANKO ; le fond principal est dessiné en direct (titre HANKO sur une ligne, logo Moozy noir à la place du disque) ; le menu fait 50 % de la largeur et 6 lignes ; la barre grandit de 18 px au survol ; le bureau actif est une pastille accent avec le chiffre en noir. Dis-moi si une maquette contredit l'un de ces choix.
4. Pour chaque élément manquant, si tu as un **fichier** à fournir (SVG, PNG, son, CSS…), donne-le avec son nom et l'endroit où le ranger dans le dépôt `omarchy-hanko-extras` ou dans le dépôt de la variante.

Réponds sous forme de tableau : élément · maquette/section · attendu · priorité (1.0 / plus tard) · fichier fourni (oui/non).
