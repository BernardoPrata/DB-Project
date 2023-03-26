--Qual o nome do retalhista (ou retalhistas) responsáveis pela reposição do maior número de categorias? 
-- Assumo que seja enm numero de categorias distintas, e nao eventso 
select distinct tin
from responsavel_por
group by tin
having count(*) >= ALL(
    select count(*)
    from (select distinct tin,nome_cat from responsavel_por) as a
    group by  tin
)



--Qual o nome do ou dos retalhistas que são responsáveis por todas as categorias simples?
select distinct T.tin
from responsavel_por as t
where not exists (
    select c.nome
    from categoria_simples as c
    EXCEPT
    select t2.nome_cat
    from responsavel_por as t2
    where t2.tin = T.tin
)



-- Quais os produtos (ean) que nunca foram repostos?
--- equivale a ver, quais eans não presentes em evento reposicao

select ean
from produto 
where ean not in (
    select ean
    from evento_reposicao
)

--Quais os produtos (ean) que foram repostos sempre pelo mesmo retalhista?

select distinct ean
from evento_reposicao p
where tin = ALL(
    select tin
    from evento_reposicao e
    where e.ean = p.ean
)

