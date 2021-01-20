# Automação de Provisionamento para ML

A motivação para o desenho desta arquitetura foi a necessidade de treinar modelos de *Machine Learning* (ML) de maneira colaborativa com uma boa relação entre custo e benefício, sem manter instâncias em execução quando não estão sendo utilizadas.

## Como funciona?

* Quando um colega desejar utilizar o **Jupyter Lab**, deverá realizar uma requisição `GET` para um *endpoint* para ativar a instância subjacente. O endereço terá o formato `https://<ID API>.execute-api.<Região>.amazonaws.com/v1/start`. Após 1-3 min, tempo de inicialização da instância EC2, recarrega a requisição para obter a URL de acesso:

![request 1](https://user-images.githubusercontent.com/37602229/105111317-683c1500-5a9f-11eb-99bf-6a33c133660d.png)

![request 2](https://user-images.githubusercontent.com/37602229/105111360-7e49d580-5a9f-11eb-8c87-4e81b6ba6a17.png)

> A maneira mais simples de realizar essa requisição é colar na barra de endereços do navegador web.

* Após 40 minutos de inatividade - *nenhuma interação na interface ou nenhum código em andamento no notebook* -, a instância recebe o comando para voltar a ficar dormente, e, assim, cessa potenciais gastos relacionados ao seu tempo de execução.

## Arquitetura

![architecture](https://user-images.githubusercontent.com/37602229/105110038-7f2d3800-5a9c-11eb-9e9a-e446d106f40e.jpg)

> Na v2, abolimos o uso do AWS SageMaker; assim, a infraestrutura está mais enxuta, com mais tipos de instâncias disponíveis e com custos ainda mais reduzidos.

## Terraform

O Terraform é uma ferramenta de DevOps open-source desenvolvida pela HashiCorp que permite o uso de *Infrastructure as Code* (IaC) para provisionamento de recursos de múltiplos provedores *Infrastructure as a Service* (IaaS).

## Instruções

1. Criar arquivo `terraform.tfvars` para alimentar as variáveis de entrada:

```hcl
credentials_profile = "<perfil das credenciais>"

region = "sa-east-1"

key_name = "<par de chaves>"

identity_file_path = "~/.ssh/<par de chaves>.pem"

allowed_ips = [
	# Fábio
	"<IP Fábio>/32",
	# Henrique
	"<IP Henrique>/32"
	# ...
]

instance_type = "t2.micro"
```

> Mais sobre os perfis de credenciais [aqui](https://docs.aws.amazon.com/pt_br/sdk-for-php/v3/developer-guide/guide_credentials_profiles.html).

> Mais sobre par de chaves EC2 e acesso SSH: [aqui](https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html).

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