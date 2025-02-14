/* Considerações:

A tabela HISTORICO representa o maior volume de dados, tendo em média 15 registros para cada registro em histórico.
A tabela TAREFA é a segunda maior em volume de dados.
Ao solicitar TAREFA de um produto cuja tarefa esteja Ativa (situações de 1 a 4, 8 e 9), apenas um novo histórico de solicitação para esta tarefa é gerado, sem haver um novo registro em tarefa.

Com as informações acima, escreva as seguintes consultas: */

-- Consulta 01
-- Consulta contendo a quantidade de tarefas de ressuprimentos solicitadas por dia.
SELECT
	DATE (DATA_HORA) AS DIA,
	COUNT(*) AS QTD_RESSUPRIMENTO
FROM
	TAREFA
WHERE
	TIPO = 1
GROUP BY
	DATE (DATA_HORA)
ORDER BY
	DIA DESC;

-- Consulta 02
-- Consulta contendo a quantidade de tarefas de ressuprimento por situação por dia.
SELECT
	DATE (DATA_HORA) AS DIA,
	SITUACAO,
	COUNT(*) AS QTD_RESSUPRIMENTO
FROM
	TAREFA
WHERE
	TIPO = 1
GROUP BY
	DATE (DATA_HORA),
	SITUACAO
ORDER BY
	DIA DESC;

-- Consulta 03
-- Consulta com a quantidade de tarefas por dia por usuário e a quantidade distinta de produtos ressuprimentos.
SELECT
	DATE (T.DATA_HORA) AS DATA,
	T.ID_USUARIO,
	U.NOME,
	COUNT(T.ID_TAREFA) AS QTD_TAREFAS,
	COUNT(DISTINCT R.ID_PRODUTO) AS QTD_DISTINTA_PROD_RESSU
FROM
	TAREFA T
	LEFT JOIN RESSUPRIMENTO R ON T.ID_LOJA = R.ID_LOJA
	AND T.ID_TAREFA = R.ID_TAREFA
	LEFT JOIN USUARIO U ON T.ID_USUARIO = U.ID_USUARIO
	/* fiquei com dúvida se é para puxar tipo de tarefas em geral, ou só de ressuprimento, de qualquer forma
	deixo o restp do código se for apenas de ressuprimento: "WHERE t.tipo = 1" */
GROUP BY
	DATE (T.DATA_HORA),
	T.ID_USUARIO,
	U.NOME
ORDER BY
	DATA DESC,
	T.ID_USUARIO;

-- Consulta 04
-- Consulta com todos os dados da primeira e da ultima tarefa executada, por tipo e por dia.
SELECT *
FROM TAREFA t1
WHERE t1.SITUACAO = 5 /* eu entendi que a situacao = 5 é a tarefa executada, 
de acordo com a tabela de situações, tarefa finalizada é a única que realmente foi executada,
as outras quem deixam a tarefa inativa, mas por outros motivos: canceladas, anuladas, e isso não quer dizer que foi executada */
AND (
    t1.DATA_HORA = (
        SELECT MIN(t2.DATA_HORA)
        FROM TAREFA t2
        WHERE DATE(t2.DATA_HORA) = DATE(t1.DATA_HORA) 
        AND t2.TIPO = t1.TIPO
        AND t2.SITUACAO = 5
    )
    OR t1.DATA_HORA = (
        SELECT MAX(t2.DATA_HORA)
        FROM TAREFA t2
        WHERE DATE(t2.DATA_HORA) = DATE(t1.DATA_HORA) 
        AND t2.TIPO = t1.TIPO
        AND t2.SITUACAO = 5
    )
)
ORDER BY DATE(t1.DATA_HORA)DESC, t1.TIPO, t1.DATA_HORA;