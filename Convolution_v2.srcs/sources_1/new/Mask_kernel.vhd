library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Mask_kernel is
    generic (
        NUM_REGS    : integer := 27
    );
    Port(
        clk, load     : in std_logic;    
        Tamano_kernel : in std_logic_vector(1 downto 0); 
        Data_in       : in Data_array(0 to NUM_REGS-1);
        Data_out      : out Data_array(0 to NUM_REGS-1)
    );
end Mask_kernel;

architecture Behavioral of Mask_kernel is
--    Tamaño_kernel <= "11" --kernel 5x5
--    Tamaño_kernel <= "10" --kernel 4x4
--    Tamaño_kernel <= "01" --kernel 3x3
--    Tamaño_kernel <= "00" --kernel 2x2

signal Registros : Data_array(0 to NUM_REGS-1); 
signal clk_load  : std_logic;

begin

    clk_load <= clk AND load;

    process(clk_load)
    begin
        if rising_edge(clk_load) then
            Registros <= Data_in;
        end if;
    end process;

    process(clk_load)
    begin
        case Tamano_kernel is
            -- KERNEL 5X5
            when "11" =>
                for i in 10 to 26 loop
                    Data_out(i) <= Registros(i);
                end loop; 
                Data_out(9) <= (others => '0');
                for i in 1 to 8 loop
                    Data_out(i) <= Registros(i+1);
                end loop;
                Data_out(0) <= (others => '0');
                
            -- KERNEL 4x4    
            when "10" =>
                for i in 19 to 26 loop
                    Data_out(i) <= Registros(i);
                end loop;
                Data_out(18) <= (others => '0');
                for i in 10 to 17 loop
                    Data_out(i) <= Registros(i+1);
                end loop;
                for i in 0 to 9 loop
                    Data_out(i) <= (others => '0');
                end loop;
            
            -- KERNEL 3x3    
            when "01" =>
                for i in 18 to 26 loop
                    Data_out(i) <= Registros(i);
                end loop;    
                for i in 0 to 17 loop
                    Data_out(i) <= (others => '0');
                end loop; 
              
            -- KERNEL 2x2                 
            when "00" =>
                for i in 23 to 26 loop
                    Data_out(i) <= Registros(i);
                end loop;
                for i in 0 to 22 loop
                    Data_out(i) <= (others => '0');
                end loop;                                                    
                                         
            when others => 
                for i in 0 to 26 loop
                    Data_out(i) <= (others => '0');
                end loop;
        end case;
    end process;
    
end Behavioral;
