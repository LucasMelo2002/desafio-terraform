
# Desafio Prático | Estágio em DevOps | VExpenseso - Terraform

## Visão Geral

Este projeto consiste em um arquivo `main.tf` que utiliza o **Terraform** para provisionar uma infraestrutura básica na AWS. Ele foi modificado para implementar melhorias de segurança e automação de configuração de servidores. Abaixo estão descritos os recursos criados, as alterações feitas e como executar o código.

## Descrição Técnica - Arquivo `main.tf` Modificado

1. **Provedor AWS**:
    - Define a região como `us-east-1` para a criação de todos os recursos na AWS.

2. **VPC (Virtual Private Cloud)**:
    - Cria uma VPC com o bloco CIDR `10.0.0.0/16`. 
    - A VPC permite a criação de uma rede isolada na AWS, onde outros recursos, como instâncias EC2 e subnets, são lançados.

3. **Subnet**:
    - Uma subnet com o bloco CIDR `10.0.1.0/24` é criada dentro da VPC.
    - Essa subnet é alocada na zona de disponibilidade `us-east-1a`, permitindo que os recursos dentro dela compartilhem a rede.

4. **Security Group (Grupo de Segurança)**:
    - Um grupo de segurança foi configurado com regras de **ingress** para permitir acesso SSH apenas de um endereço IP específico (para maior segurança), além de tráfego HTTP liberado globalmente na porta 80 para acesso ao servidor Nginx.
    - A regra **egress** permite que qualquer tráfego de saída seja autorizado.

5. **Key Pair**:
    - Um par de chaves SSH (`main_key`) é criado, permitindo acesso seguro à instância EC2 usando SSH.

6. **Instância EC2**:
    - Cria uma instância EC2 com a Amazon Linux 2 AMI (`ami-0c55b159cbfafe1f0`) e o tipo de instância `t2.micro` (incluído no nível gratuito da AWS).
    - O campo `user_data` contém um script que automatiza a instalação e configuração do Nginx na instância EC2:
        ```bash
        #!/bin/bash
        sudo apt update
        sudo apt install -y nginx
        sudo systemctl start nginx
        sudo systemctl enable nginx
        ```
      Isso garante que o Nginx seja instalado e iniciado automaticamente após a criação da instância.
      
7. **Monitoramento com CloudWatch** (Opcional):
    - Um alarme do **CloudWatch** é configurado para monitorar a utilização de CPU da instância EC2. Se a CPU exceder 80% por dois períodos de avaliação consecutivos, um alarme é disparado, o que permite monitoramento e alertas.

8. **Backup Automático** (Opcional):
    - Foi configurado um **plano de backup** utilizando o serviço AWS Backup para realizar backups diários automáticos da instância EC2.

## Melhorias Implementadas

### 1. **Segurança:**
   - O grupo de segurança foi ajustado para permitir conexões SSH apenas a partir de um IP específico, aumentando a segurança do servidor.
   - O acesso root via SSH foi desativado, forçando o uso de uma conta de usuário regular.

### 2. **Automação:**
   - O script `user_data` foi adicionado para automatizar a instalação e inicialização do servidor Nginx, economizando tempo e garantindo que a aplicação esteja pronta logo após a instância ser provisionada.

### 3. **Monitoramento e Backup:**
   - Adicionamos um alarme do CloudWatch para monitorar a utilização de CPU da instância e um plano de backup para garantir que a instância seja automaticamente protegida com backups diários.

## Instruções para Executar o Código

### Pré-requisitos:
- **Conta AWS** com permissões para criar recursos como VPCs, EC2, CloudWatch e AWS Backup.
- **Terraform** instalado na sua máquina local. Você pode seguir as instruções de instalação [aqui](https://learn.hashicorp.com/tutorials/terraform/install-cli).

### Passos para Inicializar e Aplicar o Código:

1. **Clone o repositório**:
    ```bash
    git clone <url-do-repositorio>
    cd terraform-challenge
    ```

2. **Inicialize o Terraform**:
    Este comando prepara o diretório de trabalho e baixa os provedores necessários:
    ```bash
    terraform init
    ```

3. **Crie o plano de execução**:
    Isso mostra uma prévia dos recursos que serão criados:
    ```bash
    terraform plan
    ```

4. **Aplique a configuração**:
    Este comando cria a infraestrutura na AWS:
    ```bash
    terraform apply
    ```

5. **Verifique o servidor Nginx**:
    Após a execução bem-sucedida, você pode acessar a instância EC2 usando o endereço IP público gerado. O Nginx estará rodando na porta 80.

6. **Destrua a infraestrutura** (opcional):
    Se você quiser remover todos os recursos criados, execute:
    ```bash
    terraform destroy
    ```

## Justificativas das Melhorias

1. **Segurança**: Permitir acesso SSH apenas de um IP específico e desativar o acesso root melhora drasticamente a segurança da instância, protegendo-a contra acessos não autorizados.
2. **Automação**: Automatizar a instalação do Nginx garante que a instância EC2 esteja pronta para servir conteúdo imediatamente após sua criação.
3. **Monitoramento e Backup**: O monitoramento da CPU e a automação de backups são práticas recomendadas para garantir a saúde e a continuidade da aplicação no longo prazo.

## Conclusão

Este projeto demonstra o uso de **Infraestrutura como Código** para provisionar uma infraestrutura segura e automatizada na AWS, utilizando as melhores práticas de segurança e eficiência. Além disso, ele mostra como melhorar a automação de servidores com o Terraform e aumentar a resiliência com backup e monitoramento.
