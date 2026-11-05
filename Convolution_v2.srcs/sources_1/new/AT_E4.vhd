library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E4 is
    Port (
        clk : in std_logic;
        s2  : in Vector_Array(0 to 5)(17 downto 0);
        s3  : out Vector_Array(0 to 2)(18 downto 0)
    );
end AT_E4;

architecture Behavioral of AT_E4 is
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            for i in 0 to 2 loop
                s3(i) <= std_logic_vector(
                    resize(signed(s2(PAR_ALTO_3(i))), 19) + 
                    resize(signed(s2(PAR_BAJO_3(i))), 19)
                );
            end loop;
        end if;
    end process;

end Behavioral;
