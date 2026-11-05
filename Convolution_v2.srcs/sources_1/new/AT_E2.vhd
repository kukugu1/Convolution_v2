library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E2 is
    generic(
        NUM_REGS : integer := 27
    );
    Port (
        clk : in std_logic;
        P   : in Vector_Array(0 to NUM_REGS-1)(15 downto 0);
        s1  : out Vector_Array(0 to 11)(16 downto 0)
    );
end AT_E2;

architecture Behavioral of AT_E2 is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            for i in 0 to 11 loop    
                s1(i) <= std_logic_vector(
                    resize(signed(P(PAR_ALTO_1(i))), 17) + 
                    resize(signed(P(PAR_BAJO_1(i))), 17)
                );
            end loop;
        end if;
    end process;

end Behavioral;
