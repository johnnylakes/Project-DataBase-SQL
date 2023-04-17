-- -----------------------------------------------------
-- BD 2022/23 - etapa E1 – bd046 – 54845, Bianca Moiteiro 33, TP16 (33,3%); 55164, João Lago, TP16 (33,3%); 57142, Luís Rosa, Erasmus (33,3%)
-- 
-- -----------------------------------------------------
DROP TABLE IF EXISTS Fatura;
DROP TABLE IF EXISTS visitas;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS Internamento;
DROP TABLE IF EXISTS Relatorio;
DROP TABLE IF EXISTS Exames_feitos;
DROP TABLE IF EXISTS prescricoes;
DROP TABLE IF EXISTS Exame;
DROP TABLE IF EXISTS especializacoes;
DROP TABLE IF EXISTS habilitacoes;
DROP TABLE IF EXISTS realiza;	
DROP TABLE IF EXISTS disponibiliza;
DROP TABLE IF EXISTS Tecnico;	
DROP TABLE IF EXISTS Exame_Tipo;
DROP TABLE IF EXISTS Medico;
DROP TABLE IF EXISTS Especialidade;
DROP TABLE IF EXISTS trabalhadores;
DROP TABLE IF EXISTS Funcionario;
DROP TABLE IF EXISTS Visitante; 
DROP TABLE IF EXISTS Utente;
DROP TABLE IF EXISTS Nao_funcionario; 
DROP TABLE IF EXISTS Pessoa;
DROP TABLE IF EXISTS Cama;
DROP TABLE IF EXISTS Salas_de_Internamento;
DROP TABLE IF EXISTS Salas_de_Exames;
DROP TABLE IF EXISTS Salas;
DROP TABLE IF EXISTS Horario;
DROP TABLE IF EXISTS Clinica;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------

CREATE TABLE Clinica (
	nome VARCHAR(40),
	data_inauguracao DATE,
	NIPC NUMERIC(9) NOT NULL,
	morada VARCHAR(40) NOT NULL,
	telefone CHAR(9) NOT NULL,
	correio_eletronico VARCHAR(40) NOT NULL,
	duracao_mandato NUMERIC(3) NOT NULL,
--
	CONSTRAINT pk_Clinica
		PRIMARY KEY (nome),
--
	CONSTRAINT un_Clinica_NIPC
		UNIQUE (NIPC),
--
	CONSTRAINT un_Clinica_morada
		UNIQUE(morada),
--	
	CONSTRAINT un_Clinica_telefone
		UNIQUE (telefone),	
--  
	CONSTRAINT un_Clinica_correio_eletronico
		UNIQUE (correio_eletronico),
--
	CONSTRAINT ck_Clinica_telefone
		CHECK (LEN(telefone) = 9),
--
	CONSTRAINT ck_Clinica_duracao_mandato
		CHECK (duracao_mandato > 0)

);

CREATE TABLE Horario (
	tipo Char(1),
	inicio TIME NOT NULL,
	fim TIME NOT NULL,
	Clinica VARCHAR(40),
--
	CONSTRAINT pk_Horario
		PRIMARY KEY (Clinica,tipo),
--
	CONSTRAINT fk_Horario_Clinica
		FOREIGN KEY (Clinica) REFERENCES Clinica(nome) ON DELETE CASCADE,
		
--
	CONSTRAINT ck_Horario
		CHECK (inicio < fim),
		
--
	CONSTRAINT ck_Horario_tipo
		CHECK (tipo IN ('a','b'))

);

CREATE TABLE Salas (
	Clinica VARCHAR(40),
	numero NUMERIC(4),
	piso NUMERIC(2),
	dimensao NUMERIC(3) NOT NULL,
	tipo_de_equipamento VARCHAR(40),

--
	CONSTRAINT pk_Salas
		PRIMARY KEY (Clinica,numero,piso),
--
	CONSTRAINT fk_Salas_Clinica
		FOREIGN KEY (Clinica) REFERENCES Clinica(nome) ON DELETE CASCADE,
--
    CONSTRAINT ck_Salas_numero
	    CHECK (numero>0),
--
    CONSTRAINT ck_Salas_piso
	    CHECK (piso>=0),
--
    CONSTRAINT ck_Salas_dimensao
	    CHECK (dimensao>0)
	    
);

