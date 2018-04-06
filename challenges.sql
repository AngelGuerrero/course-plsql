
-- Necesita el procedimiento compilado y almacenado para funcionar
EXECUTE make_table('my_contacts', 'name varchar2(40)');

EXECUTE make_table('clientes', 'nomcliente VARCHAR(50)', TRUE);
EXECUTE make_table('direcciones', 'direccion VARCHAR(100)', TRUE);

EXECUTE make_table('t_direcciones', 'clientes_id NUMBER, direcciones_id NUMBER', TRUE);
EXECUTE make_table('pedidos', 'fechapedido DATE, t_direcciones_id NUMBER', TRUE);

EXECUTE add_row('clientes', ' ''1'', ''Geoff Gallus'' ');
EXECUTE add_row('clientes', ' ''2'', ''Nancy'' ');
EXECUTE add_row('clientes', ' ''3'', ''Robert'' ');

EXECUTE add_row('direcciones', ' ''1'', ''Mayas 434'' ');
EXECUTE add_row('direcciones', ' ''2'', ''Palmas 432'' ');

EXECUTE add_row('t_direcciones', ' ''1'', ''1'', ''1'' ');
EXECUTE add_row('t_direcciones', ' ''2'', ''2'', ''2'' ')
;
EXECUTE add_row('t_direcciones', ' ''3'', ''3'', ''1'' ');

EXECUTE add_row('pedidos', ' ''1'', ''02/03/2018'', ''1'' ');
EXECUTE add_row('pedidos', ' ''2'', ''02/03/2018'', ''2'' ');
EXECUTE add_row('pedidos', ' ''3'', ''03/03/2018'', ''3'' ');


select *
  from clientes cli
  join t_direcciones td using (clientes_id)
  join direcciones dir  using (direcciones_id)
  join pedidos          using (t_direcciones_id)
 where pedidos_id = 3;