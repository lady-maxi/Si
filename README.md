Description
Cette application mobile Flutter est un prototype de lecteur d’articles Hacker News avec une gestion des favoris.
Elle récupère des articles via une API, affiche la liste des articles, permet de consulter les détails et de sauvegarder des articles en favoris dans une base de données locale SQLite.


Fonctionnalités
1.Lister des articles
2.vue detaillée d'un article avec commentaires
3.Ajout et suppression de favoris (persistés localement)
4.Etat des favoris féré avec Provider
5.Base de données SQLite avec sqflite
6.affichage de l'article à travers le navigateur 

Structure
LIB/
  main.dart
  models
  services
  pproviders
  screens
  widgets
  database

Technologies
  -flutter
  -Provider
  -sqflite
  -API HTTP
