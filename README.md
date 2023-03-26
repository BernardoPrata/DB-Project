# Bases de Dados 2021/2022 Projeto (All three deliveries)

The project of the DB class (Databases).

The goal of the project was to design and create an application from scratch that would manage Vending Machines. You can interact with the App in this website.

The project used Flask and pgSQL and explored concepts like relational databases, interaction user-database and SQL queries.

# How to run

The final version can be run with the file website.cgi located in delivery-03/cgi-bin/ in a web server.

## Project Details

Bases de Dados 2021/2022 Projeto - Enunciado 3

The third part of the project consists of developing SQL queries, complex integrity constraints, creating a prototype of a web application and OLAP queries.

### Database

#### Schema

Using SQL (DDL), present the instructions to create the database schema corresponding to the relational schema presented in Annex A. Make sure that the selected data types and field sizes are the most appropriate. Additionally, constraints should be specified on each field, row, and table using NOT NULL, CHECK, PRIMARY KEY, UNIQUE, and FOREIGN KEY statements as appropriate. Do not use accented characters or cedillas.

#### Loading

Using the schema developed above as a starting point, create instructions for filling the database consistently. You should consider that the records must ensure that all SQL queries presented later have a non-empty result. Record creation and loading can be performed using the method that seems most appropriate to you (manually, from an Excel sheet, through an SQL, Python or other script).

### Integrity Constraints

Present the code to implement the integrity constraints with SQL procedural extensions (Stored Procedures and Triggers) in the database schema defined in the previous point:

(RI-1) A Category cannot be contained in itself
(RI-4) The number of units replenished in a Replenishment Event cannot exceed the number of units specified in the Planogram
(RI-5) A Product can only be replenished on a Shelf that has (at least) one of the Categories of that product

Any integrity constraints defined without using procedural extensions (Stored Procedures and Triggers) must be implemented using other mechanisms, if appropriate. However, mechanisms such as ON DELETE CASCADE and ON UPDATE CASCADE are not allowed.

### SQL

Present the most concise SQL query for each of the following situations:

- What is the name of the retailer(s) responsible for replenishing the largest number of categories?
- What is the name of the retailer(s) who are responsible for all simple categories?
- Which products (ean) have never been replenished?
- Which products (ean) have always been replenished by the same retailer?

### Views

Each replenishment event represents the stock output of a quantity of product in the form of sales, waste, and theft. Assuming that waste and theft are non-existent (all product replenishments are caused by sales), create a view that summarizes the most important information about sales, combining information from different tables in the model. The view must have the following schema:

Sales (ean, cat, year, quarter, day_month, day_week, district, county, units)

In the schema of the view, the following correspondences exist between its attributes and those of the tables:

- units: corresponds to the attribute with the same name as the event_reposicao relation
- ean and cat: correspond to the primary keys of the product and category relations, respectively
- district and county: correspond to the attributes with the same name of the point_de_retalho
- year, quarter, month and day_week: attributes derived from the instant attribute

### Application Development

Using the view developed for Question 4, write two SQL queries that allow analyzing the total number of articles sold:

- In a given period (i.e., between two dates), by day of the week, by municipality, and in total.
- In a given district (i.e., "Lisbon"), by municipality, category, day of the week, and in total.

The submitted solution must use ROLLUP, CUBE, GROUPING SETS, or UNION of GROUP BY clauses.

### Indexes 

Present the SQL instructions for creating index(es) to improve query times for each of the cases listed below, explaining which operations would be optimized and how.

Indicate, with due justification, which type of index(es), on which attribute(s), and on which table(s) would make sense to create in order to speed up the execution of each query. Assume that the size of the tables exceeds the available memory by several orders of magnitude.

Assume that there are no indexes on the tables, other than those implicit when declaring primary and foreign keys.

- SELECT DISTINCT R.nome
FROM retalhista R, responsavel_por P
WHERE R.tin = P.tin and P. nome_cat = 'Frutos'
- SELECT T.nome, count(T.ean)
FROM produto P, tem_categoria T
WHERE p.cat = T.nome and P.desc like ‘A%’
GROUP BY T.nome