CREATE TABLE Salas_de_Exames (
	Clinica VARCHAR(40),
	numero NUMERIC(4),
	piso NUMERIC(2),
	
--
	CONSTRAINT pk_Salas_de_Exames
		PRIMARY KEY (Clinica,numero,piso),
--
	CONSTRAINT fk_Salas_de_Exames_Salas
		FOREIGN KEY (Clinica,numero,piso) REFERENCES Salas(Clinica,numero,piso) ON DELETE CASCADE
		
);

CREATE TABLE Salas_de_Internamento (
	Clinica VARCHAR(40),
	numero NUMERIC(4),
	piso NUMERIC(2),
	tipo VARCHAR(40) NOT NULL,
	numero_maximo_de_camas NUMERIC(2) NOT NULL,
	numero_maximo_de_visitantes_simultaneo NUMERIC(2),

--
	PRIMARY KEY(Clinica,numero,piso),
	FOREIGN KEY (Clinica,numero,piso) REFERENCES Salas(Clinica,numero,piso) ON DELETE CASCADE,
--
    CONSTRAINT ck_Salas_de_Internamento
        CHECK (numero_maximo_de_camas > 0),
--
	CONSTRAINT ck_Salas_de_Internamento
        CHECK (numero_maximo_de_visitantes_simultaneo >= 0),
--
	CONSTRAINT ck_Salas_de_Internamento_tipo
		CHECK (tipo IN ('enfermaria','quarto'))	
);

CREATE TABLE Cama (
	Clinica VARCHAR(40),
	numero_cama NUMERIC(3),
	numero NUMERIC(4),
	piso NUMERIC(2),
	
--

	PRIMARY KEY(numero_cama,Clinica,numero, piso),
	FOREIGN KEY (Clinica,numero, piso) REFERENCES Salas_de_Internamento(Clinica,numero, piso) ON DELETE CASCADE,
	
--

	CONSTRAINT ck_Cama
		CHECK (numero_cama >= 1)
		
);
	 

CREATE TABLE Pessoa (
	NIF NUMERIC(9),
	NIC NUMERIC(9) NOT NULL,
	nome VARCHAR(40) NOT NULL,
	data_nascimento DATE NOT NULL,
	morada VARCHAR(40) NOT NULL,
	telefone CHAR(9) NOT NULL,
	correio_eletronico VARCHAR(40) NOT NULL,
	genero CHAR(1) NOT NULL,
	
--
	CONSTRAINT pk_Pessoa
		PRIMARY KEY (NIF),
--
	CONSTRAINT un_Pessoa_NIC
		UNIQUE (NIC),
--
	CONSTRAINT un_Pessoa_telefone
		UNIQUE (telefone),
--
	CONSTRAINT un_Pessoa_correio_eletronico
		UNIQUE (correio_eletronico),
--
	CONSTRAINT ck_Pessoa_genero
		CHECK (genero IN ('M','F'))
	
);

CREATE TABLE Nao_funcionario (
	NIF NUMERIC(9),
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES Pessoa(NIF)  ON DELETE CASCADE
);

CREATE TABLE Visitante (
	NIF NUMERIC(9),
	voluntario CHAR(1),
	instituicao VARCHAR(40),
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES Nao_funcionario(NIF) ON DELETE CASCADE,

--
	CONSTRAINT ck_Visitante
		CHECK (voluntario IN ('S','N'))

);

CREATE TABLE Utente (
	NIF NUMERIC(9),
	PRIMARY KEY(NIF),
	FOREIGN KEY (NIF) REFERENCES Nao_funcionario(NIF) ON DELETE CASCADE

);

CREATE TABLE Funcionario (
	NIF NUMERIC(9),
--
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES Pessoa(NIF) ON DELETE CASCADE 
);

CREATE TABLE trabalhadores (
	data_inicio DATE NOT NULL,
	Funcionario NUMERIC(9),
	Clinica VARCHAR(40),
--
	CONSTRAINT pk_trabalhadores
		PRIMARY KEY (Funcionario,Clinica),
--
	CONSTRAINT fk_trabalhadores_Funcionario
		FOREIGN KEY (Funcionario) REFERENCES Funcionario(NIF),
--
	CONSTRAINT fk_trabalhadores_Clinica
		FOREIGN KEY (Clinica) REFERENCES Clinica(nome)
);

