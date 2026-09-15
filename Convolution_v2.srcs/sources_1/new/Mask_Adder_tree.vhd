library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Mask_Adder_tree is
Port ( 
    Tamano_kernel : in std_logic_vector(1 downto 0); 
    Data_out_5x5  : in Vector_Array(0 to 0)(21 downto 0); -- 1 Dato
    Data_out_4x4  : in Vector_Array(0 to 0)(21 downto 0); -- 1 Dato
    Data_out_3x3  : in Vector_Array(0 to 0)(21 downto 0); -- Posibles 3 datos
    Data_out_2x2  : in Vector_Array(0 to 0)(21 downto 0); -- Posibles 6 datos
    --Data_out_1x1  : in Vector_Array(0 to 0)(21 downto 0); -- Posibles 27 datos
    Data_out      : out std_logic_vector(21 downto 0)
);
end Mask_Adder_tree;

architecture Behavioral of Mask_Adder_tree is
--    Tamaño_kernel <= "11" --kernel 5x5
--    Tamaño_kernel <= "10" --kernel 4x4
--    Tamaño_kernel <= "01" --kernel 3x3
--    Tamaño_kernel <= "00" --kernel 2x2

begin
    process(Tamano_kernel)
    begin
        case Tamano_kernel is
        -- KERNEL 5x5
            when "11" =>
                Data_out <= Data_out_5x5(0);
                
        -- KERNEL 4x4
            when "10" =>
                Data_out <= Data_out_4x4(0);
                
        -- KERNEL 3x3
            when "01" =>
                Data_out <= Data_out_3x3(0);
                
        -- KERNEL 2x2
            when "00" =>
                Data_out <= Data_out_2x2(0);    
                
--        -- KERNEL 1x1
--            when "000" =>
--                Data_out <= Data_out_1x1(0);                             
                                        
            when others =>
                Data_out <= (Others => '0');    
        end case;
    end process;

end Behavioral;
