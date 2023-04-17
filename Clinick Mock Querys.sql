-- BD 2022/23 - etapa E2 - bd046 - Bianca Moiteiro, 54845, TP16, 34%; João Lago, 55164, TP16, 33%; Luís Rosa, 57142, Erasmus, 33%


-- 1. Nic e nome dos utentes internados em quartos, o seu género, distrito e país. O
-- resultado deve vir ordenado pelo pais e distrito de forma ascendente, e pelo nic de
-- forma descendente. Nota: pretende-se uma interrogação com apenas um SELECT,
-- ou seja, sem sub-interrogações	

SELECT p.nic, p.nome, p.genero, p.distrito, p.pais
	FROM internado i, pessoa p
	WHERE (i.utente = p.nic) AND (i.tipo = 'Q') 
	ORDER BY p.pais ASC, p.distrito ASC, p.nic DESC;
	
				 
-- 2. Cedula, nome, e país dos médicos que são especialistas em pelo menos uma das
-- especialidades: cardiologia e otorrino, ou que tenham um nome contendo a letra ‘e’
-- e tenham começado a sua actividade médica depois do ano de início da
-- pandemia C19 (2019). Nota: pode usar construtores de conjuntos.
	
(SELECT DISTINCT m.cedula, p.nome, p.pais
	FROM medico m, pessoa p, especialista e
	WHERE (m.nic = p.nic) AND (e.medico = m.nic) AND (e.especialidade = 'cardiologia' OR e.especialidade = 'otorrino'))
UNION
(SELECT m.cedula, p.nome, p.pais
	FROM medico m, pessoa p, especialista e
	WHERE (m.nic = p.nic) AND (e.medico = m.nic) AND (p.nome LIKE '%e%') AND (m.ano >= 2019));

		   		   
-- 3. Nic, nome e país dos utentes internados em enfermaria mais de 7 dias, que
-- receberam visitas solidárias de pelo menos uma pessoa de um país diferente do
-- seu e um nome com 5 letras, terminado por ‘o’.

SELECT p.nic, p.nome, p.pais
	FROM pessoa p, internado i, visita v, pessoa vp
	WHERE (p.nic = i.utente) AND (i.tipo = 'E') AND (i.dias > 7) AND (v.utente = i.utente) AND (v.tipo = 'S')
		AND (v.visitante = vp.nic) AND (vp.pais <> p.pais) AND (LENGTH(vp.nome) = 5) AND (vp.nome LIKE '%o');
		

-- 4. Nome e ano (de início) dos médicos que iniciaram actividade depois do ano da
-- pandemia de Gripe A - H1N1 (2009), e que nunca foram responsáveis por
-- internamentos em quarto que tenham durado mais de 21 dias.

SELECT p.nome, m.ano as ano_inicio
	FROM pessoa p, medico m
	WHERE (p.nic = m.nic) AND (m.ano > 2009) AND (m.nic NOT IN (SELECT i.medico
												 						FROM medico m, internado i
																		WHERE (i.medico = m.nic) AND (i.tipo = 'Q') AND (i.dias > 21)));


-- 5. Ano de actividade, nic, cedula e nome dos médicos que tenham sido responsáveis
-- por todos os internamentos de utentes do Mónaco (MC) realizados em enfermaria,
-- por mais de 100 dias, no ano em que iniciaram a sua actividade. Nota: o resultado
-- deve vir ordenado pelo ano e pelo nome de forma ascendente.
	
SELECT m.ano, p.nic, m.cedula, p.nome
	FROM pessoa p, medico m
	WHERE (p.nic = m.nic) AND (m.nic IN( SELECT i.medico
									FROM internado i 
									WHERE (m.nic = i.medico) AND (i.ano = m.ano) AND (i.dias > 100) AND (i.tipo = 'E') AND (i.utente IN( SELECT up.nic
																															FROM pessoa up 
																															WHERE (i.utente = up.nic) AND (up.pais = 'MC'))))
								 )
ORDER BY m.ano ASC, p.nome ASC;
	

-- 6. Número de internamentos da responsabilidade de cada médico (indicando nic e
-- nome) em cada especialidade. Nota: ordene o resultado pela especialidade de
-- forma ascendente e pelo nome do médico de forma descendente.

SELECT COUNT(i.medico), p.nic, p.nome, i.especialidade
	FROM pessoa p, medico m, internado i, especialista e
	WHERE (p.nic = i.medico) AND (i.medico = m.nic) AND (i.medico = e.medico) AND (i.especialidade = e.especialidade)
	GROUP BY i.especialidade, i.medico
	ORDER BY i.especialidade ASC, p.nome DESC;
		   
		   
-- 7. Cédula, nome e nacionalidade dos médicos que foram responsáveis (como
-- especialidade/actividade principal), por mais internamentos em quarto, em cada
-- uma das especialidades existentes. Notas: em caso de empate, devem ser
-- mostrados todos os médicos em causa.

SELECT m.cedula, p.nome, p.pais, i.especialidade                                          
	FROM medico m, pessoa p, especialista e , internado i
	WHERE (m.nic = p.nic) AND (e.atividade = 'P') AND (i.tipo = 'Q') AND (i.medico = m.nic) AND (e.medico = m.nic) AND (i.especialidade = e.especialidade)
	GROUP BY i.especialidade, i.medico			
	HAVING COUNT(i.medico) >= ALL (SELECT COUNT(i1.medico)
								FROM medico m1, pessoa p1, internado i1, especialista e1
								WHERE (m1.nic = p1.nic) AND (e1.atividade = 'P') AND (i1.tipo = 'Q') AND (i1.medico = m1.nic) 
									AND (e1.medico = m1.nic) AND (i1.especialidade = i.especialidade)
								GROUP BY i1.medico);				

						
-- 8. Nome, ano de nascimento e nacionalidade das pessoas que nasceram depois do
-- ano inicial da Operação Nariz Vermelho (2002) e visitaram menos de 5 internados
-- distintos, mesmo que não tenham visitado nenhum. Pretende-se uma interrogação
-- sem sub-interrogações: apenas com um SELECT.

SELECT p.nome, p.ano, p.pais, COUNT(DISTINCT v.utente) as num_pessoas_visitadas              
    FROM pessoa p, visita v LEFT OUTER JOIN internado i ON ((v.utente = i.utente) AND (v.intern = i.numero))
    WHERE (p.nic = v.visitante) AND (p.ano > 2002)
    GROUP BY v.visitante
    HAVING COUNT(DISTINCT v.utente) < 5;


-- 9. Para cada país e região de origem, o nic e nome da pessoa que realizou mais visitas
-- solidárias, indicando o número de visitas, e a maior e menor duração dos
-- internamentos visitados. Nota: devem ser mostrados todos os visitantes que
-- empatarem neste total de visitas.

SELECT p.pais, p.distrito, p.nic, p.nome, COUNT(v.visitante) as num_vis , MAX(i.dias) as maior_duracao_int, MIN(i.dias) as menor_duracao_int
	FROM pessoa p, visita v LEFT OUTER JOIN internado i ON ((v.utente = i.utente) AND (v.intern = i.numero))
	WHERE (p.nic = v.visitante) AND (v.tipo = 'S')
	GROUP BY p.nic
	HAVING COUNT(v.visitante) >= ALL (SELECT COUNT(v2.visitante)
									   FROM pessoa p1, visita v2
									   WHERE (p1.nic = v2.visitante) AND (v2.tipo = 'S') AND (p1.pais = p.pais) AND (p1.distrito = p.distrito)
                                       GROUP BY p1.nic);