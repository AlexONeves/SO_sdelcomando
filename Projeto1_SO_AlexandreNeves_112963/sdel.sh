#!/bin/sh

# Define o arquivo de log
LOGFILE=sdel.log


help() {
  echo "Sintaxe do comando: sdel [file ...] [-r dir] [-t num] [-s num] [-u] [-h]" >&2 #echos ficam com a saida padrao o terminal.
  echo "Opções:" >&2
  echo "  -r dir   Aplica o comando sdel recursivamente na diretoria especificada" >&2
  echo "  -t num   Apaga os ficheiros da diretoria ~/.LIXO com mais do número de horas especificadas pelo utilizador" >&2
  echo "  -s num   Apaga os ficheiros da diretoria ~/.LIXO com mais de num KBytes " >&2
  echo "  -u       Indica o tamanho do maior ficheiro guardado na diretoria ~/.LIXO" >&2
  echo "  -h       Mostra o Manual de Ajuda do comando sdel" >&2
}


exec 1>>$LOGFILE # Redireciona a saída padrão para o arquivo de log


# Verifica se existem argumentos
if [ $# -lt 1 ]; then
  echo "Não Existem Argumentos." >&2
  exit 1 #Erro
fi


# Cria a diretoria lixo se a mesma ainda não existir
if [ ! -d "$(pwd)"/.LIXO ]; then
  mkdir "$(pwd)"/.LIXO
fi

# Verifica se o utilizador usou mais de uma opção 
#if [ $# -ne 1 ]; then
 # echo "Só pode escolher uma opção!" >&2
  #exit 1 #Erro
#fi

# Corre o comando se a sintaxe estiver correta
while [ $# -gt 0 ]; #Enquanto o numero de argumentos for maior que 0 executa o loop
do
  case "$1" in
    -h)
        echo "Opção -h usada com sucesso" >> sdel.log
	help
  	exit 0 #Codigo correu com sucesso
      ;;
    -r)
      if [ $# -lt 2 ]; then
	exec 1>&2
        echo "A opção -r precisa de um argumento." >&2
        exit 1 #Erro
      fi
      if [ ! -d "$2" ]; then
	exec 1>&2
        echo "A diretoria $2 não existe." >&2
        exit 1 #Erro
      fi
      echo "Diretoria $2 encontrada com sucesso usando -r. " >> sdel.log
      find "$2" -type f -exec "$(pwd)"/sdel.sh {} \; # Procura ficheiros no diretorio especificado pelo utilizador e de seguida usa o comando sdel para os apagar. {} é o espaço reservado para o nome do ficheiro encontrado.
      exit 0 #Sucesso
	;;
    -t)
      if [ $# -lt 2 ]; then
	exec 1>&2
        echo "A opção -t precisa de um argumento." >&2
        exit 1 #Erro
      fi
      find "$(pwd)"/.LIXO -type f -mmin +$(( $2 * 60 )) -exec rm {} \; # Usa-se o comando find para procurar arquivos na pasta ~/.LIXO que foram modificados há mais de $2 minutos atrás, faz-se o calculo para converter horas para minutos.
      echo "Ficheiros apagados com sucessos utilizando -t. " >> sdel.log
      exit 0 #Sucesso
	;;
    -s)
      if [ $# -lt 2 ]; then
	exec 1>&2
        echo "A opção -s precisa de um argumento." >&2
        exit 1 #Erro
      fi
      find "$(pwd)"/.LIXO -type f -size +${2}k -exec rm {} \; # Procura arquivos( type -f = sem serem diretorios, etc)  na pasta Lixo com o tamanho maior que o que o utilizador especificou e de seguida remove-os. -exec serve para executar o comando num novo processo, saindo do processo anterior. 
      echo "Ficheiros apagados com sucessos utilizando -s. " >> sdel.log
      exit 0 #Sucesso
      ;;
    -u)
      echo "Tamanho do ficheiro: " >> sdel.log
      echo "Tamanho do ficheiro: $(du -sh "$(pwd)"/.LIXO | cut -f1)" >&2
      du -sh "$(pwd)"/.LIXO | cut -f1 # Comando du para conseguir o espaço do ficheiro, -sh para formatar a exibição do tamanho para human-readable, cut -f1 para cortar a informação que não queremos neste caso a primeira coluna. 
      echo "Opção -u realizada com sucesso. " >> sdel.log
      exit 0 #Codigo correu com sucesso
      ;;
    *)
      if [ ! -f "$1" ]; then
	exec 1>&2
        echo "O ficheiro $1 não existe." >&2
        exit 1 #Erro
      fi
      filename=$(basename "$1")
      gzip -c "$1" > "$(pwd)"/.LIXO/"$filename".gz # Comprime o ficheiro e move-o para a diretoria lixo
      echo "Ficheiro $1 enviados para ./lixo " >> sdel.log
      exit 0 #Sucesso
      ;;
  esac
done

