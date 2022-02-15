--Request to create the Database
go
create database BankingIndustryDataBase

go
use BankingIndustryDataBase

go 
Create table Banks(
	BankId   int IDENTITY(1,1) CONSTRAINT pk_banking PRIMARY KEY,
	BankName VARCHAR(25) NULL
);

go
Create table Accounts(
	AccountId   int IDENTITY(1,1) CONSTRAINT pk_account PRIMARY KEY,
	AccountName VARCHAR(25) NULL
);

go
Create table Towns(
	TownId  int IDENTITY(1,1) CONSTRAINT pk_town PRIMARY KEY,
	Town    VARCHAR(25) NULL
);

go
Create table Clients(
	ClientsId int IDENTITY(1,1) CONSTRAINT pk_client PRIMARY KEY,
	Client    VARCHAR(25) NULL
);

go
Create table Cards(
	CardsId int IDENTITY(1,1) CONSTRAINT pk_card PRIMARY KEY,
	Cards   VARCHAR(25) NOT  NULL
);

go
Create table InformationCLient(
	InformationClientId  int IDENTITY(1,1) CONSTRAINT pk_information PRIMARY KEY,
	ClientsId int Not NULL,
	AccountId int Not NULL,
	CardsId  int Not NULL
);
go
Create table BankingInformation(
	Id           int IDENTITY(1,1) CONSTRAINT pk_bankingInformation PRIMARY KEY,
	BankFilial   VARCHAR (25) NOT NULL, 
	BankId       int NOT NULL, 
	TownId       int NOT NULL,  
	ClientId     int NOT NULL,
	SocialStatus VARCHAR(25) NULL
);

go
ALTER TABLE BankingInformation 
ADD CONSTRAINT FK_Inf FOREIGN KEY (ClientId) 
REFERENCES  InformationCLient(ClientId); 
go
ALTER TABLE BankingInformation 
ADD CONSTRAINT FK_Inf2 FOREIGN KEY (BankId) 
REFERENCES Banks (BankId); 
go
ALTER TABLE BankingInformation 
ADD CONSTRAINT FK_Town FOREIGN KEY (TownId) 
REFERENCES Towns (TownId); 
go
ALTER TABLE InformationCLient 
ADD CONSTRAINT FK_Vac FOREIGN KEY (ClientsId) 
REFERENCES Clients (ClientsId); 
go
ALTER TABLE InformationCLient 
ADD CONSTRAINT FK_Acc FOREIGN KEY (AccountId) 
REFERENCES Accounts (AccountId); 
go
ALTER TABLE InformationCLient 
ADD CONSTRAINT FK_Card FOREIGN KEY (CardsId) 
REFERENCES Cards (CardsId); 
go

--Request to fill the Database
go
use BankingIndustryDataBase

insert into Banks (BankName)
Values
	('БеларусБанк'),
	('БелАгроПромБанк'),
	('Альфа-Банк'),
	('БелИнвестБанк'),
	('Тинькоф');
go
insert into Accounts(AccountName)
Values 
	('12345678201023344556'),
	('10233445561234567820'),
	('10101020203030405060'),
	('45678201023344556123'),
	('10160010202030304050');
go

insert into Towns(Town)
Values 
	('Гомель'),
	('Могилев'),
	('Жлобин'),
	('Житковичи'),
	('Лоев');
go

insert into Clients(Client)
Values 
	('Петров И.А.'),
	('Иванов Е.П.'),
	('Сидоров Л.А.'),
	('Сидоренко Е.П.'),
	('Петренко А.С.');
go


insert into Cards(Cards)
Values 
	('Карта 1'),
	('Карта 2'),
	('Карта 3'),
	('Карта 4'),
	('');
go


insert into InformationCLient(ClientsId, AccountId, CardsId)
Values 
	(1,1,1),
	(2,1,3),
	(3,2,2),
	(2,4,5),
	(3,5,1);
go

insert into BankingInformation(BankFilial, BankId, TownId,ClientId,SocialStatus)
Values 
	('Филиал 1',1,2,4,'студент'),
	('Филиал 2',2,1,1,'работник'),
	('Филиал 3',3,3,3,'пенсионер'),
	('Филиал 4',4,5,1,'безработный'),
	('Филиал 5',5,3,5,'студент');
