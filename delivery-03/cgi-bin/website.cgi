#!/usr/bin/python3
from wsgiref.handlers import CGIHandler
from flask import Flask
from flask import render_template, request, redirect
import psycopg2
import psycopg2.extras
import sys 
# SGBD configs
DB_HOST = "db.tecnico.ulisboa.pt"
DB_USER = "ist199184"
DB_DATABASE = DB_USER
DB_PASSWORD = "vpfm5494"
DB_CONNECTION_STRING = "host=%s dbname=%s user=%s password=%s" % (
    DB_HOST,
    DB_DATABASE,
    DB_USER,
    DB_PASSWORD
)

app = Flask(__name__)


#######
# Pergunta A - Inserir e remover categorias e as suas sub-categorias
#######

@app.route("/categorias")
def list_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM categoria;"
        cursor.execute(query)
        return render_template("categoria.html", cursor=cursor, subcategorias=False)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


# Dado que internamente no psycopg2, cada cursor executa uma transação. Tenho que armazenar
# os dados recebidos em Listas.
@app.route("/remover_categoria")
def remover_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)

        categoria_to_delete = request.args.get("categoria_name")
        query = "SELECT sub_categorias(%s) AS sub_categorias "
        data_categoria_inicial = (categoria_to_delete,)
        cursor.execute(query, data_categoria_inicial)
        sub_categorias = cursor.fetchall() + [[f"{categoria_to_delete}"]]

        for sub_categoria in sub_categorias:
            data = (sub_categoria[0],)
            # para cada subcategoria vou fazer:
            # eliminar responsavel por
            query = "DELETE FROM responsavel_por WHERE nome_cat = %s; "
            cursor.execute(query, data)

            # apagar prateleiras da categoria,e  planogramas associados
            query = "SELECT nro, num_serie, fabricante FROM prateleira WHERE nome =%s "
            cursor.execute(query, data)
            prateleiras = cursor.fetchall()

            for prateleira in prateleiras:
                data_prateleira = (prateleira[0], prateleira[1], prateleira[2])
                query = ''' DELETE FROM evento_reposicao WHERE nro=%s AND num_serie=%s AND fabricante=%s'''
                cursor.execute(query, data_prateleira)
                query = ''' DELETE FROM planograma WHERE nro=%s AND num_serie=%s AND fabricante=%s'''
                cursor.execute(query, data_prateleira)

            query = "DELETE FROM prateleira WHERE nome =%s"
            cursor.execute(query, data)

            query = "DELETE FROM tem_categoria WHERE nome=%s"
            cursor.execute(query, data)
            # apagar produtos do planograma, do evento reposicao
            query = "SELECT ean FROM produto WHERE cat =%s "
            cursor.execute(query, data)
            produtos = cursor.fetchall()

            for produto in produtos:
                data_produto = (produto[0],)
                query = "DELETE FROM tem_categoria WHERE ean=%s"
                cursor.execute(query, data_produto)
                query = "DELETE FROM evento_reposicao WHERE ean=%s"
                cursor.execute(query, data_produto)
                query = "DELETE FROM planograma WHERE ean=%s"
                cursor.execute(query, data_produto)

            query = "DELETE FROM produto WHERE cat =%s "
            cursor.execute(query, data)

            query = "DELETE FROM tem_outra WHERE categoria=%s or super_categoria=%s"
            cursor.execute(query, (sub_categoria[0], sub_categoria[0]))
            query = "DELETE FROM super_categoria WHERE nome=%s"
            cursor.execute(query, data)
            query = "DELETE FROM categoria_simples WHERE nome=%s"
            cursor.execute(query, data)
            query = "DELETE FROM categoria WHERE nome=%s"
            cursor.execute(query, data)

        return redirect(request.referrer)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

      
@app.route("/insert_categoria", methods=["POST"])
def insert_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        nome = request.form["insert_nome"]

        query = "INSERT INTO categoria VALUES (%s);"
        data = (nome,)
        cursor.execute(query, data)
        print('query!', query, '\n', file=sys.stderr)
        print('data!', data, '\n', file=sys.stderr)
        # todas categorias criadas sao simples
        query = "INSERT INTO categoria_simples VALUES (%s);"
        data = (nome,)
        cursor.execute(query, data)
        return redirect(request.referrer)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/insert_sub_categoria", methods=["POST"])
