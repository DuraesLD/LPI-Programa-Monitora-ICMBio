
# Script para cálculo do LPI
# Baseado nas instruções disponíveis em https://github.com/Zoological-Society-of-London/rlpi
# Adaptado por Elildo Carvalho Jr, ICMBio/CENAP
# Função prepara dados do icmbio e chama funções do pacote rlpi
# Em fase de TESTE

# pegando diretório do script executado (Necessário usar ctrl/command-shift-s)
setwd(dirname(parent.frame(2)$ofile))

# abrir planilha de dados mastoaves
dados <- read.csv("Planilha_consolidacao_mastoaves_24_05_2018.csv", sep=",")
dados <- dados[dados$Espécies.validadas.para.análise.do.ICMBio != "",] # remover linhas com nome de espécie em branco

# Função lpi_icmbio:
lpi_icmbio <- function(x,y,z) # x = dados, y = UC, z = Classe
{
  library(rlpi) # carrega pacote rlpi
  
  mydata <- x
  
  if(missing(y)) {    mydata <- mydata }
  else {  mydata <- subset(x, Local...Nome.da.Unidade.de.Conservação == y) } # seleciona UC
  
  if(missing(z)) {    mydata <- mydata }
  else {  mydata <- subset(mydata, Classe == z) } # seleciona taxon
  
  colnames(mydata)[20] <- "Binomial"
  mydata$Binomial <- gsub(" ", "_", mydata$Binomial) # necessário para rodar LPIMain
  mydata$Binomial <- as.factor(mydata$Binomial) # pode ser desnecessário, verificar
  mydata$Ano <- as.numeric(mydata$Ano)
  
  # colocar dados no formato exigido pela função LPIMain
  # passo 1, criar objeto a ser preenchido
  mydata2 <- data.frame(matrix(ncol = (2+length(unique(mydata$Ano))), nrow = length(unique(mydata$Binomial))))
  colnames(mydata2) <- c("ID", "Binomial", sort(unique(mydata$Ano))) # cria automaticamente os nomes de colunas de anos
  mydata2$ID <- c(1:nrow(mydata2))
  mydata2$Binomial <- sort(unique(mydata$Binomial))
  Ano <- sort(unique(mydata$Ano)) # sera necessario abaixo
  
  # passo 2, preencher objeto criado acima
  for(i in 1:nrow(mydata2))
  for(j in 1:length(Ano)){
    a <- subset(mydata, Binomial == mydata2[i,2])
    b <- subset(a, Ano == Ano[j]) # extrai o ano automaticamente
    #mydata2[i,j+2] <- nrow(b)/(sum(mydata$km.dia.de.amostragem..esforço., na.rm=TRUE))
    mydata2[i,j+2] <- nrow(b)/(sum(subset(mydata, Ano == Ano[j])$km.dia.de.amostragem..esforço., na.rm=TRUE))*10000 # o esforco usa a planilha mydata porque so uma linha por censo tem esforco
    }
  
  #mydata2[, colSums(is.na(mydata2)) != nrow(mydata2)] # remover coluna de NAs se houver
  require(stringr) # necessario para passo abaixo
  colnames(mydata2)[3:ncol(mydata2)] <- str_c( "X", colnames(mydata2)[3:ncol(mydata2)]) # adiciona um "X" no nome das colunas de anos porque o create_infile exige
  assign("taxas.medias", mydata2, envir=globalenv())
  assign("mydata2", mydata2, envir=globalenv())

  # criar vetor indice com TRUE para todas as linhas, pois todas as espécies serão incluídas
  index_vector = rep(TRUE, nrow(mydata2))
  
  # criar infile
  mydata_infile <- create_infile(mydata2, index_vector=index_vector, name="mydata_data", start_col_name = colnames(mydata2)[3], end_col_name = tail(colnames(mydata2), n=1), CUT_OFF_YEAR = Ano[1])
  #mydata_infile <- create_infile(mydata2, index_vector=index_vector, name="mydata_data", start_col_name = "X2014", end_col_name = "X2016", CUT_OFF_YEAR = 2014)
  #mydata_infile <- create_infile(mydata2, index_vector=index_vector, name="mydata_data", start_col_name = "2014", end_col_name = "2017", CUT_OFF_YEAR = "2014")
  
  
  # Calcular LPI com 100 bootstraps
  mydata_lpi <- LPIMain(mydata_infile, REF_YEAR = Ano[1], PLOT_MAX = tail(Ano, n=1), BOOT_STRAP_SIZE = 100, VERBOSE=FALSE)
  
  # Remover NAs (anos seguidos sem dados)
  mydata_lpi <- mydata_lpi[complete.cases(mydata_lpi), ]
  
  # carregar função ggplot_lpi_modif
  source("ggplot_lpi_modif.R")
  
  # Gerar gráfico mais bonito usando função ggplot_lpi_modif
  ggplot_lpi_modif(mydata_lpi, col="cornflowerblue")
  
} # Fim da função
