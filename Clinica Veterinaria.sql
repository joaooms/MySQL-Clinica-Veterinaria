create schema clinica; 
use clinica; 

create table paciente ( 
id_paciente int auto_increment primary key, 
Nome  varchar (100),
Especie varchar (50),
Idade int
 );
 
 insert into paciente (Nome, Especie, Idade)
 values ('PÉ DE PANO','CAVALO',20);
 SELECT * FROM paciente;
 
 create table veterinario (
 id_veterinario int auto_increment primary key,
 Nome varchar (100), 
 Especialidade VARCHAR (50)
 );
 
 insert into veterinario (Nome, Especialidade)
 values ('Dr Chapatin', 'Porte grande');
 SELECT * FROM veterinario;
 
 create table consultas ( 
 id_consulta int auto_increment primary key,
 id_paciente int,
 id_veterinario int,
 Data_consulta date, 
 Custo decimal (10,2),
 Foreign key (id_paciente) references paciente (id_paciente),
 Foreign key (id_veterinario)  references veterinario (id_veterinario)
 ); 
 
 insert into consultas (id_paciente, id_veterinario, Data_consulta, Custo)
 values (1,1,'2002-08-09', 10.80);
 SELECT * FROM consultas; 
  
  DELIMITER // 
  create procedure agendar_consulta(
  in p_id_paciente int,
  in p_id_veterinario int, 
  in p_Data_consulta date,
  in p_custo decimal (10,2)
  )
  begin
    insert into consultas (id_paciente, id_veterinario, Data_consulta, Custo)
    values (p_id_paciente, p_id_veterinario, p_Data_consulta, p_custo);
	end // 
	
DELIMITER ;

CALL agendar_consulta(1, 1, '2024-09-30', 100.50);


DELIMITER //
create procedure atualizar_paciente(
    in p_id_paciente int,
    in p_novo_nome varchar (100),
    in p_nova_especie varchar(50),
    in p_nova_idade int
)
begin
    update paciente
    Set Nome = p_novo_nome,
        Especie = p_nova_especie,
        Idade = p_nova_idade
    where id_paciente = p_id_paciente;
end //

DELIMITER ;
call atualizar_paciente (1,'tango','orangotango',20);


DELIMITER // 
create procedure remover_consulta(
in p_id_consulta int 
)
begin
delete from consultas 
where id_consulta = p_id_consulta;
end// 

DELIMITER ; 
CALL remover_consulta(1); 


DELIMITER //
create function total_gasto_paciente(
    in p_id_paciente int
)
returns decimal(10,2)
deterministic 
begin 
declare total decimal(10,2);

SELECT COALESCE(SUM(Custo),0) into total
from consultas
where id_paciente = p_id_paciente; 

if total is null then 
set total = 0.00;
end if; 

return total; 
END// 

DELIMITER ;
SELECT total_gasto_paciente(1) AS total_gasto;



DELIMITER //
create trigger verificar_idade_paciente
before insert on paciente
for each row
begin 
    IF NEW.Idade <= 0 THEN
        SIGNAL SQLSTATE '100'
        SET MESSAGE_TEXT = 'iDADE INVALIDA.';
    END IF;
end //

DELIMITER ;

insert into paciente (Nome, Especie, Idade) 
VALUES ('CHORRO', 'CACHORRO', -6);



DELIMITER // 
create trigger atualizar_custo_consulta
after update on consultas
for each row
begin 
    IF OLD.Custo <> NEW.Custo THEN
       insert into Log_Consultas (id_consulta, custo_antigo, custo_novo)
        values (NEW.id_consulta, OLD.Custo, NEW.Custo);
    END IF;
End //

DELIMITER ;
UPDATE consultas SET Custo = 50.00 WHERE id_consulta = 1;

/*
JOÃO Vitor Monteiro - 11221103577 
*/