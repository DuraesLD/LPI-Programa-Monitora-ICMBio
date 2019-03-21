# LPI-Programa-Monitora-ICMBio

Função **lpi_icmbio** para cálculo do LPI (Living Planet Index) a partir de dados do Programa Monitora-ICMBio

O que a função **lpi_icmbio** faz:

(1) organiza os dados do programa Monitora-ICMBio (planilha mastoaves csv), colocando-os no formato exigido pelo pacote **rlpi**
(2) cria um subset dos dados acima com a UC e o grupo taxonômico de interesse (mamíferos, aves)
(3) chama a função **LPIMain** para cálculo do LPI e geração de gráficos.

O pacote **rlpi** foi desenvolvido pela Zoological Society of London e está disponível para download (com instruções de instalação, etc.) no endereço https://github.com/Zoological-Society-of-London/rlpi

A função **lpi_icmbio** ainda precisa de vários ajustes e qualquer contribuição é bem vinda. Algumas das necessidades já identificadas já estão indicadas como anotações no próprio script **lpi_icmbio**

Por exemplo, a função poderia incluir um critério automático de exclusão de espécies raras do cálculo, pois a inclusão dessas espécies leva a um aumento muito grande nos intervalos de confiança dos gráficos.

![image](https://user-images.githubusercontent.com/39089964/46036611-4e12e780-c0dc-11e8-94d2-6e66d98edc30.png)

### Instruções para execução do script

1 - Instale o pacote devtools do R

```r
install.packages("devtools")
```

2 - Instale o pacote **rlpi** do Zoological-Society-of-London


```r
library(devtools)

install_github("Zoological-Society-of-London/rlpi", dependencies=TRUE)
```

```
## O pacote 'ggplot2' foi montado com a versão 3.2.5 do R
```

Com isso o script pode ser executado normalmente


### Exemplos

```r
lpi_icmbio(dados) # calcula LPI para todo o conjunto de dados
lpi_icmbio(dados,z="Mamíferos") # calcula LPI somente para mamíferos
lpi_icmbio(dados, "Resex Cazumbá-Iracema", "Aves") # calcula LPI somente para Resex Cazumbá-Iracema, somente para aves
```


