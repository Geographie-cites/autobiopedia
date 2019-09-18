# autobiopedia

Web scrapping Wikipedia for autobiography detection
Moissonage de Wikipédia à la recherche des autobiographies

## Contexte

Le milieu académique vit une grande crise de narcissisme (cf. Lemaître B., 2017, "Science, narcissism and the quest for visibility", *The FEBS Journal*, https://doi.org/10.1111/febs.14032). Dans ce contexte, Wikipédia devient un tremplin de promotion des chercheurs qui y couchent leur autobiographie en dépit des [recommandations de l'encyclopédie](https://fr.wikipedia.org/wiki/Wikip%C3%A9dia:Autobiographie).

Si des chercheurs s'affichent sur Wikipédia, d'autres chercheurs peuvent bien afficher ceux qui s'affichent sur Wikipédia.

## Structure de l'outil

- liste pré-établies des catégories requêtables (`Historien du XXIe siècle`, `Sociologue_français_du_XXe_siècle`, etc.), à regrouper par discipline
- extraction de la liste des individus de la catégorie 
- pour un individu donné, extraction de l'historique des modifications
- somme de la taille des contributions par utilisateur
- calcul de mesures de concentration (p.ex. entropie relative)
- détection d'un seuil à partir de la distribution de la mesure de concentration
- CRITÈRE 1 : si le nombre de contributeurs est égal inférieur ou égal à 3 (l'autobiographe aura 1, 2, peut-être 3 comptes utilisateur maximum) et/ou si l'entropie relative est faible, le contenu d'une page est éditée par très peu de contributeurs, page candidate à l'autobiographie
- sélection du petit nombre des contributeurs principaux (l'autobiographe aura 1, 2, peut-être 3 comptes utilisateur maximum)
- extraction de l'historique des contributions des contributeurs principaux
- somme de la taille des contributions par page
- calcul de la concentration (p.ex. entropie relative)
- CRITÈRE 2 : si le nombre de pages modifiées est égal à 1, ou que l'entropie relative est faible, le contributeur est caractérisé comme autobiographe


----------