CREATE TABLE Especialidade (
	sigla VARCHAR(3),
	nome VARCHAR(40),
	preco_diario_internamento NUMERIC(9),
	
--
	CONSTRAINT pk_Especialidade 
		PRIMARY KEY (sigla),
--
	CONSTRAINT ck_Especialidade_preco_diario_internamento
		CHECK (preco_diario_internamento >= 0)
);

CREATE TABLE Medico (
	NIF NUMERIC(9),
	supervisor NUMERIC(9),
	Especialidade VARCHAR(3) NOT NULL,
--
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES Funcionario(NIF) ON DELETE CASCADE, 
--
	CONSTRAINT fk_Medico_supervisor
		FOREIGN KEY (supervisor) REFERENCES Medico(NIF),
-- 
	CONSTRAINT fk_Medico_Especialidade
		FOREIGN KEY (Especialidade) REFERENCES Especialidade(sigla),
--
	CONSTRAINT ck_Medico_supervisor 
		CHECK ((supervisor <> NIF))
		
);

ALTER TABLE Clinica ADD (
    diretor_clinico NUMERIC(9),
	data_inicio_mandato DATE,
--
	CONSTRAINT fk_Clinica_diretor_clinico
		FOREIGN KEY (diretor_clinico) REFERENCES Medico(NIF),
--
	CONSTRAINT un_Clinica_diretor_clinico 
		UNIQUE (diretor_clinico),
--
	CONSTRAINT ck_data_inicio_mandato
		CHECK (data_inicio_mandato > data_inauguracao)
);
	
	CREATE TABLE Exame_Tipo(
	sigla VARCHAR(3) NOT NULL,
	tipo VARCHAR(40) NOT NULL,
	preco_normal Numeric(6,2),
	preco_urgencia NUMERIC(6,2),
--
	CONSTRAINT pk_Exame_Tipo
		PRIMARY KEY (sigla),
--
	CONSTRAINT ck_preco_normal
		Check (preco_normal >= 0),
--
	CONSTRAINT ck_preco_urgencia
		Check (preco_urgencia >= 0)

);

CREATE TABLE Tecnico (
	NIF NUMERIC(9),
	Exame_Tipo VARCHAR(3),
--
	PRIMARY KEY (NIF),
	FOREIGN KEY (NIF) REFERENCES Funcionario(NIF) ON DELETE CASCADE,
--
	CONSTRAINT fk_Tecnico_Exame_Tipo
		FOREIGN KEY (Exame_Tipo) REFERENCES Exame_Tipo(sigla)
);



CREATE TABLE disponibiliza (
	Clinica VARCHAR(40),
	Especialidade VARCHAR(3),

--
	CONSTRAINT pk_disponibiliza
		PRIMARY KEY (Clinica,Especialidade),

--
	CONSTRAINT fk_disponibiliza_Clinica
		FOREIGN KEY (Clinica) REFERENCES Clinica(nome),
		
--
	CONSTRAINT fk_disponibiliza_Especialidade
		FOREIGN KEY (Especialidade) REFERENCES Especialidade(sigla)
		
);

CREATE TABLE realiza (
	Clinica VARCHAR(40),
	Especialidade VARCHAR(3),
	Exame_Tipo VARCHAR(3),

--
	CONSTRAINT pk_realiza
		PRIMARY KEY (Clinica,Especialidade,Exame_Tipo),

--
	CONSTRAINT fk_realiza_Clinica
		FOREIGN KEY (Clinica) REFERENCES Clinica(nome),
		
--
	CONSTRAINT fk_realiza_Especialidade
		FOREIGN KEY (Especialidade) REFERENCES Especialidade(sigla),
		
--
	CONSTRAINT fk_realiza_Exame_Tipo
		FOREIGN KEY (Exame_Tipo) REFERENCES Exame_Tipo(sigla) 
		
);

