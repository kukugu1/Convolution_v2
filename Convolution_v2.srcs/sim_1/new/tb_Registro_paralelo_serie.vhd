library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constantes_pkg.all;

entity tb_Registro_paralelo_serie is
end tb_Registro_paralelo_serie;

architecture Behavioral of tb_Registro_paralelo_serie is

    constant N_DATOS        : integer := 128;
    constant N_PAD          : integer := 2;
    constant TOTAL_PALABRAS : integer := N_DATOS + 2*N_PAD;
    constant CLK_PERIOD     : time    := 10 ns;

    signal clk      : std_logic := '0';
    signal enable   : std_logic := '0';
    signal rst      : std_logic := '0';
    signal load     : std_logic := '0';
    signal Data_in  : std_logic_vector((N_DATOS*Bits)-1 downto 0) := (others => '0');
    signal Data_out : std_logic_vector(7 downto 0);

begin

    uut : entity work.Registro_paralelo_serie
        generic map (
            Data_length => N_DATOS,
            Pad_words   => N_PAD
        )
        port map (
            clk      => clk,
            enable   => enable,
            rst      => rst,
            load     => load,
            Data_in  => Data_in,
            Data_out => Data_out
        );

    ----------------------------------------------------------------
    -- Reloj
    ----------------------------------------------------------------
    clk_proc : process
    begin
        clk <= '1';
        wait for CLK_PERIOD/2;
        clk <= '0';
        wait for CLK_PERIOD/2;
    end process;

    ----------------------------------------------------------------
    -- Estimulos y verificacion
    ----------------------------------------------------------------
    stim_proc : process
    begin
        for i in 0 to 127 loop
            Data_in((1023 - (i*8)) downto (1016 - (i*8))) <= std_logic_vector(to_unsigned(i + 1, 8));
        end loop;
        rst <= '1';
        wait for 2*CLK_PERIOD;
        
        rst <= '0';
        load <= '1';
        wait for CLK_PERIOD;
        
        load <= '0';
        enable <= '1';
        wait for 132*CLK_PERIOD;
        
        rst <= '1';
        wait for 2*CLK_PERIOD;
        
        rst <= '0';
        load <= '1';
        wait for CLK_PERIOD;
        
        load <= '0';
        enable <= '1';        
        wait;        
    end process;

end Behavioral;