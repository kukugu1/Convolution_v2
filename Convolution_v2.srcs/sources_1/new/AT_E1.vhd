library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity AT_E1 is
    generic(
        NUM_REGS : integer := 27
    );
    Port (
        clk, load                          : in std_logic;
        Registros_kernel, Registros_matriz : in Data_array(0 to NUM_REGS-1);
        P                                  : out Vector_Array(0 to NUM_REGS-1)(15 downto 0)
    );
end AT_E1;

architecture Behavioral of AT_E1 is
    attribute use_dsp       : string;
    attribute use_dsp of P  : signal is "yes";
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if load = '1' then
                for i in 0 to NUM_REGS-1 loop
                    P(i) <= std_logic_vector(
                        signed(Registros_kernel(i)) * signed(Registros_matriz(i))
                        );
                end loop;
            end if;
        end if;
    end process;

end Behavioral;