CREATE TABLE habilitacoes(
	data_habilitacao DATE NOT NULL,
	Tecnico Numeric(9),
	Exame_Tipo VARCHAR(3),
--
	CONSTRAINT pk_habilitacoes
		PRIMARY KEY (Tecnico,Exame_Tipo),
--
	CONSTRAINT fk_habilitacoes_Tecnico
		FOREIGN KEY (Tecnico) REFERENCES Tecnico(NIF),
--
	CONSTRAINT fk_habilitacoes_Clinica
		FOREIGN KEY (Exame_Tipo) REFERENCES Exame_Tipo(sigla)
		
);
		



CREATE TABLE especializacoes (
	data_esp date NOT NULL,
	Especialidade VARCHAR(3),
	Medico NUMERIC(9),
--
	CONSTRAINT pk_especializacoes
		PRIMARY KEY (Especialidade, Medico),
-- 
	CONSTRAINT fk_especializacoes_Especialidade
		FOREIGN KEY (Especialidade) REFERENCES Especialidade(sigla),
-- 
	CONSTRAINT fk_especializacoes_Medico
		FOREIGN KEY (Medico) REFERENCES Medico(NIF)
);

CREATE TABLE Exame (
	codigo NUMERIC(9),
	tipo VARCHAR(40) NOT NULL,
	Exame_Tipo Varchar(3),
	Medico Numeric(9),
	inicio DATETIME,
	fim DATETIME,

	CONSTRAINT pk_Exame
		PRIMARY KEY (codigo),
--	
	CONSTRAINT fk_Exame_Exame_Tipo
		FOREIGN KEY (Exame_Tipo) REFERENCES Exame_Tipo(sigla),
		
	CONSTRAINT fk_Exame_Medico
		FOREIGN KEY (Medico) REFERENCES Medico(NIF),
--
	CONSTRAINT ck_Exame
		CHECK (inicio < fim )
);



CREATE TABLE prescricoes (
	Exame NUMERIC(9),
	Utente NUMERIC(9),
	Medico NUMERIC(9),
	
--
	CONSTRAINT pk_prescricoes
		PRIMARY KEY (Exame,Utente,Medico),

--
	CONSTRAINT fk_prescricoes_Exame
		FOREIGN KEY (Exame) REFERENCES Exame(codigo),

--
	CONSTRAINT fk_prescricoes_Utente
		FOREIGN KEY (Utente) REFERENCES Utente(NIF),

--
	CONSTRAINT fk_prescricoes_Medico
		FOREIGN KEY (Medico) REFERENCES Medico(NIF)
);

CREATE TABLE Exames_feitos (
	Tecnico NUMERIC(9),
	Exame NUMERIC(9),
	Utente NUMERIC(9),
	Medico NUMERIC(9),
	
--
	CONSTRAINT pk_Exames_feitos
		PRIMARY KEY (Tecnico, Exame, Utente, Medico),
--
	CONSTRAINT fk_Exames_feitos_Tecnico
		FOREIGN KEY (Tecnico) REFERENCES Tecnico(NIF),
--
	CONSTRAINT fk_Exames_feitos_Exame
		FOREIGN KEY (Exame) REFERENCES Exame(codigo),

--
	CONSTRAINT fk_Exames_feitos_Utente
		FOREIGN KEY (Utente) REFERENCES Utente(NIF),

--
	CONSTRAINT fk_Exames_feitos_Medico
		FOREIGN KEY (Medico) REFERENCES Medico(NIF)
);


CREATE TABLE Relatorio (
	numero NUMERIC(5),
	descricao_resultado VARCHAR(10000),
	Medico Numeric(9),
	Exame NUMERIC(9),
	data_relatorio DATE,
	parecer VARCHAR(10000),
	numero_referencia NUMERIC(5),
	exame_referencia NUMERIC(9),

--
	CONSTRAINT pk_Relatorio 
		PRIMARY KEY (Exame, numero),
		
--
	CONSTRAINT fk_Relatorio_Exame
		FOREIGN KEY (Exame) REFERENCES Exame(codigo) ON DELETE CASCADE,

--
	CONSTRAINT fk_Relatorio_Medico
		FOREIGN KEY (Medico) REFERENCES Medico(NIF),
--
	CONSTRAINT fk_Relatorio_referencia
		FOREIGN KEY (exame_referencia, numero_referencia) REFERENCES Relatorio(Exame,numero) ON DELETE CASCADE,
		
--
	CONSTRAINT ck_Relatorio_referencia
		CHECK (numero_referencia <> numero)
);





