# Solvro_Project
# ReadMe

Podstawą aplikacji jest TabBarControoler, dzieli się on na Characters i Episodes. 

Characters:
  - Wyświetla wszyskich bohaterów
  - W momencie naciśnięcia na daną komórkę przechodzimy do szczegółowego opisu postaci
  - Za pomocą lewego przycisku znaajdującego się w NavigationBar, mamy możliwość posortowania postaci
  - Za pomocą prawego przycisku znaajdującego się w NavigationBar, mamy możliwość pokazania polubionych postaci
  - W momencie naciśnięcia na zdjęcie danej postaci możemy ją polubić, naciskając kolejno, odlubić
  - Istanieje także możliwośc przeszukowania postaci ze względu na odcinek
    - Jeśli jednak zaczniemy szukać w momencie "pokazywania polubionych" to szukamy postaci z danego odcinka tylko wśród ulunionych
    - Jeśli jednak zaczniemy szukać w momenciensortowania, to szukamy postaci z danego odcinka tylko wśród tych posortowanych
  - W momencie kiedy znajdujemy się w kategorii "ulubione" mamy możliwość posortowania ze względu na status
  - W momencie kiedy wyświetlamy posortowane postaci, możemy nacisnąć "gwiazdkę" za pomocą której wyekstraktujemy i pokażemy tylko polubione
  

Episodes:
 - Wyświetla wszystkie odcinki Rick and Morty 
 - Odcinki można przeszukiwać, po ich nazwie
 - W momencie naciśnięcia na daną komórkę przechodzimy do spisu postaci które w tym odcinku występują

W Aplikacji użyłem Core Data, jako bazę danych która przetrzymuje i wyświetla potrzebne dane w razie braku połączenia z internetem.
