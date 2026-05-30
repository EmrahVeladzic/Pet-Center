Potrebno prije pokretanja (zavisi od ciljane platforme):

- Docker Desktop (odnosno Docker Engine + Docker Compose v2 ili noviji ukoliko se rad pregleda na Linuxu),
- FlutterSDK (stable),
- Android Studio,
- Android SDK,
- Emulator ili fizički uređaj. 

Koraci potrebni za pokretanje:

1. U root folderu projekta (Pet-Center) pokrenuti komandu "docker compose up -d" (odnosno "docker compose up --build -d" ukoliko se radi o prvom pokretanju).
2. Nakon što se API pokrene, bit će dostupan na portu "8080" (moguće postaviti port u .env).
3. Putanju do API-a možete postaviti u "./Frontend/pet_center_app/assets/dart_config.json", kao i putem komande "flutter run --dart-define=API_BASE_URL=http://<adresa>:<port>".
4. Ukoliko je sve prošlo bez problema, aplikacija bi trebala funkcionisati.

Pristupni podaci:

- Vlasnik instance koristi e-mail adresu "simba@example.com", a lozinku "Abcd1234". Ovi podaci se mogu postaviti prije prvog pokretanja API u .env datoteci, kao varijable "InstanceOwner__Contact", te "InstanceOwner__Password", te je njihovo korištenje za stvaranje računa preduslov za seeding i pokretanje API (poželjno je ukloniti vrijednosti nakon prvog pokretanja). 
- Krajnji korisnici (uloga "User") koriste e-mail adrese u formatu "user<n>@example.com", gdje "n" predstavlja broj od 1 do 10, npr. "user1@example.com". Njihova lozinka je "test".
- Poslovni računi, kao i administratori koriste istu lozinku, s tim što je format poslovnih računa "employee<n>@example.com", a administratora "admin<n>@example.com".
- API je trenutno podešen da elektronsku poštu šalje lokalno putem servisa "MailHog" (moguće podesiti za stvarno slanje u .env), te ukoliko vršite registraciju, transfer računa ili želite pristupiti putem one-time pristupnog koda, potrebno je da istim pristupite na "http://localhost:8025/".

Seeding:

- Za pregled nije obavezno, ali je preporučeno upoznati se sa generisanim podacima u datoteci "./API/PetCenterServices/Seeder/Implementation/TestSeeder.cs".
- Seeding implementira "ISeeder", te nastoji pokriti razne slučajeve, kao i testirati cleanup.
- Seeding nastoji da ne generiše više podataka nego što je potrebno, s ciljem da se prvo pokretanje izvrši brzo. 
- Većina podataka, uključujući slike, je proceduralno generisana.
- Varijabla okruženja "Seeder__Seed" podešava seed vrijednost, dok "Seeder__Static" brani da se generišu podaci koji nisu statični (korisnici, franšize, ljubimci, itd.).