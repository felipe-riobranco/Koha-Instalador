# Koha-Instalador

#### Um script automatizado para configurar o Koha em SO Linux. Testado em Ubuntu 22.04 e 24.04.

<img src="https://github.com/felipe-riobranco/Koha-Instalador/blob/main/instalador_koha.png" width="500" />

#### Programas que serão instalados:

* MariaDB: Banco de dados utilizado pelo Koha para armazenar registros da biblioteca
* Apache2: Servidor web que hospeda tanto a interface administrativa quanto o OPAC (interface pública)
* Koha: Sistema integrado de gerenciamento de bibliotecas (ILS)

#### Requisitos:

Para que a instalação ocorra corretamente, o sistema Linux Ubuntu 22.04 ou 24.04 deve ser recém-instalado e **não** deve ser atualizado. Isso significa que **não** deve ser executado o comando `sudo apt update`. Apenas instale o Ubuntu e siga os passos abaixo para iniciar o processo.

#### Instalação:

Você pode baixar o script diretamente do repositório ou utilizar o seguinte comando de uma linha, sem a necessidade de dependências adicionais:

```bash
sudo bash -c "$(wget -qO- https://raw.githubusercontent.com/felipe-riobranco/Koha-Instalador/refs/heads/main/koha2024_install.sh)"
```

Passos:
* O script irá configurar o banco de dados MariaDB, servidor Apache e iniciar o Koha.
Durante a execução, será solicitado que você forneça alguns dados, como o nome da biblioteca e as portas de acesso.
* Após a instalação, os links de acesso ao OPAC (interface pública) e à interface administrativa serão fornecidos, assim como as credenciais padrão de login:

<img src="https://github.com/felipe-riobranco/Koha-Instalador/blob/main/instalador_koha-finalizada.png" width="500" />
