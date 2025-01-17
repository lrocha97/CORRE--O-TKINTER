import mysql.connector

# Classe para interação com o banco de dados
class Database:
    def __init__(self):
        self.connection = mysql.connector.connect(
            host="localhost",
            user="root",         # Substitua pelo usuário do seu banco
            password="",         # Substitua pela senha do seu banco
            database="trabalho_svendas" # Substitua pelo nome do seu banco
        )
        self.cursor = self.connection.cursor()

    def login(self, email, senha):
        query = "SELECT id FROM usuarios WHERE email=%s AND senha=%s"
        self.cursor.execute(query, (email, senha))
        return self.cursor.fetchone()

    def buscar_produtos(self):
        query = "SELECT id, nome, valor, quantidade_estoque FROM produtos"
        self.cursor.execute(query)
        return self.cursor.fetchall()

    def cadastrar_venda(self, nome_cliente, cpf, usuario_id, forma_pagamento, quantidade_parcelas, valor_total, produtos):
        try:
            # Inserir na tabela vendas
            query_venda = """
                INSERT INTO vendas (nome_cliente, cpf, usuario_id, forma_pagamento, quantidade_parcelas, valor_total)
                VALUES (%s, %s, %s, %s, %s, %s)
            """
            self.cursor.execute(query_venda, (nome_cliente, cpf, usuario_id, forma_pagamento, quantidade_parcelas, valor_total))
            venda_id = self.cursor.lastrowid

            # Inserir na tabela venda_produtos
            for produto_id, quantidade, preco_unitario in produtos:
                query_venda_produto = """
                    INSERT INTO venda_produtos (venda_id, produto_id, quantidade, preco_unitario)
                    VALUES (%s, %s, %s, %s)
                """
                self.cursor.execute(query_venda_produto, (venda_id, produto_id, quantidade, preco_unitario))

            self.connection.commit()
            return True
        except Exception as e:
            self.connection.rollback()
            print("Erro ao cadastrar venda:", e)
            return False

    def buscar_vendas(self):
        query = """
            SELECT 
                v.id AS venda_id,
                v.nome_cliente AS Cliente,
                v.valor_total AS Valor_Total_Venda,
                v.data_venda AS Data_Venda,
                GROUP_CONCAT(p.nome SEPARATOR ', ') AS Produtos
            FROM vendas v
            JOIN venda_produtos vp ON v.id = vp.venda_id
            JOIN produtos p ON vp.produto_id = p.id
            GROUP BY v.id
            ORDER BY v.data_venda DESC
        """
        self.cursor.execute(query)
        return self.cursor.fetchall()