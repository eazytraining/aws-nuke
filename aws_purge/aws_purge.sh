#!/bin/bash
################################################ LES FONCTIONS DU SCRIPT ################################################
function choose_action ()
{
    echo -e "Que souhaitez vous faire ? \n    1     =  Suppression des ressources \n    2     =  Creation du default VPC \n    q|Q   =  Quitter le programme \n Faites votre choix svp"
    read -p "CHOIX : " choice
    if [ -z "$choice" ]; then
        choice="empty"
    fi
   
}


function configure_credentials ()
{
    echo "Configuration de votre compte aws et de vos credentials"
    echo -e "Entrez votre ID de compte aws \n"
    read -p "ID du compte aws : " aws_account_id
    echo -e "Entrez l'access key de votre compte aws \n"
    read -p "Votre access key : "  access_key_id
    echo -e "Entrez la secret key de votre compte aws \n"
    read -p "Votre secret  key : " secret_access_key
}

function create_nuke_config ()
{
cat <<EOF > ${workdir}/config/nuke-config.yml
regions:
- eu-west-3       # Paris
- us-east-1       # Virginie_du_Nord
- us-east-2       # Ohio
- ap-southeast-2  # Sydney
- eu-central-1    # Francfort
- us-west-1       # Californie_du_Nord
- us-west-2       # Oregon
- af-south-1      # Le_cap
- eu-north-1      # Stockholm
- me-south-1      # Bahrain
- ca-central-1    # Canada
- ap-northeast-1  # Tokyo
- ap-southeast-3  # Jakarta
- ap-east-1       # Hong Kong
- ap-south-1      # Mumbai
- ap-northeast-3  # Osaka
- ap-northeast-2  # Seoul
- ap-southeast-1  # Singapore
- eu-west-1       # Ireland
- eu-west-2       # London
- eu-south-1      # Milan
- sa-east-1       # Sao Paulo
- global

account-blocklist:
- "999999999999" # production

accounts:
  "$aws_account_id":

resource-types:
# don't nuke IAM Objects and Keypairs
  excludes:
  - IAMUser
  - IAMGroupPolicyAttachment
  - IAMUserGroupAttachment
  - IAMGroup
  - IAMUserAccessKey
  - IAMRole
  - EC2KeyPair
  - IAMUserPolicyAttachment
  - IAMLoginProfile
  - IAMRolePolicyAttachment
  - IAM*
EOF
}

function  usage ()
{
   echo -e "\n Attention, mauvaise utilisation du scrtipt. Bien vouloir suivre les instructions du programme \n"
}

function fermeture_programme ()
{
    echo -e "Le programme va se fermer dans 3 secondes"
    sleep 3 
    echo -e "Au revoir !"
    exit 0     
}

function  configure_aws_cli ()
{
cat <<EOF > ${HOME}/.aws/config
[profile ${aws_account_id}]
region = us-east-1
output = json
EOF

cat <<EOF > ${HOME}/.aws/credentials
[${aws_account_id}]
aws_access_key_id = ${access_key_id}
aws_secret_access_key = ${secret_access_key}
EOF

}

function download_awc_cli ()
{
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        sudo yum install unzip -y
        unzip awscliv2.zip
        sudo ./aws/install
        mkdir -p ${HOME}/.aws
}

function create_default_vpc_for_region ()
{
        for region in us-west-2 us-east-1 us-west-3 us-east-2 ap-southeast-2 eu-central-1 us-west-1 af-south-1; do
            aws configure set region ${region} --profile ${aws_account_id}
            aws ec2 create-default-vpc --profile ${aws_account_id}
            #aws ec2 create-default-subnet --availability-zone us-east-2a
        done
}


################################################   SCRIPT PRINCIPAL ####################################################
echo "------------------------------------------------------------------------------------------"
echo "-----------------      Purge du compte aws + Creation du default vpc       ---------------"
echo "------------------------------------------------------------------------------------------"

workdir="${HOME}/aws_purge"
echo -e "Ce sript permet de purger votre compte aws et/ou de créer le VPC par défaut"

configure_credentials
choice="0"
while [ $choice != q ] || [ $choice != Q ]; do
  choose_action
  case "$choice" in 
    1)  echo -e "Nous allons démarer la purge de votre compte"
        mkdir -p ${workdir}
        cd $workdir
        echo -e "Ce programme supprime les ressources dans les régions suivante :\nParis, Virginie du Nord, Ohio, Sydney, Francfort, Californie_du_Nord, Oregon, Le_cap,  global "
        echo -e "Si vous voulez rajouter des régions, bien vouloir éditer le fichier de configuration  ${workdir}/config/nuke-config.yml généré"
        echo "Telechargement du binaire aws-nuke"
        wget https://github.com/rebuy-de/aws-nuke/releases/download/v2.16.0/aws-nuke-v2.16.0-linux-amd64.tar.gz -O "${workdir}/aws-nuke.tar.gz"
        tar -xzvf "${workdir}/aws-nuke.tar.gz" -C "${workdir}/"
        mv "${workdir}/aws-nuke-v2.16.0-linux-amd64" "${workdir}/aws-nuke"
        echo "Creation du fichier de conf par defaut config/nuke-config.yml"
        mkdir -p "${workdir}/config"
        touch "${workdir}/config/nuke-config.yml"


        echo "Creation du fichier de conf"
        create_nuke_config

        echo "Lancement de la suppression des ressources"
        ${workdir}/aws-nuke -c ${workdir}/config/nuke-config.yml  --access-key-id ${access_key_id}  --secret-access-key ${secret_access_key} --no-dry-run
    ;;

    2)  echo -e "Téléchargement du client aws"
        download_awc_cli

        echo -e "Creation des fichiers de conf du client aws"
        configure_aws_cli

        echo -e "Creation du default VPC pour chaque région"
        create_default_vpc_for_region
    ;;

    Q|q)  fermeture_programme
    ;;

    *)  usage
    ;;
  esac 
done