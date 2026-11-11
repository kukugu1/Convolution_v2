library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E3 is
    Port (
        clk, load : in std_logic;
        s1        : in Vector_Array(0 to 11)(16 downto 0);
--        k1x1      : buffer Matrix_Array(0 to 3, 0 to 5)(15 downto 0);
        s2        : out Vector_Array(0 to 5)(17 downto 0)
    );
end AT_E3;

architecture Behavioral of AT_E3 is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
    --            k1x1(0,1) <= k1x1(0,0);
    --            k1x1(1,1) <= k1x1(1,0);
    --            k1x1(2,1) <= k1x1(2,0);
    --            k1x1(3,1) <= k1x1(3,0);
                for i in 0 to 5 loop
                    s2(i) <= std_logic_vector(
                        resize(signed(s1(PAR_ALTO_2(i))), 18) +
                        resize(signed(s1(PAR_BAJO_2(i))), 18)
                    );
                end loop;
            end if;
        end if;
    end process;

end Behavioral;
