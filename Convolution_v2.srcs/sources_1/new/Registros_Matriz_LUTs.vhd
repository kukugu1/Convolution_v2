library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Registros_Matriz_LUTs is
    generic(
        Matriz_size : natural := 132;
        NUM_ROWS    : integer := 4;   -- número de filas de la matriz
        KERNEL_SIZE : natural := 5    -- tamaño del kernel; define el offset de profundidad (antes hardcodeado como "5")
    );
    port(
        clk      : in  std_logic;
        enable   : in  std_logic;     -- Sin rst porque SRLC32E no tiene señal rst. 
        Data_in  : in  Data_array(0 to NUM_ROWS-1);
        Data_out : out Data_array(0 to NUM_ROWS-1)
    );
end Registros_Matriz_LUTs;

architecture Behavioral of Registros_Matriz_LUTs is
    constant Profundidad  : natural := Matriz_size - KERNEL_SIZE - 1;
    signal Registros_LUTs : Data_matriz(0 to NUM_ROWS-1)(0 to Profundidad);
    attribute srl_style   : string;
    attribute srl_style of Registros_LUTs : signal is "srl";
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                for i in 0 to NUM_ROWS-1 loop
                    Registros_LUTs(i)(0) <= Data_in(i);
                    for j in 1 to Profundidad loop
                        Registros_LUTs(i)(j) <= Registros_LUTs(i)(j-1);
                    end loop;
                end loop;
            end if;
        end if;
    end process;

    gen_salidas : for i in 0 to NUM_ROWS-1 generate
        Data_out(i) <= Registros_LUTs(i)(Profundidad);
    end generate;

end Behavioral;