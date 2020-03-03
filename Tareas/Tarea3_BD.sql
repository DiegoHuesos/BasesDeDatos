-- TAREA 3 DE BASES DE DATOS --
-- Profesor: Felipe López
-- Alumnos: 
	--	José Luis Gutiérrez (179888)
	--	Rodrigo González(183873)
	--	Diego Hernández Delgado (176262)

--5 - Tarea no. 3: Elabora los subprogramas almacenados, cursores o triggers que se piden a
--continuación utilizando la base de datos de Concursos-Tesis. En todos los casos controla los posibles
--errores que se puedan presentar.

--Entregables:
--La definición y la forma de ejecución de cada inciso, en un archivo de texto, el cual debe ser
--enviado por correo al profesor. Cuando envíen las respuestas, en su base de datos ya deben
--estar guardadas todas las definiciones.
--Nota:
--Dado que se van a realizar varias pruebas, la base de datos va a experimentar cambios en los
--datos. Una vez que entreguen la tarea, repongan los datos originales que tenía la base.
--Fecha límite de entrega: 21 hrs. del día previo al primer examen parcial.


--a. Elabora una función que reciba el nombre de un área (Ingeniería, Sociales o Administrativas) y
--entregue la cantidad de egresados de la misma que han participado en los concursos.
create or replace 
function cantEg (Area char)
  return integer is auxCant integer;
  begin
    select count(*) into auxCant from Ganó inner join Estudió on Estudió.idT=Ganó.idT
    inner join Carrera on Carrera.idCar=Estudió.idCar
    where Carrera.Área = Area;
    return auxCant;
  end;
 

--b. Elabora un procedimiento que entregue dos parámetros de salida, el primero con el nombre del
--área que más egresados tiene y el segundo con el de la que menos tiene (si en algún caso hay
--empate, regresa el área alfabéticamente menor). Utiliza la función anterior. No emplees cursores.
create or replace procedure mayorMenorEg(mas out varchar, menos out varchar) is
begin
select Área into menos from
  (select Área, count(*) as canti from Carrera inner join Estudió on Carrera.idCar=Estudió.idCar
  inner join Tesis on Tesis.idT=Estudió.idT group by Área order by canti, Área)
 Fetch first 1 rows only;
  
select Área into mas from
  (select Área, count(*) as canti from Carrera inner join Estudió on Carrera.idCar=Estudió.idCar
  inner join Tesis on Tesis.idT=Estudió.idT group by Área order by canti desc, Área)
  Fetch first 2 rows only;
end;

--c. Elabora un procedimiento que reciba como entrada el nombre de una organización, el nombre
--de un concurso y un monto, y agregue la tupla correspondiente en la tabla Organizó.
create or replace procedure creaConc(org varchar, conc varchar, monto float) is
idC integer; idO integer;
begin
  select idOrg into idO from Organización where NomOrg = org;
  select idCon into idC from Concurso where NomCon = conc;
  insert into Organizó values(idO,idC,monto);
end;

--d. Elabora una función que reciba dos valores enteros de entrada, representando años en que se han
--efectuado concursos. La función deberá entregar como resultado una cadena ‘Sí’, en caso de que
--todas las empresas que participaron en la organización de los concursos del año dado en el
--primer parámetro, hayan participado también en la organización de los concursos celebrados en
--el año dado en el segundo; en caso contrario, la función debe regresar la cadena ‘No’. Utiliza
--cursores para que esta función sea más eficiente. Este problema es de inclusión de conjuntos.

--Declaración:
create or replace function incisoD(anio1 int, anio2 int) return varchar is
  participaron varchar(5); orgID int; conID int;
    cursor org is select IDORG FROM ORGANIZACIÓN;
    cursor con is (select distinct IdOrg from Organizó o, Concurso c
    where o.IDCON=c.IDCON
    and (Extract( year from (c.FECHAINI))=anio1 or Extract(year from (c.FECHAFIN))=anio1))
    intersect (select distinct IdOrg from Organizó o, Concurso c
    where o.IDCON=c.IDCON
    and (Extract( year from (c.FECHAINI))=anio2 or Extract(year from (c.FECHAFIN))=anio2));
begin
    orgID := 0;
    conID := 0;
    for orgTupla in org loop
        orgID := orgID + 1;
    end loop;
    for conTupla in con loop
        conID := conID + 1;
    end loop;
    if orgID <> conID then
        participaron:='No';
    else
        participaron:='Sí';
    end if;
    return participaron;
end;

--Ejecución
declare
    anio1 int; anio2 int; resp varchar(5);
begin
    anio1:=2016;
    anio2:=2017;
    resp:=incisoD(anio1,anio2);
    dbms_output.put_line(resp);
end;


