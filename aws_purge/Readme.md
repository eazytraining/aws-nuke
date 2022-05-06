# AWS PURGE
## Objectifs
Ce repertoire contient un script vous permettant de **nettoyer le compte aws** ou de **re-créer le VPC par défaut**
Pour faire la purge de votre compte AWS, il suffit d'exécuter le script **aws_purge.sh** sur un système Linux ***dérivé de Redhat***
Le script seul suffit, il va installer tout ce dont il a besoin de dépendances. Il ne prend pas encore en compte les autres distributions **Linux** (**debian**, **ubuntu**, etc ...)


## Prérequis
- Un OS **Redhat** ou dérivé (**Fedora**, **Centos**, etc...)
- Le shell **Bash** présent sur cet OS
- L'accès Root sur votre VM

## Documentations annexe utile.
- **Creation du default VPC**  : https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html#create-default-vpc
- **Installation de la cli aws v2**: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
- **Configuration de la cli avec les access et secret key** : https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html
