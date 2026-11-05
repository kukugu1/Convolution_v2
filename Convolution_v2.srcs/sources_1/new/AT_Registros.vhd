library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_Registros is
    generic(
        NUM_REGS : integer := 27
    );
    Port (
        clk                                : in std_logic;
        Data_in_kernel, Data_in_matriz     : in Data_array(0 to NUM_REGS-1);    
        Registros_kernel, Registros_matriz : out Data_array(0 to NUM_REGS-1)
    );
end AT_Registros;

architecture Behavioral of AT_Registros is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            Registros_kernel <= Data_in_kernel;
            Registros_matriz <= Data_in_matriz;
        end if;
    end process;

end Behavioral;
