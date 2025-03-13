#!/bin/bash

realiza_implantacao() {
	# Armazena a data atual na variavel DATA_ATUAL
	DATA_ATUAL=$(date +"%Y-%m-%d")
	ANO=$(date +"%Y")

	echo "Hoje e  dia: $DATA_ATUAL A pasta da GMUD deve conter a mesma data. "

	# Verifica se foi passado o container e o local (tomcat6 ou tomcat9)
	if [ -z "$1" ] || [ -z "$2" ]; then
		echo "ATENCAO: ./script_implantacao.sh <nome_do_container> <tomcat6 OU tomcat9>"
		exit 1
	fi

	# Define as variaveis
	CONTAINER_NAME=$1
	BASE_PATH=$2
	SOURCE_DIR="/usr/local/${BASE_PATH}/webapps/"
	BACKUP_DIR="/home/administrator/containers/backup_container/"
	LOCAL_CLASSES="/home/administrator/GMUD${ANO}/${DATA_ATUAL}/${CONTAINER_NAME}/" 

	# Cria o diretório de backup se não existir
	mkdir -p "$BACKUP_DIR"

	# Caminho completo para o arquivo de backup
	BACKUP_FILE="${BACKUP_DIR}${CONTAINER_NAME}.tar"

	#Local onde as novas classes devem ser atualizadas após o backup
	CONTAINER_FILE="${SOURCE_DIR}${CONTAINER_NAME}"

	# Navega até o diretório onde estão os modelos
	cd "$SOURCE_DIR" || {
		echo "Diretório ${SOURCE_DIR} não encontrado."
		exit 1
	}

	#Verifica se o local de origem possui a pasta do container para atualizar
	if [ -e "$LOCAL_CLASSES" ]; then
		# Verifica se o container existe
		if [ -e "$CONTAINER_NAME" ]; then
			# Remove o backup anterior, se existir
			if [ -f "$BACKUP_FILE" ]; then
				rm "$BACKUP_FILE"
			fi

			# Cria o arquivo de backup
			#tar -cf "$BACKUP_FILE" "$CONTAINER_NAME"
			
			
                        #pv comentado porque nao está instalado e sem permissão para instalar
                        #tar -cf "$BACKUP_FILE" "$CONTAINER_NAME" |pv -s $(du - "$BACKUP_DIR"  | awk '{print $1}') > "${CONTAINER_NAME}.tar"


                        #Mostra o progresso dos arquivos compactados, apresenta a cada 100 arquivos processados,
                        ##A variável TAR_CHECKPOINT é uma variável especial usada pelo tar para armazenar o número atual
                        #do checkpoint durante a execução de um comando com a opção --checkpoint-action=exec=
                        tar -cf "$BACKUP_FILE" "$CONTAINER_NAME" --checkpoint=100 --checkpoint-action=exec='printf "\rArquivos %s concluído" "$TAR_CHECKPOINT"' && printf "\n"

			
			
			echo "Backup efetuado: $BACKUP_FILE"

			echo "INICIANDO O PROCESSO DE CÓPIA DOS ARQUIVOS PARA: ${CONTAINER_FILE}"

			cp -r "$LOCAL_CLASSES" "$SOURCE_DIR"

			if [ $? -eq 0 ]; then
				echo "Cópia realizada com sucesso em: ${CONTAINER_FILE}"

				echo "---------RELACAO DAS CLASSES NAS ÚLTIMAS 24 HORAS-----------"
				#Lista os arquivos atualizados nas últimas 24 horas
				find "${CONTAINER_FILE}" -type f -name "*.class" -mtime -1 -exec ls -lh {} +

			else
				echo "Erro ao realizar a cópia."
			fi

		else
			echo "Container destino: '${CONTAINER_NAME}' inexistente."

                        echo " "
                        echo "CRIANDO a pasta : '${CONTAINER_NAME}' no local de destino e realizando a CÓPIA"

                        #cria a pasta vazia de destino no tomcat
                        mkdir ${CONTAINER_FILE}

                        #realiza a cópia
                        cp -r "$LOCAL_CLASSES" "$SOURCE_DIR"


                        echo "---------RELACAO DAS CLASSES NAS ÚLTIMAS 24 HORAS-----------"
                        #Lista os arquivos atualizados nas últimas 24 horas
                        find "${CONTAINER_FILE}" -type f -name "*.class" -mtime -1 -exec ls -lh {} +

		fi
	else
		echo "Container origem: '$LOCAL_CLASSES' não existe"
	fi

}