--e. Elabora un trigger que actualice todas las tablas que sean necesarias cuando se cambie la clave
--de una tesis.
create or replace trigger trigerIdT
after update on Tesis
for each row
begin
  update Estudió set IdT = :new.IdT where IdT = :old.IdT;
  update Ganó set IdT = :new.IdT where IdT = :old.Idt;
end;

--f. Elabora un trigger que actualice todas las tablas que sean necesarias cuando se cambie la clave
--de una organización. En este caso tendrás que definir otros triggers de actualización sobre las
--tablas de Escuela e Imparte para poder hacer todas las actualizaciones que se requieran.
create or replace trigger cambiaOrg
after update on Organización
for each row
begin
  update Estudió set idOrg = :new.idOrg where idOrg =:old.idOrg;
  update Imparte set idOrg = :new.idOrg where idOrg =:old.idOrg;
  update Organizó set idOrg = :new.idOrg where idOrg =:old.idOrg;
  update Escuela set idOrg = :new.idOrg where idOrg =:old.idOrg;
  update Empresa set idOrg = :new.idOrg where idOrg =:old.idOrg;
end;

--g. Elabora un trigger sobre la tabla Organizó de tal manera que cuando se inserte una tupla, se
--muestren en pantalla el nombre de las organizaciones y la suma total que cada una ha aportado
--para la organización de los concursos registrados. Requerirás de un cursor para poder hacer el
--desplegado.
--Nota: en este caso debes usar after insert, y no usar for each row en la definición del trigger. Al
--no usar esta cláusula, no se podrá emplear :old, ni :new, aunque no son necesarios para este
--ejercicio.

--Declaración:
   create or replace trigger InsOrganiza  
	after insert on Organizó
    declare cursor Organiza is
	select NomOrg, sum(monto)
	from Organización org, Organizó o
	where org.IdOrg=o.IdOrg group by nomOrg;
	nombre varchar(30); monto real;
	    begin
    	open Organiza;
	      loop
    	fetch Organiza into nombre, monto;
    	exit when Organiza%notfound;
    	dbms_output.put_line('La organización: ' || nombre || ', Suma: ' || monto);
	  end loop;
	 close Organiza;
	    end;

--Ejecución:
	set SERVEROUTPUT ON
create or replace function cantMatersAlum(nombre char) return integer is
  cantMaters integer;
begin
  select count(*) into cantMaters
  from Alum a, Inscrito i
  where Nomal=nombre and a.CU=i.CU;
  return cantMaters;
end;


--h. El inciso 4.f.
--Elabora un procedimiento que tome como parámetros el nombre de dos alumnos, que use
--cursores y que regrese en un parámetro de salida:
--0: si no llevan exactamente las mismas materias
--1: si sí, y
--2: si ambos no llevan materia alguna.
--Usa la función creada en el inciso 4.a para
--Usa la función creada en el inciso 4.a para contar las materias:
create or replace function cantMatersAlum(nombre char) return integer is
  cantMaters integer;
begin
  select count(*) into cantMaters
  from Alum a, Inscrito i
  where Nomal=nombre and a.CU=i.CU;
  return cantMaters;
end;

create or replace procedure igualMaterias(alum1 varchar, alum2 varchar) is 
  cantAlum1 integer; cantAlum2 integer; resp integer;
  
  declare cursor MateriasAlum1 is
    select m.ClaveM as matsAlum1 from Inscrito i, Alum a, Grupo g, Mater m where a.NomAl=alum1
    and a.CU = i.CU and i.ClaveG = g.ClaveG and g.ClaveM = m.ClaveM GROUP BY m.ClaveM ORDER BY m.ClaveM;

  declare cursor MateriasAlum2 is
    select m.ClaveM as matsAlum2 from Inscrito i, Alum a, Grupo g, Mater m where a.NomAl=alum2
    and a.CU = i.CU and i.ClaveG = g.ClaveG and g.ClaveM = m.ClaveM GROUP BY m.ClaveM ORDER BY m.ClaveM;
        
  idMatAlum1 integer; idMatAlum2 integer;
  tuplaAlum1 MateriasAlum1%rowtype; tuplaAlum2 MateriasAlum1%rowtype;
  
begin
  cantAlum1 := cantMatersAlum(alum1);
  cantAlum2 := cantMatersAlum(alum2);
  
  if cantAlum1 = cantAlum2 then
    if cantAlum1 = 0 then
      res := 2;
    else
      begin
        open 
        loop
          fetch MateriasAlum1 into idMatAlum1;
          fetch MateriasAlum2 into idMatAlum2;
          exit when MateriasAlum1%notfound or idMatAlum1 <> idMatAlum2;
        end loop;
        close MateriasAlum1;
        close MateriasAlum2;
      end;
      if MateriasAlum1%notfound then
        resp := 1;
      else
        resp := 0;
      end if;

    end if;
  end if;
  dbms_output.put_line(resp);
end;


begin
igualMaterias('Ana','José');
end;
