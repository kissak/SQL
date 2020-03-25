/*1. Hozzunk l�tre egy sorsz�mgener�tort (Sequence) 
�s k�rdezz�k le a k�vetkez� �rt�k�t, aktu�lis �rt�k�t!*/

CREATE SEQUENCE sorsz�mpr�ba START WITH 1000 INCREMENT BY 10;
SELECT sorsz�mpr�ba.nextval FROM dual;
SELECT sorsz�mpr�ba.currval FROM dual;

/*2. T�r�lj�k ki az �sszes t�bl�nakat �s sorozatunkat!*/

SELECT * FROM user_objects
ORDER BY object_type;

SELECT 
'drop '|| object_type ||' '
||object_name
||case when lower(object_type)='table' then ' purge;' else ';' end Lefuttatni
FROM user_objects
where lower(object_type) in ('table','sequence') and lower(generated)='n'
ORDER BY created DESC;

select * from user_objects;

/*3. Hozzunk l�tre egy KOLCSONZO t�bl�t, azonos�t� �s n�v legyen benne. 
Az azonos�t� automatikusan gener�l�djon!*/

CREATE TABLE kolcsonzo
(kid NUMBER(4) GENERATED AS IDENTITY PRIMARY KEY
,nev VARCHAR2(40));

INSERT INTO kolcsonzo
VALUES(
10
,'M�zga G�za'
);

INSERT INTO kolcsonzo(nev)
VALUES('M�zga G�za');
INSERT INTO kolcsonzo(nev)
VALUES('M�zga Alad�r');
INSERT INTO kolcsonzo(nev)
VALUES('Hufn�gel Pisti');

SELECT * FROM kolcsonzo;
ROLLBACK;

COMMIT;


DROP TABLE kolcsonzo PURGE;

CREATE TABLE kolcsonzo
(kid NUMBER(4) GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
,nev VARCHAR2(40));

INSERT INTO kolcsonzo
VALUES(
10
,'M�zga G�za'
);


INSERT INTO kolcsonzo(nev)
VALUES('M�zga G�za');
INSERT INTO kolcsonzo(nev)
VALUES('M�zga Alad�r');
INSERT INTO kolcsonzo(nev)
VALUES('Hufn�gel Pisti');

SELECT * FROM kolcsonzo;

/*Hozzunk l�tre egy k�lcs�nz�s t�bl�t! Sorsz�mmal, hivatkoz�ssal a kolcsonzo
t�bl�ra �s k�nyvc�mmel!*/

CREATE TABLE kolcsonzes(
sorszam NUMBER(5) GENERATED AS IDENTITY PRIMARY KEY
,kolcsonzo NUMBER(3) REFERENCES kolcsonzo (kid)
,konyv VARCHAR2(40)
);

INSERT INTO kolcsonzes(kolcsonzo, konyv)
VALUES(
'10'
,'�rutaz�s'
);

INSERT INTO kolcsonzes(kolcsonzo, konyv)
VALUES(
'10'
,'�rutaz�s2'
);

select * from kolcsonzes;

drop table kolcsonzo purge;

drop table kolcsonzes purge;

CREATE TABLE kolcsonzes(
sorszam NUMBER(5) GENERATED AS IDENTITY PRIMARY KEY
,kolcsonzo NUMBER(3) 
,konyv VARCHAR2(40)
,foreign key (kolcsonzo)REFERENCES kolcsonzo (kid)
);

select * from user_objects;
select * from user_constraints;

/******************/
/*Csoport feladat:*/
/******************/

/*1. A 3 le�r�s k�z�l a felesleges kett�t t�r�lj�k ki, a harmadikat pedig tervezz�k
meg az oktat�val k�z�sen!*/

/*A Sz�ll�shely s�ma instrukci�i:

Egy sz�ll�shely k�zvet�t� oldal egyszer�s�tett adatb�zis�t kell 
megtervezn�nk, amelyben t�roljuk a sz�ll�shelyek, az �gyfelek 
�s a foglal�sok adatait. 

Az �gyfeleink mag�nszem�lyek, akik regisztr�ci�val ker�lnek 
az adatb�zisunkba, ahol meg kell adniuk logint, e-mail c�met, 
nevet, sz�let�si adatokat, sz�ml�z�si c�met.
Nem lehet k�t regisztr�ci� azonos e-mail c�mmel.

A sz�ll�shelyekr�l t�rolunk k�l�nb�z� adatokat: legyen nev�k, 
t�pusuk, kapacit�suk (szobasz�m, �sszes f�r�hely), c�m�k, ter�leti 
elhelyezked�s�k. 
A sz�ll�shelyeket munkat�rsaink r�gz�tik az adatb�zisban, �gy 
legyen egy mez�, ami a felviv� azonos�t�j�t t�rolja �s a felvitel 
d�tum�t (mindkett�t default).

A sz�ll�shelyek szob�it is t�roljuk le k�l�n-k�l�n. Csak alap 
adatok legyenek, azonos�t�, szobasz�m, �gysz�m, p�t�gy, l�gkondi.

T�roljuk m�g a foglal�sok adatait is. Melyik felhaszn�l�, mikor, 
mikorra h�ny f� feln�tt, h�ny f� gyerekre foglalta. Lehet itt egy 
megjegyz�s rovat is.
*/

