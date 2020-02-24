-- TAREA 2 DE BASES DE DATOS --
-- Profesor: Felipe López
-- Alumnos: 
	--	José Luis Gutiérrez (179888)
	--	Rodrigo González()
	--	Diego Hernández Delgado (176262)

"Tarea no. 2: Utilizando la base de datos de Concursos-Tesis contesta las siguientes preguntas
empleando frases select (recuerda que cualquier autor que aparezca en la base de datos ya es
ganador, sin importar que lugar haya ganado; también recuerda que las organizaciones se dividen
en escuelas o empresas):

Fecha de entrega: clase 10, a las 21 hrs. (máximo). Enviar al correo del profesor (flopez@itam.mx)
el archivo de texto con los selects."

--a. Escribir el nombre de las universidades que tienen carreras en el área de ‘Ingeniería’, junto con
--el nombre de dichas carreras y el de sus egresados.
select nomorg,Noma,carrera.nomcar from Organización inner join Estudió on Organización.Idorg=Estudió.IdOrg
inner join Tesis on Estudió.idT=Tesis.idT
inner join Autor on Estudió.IdA=Autor.IdA
inner join Carrera on Carrera.IdCar=Estudió.IdCar
where NomCar like 'Ing%'

--b. Listar el título de las tesis que participaron en concursos del año pasado. Ordenar
--descendentemente por nombre del concurso y ascendentemente por nombre de la tesis.
select nomt,nomcon from tesis inner join Estudió on tesis.idt=Estudió.idt
inner join Organizó on Organizó.idorg=Estudió.idorg
inner join Concurso on Concurso.idcon=Organizó.idcon
inner join ganó on tesis.idt=ganó.idt
where extract(year from fechatit) = extract(year from sysdate)
order by nomcon desc, nomt

--c. Mostrar el nombre de las empresas que han participado en la organización de concursos con
--montos mínimos de 40,000. Ordenar descendentemente por año y por monto.
SELECT o.NomOrg, EXTRACT(YEAR FROM c.FechaFin), oó.Monto FROM Organización o, Organizó oó, Concurso c
WHERE  oó.IdOrg=o.IdOrg AND o.Tipo = 'emp'AND oó.Monto >= 40000
ORDER BY EXTRACT(YEAR FROM c.FechaFin) DESC, oó.Monto DESC


--d. Obtener el nombre de todas las carreras que son licenciaturas, junto con el nombre de las
--universidades en que se imparten.
select nomorg,carrera.nomcar from Organización inner join Estudió on Organización.Idorg=Estudió.IdOrg
inner join Tesis on Estudió.idT=Tesis.idT
inner join Autor on Estudió.IdA=Autor.IdA
inner join Carrera on Carrera.IdCar=Estudió.IdCar
where NomCar like 'Lic%'

--e. Escribir el nombre de los concursos, y el año, en los cuales no participaron egresados del ITAM.
--Ordenar ascendentemente por año.
select distinct nomcon, extract(year from fechaini) from concurso
inner join ganó on concurso.idcon=ganó.idcon
inner join Estudió on Ganó.idt=Estudió.idt
where Estudió.idorg <> (select idorg from Organización where nomorg = 'ITAM')

--f. Listar el nombre de las tesis que ganaron algún lugar en los concursos BANAMEX y AMIME
--del año pasado (en ambos, no sólo en uno u otro).
SELECT t.NomT FROM Tesis t, Ganó g, Concurso c, Organizó oó
WHERE t.IdT=g.IdT AND g.IdCon=c.IdCon AND c.IdCon=oó.IdCon AND extract(year from c.FechaIni)=extract(year from sysdate)-1
AND oó.IdOrg IN
    (SELECT o.IdOrg FROM Organización o, Organizó oó
    WHERE  oó.IdOrg=o.IdOrg AND (o.NomOrg='BANAMEX' AND o.NomOrg='AMIME')
    GROUP BY  o.IdOrg) --Query para obtener Id de BANAMEX y AMIME
    

--g. Mostrar el nombre de los autores que participaron en algún concurso tanto el año pasado como
--éste (en ambos, no sólo en uno u otro). Acompañarlos con el nombre de la(s) carrera(s) de la(s)
--que egresaron.

select distinct Noma, carrera.nomcar from AUTOR inner join Estudió on AUTOR.IdA=Estudió.IdA  inner join Carrera on Estudió.IdCar=Carrera.IdCar inner join Tesis on Estudió.IdT=Tesis.IdT inner join Ganó on Tesis.IdT=Ganó.IdT inner join Concurso on Ganó.IdCon=Concurso.IdCon where Noma in
(select Noma from AUTOR inner join Estudió on AUTOR.IdA=Estudió.IdA inner join Tesis on Estudió.IdT=Tesis.IdT inner join Ganó on Tesis.IdT=Ganó.IdT inner join Concurso on Ganó.IdCon=Concurso.IdCon where extract (year from FechaIni) = extract(year from sysdate)-1)
and Noma in
(select Noma from AUTOR inner join Estudió on AUTOR.IdA=Estudió.IdA inner join Tesis on Estudió.IdT=Tesis.IdT inner join Ganó on Tesis.IdT=Ganó.IdT inner join Concurso on Ganó.IdCon=Concurso.IdCon where extract (year from FechaIni) = extract(year from sysdate))