def insert_sub_categoria():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        super_categoria = request.form["super-categoria"]
        categoria = request.form["categoria"]

        query = "DELETE FROM categoria_simples WHERE nome = %s;"
        cursor.execute(query, (super_categoria,))
        query = '''INSERT INTO super_categoria(nome) SELECT %s WHERE NOT EXISTS
                 (SELECT * FROM super_categoria WHERE nome=%s)'''
        data = (super_categoria, super_categoria)
        cursor.execute(query, data)

        query = "INSERT INTO tem_outra VALUES (%s,%s);"
        data = (super_categoria, categoria)
        cursor.execute(query, data)

        return redirect(request.referrer)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()

#######
# Pergunta B - INSERIR E REMOVER RETALHISTAS;
#######


@app.route("/retalhistas")
def list_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM retalhista;"
        cursor.execute(query)
        return render_template("retalhista.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/delete_retalhista")
def delete_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin = request.args.get("retailer_id")

        query = f"DELETE FROM responsavel_por r WHERE r.tin = '{tin}';"
        cursor.execute(query)

        query = f"DELETE FROM evento_reposicao r WHERE r.tin = '{tin}';"
        cursor.execute(query)

        query = f"DELETE FROM retalhista r WHERE r.tin = '{tin}';"
        cursor.execute(query)

        return redirect(request.referrer)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


@app.route("/insert_retalhista", methods=["POST"])
def insert_retalhista():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        tin = request.form["insert_tin"]
        nome = request.form["insert_nome"]

        query = "INSERT INTO retalhista VALUES (%s,%s);"
        data = (tin, nome)
        cursor.execute(query, data)

        return redirect(request.referrer)
    except Exception as e:
        return str(e)
    finally:
        dbConn.commit()
        cursor.close()
        dbConn.close()


#######
# Pergunta C - LISTAR EVENTO DE REPOSICAO DA IVM E NUMERO UNIDADES REPOSTAS POR CATEGORIA
#######


@app.route("/ivms")
def list_ivm():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT * FROM ivm;"
        cursor.execute(query)
        return render_template("ivm.html", cursor=cursor)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


@app.route("/ivm_events")
def list_ivm_events():
    dbConn = None
    cursor = None
    try:
        num_serie = int(request.args.get("num_Serie"))
        fabricante = request.args.get("fabricante")

        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(
            cursor_factory=psycopg2.extras.DictCursor)

        # Eventos de Reposicao
        query_evento = " SELECT ean,nro,instante,unidades,tin FROM evento_reposicao e WHERE e.num_serie=%s AND e.fabricante=%s;"
        data = (num_serie, fabricante)
        cursor.execute(query_evento, data)
        eventos = cursor.fetchall()
        # Categorias
        query_categoria = '''SELECT p.nome,SUM(e.unidades) 
                            FROM evento_reposicao e JOIN tem_categoria p
                            ON e.ean=p.ean 
                            WHERE e.num_serie=%s AND e.fabricante=%s
                            GROUP BY  p.nome;'''
        cursor.execute(query_categoria, data)
        categorias = cursor.fetchall()

        return render_template("ivm_events.html", params=request.args, cursor_evento=eventos, cursor_categoria=categorias)
    except Exception as e:
        return str(e)
    finally:
        cursor.close()
        dbConn.close()


#######
# Pergunta D - LISTAR TODAS AS SUB-CATEGORIAS DE UMA SUPER_CATEGORIA
#######

@app.route("/sub_categorias")
def sub_categorias():
    dbConn = None
    cursor = None
    try:
        dbConn = psycopg2.connect(DB_CONNECTION_STRING)
        cursor = dbConn.cursor(cursor_factory=psycopg2.extras.DictCursor)
        query = "SELECT sub_categorias(%s) AS sub_categorias;"
        data = (request.args.get("categoria_name"),)
        cursor.execute(query, data)
        return render_template("subcategoria.html",
                               cursor=cursor, params=request.args)
    except Exception as e:
        return str(e)


CGIHandler().run(app)
