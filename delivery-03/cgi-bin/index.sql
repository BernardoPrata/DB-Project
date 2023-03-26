DROP INDEX nome_retalhista_index;
DROP INDEX nome_cat_tin_index;
DROP INDEX cat_do_produto_index;
DROP INDEX descr_nome_tem_categoria_index;

--------
-- 7 A)
--------

SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P
WHERE R.tin = P.tin and P.nome_cat = 'Frutos'


create index nome_cat_tin_index on responsavel_por(nome_cat,tin);



--------
-- 7 B)
--------
SELECT T.nome, count(T.ean)
FROM produto P, tem_categoria T
WHERE P.cat = T.nome and P.descr like 'A%'
GROUP BY T.nome


create index cat_do_produto_index on produto(descr,cat);