--h. Obtener el nombre de los alumnos que egresaron de alguna carrera del área de ‘Administrativas’-
--o que participaron en algún concurso celebrado este año.
select noma from Ganó,Autor inner join Estudió on Autor.idA=Estudió.ida
inner join Carrera on Carrera.idCar=Estudió.idCar
where (área='Administrativas') or (extract(year from fechatit) = extract(year from sysdate) and Estudió.idt in Ganó.idt)

--i. Por empresa y por año, contar la cantidad de concursos que han organizado.
SELECT o.NomOrg, EXTRACT(YEAR FROM c.FechaIni) AS Fecha, COUNT(*) 
FROM Organización o, Organizó oó, Concurso c
WHERE oó.IdOrg=o.IdOrg
GROUP BY o.NomOrg, EXTRACT(YEAR FROM c.FechaIni)
ORDER BY o.NomOrg


--j. Escribir el nombre de las escuelas cuyos egresados han ganado algún lugar en más de dos
--concursos distintos.

select nomorg,count(distinct idcon) Cant_concursos_distintos
	from organización org, estudió e, ganó g
	where org.idorg=e.idorg and e.idt=g.idt
	group by nomorg
	having count(distinct idcon)>2


--k. Listar el nombre de los concursos cuyo monto total de organización fue de al menos 100,000.
--Acompañarlos con el nombre de las organizaciones participantes, ordenando ascendentemente
--por nombre del concurso y descendentemente por el de la organización.
select x.nomcon,Organización.nomorg from
(select distinct nomcon,Estudió.idorg as org from Concurso inner join Organizó on Concurso.idcon=Organizó.idcon
inner join Ganó on Ganó.idcon=Concurso.idcon
inner join Estudió on Estudió.idT=Ganó.idT
where monto >= 100000) x
inner join Organización on Organización.idorg = x.org
order by nomcon, Organización.nomorg desc

--l. Encontrar el nombre de los autores que ganaron el primer lugar en máximo un concurso durante
--el año pasado. Acompañarlos con el nombre de la tesis con la cual ganaron.
SELECT NomA, NomT, Lugar, EXTRACT(YEAR FROM FechaFin)
FROM Autor a, Estudió e, Tesis t, Ganó g, Concurso c
WHERE EXTRACT (YEAR FROM fechaini)=EXTRACT(YEAR FROM SYSDATE)-1
      AND t.IdT IN (SELECT IdT
                    FROM Ganó g, Concurso c
                    WHERE Lugar=1 
                          AND EXTRACT (YEAR FROM fechaini)=EXTRACT(YEAR FROM SYSDATE)-1
                          AND g.IdCon=c.IdCon
                    GROUP BY IdT
                    HAVING COUNT(IdT)=1)
      AND a.IdA=e.IdA AND e.IdT=t.IdT AND t.IdT=g.IdT AND g.IdCon=c.IdCon



--m. Obtener el nombre de la(s) organización(es) que más concursos ha(n) organizado.
select nomOrg, count(*) Cant_concursos
from organización, organizó, concurso 
where organización.idOrg = organizó.idOrg and organizó.idCon = concurso.idCon
group by nomOrg having count(*) >= all
		(select count(*)
		from organizó
		group by idorg)

--n. Mostrar el nombre de las carreras cuyos egresados tienen menos participaciones en los
--concursos. Mostrar también el nombre de las universidades en que se imparten.
select x.nom,organización.nomorg from
	(select nomcar as nom,min(count(*)) as cont 
	from carrera inner join imparte on carrera.idcar=imparte.idcar
	inner join Organización on Organización.idorg=imparte.idorg
	inner join Estudió on  Estudió.idorg=Organización.idorg
	inner join Ganó on Ganó.idt=Estudió.idT
	group by nomcar
	order by nomcar) x
inner join carrera on x.nom=carrera.nomcar
inner join imparte on carrera.idcar=imparte.idcar
inner join Organización on organización.idorg=imparte.idorg
where x.cont = (select min(count(*))
		from carrera inner join imparte on carrera.idcar=imparte.idcar
		inner join Organización on Organización.idorg=imparte.idorg
		inner join Estudió on  Estudió.idorg=Organización.idorg
		inner join Ganó on Ganó.idt=Estudió.idT
		group by nomcar)

--o. Listar el nombre de las tesis, y el de sus autores, que han participado en más concursos.
SELECT NomT, NomA, COUNT(*) AS Num_Concursos
FROM Autor a, Estudió e, Tesis t, Ganó g, Concurso c
WHERE a.IdA=e.IdA AND e.IdT=t.IdT AND t.IdT=g.IdT AND g.IdCon=c.IdCon
GROUP BY NomT, NomA
HAVING COUNT(*) = (SELECT MAX(COUNT(Lugar))
                   FROM Ganó
                   GROUP BY IdT)
		   

--p. Escribir el nombre de las organizaciones (escuelas o empresas) que han participado en la
--organización de todos los concursos registrados.

select nomOrg, count(*) cant_concursos
from organización, organizó, concurso 
where organización.idOrg = organizó.idOrg and organizó.idCon = concurso.idCon
group by nomOrg having count(*)>=all
  (select count(idCon) 
  from concurso)
