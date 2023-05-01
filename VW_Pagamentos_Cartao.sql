CREATE VIEW VW_Pagamentos_Cartao AS
SELECT Emp.nrCNPJ,
		Pv.nrNSU,
		Pc.dtPagamento,
		Pv.idBandeira,
		Band.dsBandeira,
		Pv.vlPagamento as vlVenda,
		Pv.qtParcelas,
		Pv.idPagamentoVenda as cdERP
FROM card.tbEmpresa Emp (nolock)
join card.tbPagamentoVenda Pv (nolock) on Emp.idEmpresa = Pv.idEmpresa
join card.tbBandeira Band (nolock) on Pv.idBandeira = Band.idBandeira
join card.tbParcela PC (nolock) on Pv.idEmpresa = PC.idEmpresa
WHERE PV.nrNSU IS NOT NULL AND PC.dtPagamento IS NOT NULL


SELECT * FROM VW_Pagamentos_Cartao