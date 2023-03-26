drop table if exists categoria cascade;
drop table if exists categoria_simples cascade;
drop table if exists super_categoria cascade;
drop table if exists tem_outra cascade;
drop table if exists produto cascade;
drop table if exists tem_categoria cascade;
drop table if exists ivm cascade;
drop table if exists ponto_de_retalho cascade;
drop table if exists instalada_em cascade;
drop table if exists prateleira cascade;
drop table if exists planograma cascade;
drop table if exists retalhista cascade;
drop table if exists responsavel_por cascade;
drop table if exists evento_reposicao cascade;

----------------------------------------
-- Table Creation
----------------------------------------

create table categoria
   (nome 	varchar(80)	not null unique,
    constraint pk_categoria primary key(nome));

create table categoria_simples
   (nome 	varchar(80)	not null unique,
    constraint pk_categoria_simples primary key(nome),
    constraint pk_categoria foreign key(nome) references categoria(nome));

create table super_categoria
   (nome 	varchar(80)	not null unique,
    constraint pk_super_categoria primary key(nome),
    constraint pk_categoria foreign key(nome) references categoria(nome));

create table tem_outra
   (super_categoria 	varchar(80)	not null,
    categoria 	varchar(80)	not null unique,
    constraint pk_tem_outra primary key(categoria),
    constraint fk_tem_outra_super foreign key(super_categoria) references super_categoria(nome),
    constraint fk_tem_outra_categoria foreign key(categoria) references categoria(nome));

create table produto
   (ean varchar(80)	not null unique,
    cat varchar(80)	not null ,
    descr	varchar(80)	not null ,
    constraint pk_ean primary key(ean),
    constraint fk_produto_categoria foreign key(cat) references categoria(nome));

create table tem_categoria
   (ean varchar(80) not null,
    nome		varchar(80) not null,
    constraint pk_tem_categoria primary key(nome,ean),
    constraint fk_tem_categoria_produto foreign key(ean) references produto(ean),
    constraint fk_tem_categoria_categoria foreign key(nome) references categoria(nome));

create table ivm
   (  
    num_serie 		integer    not null,
    fabricante 	varchar(80) not null,
    constraint pk_borrower primary key(num_serie,fabricante));

create table ponto_de_retalho
   (  
    nome_retalho 		varchar(80)	not null unique,
    distrito 	varchar(80) not null,
    concelho 	varchar(80) not null,
    constraint pk_ponto_de_retalho primary key(nome_retalho));

create table instalada_em
   (  
    num_serie 		integer    not null,
    fabricante 	varchar(80) not null,
    local_nome 	varchar(80) not null,
    constraint pk_instalada_em primary key(num_serie,fabricante),
    constraint fk_instalada_em_ivm foreign key(num_serie,fabricante) references ivm(num_serie,fabricante),
    constraint fk_instalada_em_local foreign key(local_nome) references ponto_de_retalho(nome_retalho));

create table prateleira
   (  
    nro 	integer not null,
    num_serie 		integer    not null,
    fabricante 	varchar(80) not null,
    altura 		numeric(3,2)   not null,
    nome 	varchar(80)	not null ,
    constraint pk_prateleira primary key(nro,num_serie,fabricante),
    constraint fk_ivm foreign key(num_serie,fabricante) references ivm(num_serie,fabricante),
    constraint fk_nome foreign key(nome) references categoria(nome));
  
create table planograma
   (  
    ean varchar(80)	not null ,
    nro 	integer not null,
    num_serie 		integer    not null,
    fabricante 	varchar(80) not null,
    faces 	integer   not null ,
    unidades 		integer   not null,
    loc 		integer  not null,
    constraint pk_planograma primary key(ean,nro,num_serie,fabricante),
    constraint fk_planograma_prateleira foreign key(nro,num_serie,fabricante) references prateleira(nro,num_serie,fabricante),
    constraint fk_planograma_produto foreign key(ean) references produto(ean));

create table retalhista
   (  
    tin 	varchar(80)	not null unique ,
    nome 	varchar(80)	not null unique,
    constraint pk_retalhista primary key(tin));

create table responsavel_por
   (  
    nome_cat 	varchar(80)	not null  ,
    tin 	varchar(80)	not null  ,
    num_serie 		integer    not null,
    fabricante 	varchar(80) not null,
    constraint pk_responsavel_por primary key(num_serie,fabricante),
    constraint fk_responsavel_por_ivm foreign key(num_serie,fabricante) references ivm(num_serie,fabricante),
    constraint fk_responsavel_por_retalhista foreign key(tin) references retalhista(tin),
    constraint fk_responsavel_por_categoria foreign key(nome_cat) references categoria(nome));

create table evento_reposicao
   (  
      ean varchar(80)	not null ,
      nro 	integer not null,
    num_serie 		integer    not null,
    fabricante 	varchar(80) not null,
    instante timestamp not null,
    unidades 		integer   not null,
    tin 	varchar(80)	not null  ,
    constraint pk_reposicao primary key(ean,nro,num_serie,fabricante,instante),
    constraint fk_reposicao_planograma foreign key(ean,nro,num_serie,fabricante) references planograma(ean,nro,num_serie,fabricante),
    constraint fk_reposicao_retalhista foreign key(tin) references retalhista(tin));