CREATE TABLE Internamento (
	Clinica VARCHAR(40),
	Cama NUMERIC(3),
	Utente NUMERIC(9),
	numero NUMERIC(4),
	piso NUMERIC(2),
	especialidade VARCHAR(40) NOT NULL,
	Medico NUMERIC(9),
	inicio DATE NOT NULL,
	fim DATE NOT NULL,
	numero_maximo_de_visitantes_simultaneo NUMERIC(2),
	
--
	CONSTRAINT pk_Internamento
		PRIMARY KEY(Clinica, numero,piso,Cama,Utente),
	
--
	CONSTRAINT fk_Internamento_Cama
		FOREIGN KEY (Clinica,numero,piso,Cama) REFERENCES Cama(Clinica,numero,piso,numero_cama),

--
	CONSTRAINT fk_Internamento_Medico
		FOREIGN KEY (Medico) REFERENCES Medico(NIF),

--
	CONSTRAINT fk_Internamento_Utente
		FOREIGN KEY (Utente) REFERENCES Utente(NIF),
		
--
	CONSTRAINT ck_Internamento
		CHECK (inicio < fim )
);

CREATE TABLE visitas ( 
	Visitante NUMERIC(9),
	solidaria CHAR(1) NOT NULL,
	inicio TIME NOT NULL,
	fim TIME NOT NULL,
	data_visita DATE NOT NULL,
	Clinica VARCHAR(40),
    numero NUMERIC(4),
    piso NUMERIC(2),
    Cama Numeric(3),
    Utente NUMERIC(9),
	
--
	CONSTRAINT pk_visitas
		PRIMARY KEY (Visitante),

--
	CONSTRAINT fk_visitas_Visitante
		FOREIGN KEY (Visitante) REFERENCES Visitante(NIF),
		
--
	CONSTRAINT fk_visitas_Internamento
		FOREIGN KEY (Clinica,numero,piso,Cama,Utente) REFERENCES Internamento(Clinica,numero,piso,Cama,Utente),
		
--
	CONSTRAINT ck_visitas
		CHECK (inicio < fim),
		
--
	CONSTRAINT ck_visitas_solidaria
		CHECK (solidaria IN ('S','N'))
		
);

CREATE TABLE Fatura (
	numero NUMERIC(9),
	data_emissao DATE NOT NULL,
	data_pagamento DATE NOT NULL,
	Utente NUMERIC(9) NOT NULL,
	Clinica VARCHAR(40),
	
--
	CONSTRAINT pk_Fatura
		PRIMARY KEY (numero,Clinica),
		
--
	CONSTRAINT fk_Fatura_Internamento
		FOREIGN KEY (Utente) REFERENCES Internamento(Utente),
		
--
	CONSTRAINT fk_Fatura_Clinica
		FOREIGN KEY (Clinica) REFERENCES Clinica(nome),
		
--
	CONSTRAINT ck_Fatura
		CHECK (numero > 0)

);



-- Inserts

-- Clinica 

INSERT INTO Clinica (nome, data_inauguracao, NIPC, morada, telefone, correio_eletronico, duracao_mandato,diretor_clinico,data_inicio_mandato)
	VALUES ('Clinica do Joao', '2019-09-18', 134567898, 'Rua jose santos', '334567889', 'clinicadojoao@gmail.com', 4,NULL,NULL);

INSERT INTO Clinica (nome, data_inauguracao, NIPC, morada, telefone, correio_eletronico, duracao_mandato,diretor_clinico,data_inicio_mandato)
	VALUES ('Clinica do Luis', '2008-03-20', 223898333, 'Rua hugo faria', '223115432', 'clinicadoluis@gmail.com', 5,NULL,NULL);

INSERT INTO Clinica (nome, data_inauguracao, NIPC, morada, telefone, correio_eletronico, duracao_mandato,diretor_clinico,data_inicio_mandato)
	VALUES ('Clinica da Bianca', '2005-02-08', 111444555, 'Avenida marcos relampago', '222161775', 'clinicadabianca@gmail.com', 2,NULL,NULL);

-- Horario

INSERT INTO Horario(tipo, inicio, fim, Clinica)
	VALUES ('a','17:30', '22:30','Clinica do Joao');