/*Az Egyetem s�ma instrukci�i:

Egy egyetem egyszer�s�tett adatb�zis�t kell megtervezn�nk, 
amelyben t�roljuk a hallgat�k adatait, valamint a t�rgyakat 
�s az abb�l el�rt eredm�nyeket. Az eredm�nyek f�l�vekre oszlanak. 

A hallgat�kr�l t�roljuk az egyedi azonos�t�jukat, nev�ket, 
sz�let�s�ket. Ezen k�v�l a tanulm�nyaik kezd�s�nek d�tum�t 
(ami valamelyik �v szeptember 1. vagy febru�r 1. lehet), illetve a szakj�t.

A tant�rgyaknak van egyedi k�dja, nem felt�tlen�l egyedi neve, 
kredit�rt�ke �s besorol�sa (k�telez�, k�telez�en v�laszthat�, v�laszthat�), 
tant�rgyfelel�se �s egy szervezeti egys�g, amihez tartozik. 
Ezen k�v�l van egy le�r�s mez� is a tant�rgyle�r�s sz�m�ra.

A hallgat�k a t�rgyakat k�l�nb�z� f�l�vekben vehetik fel �s ott 
k�l�nb�z� eredm�nyeik lehetnek. Egy t�rgyat t�bbsz�r is fel lehet 
venni �s egy felv�tel alkalm�val is t�bb eredm�ny sz�lethet. 
Az eredm�ny lehet egy oszt�lyzat, vagy egy�b (nem vizsg�zott, 
nem jelent meg, igazoltan nem jelent meg). 

Az eredm�nyeket munkat�rsaink r�gz�tik az adatb�zisban, �gy 
legyen egy mez�, ami a felviv� azonos�t�j�t t�rolja �s a 
felvitel d�tum�t (mindkett�t default).
*/

/*A Web�ruh�z s�ma instrukci�i:

Egy web�ruh�z egyszer�s�tett adatb�zis�t kell megtervezn�nk, 
amelyben t�roljuk a term�keket, az �gyfeleket �s a rendel�seiket. 

A term�kekr�l t�rolunk egy egyedi term�kk�dot, megnevez�st, 
lista�rat, kateg�ri�t, le�r�st, melyik rakt�runkban van �s 
mekkora k�szlet�nk van bel�le. 
A term�keket munkat�rsaink r�gz�tik az adatb�zisban, �gy 
legyen egy mez�, ami a felviv� azonos�t�j�t t�rolja �s a 
felvitel d�tum�t (mindkett�t default).

A vev�ink regisztr�ci�val ker�lnek az adatb�zisunkba, ahol 
meg kell adniuk logint, e-mail c�met, nevet, sz�let�si adatokat, 
nemet, sz�ml�z�si c�met. Nem lehet k�t regisztr�ci� azonos e-mail c�mmel.

Egy id�ben egy rendel�st lehet leadni egyf�le kisz�ll�t�si d�tummal, 
m�ddal �s c�mmel �s sz�ml�z�si c�mmel, de egy rendel�si kos�rban t�bb 
t�tel is szerepelhet, ahol az �r elt�rhet a lista�rt�l.
*/

/*2. Hozz�k l�tre a k�z�sen megtervezett adatb�zist!*/

select user from dual;

/*a) Sz�ll�shely*/

SELECT 
'drop '|| object_type ||' '
||object_name
||case when lower(object_type)='table' then ' purge;' else ';' end Lefuttatni
FROM user_objects
where lower(object_type) in ('table','sequence') and lower(generated)='n'
ORDER BY created DESC;

CREATE TABLE ugyfel(
 login VARCHAR2(20) PRIMARY KEY
,nev VARCHAR2(50) NOT NULL
,email VARCHAR2(50) NOT NULL UNIQUE 
  CHECK (email LIKE '%@%.__' OR  email LIKE '%@%.___')
,szuldat DATE
,c�m varchar2(100)
);

CREATE TABLE szallashely(
ID NUMBER(3) GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
,nev VARCHAR2(50) NOT NULL
,tipus VARCHAR2(20) 
,csillagok NUMBER(1) CHECK (csillagok BETWEEN 1 AND 5)
,szobaszam NUMBER(4)
,agyszam NUMBER(5)
,hely VARCHAR2(50)
,felvitte VARCHAR2(10) DEFAULT USER NOT NULL
,felvitel_datum date default sysdate not null
);

