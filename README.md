# Toeplitz Verilog

Exploração, simulação e validação de uma implementação em hardware de um extrator de entropia baseado em Toeplitz, utilizando Verilog/SystemVerilog.

## Sobre

Este repositório documenta minha exploração da implementação em Verilog de um extrator de entropia baseado em Toeplitz, originalmente desenvolvido por Rok Žitko e colaboradores.

O projeto original implementa a extração de entropia baseada em Toeplitz para o pós-processamento de fluxos de bits aleatórios. Essa técnica pode melhorar a qualidade da entropia de um fluxo de bits de saída, ao custo de uma menor taxa de bits na saída.

Repositório original: https://github.com/rokzitko/toeplitz

## Objetivos

- Compreender as implementações de hardware serial e paralela.
- Executar os testbenches existentes utilizando o Icarus Verilog.
- Documentar problemas de compatibilidade e as adaptações necessárias para realizar as simulações.
- Validar as saídas comparando-as com os vetores de referência fornecidos.
- Investigar possíveis melhorias na implementação de hardware.

## Executando o testbench paralelo

Requisitos:
- Icarus Verilog
- `vvp`

A partir do diretório `src/`, compile o testbench:

```bash
iverilog -g2012 -s tb_toeplitz_p -o tb_toeplitz_p.vvp \
  tb_toeplitz_p.sv toeplitz_p.sv gencol.sv readrc.sv serializer.sv
```

Execute a simulação:

```bash
vvp tb_toeplitz_p.vvp
```

O testbench processa quatro vetores de entrada e compara os resultados obtidos com os respectivos vetores de referência.

## Observações sobre compatibilidade

O código original utiliza concatenações de fluxo (*streaming concatenations*) do SystemVerilog que não são suportadas pela versão do Icarus Verilog utilizada durante esta exploração.

Foram feitas adaptações temporárias de compatibilidade, substituindo essas expressões por concatenações explícitas. As alterações foram realizadas no testbench e no arquivo `readrc.sv` para permitir a execução da simulação.

A equivalência dessas adaptações, especialmente no que diz respeito à ordenação dos bits, ainda precisa ser validada.

## Organização do repositório

- `orig/` e `src/`: módulos de hardware, testbenches e vetores de referência.
- `docs/`: anotações da investigação, resultados dos testes e análises futuras.

## Atribuição e licença

A implementação original está disponível em https://github.com/rokzitko/toeplitz e é distribuída sob a licença MIT.

Este repositório documenta uma exploração independente da implementação original. As adaptações e a nova documentação devem ser distinguidas do código-fonte original.