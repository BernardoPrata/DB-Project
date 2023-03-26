
----------------------------------------
-- Triggers
----------------------------------------


-----------
--(RI-1) Uma Categoria não pode estar contida em si própria
-----------
create or replace function não_contida_proc() returns Trigger as
$$
BEGIN
    IF New.categoria = New.super_categoria THEN
        RAISE EXCEPTION 'Uma Categoria não pode estar contida em si própria.';
    END IF;
    RETURN New;
END;
$$ LANGUAGE plpgsql;

create  trigger nao_contida_trigger
before update or insert on tem_outra
for each row execute procedure não_contida_proc();



-----------
--(RI-4) O número de unidades repostas num Evento de Reposição não pode exceder o número de
--unidades especificado no Planograma
-----------


create or replace function max_unidades_respostas_proc() returns Trigger as
$$
DECLARE max_units INTEGER:=0;
BEGIN
    SELECT unidades INTO max_units
    FROM planograma p 
    WHERE p.ean = NEW.ean AND p.nro=NEW.nro AND
        p.num_serie= NEW.num_serie AND p.fabricante=NEW.fabricante;

    IF New.unidades > max_units THEN
        RAISE EXCEPTION 'O número de unidades repostas num Evento de Reposição
         não pode exceder o número de unidades especificado no Planograma';
    END IF;
    RETURN New;
END;
$$ LANGUAGE plpgsql;


create  trigger max_unidades_respostas_trigger
before update or insert on evento_reposicao
for each row execute procedure max_unidades_respostas_proc();

-----------
--(RI-5) Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das
--Categorias desse produto.
-----------

create or replace function prateleira_produto_categoria_proc() returns Trigger as
$$
BEGIN

    -- categoria da prateleira
    IF NOT EXISTS (
            (SELECT distinct p.nome
            FROM prateleira p 
            WHERE p.nro = NEW.nro AND p.num_serie= NEW.num_serie AND p.fabricante=NEW.fabricante)
            INTERSECT
            (SELECT distinct t.nome
            FROM tem_categoria t
            WHERE t.ean = NEW.ean)
    ) THEN
        RAISE EXCEPTION 'Um Produto só pode ser reposto numa Prateleira que apresente (pelo menos) uma das Categorias desse produto';
    END IF;
    RETURN New;
END;
$$ LANGUAGE plpgsql;



create  trigger prateleira_produto_categoria_trigger
before update or insert on evento_reposicao
for each row execute procedure prateleira_produto_categoria_proc();



-------------------------------------------
---------  AUXILIARES
-------------------------------------------


------------
--5-d) Listar todas as sub-categorias de uma super-categoria, a todos os níveis de profundidade.
--------

create or replace function sub_categorias(cat_nome VARCHAR(80)) returns TABLE(categoria varchar(80))  as
$$
BEGIN
    RETURN QUERY WITH RECURSIVE subordinates AS (
	SELECT
		t.categoria
	FROM
		tem_outra t
	WHERE
		t.super_categoria = cat_nome
	UNION
		SELECT
			e.categoria
		FROM
			tem_outra e
		INNER JOIN subordinates s ON s.categoria = e.super_categoria
    ) SELECT z.categoria FROM subordinates as z;
END;
$$ LANGUAGE plpgsql;


------------
-- Listar todas as super-categorias de uma categoria
--------

create or replace function super_categoria(cat_nome VARCHAR(80)) returns TABLE(categoria varchar(80))  as
$$
BEGIN
    RETURN QUERY WITH RECURSIVE subordinates AS (
	SELECT
		t.super_categoria
	FROM
		tem_outra t
	WHERE
		t.categoria = cat_nome
	UNION
		SELECT
			e.super_categoria
		FROM
			tem_outra e
		INNER JOIN subordinates s ON s.super_categoria = e.categoria
    ) SELECT z.super_categoria FROM subordinates as z;
END;
$$ LANGUAGE plpgsql;


-- Quando produto é inserido em categoria, é inserido em todas as super-categorias acima dessa categoria.
create or replace function produto_tem_categoria() returns Trigger as
$$
    DECLARE	cursor__super	CURSOR FOR SELECT * from super_categoria(NEW.cat);
    DECLARE categoria_name VARCHAR(80);
    BEGIN
        IF NOT EXISTS (SELECT * FROM tem_categoria WHERE ean = NEW.ean  AND nome = NEW.cat)
        THEN
            INSERT INTO tem_categoria VALUES (NEW.ean ,NEW.cat);
            OPEN	cursor__super;
		    LOOP
			    FETCH	cursor__super	INTO	categoria_name;
			    EXIT WHEN NOT FOUND;
			    IF NOT EXISTS (SELECT * FROM tem_categoria t  WHERE t.ean = NEW.ean  AND t.nome = categoria_name)
                THEN INSERT INTO tem_categoria VALUES (NEW.ean,categoria_name);
                END IF;
		    END	LOOP;
		    CLOSE	cursor__super;
        END IF;
    RETURN New;
    END
$$ LANGUAGE plpgsql;


create  trigger produto_tem_categoria_trigger
after insert on produto
for each row execute procedure produto_tem_categoria();