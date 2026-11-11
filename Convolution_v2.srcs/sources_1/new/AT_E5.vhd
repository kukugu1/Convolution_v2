library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E5 is
    Port (
        clk, load : in std_logic;
        s3        : in Vector_Array(0 to 2)(18 downto 0);
        k1x1      : in Matrix_Array(0 to 3, 0 to 5)(15 downto 0);
        s4        : out Vector_Array(0 to 2)(19 downto 0)
    );
end AT_E5;

architecture Behavioral of AT_E5 is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                for i in 0 to 2 loop
                    s4(i) <= std_logic_vector(
                        resize(signed(s3(PAR_ALTO_4(i))), 20) +
                        resize(signed(k1x1(PAR_BAJO_4(i),2)), 20)
                    );
                end loop;
            end if;
        end if;
    end process;

end Behavioral;
