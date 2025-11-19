library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ula is
    -- O Testbench não tem portas (ele é uma caixa fechada)
end tb_ula;

architecture Sim of tb_ula is

    -- 1. Chamamos o componente da ULA (Cópia exata da Entity do arquivo ULA.vhd)
    component ULA
        Port (
            entrada_a : in  STD_LOGIC_VECTOR(3 downto 0);
            entrada_b : in  STD_LOGIC_VECTOR(3 downto 0);
            seletor_operacao : in  STD_LOGIC_VECTOR(1 downto 0); 
            resultado_final     : out STD_LOGIC_VECTOR(3 downto 0); 
            indicador_overflow  : out STD_LOGIC;                    
            indicador_carry_out : out STD_LOGIC
        );
    end component;

    -- 2. Sinais para ligar nas portas da ULA
    signal s_a, s_b, s_result : STD_LOGIC_VECTOR(3 downto 0);
    signal s_sel : STD_LOGIC_VECTOR(1 downto 0);
    signal s_over, s_cout : STD_LOGIC;

begin

    -- 3. Instância da ULA (Conectando os fios)
    UUT: ULA port map (
        entrada_a => s_a,
        entrada_b => s_b,
        seletor_operacao => s_sel,
        resultado_final => s_result,
        indicador_overflow => s_over,
        indicador_carry_out => s_cout
    );

    -- 4. Processo de Estímulo (Onde a mágica acontece)
    process
    begin
        report "Iniciando Testes da ULA...";

        -- ==========================================
        -- CASO 1: SOMA (SS = 00)
        -- ==========================================
        s_sel <= "00"; 
        
        -- Teste 1.1: Soma Simples (2 + 3 = 5)
        s_a <= "0010"; s_b <= "0011";
        wait for 10 ns;
        
        -- Teste 1.2: Soma com Carry Out (15 + 1 = 0, com Carry 1)
        s_a <= "1111"; s_b <= "0001";
        wait for 10 ns;
        
        -- Teste 1.3: Soma com Overflow (Positivo + Positivo = Negativo)
        -- 7 (0111) + 1 (0001) = -8 (1000) em complemento de 2
        s_a <= "0111"; s_b <= "0001";
        wait for 10 ns;

        -- ==========================================
        -- CASO 2: SUBTRAÇÃO (SS = 01)
        -- ==========================================
        s_sel <= "01";

        -- Teste 2.1: Subtração Simples (5 - 2 = 3)
        s_a <= "0101"; s_b <= "0010";
        wait for 10 ns;

        -- Teste 2.2: Subtração Negativa (2 - 5 = -3 ou "1101")
        s_a <= "0010"; s_b <= "0101";
        wait for 10 ns;

        -- Teste 2.3: Overflow na Subtração (Negativo - Positivo = Positivo)
        -- -8 (1000) - 1 (0001) = +7 (0111) -> Isso é matematicamente impossível em 4 bits
        s_a <= "1000"; s_b <= "0001";
        wait for 10 ns;

        -- ==========================================
        -- CASO 3: AND (SS = 10)
        -- ==========================================
        s_sel <= "10";

        -- Teste 3.1: Máscara de bits
        -- A: 1010
        -- B: 1100
        -- R: 1000 (8)
        s_a <= "1010"; s_b <= "1100";
        wait for 10 ns;

        -- ==========================================
        -- CASO 4: OR (SS = 11)
        -- ==========================================
        s_sel <= "11";

        -- Teste 4.1: Combinação de bits
        -- A: 1010
        -- B: 0101
        -- R: 1111 (F)
        s_a <= "1010"; s_b <= "0101";
        wait for 10 ns;

        report "Fim dos Testes.";
        wait; -- Para a simulação
    end process;

end Sim;