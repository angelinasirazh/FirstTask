--������ ������
Select dbo.Banks.BankName
From dbo.Banks
  Join dbo.BankingInformation 
	on  dbo.BankingInformation.BankId = dbo.Banks.BankId 
  Join dbo.Towns 
	on dbo.BankingInformation.TownId = dbo.Towns.TownId
Where dbo.Towns.Town = '������'

--������ ������
Select dbo.Cards.Cards,dbo.Cards.Balance,dbo.Clients.Client,dbo.Banks.BankName
From   dbo.InformationCLient
	Join dbo.Cards 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	Join dbo.Clients 
		on  dbo.InformationCLient.ClientsId = dbo.Clients.ClientsId
	Join dbo.BankingInformation 
		on  dbo.BankingInformation.ClientId = dbo.InformationCLient.ClientId
	Join dbo.Banks 
		on  dbo.Banks.BankId = dbo.BankingInformation.BankId

--������ ������
Select Accounts.AccountName,Accounts.Balance,Sum(Cards.Balance) AS SumCards,Accounts.Balance - Sum(Cards.Balance) as Difference
From InformationCLient
	Join dbo.Accounts 
		on  dbo.InformationCLient.AccountId = dbo.Accounts.AccountId
	Join dbo.Cards 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
group by Accounts.AccountName,Accounts.Balance
HAVING (Accounts.Balance <> Sum(Cards.Balance))

--��������� ������ (� group by)
Select BankingInformation.SocialStatus,COUNT(dbo.Cards.Cards) As CountStatus
From   dbo.Cards 
	Join dbo.InformationCLient 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	Join dbo.BankingInformation 
		on  dbo.BankingInformation.ClientId = dbo.InformationCLient.ClientId
GROUP BY BankingInformation.SocialStatus

--��������� ������� ����������� (�� � ������� ���� � group by)
SELECT A.SocialStatus, COUNT(A.Count) as Count
FROM
(SELECT SocialStatus,
					(SELECT COUNT(I2.ClientsId)
					FROM InformationCLient as I2
					WHERE I2.ClientId= I1.ClientId) as Count
FROM BankingInformation as I1) as A 
group by A.SocialStatus

--����� ������
USE BankingSphere
GO
Alter PROCEDURE [dbo].AddDollars AS
BEGIN
	Update Accounts
	Set Accounts.Balance += 10
	FROM Accounts 
		INNER JOIN InformationClient ON Accounts.AccountId = InformationClient.AccountId 
		INNER JOIN BankingInformation ON InformationClient.ClientId = BankingInformation.ClientId
	WHERE BankingInformation.SocialStatus='�������'
END;

--������ ������
Select Clients.Client,Accounts.Balance - Sum(Cards.Balance) as AvailableMoneyForTransfer
From InformationCLient
	Join dbo.Accounts 
		on  dbo.InformationCLient.AccountId = dbo.Accounts.AccountId
	Join dbo.Cards 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	Join dbo.Clients
		on dbo.Clients.ClientsId = InformationCLient.ClientsId
group by Accounts.AccountName,Accounts.Balance,Clients.Client

--������� ������
USE BankingSphere
GO
Create PROCEDURE [dbo].ProcedureTransaction AS
BEGIN
BEGIN TRANSACTION

   --���������� 1
   UPDATE Cards SET Cards.Balance = Cards.Balance+Accounts.Balance
   from  dbo.Accounts 
	   JOIN dbo.InformationCLient ON dbo.Accounts.AccountId = dbo.InformationCLient.AccountId 
	   JOIN dbo.Cards ON dbo.InformationCLient.CardsId = dbo.Cards.CardsId;
  
   --���������� 2
    UPDATE Accounts SET Accounts.Balance = 0
   from  dbo.Accounts
		JOIN dbo.InformationCLient ON dbo.Accounts.AccountId = dbo.InformationCLient.AccountId 
		JOIN dbo.Cards ON dbo.InformationCLient.CardsId = dbo.Cards.CardsId;
   COMMIT TRANSACTION
End;

SELECT dbo.Accounts.Balance, dbo.Cards.Balance AS Expr1, dbo.Accounts.AccountName, dbo.Cards.Cards
FROM     dbo.Accounts 
		JOIN dbo.InformationCLient ON dbo.Accounts.AccountId = dbo.InformationCLient.AccountId
		JOIN dbo.Cards ON dbo.InformationCLient.CardsId = dbo.Cards.CardsId;

--������� ������
USE BankingSphere
GO

Create TRIGGER [dbo].Prohibition
   ON  [dbo].Accounts
   instead of update
AS 
	IF(SELECT Balance FROM inserted)<(Select Sum(Cards.Balance) as SumAccoutsBalance
From   dbo.InformationCLient 
	Join dbo.Accounts 
	on  dbo.InformationCLient.AccountId = dbo.Accounts.AccountId
	Join dbo.Cards 
	on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	GROUP BY Accounts.Balance)
BEGIN
	PRINT'�� �� ������ �������� ������ ������� ��������'
	ROLLBACK 
END

go
Create TRIGGER [dbo].Prohibition2
   ON  [dbo].Cards
   instead of update
AS 
	IF (Select Sum(Cards.Balance) as SumAccoutsBalance
From   dbo.InformationCLient 
  Join dbo.Accounts 
	on  dbo.InformationCLient.AccountId = dbo.Accounts.AccountId
	Join dbo.Cards 
	on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	GROUP BY Accounts.Balance)>(SELECT Balance FROM inserted)
BEGIN
	PRINT'�� �� ������ �������� ������ ������� ��������'
	ROLLBACK 
END