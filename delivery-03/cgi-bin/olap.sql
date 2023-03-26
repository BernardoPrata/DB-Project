
--1
SELECT v.dia_semana, v.concelho, SUM(v.unidades) FROM Vendas AS v
WHERE  make_date(CAST(v.ano AS integer), CAST(v.mes AS integer),CAST(v.dia_mes AS integer)) BETWEEN '2015-01-01' AND '2022-07-01'
GROUP BY GROUPING SETS ((v.dia_semana),(v.concelho),());



-- 2.1)se for por concelho,categoria e dia_semana como um conjunto 
SELECT v.concelho, v.cat, v.dia_semana, SUM(v.unidades) as soma_unidades FROM Vendas as v
WHERE v.distrito = 'Lisboa'
GROUP BY GROUPING SETS ((v.concelho,v.cat,v.dia_semana),());


-- 2.2)se for por todas as combinaçoes possiveis entre concelho,categoria e dia_semana e depois total
SELECT v.concelho, v.cat, v.dia_semana, SUM(v.unidades) as soma_unidades FROM Vendas as v
WHERE v.distrito = 'Lisboa'
GROUP BY CUBE(v.concelho,v.cat,v.dia_semana);


--- Dado que a 2.1 nos parece a mais plausivel pela forma como o problema está enunciado,
--- por concelho, categoria, dia da semana, assumimos essa opção como resposta em caso de dúvida.