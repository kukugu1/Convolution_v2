library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E2 is
    generic(
        NUM_REGS : integer := 27
    );
    Port (
        clk, load : in std_logic;
        P         : in Vector_Array(0 to NUM_REGS-1)(15 downto 0);
--        k1x1      : buffer Matrix_Array(0 to 3, 0 to 5)(15 downto 0);
        s1        : out Vector_Array(0 to 11)(16 downto 0)
    );
end AT_E2;

architecture Behavioral of AT_E2 is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
--            k1x1(0,0) <= P(26);
--            k1x1(1,0) <= P(18);
--            k1x1(2,0) <= P(9);
--            k1x1(3,0) <= P(0);            
                for i in 0 to 11 loop
                    s1(i) <= std_logic_vector(
                        resize(signed(P(PAR_ALTO_1(i))), 17) +
                        resize(signed(P(PAR_BAJO_1(i))), 17)
                    );
                end loop;
            end if;
        end if;
    end process;

end Behavioral;
