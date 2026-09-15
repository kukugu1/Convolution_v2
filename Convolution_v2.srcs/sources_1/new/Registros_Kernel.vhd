library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Registros_Kernel is
    generic (
        Data_length : integer := 8;
        NUM_REGS    : integer := 27   -- número de registros del banco (índices 0 a NUM_REGS-1)
    );
    Port (
        clk      : in  std_logic;
        rst      : in  std_logic;                             -- reset síncrono, activo en alto
        enable   : in  std_logic;                             -- habilita el desplazamiento del banco
        Data_in  : in  std_logic_vector(Data_length-1 downto 0);          
        Data_out : out Data_array(0 to NUM_REGS-1)
    );
end Registros_Kernel;

architecture Behavioral of Registros_Kernel is
    signal Registros : Data_array(0 to NUM_REGS-1);
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                for i in 0 to NUM_REGS-1 loop
                    Registros(i) <= (others => '0');
                end loop;
            elsif enable = '1' then
                Registros(0) <= Data_in;
                for i in 1 to NUM_REGS-1 loop
                    Registros(i) <= Registros(i-1);
                end loop;
            end if;
        end if;
    end process;

    gen_salidas: for i in 0 to NUM_REGS-1 generate
        Data_out(i) <= Registros(i);
    end generate;

end Behavioral;