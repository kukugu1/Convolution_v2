library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E6 is
    Port (
        clk         : in std_logic;
        s4          : in Vector_Array(0 to 2)(19 downto 0);
        corrimiento : in Matrix_Array(0 to 1, 0 to 1)(18 downto 0);
        s5          : out Vector_Array(0 to 0)(20 downto 0)
    );
end AT_E6;

architecture Behavioral of AT_E6 is
    
begin
    process(clk)
    begin     
        if rising_edge(clk) then
            s5(0) <= std_logic_vector(
                      resize(signed(s4(0)), 21) + resize(signed(corrimiento(0,0)), 21)
                  );
        end if;
    end process;

end Behavioral;
