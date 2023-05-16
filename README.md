# Desafio-Financeiro-SQL

# Para a View criada tem como objetivo:
Fornecer uma camada adicional de abstração e simplificação na manipulação e consulta de dados. As views são objetos de banco de dados que representam consultas SQL predefinidas, armazenando-as como uma "visão" da estrutura e dos dados subjacentes nas tabelas do banco de dados.

# A stored procedure (SP) chamada "SP_Corrige_Parcelas" tem como objetivo corrigir as parcelas de um pagamento de venda. Ela aceita três parâmetros: @ID_PAGAMENTO_VENDA (que é o ID do pagamento de venda a ser corrigido), @QTD_PARCELAS_A_CORRIGIR (que é a quantidade de parcelas a serem corrigidas) e @PRC_TAXA_ADMINISTRACAO (que é a taxa de administração a ser aplicada).
Descrição dos procedimentos e validações realizados pela SP:

Inicia uma transação para garantir a consistência dos dados.
Verifica a quantidade de parcelas existentes para o ID do pagamento de venda fornecido.
Calcula o valor atualizado de cada parcela (@VLR_PARCELA_ATUALIZADA) com base no valor total do pagamento de venda e na quantidade de parcelas a serem corrigidas.
Se não houver parcelas existentes para o pagamento de venda ou se o valor for nulo, insere as parcelas corrigidas utilizando um loop while. Cada parcela é inserida na tabela tbParcela, com os respectivos valores de ID do pagamento de venda, número da parcela, empresa, datas de emissão e vencimento, valor da parcela atualizada, taxa de administração, conta corrente e outros campos relacionados.
Caso contrário, se houver parcelas existentes, verifica se a quantidade de parcelas a serem inseridas é menor ou igual às parcelas existentes. Se for, gera um erro e cancela a transação.
Caso contrário, atualiza o valor das parcelas existentes para o valor atualizado (@VLR_PARCELA_ATUALIZADA) e insere as parcelas adicionais (faltantes) usando um loop while semelhante ao mencionado anteriormente.
Comita a transação se tudo for executado com sucesso. Caso contrário, desfaz a transação e imprime a mensagem de erro.
Você pode executar essa SP fornecendo os valores adequados para os parâmetros. Por exemplo, "EXEC SP_Corrige_Parcelas 61476419, 2, 2.00;" irá executar a SP para corrigir 2 parcelas do pagamento de venda com ID 61476419, aplicando uma taxa de administração de 2.00. Certifique-se de ajustar os valores de acordo com o seu caso específico.

# A stored procedure (SP) chamada "SP_Baixa_Titulos" tem como objetivo realizar a baixa de títulos (parcelas) com base em determinados parâmetros. Ela aceita cinco parâmetros: @DT_PAGAMENTO (data de pagamento), @ID_EMPRESA (ID da empresa), @ID_CONTA_CORRENTE (ID da conta corrente), @NR_DOCUMENTO (número do documento) e @DS_MOVIMENTO (descrição do movimento).

Descrição dos procedimentos e validações realizados pela SP:

Inicia uma transação para garantir a consistência dos dados.
Seleciona as linhas de parcelas a serem baixadas com base na data de vencimento fornecida (@DT_PAGAMENTO) e as insere em uma tabela temporária (#LINHAS_BAIXAR_PARCELA).
Declara uma tabela de saída (@OUT_VL_PARCELAS) para armazenar os valores das parcelas que serão baixadas.
Atualiza as parcelas selecionadas na tabela tbParcela. Define a data de pagamento, valor pago (subtraindo a taxa de administração, se houver), status da parcela e ID do movimento bancário. Os valores das parcelas atualizadas são inseridos na tabela de saída @OUT_VL_PARCELAS.
Verifica se a empresa com o ID fornecido (@ID_EMPRESA) e a conta corrente com o ID fornecido (@ID_CONTA_CORRENTE) existem na base de dados. Se ambas existirem, insere um novo registro na tabela tbMovimentoBanco com os dados fornecidos, incluindo a soma dos valores das parcelas baixadas. O tipo de operação é "E" (entrada) e a data do movimento é definida como a data de pagamento.
Caso contrário, se a empresa ou a conta corrente não existirem, desfaz a transação, gera um erro e exibe uma mensagem indicando que os valores informados não estão na base de dados.
Comita a transação se tudo for executado com sucesso. Caso contrário, desfaz a transação e imprime a mensagem de erro.
Você pode executar essa SP fornecendo os valores adequados para os parâmetros. Por exemplo, "exec [dbo].[SP_Baixa_Titulos] '20190917',1,2,'123456','RECEBIMENTO DE CARTÃO';" irá executar a SP para realizar a baixa dos títulos com a data de pagamento 2019-09-17, ID da empresa 1, ID da conta corrente 2, número do documento 123456 e descrição do movimento "RECEBIMENTO DE CARTÃO". Certifique-se de ajustar os valores de acordo com o seu caso específico.