INSERT INTO Horario(tipo, inicio, fim, Clinica)
	VALUES ('b','07:00', '17:00','Clinica do Joao');

INSERT INTO Horario(tipo, inicio, fim, Clinica)
	VALUES ('a','17:30', '22:30','Clinica do Luis');

INSERT INTO Horario(tipo, inicio, fim, Clinica)
	VALUES ('b','07:00', '17:00','Clinica do Luis');

INSERT INTO Horario(tipo, inicio, fim, Clinica)
	VALUES ('a','17:00', '22:30','Clinica da Bianca');

INSERT INTO Horario(tipo, inicio, fim, Clinica)
	VALUES ('b','07:00', '17:00','Clinica da Bianca');



-- Salas

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES ('Clinica do Joao',2244, 02, 20, 'eletrocardiograma');

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica do Joao',2254, 03, 40, 'hemodialise');

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica do Joao',2211, 01, 25,NULL);

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica do Luis',3314, 01, 10, 'raio x');

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica do Luis',3355, 02, 10, 'raio x');

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica do Luis',3312, 01, 25,NULL);

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica da Bianca',4411, 05, 25, 'equipamento cirurgico');

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica da Bianca',4423, 02, 35, 'raio x');

INSERT INTO Salas (Clinica, numero, piso, dimensao, tipo_de_equipamento)
	VALUES('Clinica da Bianca',4499, 01, 25,NULL);


-- Salas_de_Exames

INSERT INTO Salas_de_Exames (Clinica,numero, piso)
	VALUES ('Clinica do Joao',2244,02);

INSERT INTO Salas_de_Exames (Clinica,numero, piso)
	VALUES ('Clinica do Joao',2254,03);

INSERT INTO Salas_de_Exames (Clinica,numero, piso)
	VALUES ('Clinica do Luis',3314,01);

INSERT INTO Salas_de_Exames (Clinica,numero, piso)
	VALUES ('Clinica do Luis',3355,02);

INSERT INTO Salas_de_Exames (Clinica,numero, piso)
	VALUES ('Clinica da Bianca',4411,05);

INSERT INTO Salas_de_Exames (Clinica,numero, piso)
	VALUES ('Clinica da Bianca',4423,02);


-- Salas_de_Internamento

INSERT INTO Salas_de_Internamento (Clinica,numero, piso, tipo, numero_maximo_de_camas, numero_maximo_de_visitantes_simultaneo)
	VALUES ('Clinica do Joao',2211,01,'quarto',15,4);

INSERT INTO Salas_de_Internamento (Clinica,numero, piso, tipo, numero_maximo_de_camas, numero_maximo_de_visitantes_simultaneo)
	VALUES ('Clinica do Luis',3312,01,'quarto',25,5);

INSERT INTO Salas_de_Internamento (Clinica,numero, piso, tipo, numero_maximo_de_camas, numero_maximo_de_visitantes_simultaneo)
	VALUES ('Clinica da Bianca',4499,01,'enfermaria',3,0);


-- Cama

INSERT INTO Cama (Clinica,numero_cama,numero,piso)
	VALUES('Clinica do Joao',005,2211,01);

INSERT INTO Cama (Clinica,numero_cama,numero,piso)
	VALUES('Clinica do Luis',007,3312,01);

INSERT INTO Cama (Clinica,numero_cama,numero,piso)
	VALUES('Clinica da Bianca',012,4499,01);


-- Pessoa

INSERT INTO Pessoa (NIF, NIC, nome, data_nascimento, morada, telefone, correio_eletronico, genero)
	VALUES (445566765, 234123777, 'Pedro Santos', '1950-12-11', 'Rua faria lima','123123445','emaildopedro@gmail.com', 'M');

INSERT INTO Pessoa (NIF, NIC, nome, data_nascimento, morada, telefone, correio_eletronico, genero)
	VALUES (555111333, 333111555, 'Joao Alegre', '1980-02-01', 'Rua fabio maria','222333444','emaildojoao@gmail.com', 'M');

INSERT INTO Pessoa (NIF, NIC, nome, data_nascimento, morada, telefone, correio_eletronico, genero)
	VALUES (666777999, 999222444, 'Bianca Feliz', '1999-05-21', 'Rua do lado de lá','212134344','emaildabianca@gmail.com', 'F');

