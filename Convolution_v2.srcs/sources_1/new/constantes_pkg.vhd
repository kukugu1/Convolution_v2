library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package constantes_pkg is
    constant Bits  : integer := 8;
    constant zeros : std_logic_vector(7 downto 0) := (others => '0');

    type Data_array   is array (natural range <>) of std_logic_vector(7 downto 0);
    type Data_matriz  is array (natural range <>) of Data_array;

    type indice_array is array (natural range <>) of natural;
    type Vector_Array is array (natural range <>) of std_logic_vector;
    type Matrix_Array is array (natural range <>, natural range <>) of std_logic_vector;

    -- Etapa 1: pares dentro de P (27 elementos, 16 bits c/u) -> s1 (12 elem, 17 bits)
    constant PAR_ALTO_1 : indice_array(0 to 11) := (26,24,22,20,17,15,13,11,8,6,4,2); -- sobran 18,9,0
    constant PAR_BAJO_1 : indice_array(0 to 11) := (25,23,21,19,16,14,12,10,7,5,3,1);

    -- Etapa 2: pares dentro de s1 -> s2 (6 elem, 18 bits)
    constant PAR_ALTO_2 : indice_array(0 to 5) := (0,2,4,6,8,10);
    constant PAR_BAJO_2 : indice_array(0 to 5) := (1,3,5,7,9,11);

    -- Etapa 3: pares dentro de s2 -> s3 (3 elem, 19 bits)
    constant PAR_ALTO_3 : indice_array(0 to 2) := (0,2,4);
    constant PAR_BAJO_3 : indice_array(0 to 2) := (1,3,5);

    -- Etapa 4: mezcla s3 (sumas) y P (sobrantes) -> s4 (3 elem, 20 bits)
    constant PAR_ALTO_4 : indice_array(0 to 2) := (0,1,2); -- indices en s3
    constant PAR_BAJO_4 : indice_array(0 to 2) := (1,2,3); 

end package;
