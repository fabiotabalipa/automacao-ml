# Automação de provisionamento de recursos para ML

A motivação para o desenho desta arquitetura foi a necessidade de treinar modelos de *Machine Learning* (ML) de maneira colaborativa com uma boa relação entre custo e benefício, sem manter instâncias em execução quando não estão sendo utilizadas.

## Como funciona?

* Quando um colega desejar utilizar o **Jupyter Lab**, deverá: 

	1. ...realizar uma requisição `GET` para um *endpoint* para ativar a instância subjacente. O endereço terá o formato `https://<ID API>.execute-api.<Região>.amazonaws.com/v1/start?pass=<senha>`; a resposta será:

	```
	{"message": "Jupyter Lab will start in 1-3 min. Wait and reload this request to get the access URL."}
	```

	2. ...após 1-3 min - tempo de inicialização da instância EC2 -, recarregar a requisição para obter a URL de acesso; a resposta será algo como:

	```
	{"message": "Jupyter Lab already running at http://ec2-3-215-117-171.compute-1.amazonaws.com:8443/lab. Remember: it will be inactive again when idle for 40 min."}
	```

	3. ...acessar a URL fornecida pela resposta e colocar a senha configurada.

	> A maneira mais simples de realizar essas requisições é colar na barra de endereços do navegador web.

* Após 40 minutos de inatividade - *nenhuma interação na interface ou nenhum código em andamento no notebook* -, a instância recebe o comando para voltar a ficar dormente, e, assim, cessa potenciais gastos relacionados ao seu tempo de execução.

* Qualquer arquivo gerado dentro do Jupyter Lab é automaticamente salvo em um repositório privado do Github configurado.

## Arquitetura

![architecture](https://user-images.githubusercontent.com/37602229/105110038-7f2d3800-5a9c-11eb-9e9a-e446d106f40e.jpg)

## Terraform

O Terraform é uma ferramenta de DevOps open-source desenvolvida pela HashiCorp que permite o uso de *Infrastructure as Code* (IaC) para provisionamento de recursos de múltiplos provedores *Infrastructure as a Service* (IaaS).

## Instruções

1. Criar arquivo `terraform.tfvars` para alimentar as variáveis de entrada:

```hcl
credentials_profile = "<perfil das credenciais AWS>"

region = "us-east-1"

key_name = "<nome do par de chaves para acesso instância SSH>"

identity_file_path = "<caminho arquivo .pem para acesso instância SSH>"

allowed_ips = [
	# IP que pode acessar instância via SSH ...
	"<IP administrador da instância>/32"
]

team_pass = "<senha para os endpoints de inicialização e Jupyter Lab>"

instance_type = "g4dn.4xlarge"

ami = "ami-064d8dbbcc5ded164"

github_repo_name = "<nome do repositório privado do Github>"

github_user_name = "<nome do usuário no Github>"

github_access_token = "<token de acesso do usuário no Github>"
```

> Mais sobre os perfis de credenciais [aqui](https://docs.aws.amazon.com/pt_br/sdk-for-php/v3/developer-guide/guide_credentials_profiles.html).

> Mais sobre par de chaves EC2 e acesso SSH: [aqui](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html).

> Mais sobre a obtenção de token de acesso do usuário no Github aqui: [aqui](https://docs.github.com/pt/github/authenticating-to-github/creating-a-personal-access-token).

2. Aplicar as configurações:
```shell
cd infrastructure
terraform init
terraform plan
terraform apply
```

3. Verificar no console do API Gateway qual a URL para disparo da função lambda e repassá-la aos colegas detentores dos IPs liberados.

## Como contribuir

Colaborações e sugestões são bem-vindas.

## Licença

MIT.