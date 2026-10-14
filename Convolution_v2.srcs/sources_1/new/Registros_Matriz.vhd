library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Registros_Matriz is
    generic(
        Data_length : integer := 8;    
        Matriz_size : natural := 132;
        ROW_LENGTH  : integer := 5;   -- registros por fila (y también número de elementos de Data_in)
        NUM_ROWS    : integer := 5;   -- número de filas de la matriz    
        KERNEL_SIZE : natural := 5
    );
    Port ( 
        clk      : in std_logic;    
        rst      : in std_logic;                              -- reset síncrono, activo en alto
        enable   : in std_logic;                              -- habilita el desplazamiento del banco    
        Data_in  : in std_logic_vector(Data_length-1 downto 0);
        Data_out : out Data_array(0 to (ROW_LENGTH*NUM_ROWS)-1)
    );
end Registros_Matriz;

architecture Behavioral of Registros_Matriz is
signal Nodos      : Data_array(0 to 3);
signal Adder_tree : Data_array(0 to (ROW_LENGTH*NUM_ROWS)-1);

begin

    RegistrosFFD : entity work.Registros_Matriz_FFD
    generic map(
        ROW_LENGTH => ROW_LENGTH,
        NUM_ROWS   => NUM_ROWS
    )        
    port map(
        clk        => clk,
        rst        => rst,
        enable     => enable,
        Data_in(4) => Data_in,
        Data_in(3) => Nodos(3),
        Data_in(2) => Nodos(2),
        Data_in(1) => Nodos(1),   
        Data_in(0) => Nodos(0),    
        Data_out => Adder_tree
    );
    
    RegistrosLUTs : entity work.Registros_Matriz_LUTs
    generic map(
        Matriz_size => Matriz_size,
        NUM_ROWS    => 4,
        KERNEL_SIZE => KERNEL_SIZE
    )
    port map(
        clk         => clk,
        enable      => enable,        
        Data_in(3)  => Adder_tree(4),
        Data_in(2)  => Adder_tree(9),
        Data_in(1)  => Adder_tree(14),
        Data_in(0)  => Adder_tree(19),
        Data_out(3) => Nodos(3),       
        Data_out(2) => Nodos(2),
        Data_out(1) => Nodos(1),
        Data_out(0) => Nodos(0)        
    );
    
    Data_out <= Adder_tree;
end Behavioral;