INSERT INTO Pessoa (NIF, NIC, nome, data_nascimento, morada, telefone, correio_eletronico, genero)
	VALUES (898923233, 678987321, 'Salsicha Lombres', '1988-02-15', 'Rua biscoito ruim','316600900','emaildosalsicha@gmail.com', 'M');
	
INSERT INTO Pessoa (NIF, NIC, nome, data_nascimento, morada, telefone, correio_eletronico, genero)
	VALUES (143672952, 374562811, 'Marco Horacio', '1978-02-15', 'Rua biscoito bom','912834753','emaildomarco@gmail.com', 'M');

INSERT INTO Pessoa(NIF, NIC, nome, data_nascimento,	morada,	telefone, correio_eletronico, genero)
	VALUES (196874532, 173429086, 'Bruno Fernandes', '1987-03-23','Rua da posta de bacalhau', '923847252', 'brunof@gmail.com', 'M');
	
INSERT INTO Pessoa(NIF, NIC, nome, data_nascimento,	morada,	telefone, correio_eletronico, genero)
	VALUES (536368291, 456220523, 'Fernanda Santos', '1965-12-29', 'Rua do salmao', '934576284', 'nanda@gmail.com', 'F');

-- Nao_funcionario

INSERT INTO Nao_funcionario(NIF)  
	VALUES (196874532);
	
INSERT INTO Nao_funcionario(NIF)   
	VALUES (898923233);
	
INSERT INTO Nao_funcionario(NIF)  
	VALUES (536368291);
	
	
-- Utente

INSERT INTO Utente (NIF)
	VALUE (898923233);
	
INSERT INTO Utente (NIF)
	VALUE (536368291);
	
-- Visitante

INSERT INTO Visitante(NIF, voluntario, instituicao)
	VALUES (196874532, 'S', 'CDA');

-- Funcionario

INSERT INTO Funcionario (NIF)
VALUES (445566765);

INSERT INTO Funcionario (NIF)
VALUES (555111333);

INSERT INTO Funcionario (NIF)
VALUES (666777999);

INSERT INTO Funcionario (NIF)
VALUES (143672952);


-- trabalhadores

INSERT INTO trabalhadores (data_inicio,Funcionario,Clinica)
VALUES ('2021-04-07',445566765,'Clinica do Joao');

INSERT INTO trabalhadores (data_inicio,Funcionario,Clinica)
VALUES('2022-08-17',555111333,'Clinica do Joao');

INSERT INTO trabalhadores (data_inicio,Funcionario,Clinica)
VALUES('2021-09-29',666777999,'Clinica do Joao');

INSERT INTO trabalhadores (data_inicio,Funcionario,Clinica)
VALUES('2020-10-18',143672952,'Clinica do Joao');

-- Especialidade

INSERT INTO Especialidade(sigla, nome, preco_diario_internamento)
	VALUES ('CAR', 'Cardiologia', 20);
	
INSERT INTO Especialidade(sigla, nome, preco_diario_internamento)
	VALUES ('RAD', 'Radiologia', 15);
	
-- Medico

INSERT INTO Medico(NIF,	supervisor,	Especialidade)
	VALUES (666777999, NULL, 'CAR');

INSERT INTO Medico(NIF,	supervisor,	Especialidade)
	VALUES (555111333, 666777999, 'CAR');
	
INSERT INTO Medico(NIF,	supervisor,	Especialidade)
	VALUES (143672952, 666777999 , 'CAR');
	

	
-- Exame_Tipo

INSERT INTO Exame_Tipo(sigla, tipo, preco_normal, preco_urgencia)
	VALUES ('ECG', 'CAR', 10, 20);

-- Tecnico

INSERT INTO Tecnico(NIF,Exame_Tipo)
	VALUES (445566765,'ECG');
	

-- disponibiliza

INSERT INTO disponibiliza(Clinica, Especialidade)
	VALUES ('Clinica do Joao', 'CAR');
	
INSERT INTO disponibiliza(Clinica, Especialidade)
	VALUES ('Clinica do Joao', 'RAD');
	
-- realiza

INSERT INTO realiza(Clinica, Especialidade,	Exame_Tipo)
	VALUES ('Clinica do Joao', 'CAR', 'ECG');
	
