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

--h. El inciso 4.f.
--Elabora un procedimiento que tome como parámetros el nombre de dos alumnos, que use
--cursores y que regrese en un parámetro de salida:
--0: si no llevan exactamente las mismas materias
--1: si sí, y
--2: si ambos no llevan materia alguna.
--Usa la función creada en el inciso 4.a para
