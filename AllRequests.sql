--Первый запрос
Select dbo.Banks.BankName
From dbo.Banks
  Join dbo.BankingInformation 
	on  dbo.BankingInformation.BankId = dbo.Banks.BankId 
  Join dbo.Towns 
	on dbo.BankingInformation.TownId = dbo.Towns.TownId
Where dbo.Towns.Town = 'Гомель'

--Второй запрос
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

--Третий запрос
Select Accounts.AccountName,Accounts.Balance,Sum(Cards.Balance) AS SumCards,Accounts.Balance - Sum(Cards.Balance) as Difference
From InformationCLient
	Join dbo.Accounts 
		on  dbo.InformationCLient.AccountId = dbo.Accounts.AccountId
	Join dbo.Cards 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
group by Accounts.AccountName,Accounts.Balance
HAVING (Accounts.Balance <> Sum(Cards.Balance))

--Четвертый запрос (с group by)
Select BankingInformation.SocialStatus,COUNT(dbo.Cards.Cards) As CountStatus
From   dbo.Cards 
	Join dbo.InformationCLient 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	Join dbo.BankingInformation 
		on  dbo.BankingInformation.ClientId = dbo.InformationCLient.ClientId
GROUP BY BankingInformation.SocialStatus

--Четвертый запросс подзапросом 
SELECT BankingInformation.SocialStatus, COUNT(BankingInformation.Count) as Count
FROM
(SELECT SocialStatus,
					(SELECT COUNT(InformationCLient.ClientsId)
					FROM InformationCLient 
					WHERE InformationCLient.ClientId= BankingInformation.ClientId) as Count
FROM BankingInformation ) as BankingInformation
group by BankingInformation.SocialStatus

--Пятый запрос
USE BankingSphereDataBase
GO
Alter PROCEDURE [dbo].AddDollars AS
BEGIN
	Update Accounts
	Set Accounts.Balance += 10
	FROM Accounts 
		INNER JOIN InformationClient ON Accounts.AccountId = InformationClient.AccountId 
		INNER JOIN BankingInformation ON InformationClient.ClientId = BankingInformation.ClientId
	WHERE BankingInformation.SocialStatus='студент'
END;

--Шестой запрос
Select Clients.Client,Accounts.Balance - Sum(Cards.Balance) as AvailableMoneyForTransfer
From InformationCLient
	Join dbo.Accounts 
		on  dbo.InformationCLient.AccountId = dbo.Accounts.AccountId
	Join dbo.Cards 
		on  dbo.InformationCLient.CardsId = dbo.Cards.CardsId
	Join dbo.Clients
		on dbo.Clients.ClientsId = InformationCLient.ClientsId
group by Accounts.AccountName,Accounts.Balance,Clients.Client

--Седьмой запрос
USE BankingSphere
GO

Alter PROCEDURE [dbo].ProcedureTransaction @Balance AS INT = 10 AS
Begin
	BEGIN TRY
	BEGIN TRANSACTION

	   --Инструкция 1
	   UPDATE Cards SET Cards.Balance = @Balance+Cards.Balance
	   from  dbo.Accounts INNER JOIN
					  dbo.InformationCLient ON dbo.Accounts.AccountId = dbo.InformationCLient.AccountId INNER JOIN
					  dbo.Cards ON dbo.InformationCLient.CardsId = dbo.Cards.CardsId;
		
  
	   --Инструкция 2
		UPDATE Accounts SET Accounts.Balance = Accounts.Balance - @Balance
	    from  dbo.Accounts INNER JOIN
					  dbo.InformationCLient ON dbo.Accounts.AccountId = dbo.InformationCLient.AccountId INNER JOIN
					  dbo.Cards ON dbo.InformationCLient.CardsId = dbo.Cards.CardsId;
		
	END TRY
	BEGIN CATCH
	ROLLBACK TRANSACTION

		  --Выводим сообщение об ошибке
		  SELECT ERROR_NUMBER() AS [Номер ошибки],
				 ERROR_MESSAGE() AS [Описание ошибки]
	RETURN
	END CATCH
	COMMIT TRANSACTION
End;

SELECT dbo.Accounts.Balance, dbo.Cards.Balance AS Expr1, dbo.Accounts.AccountName, dbo.Cards.Cards
FROM     dbo.Accounts 
		JOIN dbo.InformationCLient ON dbo.Accounts.AccountId = dbo.InformationCLient.AccountId
		JOIN dbo.Cards ON dbo.InformationCLient.CardsId = dbo.Cards.CardsId;

--Восьмой запрос
USE BankingSphereDataBase
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
	PRINT'Вы не можете изменить данные баланса аккаунта'
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
	PRINT'Вы не можете изменить данные баланса карточки'
	ROLLBACK 
END