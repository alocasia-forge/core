# core

### Sessions manager connect and forward
```bash 
terraform output keycloak
```

### Keycloak commands
```bash
# Installer dépendances
sudo su - ec2-user

sudo dnf install -y unzip wget java-17-amazon-corretto firewalld
sudo systemctl enable --now firewalld
sudo firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080
sudo firewall-cmd --reload
cd /opt
sudo wget https://github.com/keycloak/keycloak/releases/download/26.3.3/keycloak-26.3.3.zip
sudo unzip keycloak-26.3.3.zip
sudo chown -R ec2-user:ec2-user keycloak-26.3.3
cd /opt/keycloak-26.3.3
sudo -u ec2-user nohup bin/kc.sh start-dev > /home/ec2-user/keycloak.log 2>&1 &

tail -f /home/ec2-user/keycloak.log
```

1. Se connecter à localhost:8080 après avoir fait la commande de forward

2. Créer un nouveau compte admin avec le role real-admin.

3. Lui rajouter un mdp

3. Desactiver le 100% HTTPS pour la production : http://localhost:8080/admin/master/console/#/master/realm-settings  REQUIRE SSL
 
3. TOUT A LA FIN DE CETTE PROCEDURE, Changer le host url et mettre https://sso.matih.eu

```bash
sudo su - ec2-user

sudo nohup /home/ec2-user/keycloak-26.3.3/bin/kc.sh start --http-port=80 --http-enabled=true > /tmp/keycloak.log 2>&1 &

tail -f /home/ec2-user/keycloak.log
```