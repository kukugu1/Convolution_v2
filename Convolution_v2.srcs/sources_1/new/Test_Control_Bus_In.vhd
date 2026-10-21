library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.constantes_pkg.all;

entity Test_Control_Bus_In is
    generic(
        Data_length : integer := 128
    );
    Port( 
        Data_in  : in std_logic_vector((Data_length*Bits)-1 downto 0); --1024 datos para 128 registros de 8 bits
        clk, selector, T_valid_in   : in std_logic;
        Bus_valid_Size              : in std_logic_vector(2 downto 0);
        Padding                     : in std_logic_vector(1 downto 0);
        rst_RPS_0, CAP_RPS_0, SEL_0 : out std_logic;
        T_ready_out                 : out std_logic;
        Data_out_k                  : out Data_array(0 to 26);
        Data_out_m                  : out Data_array(0 to 24)
    );
end Test_Control_Bus_In;

architecture Behavioral of Test_Control_Bus_In is
signal EN_1, EN_1M, EN_1K    : std_logic;
signal rst_RPS, CAP_RPS, SEL : std_logic;
signal clk_EN_1M, clk_EN_1K  : std_logic;
signal Data_out_RPS          : std_logic_vector(7 downto 0) := x"00";
signal kernel_in, matriz_in  : std_logic_vector(7 downto 0) := x"00";

begin
    rst_RPS_0 <= rst_RPS;
    CAP_RPS_0 <= CAP_RPS;
    SEL_0     <= SEL;
    clk_EN_1M <= clk and EN_1M;
    clk_EN_1K <= clk and EN_1K;
    EN_1      <= EN_1M OR EN_1K;
    
    CBI : entity work.Control_Bus_in
    generic map(
        kernel_size => 27,
        matriz_size => 128
    )
    port map(
        clk            => clk,
        selector       => selector,
        T_valid        => T_valid_in,
        Bus_valid_Size => Bus_valid_Size,
        Padding        => Padding,
        rst            => rst_RPS,
        CAP            => CAP_RPS,
        EN_1K          => EN_1K,
        EN_1           => EN_1M,
        SEL            => SEL,
        T_ready        => T_ready_out
    );
    
    Parallel_Serial_Register : entity work.Registro_paralelo_serie
    generic map(
        Data_length => Data_length,
        Pad_words   => 2,
        Pad_value   => '0'
    )
    port map(
        clk      => clk,
        enable   => EN_1,
        load     => CAP_RPS,
        rst      => rst_RPS,
        Data_in  => Data_in,
        Data_out => Data_out_RPS
    );
    
    Demux1 : entity work.Demux
    generic map(
        Data_length => 8
    )
    port map(
        sel      => SEL,
        entrada  => Data_out_RPS,
        salida_1 => matriz_in,
        salida_0 => kernel_in
    );

    Kernel_Registers : entity work.Registros_kernel
    generic map(
        Data_length => 8,
        NUM_REGS    => 27
    )    
    port map(
        clk      => clk_EN_1K,    
        rst      => '0',
        enable   => '1',
        Data_in  => kernel_in,
        Data_out => Data_out_k
    );
    
    Matrix_Registers : entity work.Registros_Matriz
    generic map(
        Data_length => 8,
        Matriz_size => 132,
        ROW_LENGTH  => 5,
        NUM_ROWS    => 5,
        KERNEL_SIZE => 5 
    )
    port map(
        clk      => clk_EN_1M,
        rst      => '0',
        enable   => '1',
        Data_in  => matriz_in,
        Data_out => Data_out_m
    );

end Behavioral;
