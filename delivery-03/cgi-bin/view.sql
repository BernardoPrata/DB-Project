
------
-- Na relacao produto tenho apenas uma categoria e é essa que vou assumir como categoria da venda. E ignorar, todas as 
--  outras categorias do produto em tem_categoria. - se nao ignorasse, iria ter varias linhas para o mesmo evento de reposicao,
-- o que indicaria várias vendas para o mesmo evento.
--
------

create  view Vendas
as
select e.ean as ean,
    c.cat as cat,
    EXTRACT(YEAR FROM e.instante) as ano, 
    EXTRACT(QUARTER FROM e.instante) as trimestre, 
    EXTRACT(MONTH FROM e.instante) as mes,
    EXTRACT(DAY FROM e.instante) as dia_mes,
    EXTRACT(DOW FROM e.instante) as dia_semana,
    p.distrito as distrito,
    p.concelho as concelho,
    e.unidades as unidades
from evento_reposicao e  JOIN produto c 
            ON e.ean = c.ean
        JOIN instalada_em i 
            ON e.num_serie = i.num_serie AND e.fabricante = i.fabricante 
        JOIN ponto_de_retalho p
            ON  i.local_nome = p.nome_retalho


