library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Registros_Matriz_FFD is
    generic(
        ROW_LENGTH : integer := 5;   -- registros por fila (y también número de elementos de Data_in)
        NUM_ROWS   : integer := 5    -- número de filas de la matriz
    );
    port(
        clk      : in  std_logic;
        rst      : in  std_logic;                              -- reset síncrono, activo en alto
        enable   : in  std_logic;                              -- habilita el desplazamiento del banco
        Data_in  : in  Data_array(0 to NUM_ROWS-1);
        Data_out : out Data_array(0 to (ROW_LENGTH*NUM_ROWS)-1)
    );
end Registros_Matriz_FFD;

architecture Behavioral of Registros_Matriz_FFD is
    signal Registros : Data_array(0 to (ROW_LENGTH*NUM_ROWS)-1);
begin

    Resto_de_filas: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                for k in 0 to (ROW_LENGTH * NUM_ROWS) - 1 loop
                    Registros(k) <= (others => '0');
                end loop;
            elsif enable = '1' then
                for i in 0 to NUM_ROWS-1 loop
                    -- Carga del primer registro de la fila i
                    Registros(i * ROW_LENGTH) <= Data_in(NUM_ROWS - 1 - i);

                    -- Desplazamiento del resto de los registros de la fila i
                    for j in (i * ROW_LENGTH) + 1 to (i * ROW_LENGTH) + (ROW_LENGTH - 1) loop
                        Registros(j) <= Registros(j - 1);
                    end loop;
                end loop;
            end if;
        end if;
    end process;

    gen_salidas: for i in 0 to (ROW_LENGTH*NUM_ROWS)-1 generate
        Data_out(i) <= Registros(i);
    end generate;

end Behavioral;