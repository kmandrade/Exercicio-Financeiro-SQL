
-- DATA DE VENCIMENTO IGUAL DATA DE PAGAMENTO COLOCAR NUMA TABELA TEMPORARIA 
CREATE PROCEDURE SP_Baixa_Titulos(
 @DT_PAGAMENTO DATE,
 @ID_EMPRESA INT,
 @ID_CONTA_CORRENTE INT,
 @NR_DOCUMENTO VARCHAR(20),
 @DS_MOVIMENTO VARCHAR(50)
)
AS
BEGIN
	BEGIN TRANSACTION
		BEGIN TRY
			SELECT *
			INTO #LINHAS_BAIXAR_PARCELA
			FROM CARD.tbParcela (NOLOCK) 
			WHERE dtVencimento = @DT_PAGAMENTO
		
			DECLARE @OUT_VL_PARCELAS TABLE (VL_PARCELA DECIMAL(20,2))

			UPDATE  CARD.tbParcela
				SET 
				dtPagamento = pc.dtVencimento,
				vlPago = PC.vlParcela - PC.vlTaxaAdministracao,
				idStatusParcela = 1,
				idMovimentoBanco = MB.idMovimentoBanco
				OUTPUT inserted.vlParcela INTO @OUT_VL_PARCELAS(VL_PARCELA)
			FROM #LINHAS_BAIXAR_PARCELA PC
			JOIN CARD.tbMovimentoBanco MB (NOLOCK) ON PC.idMovimentoBanco = MB.idMovimentoBanco
			WHERE PC.idEmpresa = @ID_EMPRESA
			AND MB.idContaCorrente = @ID_CONTA_CORRENTE

			IF((SELECT TOP 1 1 FROM CARD.tbEmpresa E WHERE E.idEmpresa = 1 ) IS NOT NULL
			AND ((SELECT TOP 1 1 FROM CARD.tbContaCorrente CC WHERE CC.idContaCorrente = 2 )IS NOT NULL))
				BEGIN
				INSERT INTO CARD.tbMovimentoBanco
						 (idEmpresa,idContaCorrente, nrDocumento,
						 dsMovimento,vlMovimento,tpOperacao,dtMovimento)
						VALUES(
							@ID_EMPRESA,
							@ID_CONTA_CORRENTE,
							@NR_DOCUMENTO,
							@DS_MOVIMENTO,
							(SELECT SUM(VL_PARCELA) FROM @OUT_VL_PARCELAS),
							'E',
							@DT_PAGAMENTO)
				END
			ELSE
				BEGIN
					ROLLBACK;
					THROW 50001, 'Valores informados não constam na base de dados.', 1;
				END

				COMMIT TRANSACTION
			END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		PRINT ERROR_MESSAGE();
	END CATCH;
			
END
	
exec [dbo].[SP_Baixa_Titulos] '20190917',1,2,'123456','RECEBIMENTO DE CARTÃO';

SELECT * FROM CARD.tbParcela
	WHERE dtVencimento = '20190917'

	select * from card.tbMovimentoBanco
	where dtMovimento = '20190917' and idEmpresa = 1 and idContaCorrente = 2 and nrDocumento = '123456' and dsMovimento= 'RECEBIMENTO DE CARTÃO'
	
