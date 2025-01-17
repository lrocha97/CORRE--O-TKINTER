create database trabalho_svendas;
use trabalho_svendas;
-- drop database trabalho_svendas;

create table cargos(
	id int not null primary key auto_increment,
    nome_cargo varchar(30) not null
);

create table usuarios(
	id int not null primary key auto_increment,
    email varchar(40) not null,
    senha varchar (8) not null,
    cargo_id int not null,
    foreign key (cargo_id) references cargos(id)
);

create table produtos(
	id int not null primary key auto_increment,
    nome varchar(40) not null,
    descricao varchar (55) not null,
    quantidade_estoque int not null default 0,
    valor decimal(10, 2) not null
);

CREATE TABLE vendas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_cliente varchar(50) not null,
    cpf varchar(11) not null,
    usuario_id INT NOT NULL,
    data_venda DATETIME DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento ENUM('à vista', 'parcelado') NOT NULL,
    quantidade_parcelas INT DEFAULT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

CREATE TABLE venda_produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    venda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (venda_id) REFERENCES vendas(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- TRIGGER
DELIMITER //

CREATE TRIGGER atualizar_estoque
AFTER INSERT ON venda_produtos
FOR EACH ROW
BEGIN
    -- Atualiza a quantidade em estoque na tabela produtos
    UPDATE produtos
    SET quantidade_estoque = quantidade_estoque - NEW.quantidade
    WHERE id = NEW.produto_id;
END;
//

DELIMITER ;



-- TESTAR O BANCO
-- cargos
INSERT INTO cargos (nome_cargo) VALUES ('Administrador'), ('Vendedor');

-- usuarios
INSERT INTO usuarios (email, senha, cargo_id) 
VALUES 
('joao@empresa.com', '12345678', 2), -- Vendedor
('maria@empresa.com', 'senha123', 1); -- adm

-- produtos
INSERT INTO produtos (nome, descricao, quantidade_estoque, valor)
VALUES 
('Notebook', 'Eletrônico', 10, 3500.00),
('Smartphone', 'Eletrônico', 20, 2000.00),
('Mouse', 'Acessório', 50, 50.00);

-- venda
INSERT INTO vendas (nome_cliente, cpf, usuario_id, forma_pagamento, quantidade_parcelas, valor_total)
VALUES 
('Carlos Silva', '12345678901', 1, 'parcelado', 3, 4000.00), -- Venda feita por João
('Ana Santos', '98765432100', 2, 'à vista', NULL, 2000.00); -- Venda feita por Maria

-- Produtos vendidos na primeira venda (venda_id = 1)
INSERT INTO venda_produtos (venda_id, produto_id, quantidade, preco_unitario)
VALUES 
(1, 1, 1, 3500.00), -- 1 Notebook
(1, 3, 10, 50.00);  -- 10 Mouse

select * from produtos; -- testar a trigger 

-- Produtos vendidos na segunda venda (venda_id = 2)
INSERT INTO venda_produtos (venda_id, produto_id, quantidade, preco_unitario)
VALUES 
(2, 2, 1, 2000.00); -- 1 Smartphone


-- relatorio
SELECT 
    v.nome_cliente AS Cliente,
    u.email AS Usuario_Responsavel,
    c.nome_cargo AS Cargo_Responsavel,
    GROUP_CONCAT(p.nome SEPARATOR ', ') AS Produtos,
    v.valor_total AS Valor_Total_Venda,
    v.data_venda AS Data_Venda
FROM 
    vendas v
JOIN 
    usuarios u ON v.usuario_id = u.id
JOIN 
    cargos c ON u.cargo_id = c.id
JOIN 
    venda_produtos vp ON v.id = vp.venda_id
JOIN 
    produtos p ON vp.produto_id = p.id
GROUP BY 
    v.nome_cliente;