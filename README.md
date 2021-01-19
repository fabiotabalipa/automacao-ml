# Automação de Provisionamento para ML

A motivação para o desenho desta arquitetura foi a necessidade de treinar modelos de *Machine Learning* (ML) de maneira colaborativa com uma boa relação entre custo e benefício, sem manter instâncias em execução quando não estão sendo utilizadas.

## Como funciona?

* Quando um cientista de dados desejar realizar mineração de dados ou treinar um modelo de ML com o SageMaker, chama o *endpoint* para acordar a instância dormente: `https://<ID API>.execute-api.<Região>.amazonaws.com/v1/wake-up` e aguarda cerca de 3 min até que se inicie.

* Após 40 minutos de inatividade - nenhuma interação na interface ou nenhum código em andamento no notebook -, o SageMaker recebe o comando para voltar a ficar dormente, e, assim, cessa potenciais gastos relacionados ao tempo de execução da instância.

## Arquitetura

![arquitetura](https://user-images.githubusercontent.com/37602229/104976472-05ce1080-59dc-11eb-8448-3578e263840b.png)

## Terraform

O Terraform é uma ferramenta de DevOps open-source desenvolvida pela HashiCorp que permite o uso de *Infrastructure as Code* (IaC) para provisionamento de recursos de múltiplos provedores *Infrastructure as a Service* (IaaS).

## Configuração e execução

1. Criar arquivo `terraform.tfvars` para alimentar as variáveis de entrada:

```
default_vpc_id = "<ID VPC>"

allowed_ips = [
	# Fábio
	"<IP Fábio>/32",
	# Henrique
	"<IP Henrique>/32"
	# ...
]
```

2. Aplicar as configurações:
```shell
terraform init
terraform plan
terraform apply
```

3. Verificar no console do API Gateway qual a URL para disparo da função lambda e repassá-la aos colegas.

## Contribuindo

Fique à vontade para abrir uma *issue* ou enviar um PR.

## Licença

MIT.