CREATE TABLE szoba(
szoba_id NUMBER(6) GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY
,szallashely NUMBER(3) NOT NULL REFERENCES szallashely(ID)
,szobaszam VARCHAR2(5) NOT NULL
,agyszam NUMBER(2) not null
,potagy NUMBER(2) default 0 CHECK (potagy>=0)
,legkondi VARCHAR2(1) CHECK(legkondi IN ('I','N'))
,UNIQUE(szallashely,szobaszam)
);

CREATE TABLE foglalas(
sorszam NUMBER GENERATED AS IDENTITY PRIMARY KEY
,szoba NUMBER(6) NOT NULL REFERENCES szoba(szoba_id)
,szemely VARCHAR2(20) NOT NULL REFERENCES szemely(login)
,erkezes DATE NOT NULL
,tavozas DATE not null
,felnott_fo NUMBER(2)
,gyermek_fo NUMBER(2)
,megjegyzes CLOB
,CHECK (tavozas>erkezes)
,UNIQUE(szoba,szemely,erkezes)
);

select * from user_objects
order by object_type;

select * from user_constraints
order by table_name, constraint_type;

/*b) Egyetem*/

SELECT 
'drop '|| object_type ||' '
||object_name
||case when lower(object_type)='table' then ' purge;' else ';' end Lefuttatni
FROM user_objects
where lower(object_type) in ('table','sequence') and lower(generated)='n'
ORDER BY created DESC;

create table hallgato(
 neptun varchar2(6) primary key check (length(neptun)=6)
,nev varchar2(50) not null
,szuldat date not null
,szak varchar2(20)
,kezdes date check (to_char(kezdes,'mmdd') in ('0901','0201') )
);

create table tantargy(
 tantargykod varchar2(15) primary key
,tantargy varchar2(50) not null
,kredit number(2) not null check (kredit>=0)
,besorolas varchar2(30) check (besorolas in ('k�telez�','v�laszthat�','k�telez�en v�laszthat�'))
,felelos varchar2(50)
,szervezet varchar2(50)
,leiras clob
);

create table targyfelvetel(
 sorszam number(6) generated as identity primary key
,hallgato varchar2(6) not null references hallgato(neptun)
,tantargy varchar2(15) not null references tantargy(tantargykod)
,felev varchar2(11) not null check (felev like '____/____ 1' or felev like '____/____ 2')
);

create table eredmeny(
targyfelvetel number(6) references targyfelvetel(sorszam)
,hanyadik number(1) not null 
,eredmeny number(1) check (eredmeny between 1 and 5)
,egyeb varchar2(30) check (egyeb in ('nem vizsg�zott','nem jelent meg','igazoltan nem jelent meg'))
,felvitte VARCHAR2(10) DEFAULT USER NOT NULL
,felvitel_datum date default sysdate not null
,primary key(targyfelvetel,hanyadik)
,unique(targyfelvetel,felvitel_datum)
,check (eredmeny is not null or egyeb is not null)
);

select * from user_objects
order by object_type;

select * from user_constraints
order by table_name, constraint_type;

/*Web�ruh�z*/

SELECT 
'drop '|| object_type ||' '
||object_name
||case when lower(object_type)='table' then ' purge;' else ';' end Lefuttatni
FROM user_objects
where lower(object_type) in ('table','sequence') and lower(generated)='n'
ORDER BY created DESC;

CREATE TABLE ugyfel(
 login VARCHAR2(20) PRIMARY KEY
,nev VARCHAR2(50) NOT NULL
,email VARCHAR2(50) NOT NULL UNIQUE 
  CHECK (email LIKE '%@%.__' OR  email LIKE '%@%.___')
,szuldat DATE
,nem varchar2(1) check (nem in ('F','N'))
,cim varchar2(100)
,regisztracio date default sysdate
);

create table termek(
 termekkod varchar2(12) primary key
,termeknev varchar2(100) not null
,ar number(10,2) check (ar>=0)
,kategoria varchar2(20) not null
,raktar varchar2(1)
,keszlet number(5) check (keszlet>=0)
,leiras clob
,felvitte VARCHAR2(10) DEFAULT USER NOT NULL
,felvitel_datum date default sysdate not null
);

create table rendeles(
 sorszam number(6) generated as identity primary key
,vevo varchar2(20) references ugyfel(login)
,datum date default sysdate not null
,szall_datum date
,kiszallitas varchar2(10) check (kiszallitas in('posta','GLS','szem�lyes'))
,szall_cim varchar2(100)
,szamla_cim varchar2(100)
,unique (vevo,datum)
,check (szall_datum>=datum)
);

create table rendelesi_tetel(
 rendeles number(6) references rendeles(sorszam)
,termek varchar2(12) references termek(termekkod)
,darabszam number(5) not null check (darabszam>0)
,ar number(10,2) not null
,primary key (rendeles,termek)
);

select * from user_objects
order by object_type;

select * from user_constraints
order by table_name, constraint_type;