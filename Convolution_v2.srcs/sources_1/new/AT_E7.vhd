library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E7 is
    Port (
        clk         : in std_logic;
        s5          : in Vector_Array(0 to 0)(20 downto 0);
        corrimiento : in Matrix_Array(0 to 1, 0 to 1)(18 downto 0);
        s6          : out Vector_Array(0 to 0)(21 downto 0)
    );
end AT_E7;

architecture Behavioral of AT_E7 is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            s6(0) <= std_logic_vector(
                      resize(signed(s5(0)), 22) + resize(signed(corrimiento(1,1)), 22)
                  );
        end if;
    end process;

end Behavioral;
