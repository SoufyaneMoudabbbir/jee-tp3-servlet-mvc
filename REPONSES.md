# TP 3 : Du Servlet au MVC — Réponses aux questions

> ENIAD Berkane · GINF2 · Pr. Hayat Ouadi

---

## Question 1 — Pourquoi un `forward` quand le login échoue, mais un `sendRedirect` quand il réussit ?

**Échec → `forward`**

- Le `forward` se fait **côté serveur, dans la même requête** : les attributs placés avec
  `req.setAttribute(...)` (`erreur` et `username`) sont encore disponibles dans `login.jsp`.
- On peut donc ré-afficher le formulaire avec le message d'erreur **et le login déjà saisi**.
- Rien n'a changé côté serveur (aucune session créée, aucune donnée modifiée) : il n'y a donc
  aucun risque à ce que la requête soit rejouée.

**Succès → `sendRedirect`**

- Une connexion réussie **change l'état** du serveur : l'utilisateur est placé dans la session.
- Le `redirect` demande au navigateur d'envoyer une **nouvelle requête GET** vers `/dashboard` :
  l'URL affichée devient `/dashboard` (et non `/login`).
- Si l'utilisateur appuie sur **F5**, le navigateur recharge le `GET /dashboard` et **ne renvoie pas
  le POST** contenant le mot de passe (pas de fenêtre « Confirmer le renvoi du formulaire »).
- C'est l'application du pattern **Post/Redirect/Get (PRG)**.

> En résumé : `forward` = même requête, URL inchangée, attributs conservés ;
> `redirect` = nouvelle requête, URL modifiée, à utiliser après tout changement d'état.

---

## Question 2 — F5 juste après l'ajout d'un produit

**(a) `doPost` fait un `forward` vers la liste**

La dernière requête connue du navigateur est le **POST** `/produits`. En appuyant sur F5, le
navigateur propose de **renvoyer le formulaire** ; si l'utilisateur accepte, le POST est rejoué et
le produit est **ajouté une deuxième fois** (doublon). De plus, l'URL affichée reste celle du POST.

**(b) `doPost` fait un `redirect` vers `/produits`**

Après le POST, le serveur répond `302` et le navigateur fait un **GET `/produits`**. La dernière
requête est donc ce GET : F5 recharge simplement la liste, **sans doublon** et sans alerte.

**Nom du pattern :** **Post/Redirect/Get (PRG)**. Il est appliqué ici après chaque POST réussi
(création, modification, suppression), avec un message *flash* stocké en session pour informer
l'utilisateur sur la page de destination.

---

## Question 3 — Nom de produit `<script>alert('XSS')</script>`

| Affichage dans `list.jsp` | Résultat |
|---|---|
| `${produit.nom}` | La chaîne est insérée **telle quelle** dans le HTML : le navigateur l'interprète comme une balise `<script>` et **l'alerte s'exécute**. Comme le nom est enregistré dans le DAO, le script s'exécute pour **chaque visiteur** de la liste : c'est une **faille XSS stockée**. |
| `<c:out value="${produit.nom}"/>` | Les caractères spéciaux sont **échappés** (`<` → `&lt;`, `>` → `&gt;`, `'` → `&#039;`…). Le navigateur affiche le texte `<script>alert('XSS')</script>` **comme du texte**, sans l'exécuter. |

**Conclusion :** il ne faut **jamais** faire confiance aux données saisies par l'utilisateur. Toute
donnée affichée doit être **échappée** : `<c:out>` dans le contenu des pages, et
`${fn:escapeXml(...)}` dans les attributs HTML (par exemple `value="..."` des champs du
formulaire). C'est ce que fait le projet dans `list.jsp`, `form.jsp`, `login.jsp` et `dashboard.jsp`.

---

## Question 4 — Avantage du filtre et autres usages

**Avantages du filtre `AuthFilter` par rapport à une vérification dans chaque servlet :**

- **Règle centralisée** : le contrôle d'accès est écrit **une seule fois**, à un seul endroit.
- **Pas de duplication** : on supprime le `if (user == null) redirect(...)` recopié dans chaque
  servlet (DRY) ; une modification de la règle se fait dans un seul fichier.
- **Impossible d'oublier une page** : toute URL couverte par le mapping
  (`/dashboard`, `/produits`, `/produits/*`) est protégée automatiquement, y compris les futures
  servlets ajoutées sous `/produits/*`.
- **Séparation des responsabilités** : les servlets ne s'occupent que de leur logique métier ; la
  sécurité est une préoccupation transversale gérée **avant** que la requête n'atteigne le contrôleur.

**Deux autres usages classiques des filtres :**

1. **Encodage des caractères** : appeler `req.setCharacterEncoding("UTF-8")` (et fixer l'encodage de
   la réponse) pour toutes les requêtes, au lieu de le répéter dans chaque `doPost`.
2. **Journalisation (logs)** : tracer chaque requête (méthode, URL, utilisateur, durée de traitement,
   code de réponse).

Autres exemples : compression GZIP des réponses, ajout d'en-têtes de sécurité
(`Content-Security-Policy`, `X-Frame-Options`…), gestion du CORS, mesure des performances.
