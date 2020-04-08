#/bin/sh

read -p "Github Personal Access Token: " PAT
read -p "Email Address for account: " email
key_path="$HOME/.ssh/id_rsa"

# Generate SSH key
ssh-keygen -t rsa -b 4096 -C $email -f $key_path -q -P ""

# Add key to SSH agent
eval "$(ssh-agent -s)"
ssh-add $key_path

# Upload key to github
curl -X POST -H "Authorization: token $PAT" \
 --data "{\"title\":\"$(hostname)\",\"key\":\"$(cat $key_path.pub)\"}" \
 https://api.github.com/user/keys
