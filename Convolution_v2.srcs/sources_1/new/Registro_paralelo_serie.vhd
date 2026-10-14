library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Registro_paralelo_serie is
    generic(
        Data_length : integer := 128;
        Pad_words   : integer := 2 
    );
    Port (
        clk, enable, rst : in std_logic;
        load             : in std_logic;
        Data_in          : in std_logic_vector((Data_length*Bits)-1 downto 0);
        Data_out         : out std_logic_vector(7 downto 0)
    );
end Registro_paralelo_serie;

architecture Behavioral of Registro_paralelo_serie is
    constant TOTAL_BITS         : integer := (Data_length + 2*Pad_words) * Bits;
    constant ZERO_PAD           : std_logic_vector((Pad_words*Bits)-1 downto 0) := (others => '0');
    signal Registro_corrimiento : std_logic_vector(TOTAL_BITS-1 downto 0);
    
begin

    CorrimientoDeSalida : process(clk)
    begin
        if falling_edge(clk) then
            if (rst = '1') then
                Registro_corrimiento <= (others => '1');
            elsif (load = '1') then
                Registro_corrimiento <= ZERO_PAD & Data_in & ZERO_PAD;
            elsif (enable = '1') then
                Registro_corrimiento <= Registro_corrimiento(TOTAL_BITS-9 downto 0) & "00000000";
            end if;
        end if;
    end process;

    Data_out <= Registro_corrimiento(TOTAL_BITS-1 downto TOTAL_BITS-8);

end Behavioral;