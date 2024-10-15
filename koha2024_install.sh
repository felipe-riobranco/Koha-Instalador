#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script deve ser executado como root."
  exit 1
fi

# Exibe a arte ASCII do nome Koha
cat << "EOF"
=============================================================

       @%%%%%%%       %%                     @%                
   %%%%%%%%%%%     %%%                    %%@                
  %%%%%%%%%%%%%    %%                     %%                 
 %%%%%%%%%%%%%%   %%%  %%%    %%%%%%     %%%%%%%     %%%%%%%%
%%%%%%%%%%%%%%%   %% %%     %%%    %%   %%%%  %%    %%   %%% 
%%%%%%%%%%%%%%   %%%%       %%    @%%   %%@  %%%   %%    %%% 
%       %%%%%   %%%%%%     %%%    %%%  %%%   %%   @%%    %%  
%       %%%%    %%  %%% %%  %%   %%%   %%   %%%%%  %%   %%% %
    %%%%%%%     %%   %%%%    %%%%%    %%%   %%%%    %%%% %%% 

==============================================================
EOF

# Pergunta ao usuário o nome da biblioteca
read -p "Digite o nome da biblioteca: " library_name

# Pergunta ao usuário a porta para a Interface Administrativa (INTRAPORT)
read -p "Digite a porta para a Interface Administrativa (INTRAPORT): " INTRAPORT

# Pergunta ao usuário a porta para o OPAC (OPACPORT)
read -p "Digite a porta para o OPAC (OPACPORT): " OPACPORT

# Exibe as entradas fornecidas pelo usuário
echo "Nome da Biblioteca: $library_name"
echo "Porta da Interface Administrativa (INTRAPORT): $INTRAPORT"
echo "Porta do OPAC (OPACPORT): $OPACPORT"

SECONDS=0

# Atualiza repositórioe do sistemaecho 
echo "------------------------------------------------------------------"
echo "Configurando fontes de pacotes... "
echo "------------------------------------------------------------------"
apt-get update
apt install -y apt-transport-https ca-certificates curl
mkdir -p --mode=0755 /etc/apt/keyrings
curl -fsSL https://debian.koha-community.org/koha/gpg.asc -o /etc/apt/keyrings/koha.asc
apt-get update

# Adiciona o repositório do Koha
echo "------------------------------------------------------------------"
echo "Adicionando o repositório do Koha..."
echo "------------------------------------------------------------------"
echo 'deb [signed-by=/etc/apt/keyrings/koha.asc] https://debian.koha-community.org/koha stable main' | tee /etc/apt/sources.list.d/koha.list

# Atualiza os repositórios do sistema após adicionar o repositório do Koha
echo "------------------------------------------------------------------"
echo "Atualizando os repositórios após adicionar o repositório do Koha..."
echo "------------------------------------------------------------------"
apt-get update

# Instala o Koha
echo "------------------------------------------------------------------"
echo "Instalando o Koha..."
echo "------------------------------------------------------------------"
apt install -y koha-common

# Instala o banco de dados MariaDB
echo "------------------------------------------------------------------"
echo "Instalando o MariaDB..."
echo "------------------------------------------------------------------"
apt install -y mariadb-server

# Configura as portas do Koha no arquivo de configuração
echo "Configurando as portas do Koha..."
sed -i "s/INTRAPORT=\"80\"/INTRAPORT=\"$INTRAPORT\"/g" /etc/koha/koha-sites.conf
sed -i "s/OPACPORT=\"80\"/OPACPORT=\"$OPACPORT\"/g" /etc/koha/koha-sites.conf

# Habilita módulos do Apache
echo "Habilitando módulos CGI e Rewrite do Apache..."
a2enmod rewrite
a2enmod cgi

# Reinicia o Apache
echo "Reiniciando o Apache..."
systemctl restart apache2

# Configura o Apache para escutar nas portas 80, INTRAPORT e OPACPORT
echo "Configurando o Apache para escutar nas portas 80, $INTRAPORT e $OPACPORT..."
sed -i "s/Listen 80/Listen 80\nListen $INTRAPORT\nListen $OPACPORT/g" /etc/apache2/ports.conf

# Cria a biblioteca Koha com o nome fornecido pelo usuário
echo "------------------------------------------------------------------"
echo "Criando a biblioteca Koha..."
echo "------------------------------------------------------------------"
koha-create --create-db $library_name

# Instala a tradução para português
echo "Instalando a tradução para português..."
koha-translate --install pt-BR

# Reinicia o Apache novamente
echo "Ativando koha-plack..."
a2enmod headers proxy_http
koha-plack --enable $library_name
koha-plack --start $library_name
systemctl restart apache2

# Start serviços
echo "iniciando serviços MariaDB, Koha e Apache..."
systemctl start mariadb
systemctl enable mariadb
systemctl start koha-common
systemctl enable koha-common
systemctl start apache2
systemctl enable apache2

# Captura o endereço IP do servidor
ipaddress=$(hostname -I | awk '{print $1}')

# Captura o nome de usuário e senha do arquivo de configuração XML do Koha
user=$(xmlstarlet sel -t -v 'yazgfs/config/user' /etc/koha/sites/$library_name/koha-conf.xml)
passwd=$(xmlstarlet sel -t -v 'yazgfs/config/pass' /etc/koha/sites/$library_name/koha-conf.xml)

# Exibe as informações para o usuário
echo "================================================================="
echo "   I N S T A L A Ç Ã O   F I N A L I Z A D A"
duration=$SECONDS
echo "       Tempo decorrido:  $(($duration / 60)) minutos e $(($duration % 60)) segundos"
echo "================================================================="
echo "  Complete a instalação pela"
echo "  Interface Administrativa: http://$ipaddress:$INTRAPORT"
echo " "
echo "  OPAC:                     http://$ipaddress:$OPACPORT"
echo "================================================================="
echo " "

# Exibe o login e senha para a configuração web
echo "  L O G I N   P A R A  C O N F I G U R A Ç Ã O  W E B"
echo "  Usuário: $user"
echo "  Senha: $passwd"
echo " "
