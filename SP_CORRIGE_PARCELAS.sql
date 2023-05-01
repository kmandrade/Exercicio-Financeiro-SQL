
CREATE PROCEDURE SP_Corrige_Parcelas(
@ID_PAGAMENTO_VENDA INT,
@QTD_PARCELAS_A_CORRIGIR INT,
@PRC_TAXA_ADMINISTRACAO NUMERIC(9,2))
AS 
	
  BEGIN

	BEGIN TRANSACTION
			BEGIN TRY

			DECLARE @COUNT_PARCELAS_INSERIDAS INT
				  SET @COUNT_PARCELAS_INSERIDAS = 1
			DECLARE @QTD_PARCELAS_EXISTENTES INT
				  SET  @QTD_PARCELAS_EXISTENTES = ISNULL((SELECT COUNT(nrParcela) AS 'QTD_PARCELAS' FROM CARD.tbParcela (NOLOCK) WHERE idPagamentoVenda = @ID_PAGAMENTO_VENDA),0)

			DECLARE @VLR_PARCELA_ATUALIZADA DECIMAL (5,1)
				SET @VLR_PARCELA_ATUALIZADA= (SELECT (CAST(vlPagamento AS DECIMAL(5,1))/@QTD_PARCELAS_A_CORRIGIR) 
												FROM CARD.tbPagamentoVenda WHERE idPagamentoVenda = @ID_PAGAMENTO_VENDA)

				IF(@QTD_PARCELAS_EXISTENTES = 0 OR @QTD_PARCELAS_EXISTENTES = NULL)
				BEGIN
					
					 WHILE(@COUNT_PARCELAS_INSERIDAS <= @QTD_PARCELAS_A_CORRIGIR)
						BEGIN
								INSERT INTO CARD.tbParcela 
								(idPagamentoVenda,
								nrParcela,
								idEmpresa,
								dtEmissao,
								dtVencimento,
								vlParcela,
								vlTaxaAdministracao,
								idContaCorrente,
								dtPagamento,
								vlPago,
								idStatusParcela,
								idMovimentoBanco)
							SELECT 
							@ID_PAGAMENTO_VENDA,
										@COUNT_PARCELAS_INSERIDAS,
										P.idEmpresa,
										P.dtEmissao,
										DATEADD(DAY,30,P.dtEmissao), -- as parcelas vencem a cada 30 dias a partir da data de emissão
										@VLR_PARCELA_ATUALIZADA, --  valor da parcela de acordo com o valor total do pagamento e quantidade de parcelas
										@PRC_TAXA_ADMINISTRACAO, --valor da taxa calculado de acordo com o percentual informado
										P.idContaCorrente,
										NULL,
										NULL,
										P.idStatusParcela,
										NULL
							  FROM CARD.tbParcela P(NOLOCK)
							  JOIN CARD.tbPagamentoVenda PGV(NOLOCK) ON P.idPagamentoVenda = PGV.idPagamentoVenda
							  WHERE P.idStatusParcela = 1 AND P.idPagamentoVenda = @ID_PAGAMENTO_VENDA
	  							  SET @COUNT_PARCELAS_INSERIDAS = @COUNT_PARCELAS_INSERIDAS + 1
							
						END
				END

				ELSE
					BEGIN
				  
				  DECLARE @QTD_PARCELAS_FALTANTES INT
				  SET @QTD_PARCELAS_FALTANTES = @QTD_PARCELAS_A_CORRIGIR - @QTD_PARCELAS_EXISTENTES
					IF(@QTD_PARCELAS_FALTANTES < 1)
						BEGIN
							ROLLBACK;
							THROW 50001, 'A quantidade de parcelas inseridas não pode ser menor ou igual que as existentes.', 1;
						END

					ELSE
					BEGIN
					
						UPDATE CARD.tbParcela
								SET vlParcela = @VLR_PARCELA_ATUALIZADA
								WHERE idPagamentoVenda = @ID_PAGAMENTO_VENDA
								 
						WHILE(@COUNT_PARCELAS_INSERIDAS  <= @QTD_PARCELAS_FALTANTES)
							BEGIN
								--PARCELAS FALTANTES QUE SERÃO INSERIDAS EM TB_PARCELA 
									INSERT INTO CARD.tbParcela 
									(idPagamentoVenda,
									nrParcela,
									idEmpresa,
									dtEmissao,
									dtVencimento,
									vlParcela,
									vlTaxaAdministracao,
									idContaCorrente,
									dtPagamento,
									vlPago,
									idStatusParcela,
									idMovimentoBanco)
								SELECT 
								@ID_PAGAMENTO_VENDA,
											ISNULL((SELECT MAX(nrParcela) FROM CARD.tbParcela (NOLOCK) WHERE idPagamentoVenda = @ID_PAGAMENTO_VENDA), 0) + 1,
											P.idEmpresa,
											P.dtEmissao,
											DATEADD(DAY,30,P.dtEmissao), 
											(CAST(PGV.vlPagamento AS DECIMAL(5,1))/@QTD_PARCELAS_A_CORRIGIR),
											@PRC_TAXA_ADMINISTRACAO,
											P.idContaCorrente,
											NULL,
											NULL,
											P.idStatusParcela,
											NULL
								  FROM CARD.tbParcela P(NOLOCK)
								  JOIN CARD.tbPagamentoVenda PGV(NOLOCK) ON P.idPagamentoVenda = PGV.idPagamentoVenda
								  WHERE P.idStatusParcela = 1 AND P.idPagamentoVenda = @ID_PAGAMENTO_VENDA
	  								  SET @COUNT_PARCELAS_INSERIDAS += 1
									  
							END
						END
				  END

					COMMIT TRANSACTION
			END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		PRINT ERROR_MESSAGE();
	END CATCH;
END
GO

EXEC SP_Corrige_Parcelas 61476419, 2, 2.00;