INSERT INTO realiza(Clinica, Especialidade,	Exame_Tipo)
	VALUES ('Clinica do Joao', 'RAD', 'ECG');
	

-- habilitacoes

INSERT INTO habilitacoes(data_habilitacao, Tecnico,	Exame_Tipo)
	VALUES ('2018-04-03', 445566765, 'ECG');
	
-- especializacoes

INSERT INTO especializacoes(data_esp, Especialidade, Medico)
	VALUES ('2021-07-03', 'CAR', 666777999);
	
-- Exame

INSERT INTO Exame(codigo, tipo,	Exame_Tipo, Medico, inicio, fim)
	VALUES (52346, 'Eletrocardiograma', 'ECG',666777999, '2021-09-14 17:00', '2021-09-14 18:00');
	
-- prescricoes

INSERT INTO prescricoes(Exame, Utente,	Medico)
	VALUES (52346, 536368291, 666777999);
	
-- Exames_feitos

INSERT INTO Exames_feitos(Tecnico,Exame,Utente,Medico)
	VALUES (445566765,52346,536368291,666777999);

-- Relatorio

INSERT INTO Relatorio(numero, descricao_resultado, Medico, Exame, data_relatorio, parecer, numero_referencia, exame_referencia)
	VALUES (1, 'Está tudo bem.', 666777999, 52346, '2021-09-24', 'Dou-lhe 5 semanas.', NULL, NULL);


-- Internamento

INSERT INTO Internamento(Clinica, Cama, Utente,	numero,	piso, especialidade, Medico, inicio, fim, numero_maximo_de_visitantes_simultaneo)
	VALUES ('Clinica do Joao', 005, 898923233, 2211, 01, 'CAR', 666777999, '2022-10-13', '2022-10-16', 4);

	
-- visitas

INSERT INTO visitas(Visitante, solidaria, inicio, fim, data_visita, Clinica, numero, piso, Cama, Utente)
	VALUES (196874532, 'S', '15:00', '17:00', '2022-10-14', 'Clinica do Joao', 2211, 01, 005, 898923233 );
	
	
-- Fatura

INSERT INTO Fatura(numero, data_emissao, data_pagamento, Utente, Clinica)
	VALUES (1,'2022-10-16', '2022-10-16', 898923233, 'Clinica do Joao');
	
-- Diretor Clinico
UPDATE Clinica
	SET diretor_clinico = 143672952 WHERE (nome='Clinica do Joao');

UPDATE Clinica
	SET data_inicio_mandato = '2022-08-07' WHERE (nome='Clinica do Joao');
	

-- RIAs
-- RIA1: diretor clínico tem de ser médico na clínica que dirige
-- RIA2: data de início mandato ≥ data de início da associacao “trabalha”
-- RIA3: data de início mandato ≥ data de inauguracao da Clinica
-- RIA4: data de início ≥ data de inauguracao da Clínica
-- RIA5: Supervisor tem de trabalhar na mesma clínica em que o medico supervisionado trabalha
-- RIA6: Supervisor tem de ter a mesma especialidade que o medico supervisionado
-- RIA7: Supervisor nao se pode supervisionar a si proprio
-- RIA8: Caso nao exista supervisor, reportam aos diretores clinicos das clinicas onde trabalham
-- RIA9: Medico que prescreve o exame e o medico responsavel pelo paciente internado a que se refere o exame
-- RIA10: nº ≤ nº maximo de camas 
-- RIA11: Salas de internamento AND Salas de exames COVER Salas
-- RIA12: Medico AND Tecnico COVER Funcionario
-- RIA13: Funcionario AND Nao funcionario COVER Pessoa
-- RIA14: Utente AND Visitante COVER Nao funcionario
-- RIA15: Utente AND Visitante tem OVERLAP
-- RIA16: inicio ≥ inicio do horario do tipo “b” e fim ≤ fim do horario do tipo “b”
-- RIA17: nº máximo de visitantes em simultaneo ≤ nº maximo de visitantes em simultaneo permitidos pela sala em que o utente se encontra 
-- RIA18: tipo de equipamento tem de corresponder ao necessario para o tipo de exame	
	




		
	´
	


	
		

	
	
	
	
	
	
	 