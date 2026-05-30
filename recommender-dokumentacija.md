Sistem preporuke:

- U nastavku su opisane funkcionalnosti sistema preporuke, koji se može smatrati hibridnim sistemom, jer koristi, pored euklidske udaljenosti vektora s zapisima životne sredine, i pravila koja se odnose na njegove podatke u bazi podataka.

GetMostCompatibleBreeds:

- Po osnovi unesenih podataka životne sredine korisnika, računa se idealan 5D vektor osobina pasmine odabrane životinje te se vrši upit koji poredi osobine postojećih pasmina. 
- Svaka osa vektora se kreće od 0 do 1. Odgovaranjem na neobavezna pitanja životne sredine se mijenjaju vrijednosti vektora. Pitanja mogu da utiču na više osi. 

RecommendListingToUsers:

- Kada se listing s proizvodom učini vidljivim, ili stavi na popust, korisnicima koji imaju stavku u svome wishlist-u koja odgovara izrazu u naslovu listinga se šalje notifikacija, bez potrebe za ručnim slanjem notifikacija os strane radnika franšize. 
- Notifikacije se šalju samo onim korisnicima koji posjeduju jednu ili više životinja koje su ciljane od strane proizvoda (npr. vlasnik psa može imati stavku "Hrana" u wishlist-u, te mu se neće preporučivati hrana za mačke).  

AddNotesToPet:

- Kad krajnji korisnik vuče svoje podatke s servera, za sve njegove ljubimce će, ukoliko je potrebno, biti dodan zapis o medicinskim procedurama koje bi trebali imati, po specifikacijama vezanim za njihovu vrstu, spol, dob i pasminu, kao i podacima o prijašnjim procedurama.
- Ovi podaci se nalaze ne ekranu "Feed" pod stranicom "Automated".

AddUsageInfoToProductListing:

- Ukoliko korisnik pretražuje proizvode koji se troše, te koji su primjenjivi na neke od njegovih ljubimaca, sistem će ga obavijestiti o procjeni vremena trajanja količine proizvoda u ponudi, u danima, uzimajući u obzir gramažu, sumu procjena uporabe od strane svakog korisnikovog ljubimca ciljanog od strane proizvoda, te količinu po listingu. 

AddInfoToMedicalListing: 

- Podsjetnik za listinge koji nude medicinske procedure. Ukoliko je procedura primjenjiva na ljubimca, dodaje obavijest na listing. Korisnik na taj način ima potvrdu da se radi o istoj proceduri koja je bila preporučena u AddNotesToPet.

ShoppingList:

- Kad krajnji korisnik vuče svoje podatke s servera, za sve namirnice čije zalihe prati je izračunata procjena preostalih dana, po procjenama dnevnog korištenja. Ukoliko je ostalo manje zaliha nego procjena korištenja za sedmicu, dodan je zapis koji ga obavještava.
- Ovi podaci se nalaze na ekranu "Feed" pod stranicom "Automated".