para_tomcats() {
	END=0
	COMANDO="java"
	TOMCAT_KEYWORD="tomcat"

	while [ $END -eq 0 ]; do
		# Procura os processos relacionados ao Tomcat
		processes=$(ps -eo pid,cmd --sort=start_time | grep -F "$COMANDO" | grep "$TOMCAT_KEYWORD" | grep -v grep)
		pids=($(echo "$processes" | awk '{print $1}'))

		if [ ${#pids[@]} -gt 0 ]; then
			echo "Encontrados os seguintes processos do Tomcat:"
			echo "$processes"

			for pid in "${pids[@]}"; do
				echo "Encerrando processo PID: $pid"
				kill -9 "$pid" 2>/dev/null
			done

			echo "Todos os processos do Tomcat foram encerrados."
			END=1
			#    else
			#        echo "Nenhum processo do Tomcat em execução. Aguardando..."
			#        sleep 3
		fi
	done
}

linha="------------------------------------------------------------"
linha2="-------- MENU --------"
linha3="1) Tomcat 9 - interfaces"
linha4="2) Tomcat 9 - telegram  "
linha5="3) Tomcat 9 - totem     "
linha6="4) Tomcat 9 - webcards4 "
linha7="5) Tomcat 6 - webcar    "
linha8="6) Tomcat 6 - webcards  "
linha9="7) Tomcat 6 - webcobra  "
linhaE="c) Tomcat 8 - Contabil  " 
linhaA="8) Parar SERVICOS       "
linhaB="9) Subir SERVICOS       "
linhaC="0) Status SERVICOS      "
linhaD="00) SAIR                "

while true; do
	printf "%*s\n" $((($(tput cols) + ${#linha}) / 2)) "$linha"
	printf "%*s\n" $((($(tput cols) + ${#linha}) / 2)) "$linha"

	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha2"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha3"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha4"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha5"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha6"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha7"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha8"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linha9"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linhaE"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linhaA"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linhaB"
	printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linhaC"
        printf "%*s\n" $((($(tput cols) + ${#linha3}) / 2)) "$linhaD"


	printf "%*s\n" $((($(tput cols) + ${#linha}) / 2)) "$linha"
	printf "%*s\n" $((($(tput cols) + ${#linha}) / 2)) "$linha"

	echo -n "Escolha um container: "
	read opcao

	case $opcao in
	1)
		CONTAINER_NAME="interfaces"
		BASE_PATH="tomcat9"
		echo "Você escolheu a Opção ${CONTAINER_NAME}"

		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
		;;
	2)
		CONTAINER_NAME="telegram"
		BASE_PATH="tomcat9"
		echo "Você escolheu a Opção  ${CONTAINER_NAME}"
		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"

		;;
	3)
		CONTAINER_NAME="totem"
		BASE_PATH="tomcat9"
		echo "Você escolheu a Opção  ${CONTAINER_NAME}"
		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
		;;
	4)
		CONTAINER_NAME="webcards4"
		BASE_PATH="tomcat9"
		echo "Você escolheu a Opção  ${CONTAINER_NAME}"
		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
		;;

	5)
		CONTAINER_NAME="webcar"
		BASE_PATH="tomcat6"
		echo "Você escolheu a Opção  ${CONTAINER_NAME}"
		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
		;;

	6)
		CONTAINER_NAME="webcards3"
		BASE_PATH="tomcat6"
		echo "Você escolheu a Opção  ${CONTAINER_NAME}"
		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
		;;

	7)
		CONTAINER_NAME="webcobra"
		BASE_PATH="tomcat6"
		echo "Você escolheu a Opção  ${CONTAINER_NAME}"
		realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
		;;

	8)
		echo "Para Serviço Tomcat6, Tomcat9 e Portais do cliente"
		#Comentado em 29/01 para utilizar os mesmos comandos a infra
		#para_tomcats		

		systemctl stop tomcat9.service
		systemctl stop tomcat6.service

		;;
	9)
		echo "Inicia Serviços Tomcat6, Tomcat9 e Portais do cliente"
		
		systemctl start tomcat9.service
		systemctl start tomcat6.service
		;;

	c)      CONTAINER_NAME="contabil"
                BASE_PATH="tomcat9"
                echo "Você escolheu a Opção  ${CONTAINER_NAME}"
                realiza_implantacao "$CONTAINER_NAME" "$BASE_PATH"
                ;;
	
	0) 
		echo "STATUS do Serviço TOMCAT 9.0"
		systemctl status tomcat9


		echo "STATUS do Serviço TOMCAT 6.0"		
		systemctl status tomcat6
		;;

	00)
		echo "Saindo..."
		break
		;;
	*)
		echo "Opção inválida, tente novamente!"
		;;
	esac
done
