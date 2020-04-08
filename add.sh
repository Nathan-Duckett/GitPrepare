#/bin/sh

# Function to get parameters from cli arguments
function get_params () {
    # =====================================
    # Parameter parsing for bash script
    # =====================================
    PARAMS=""
    while (( "$#" )); do
    case "$1" in
        -pat|--personal-access-token)
        PAT=$2
        shift 2
        ;;
        -n|--name)
        name=$2
        shift 2
        ;;
        -e|--email)
        email=$2
        shift 2
        ;;
        --) # end argument parsing
        shift
        break
        ;;
        -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
        *) # preserve positional arguments
        PARAMS="$PARAMS $1"
        shift
        ;;
    esac
    done
    # set positional arguments in their proper place
    eval set -- "$PARAMS"
}

get_params

# =====================================
# Check values exist otherwise set them
# =====================================
if [ "$PAT" == "" ]; then
    read -p "Github Personal Access Token: " PAT
fi

if [ "$name" == "" ]; then
    read -p "Your name for the account: " name
fi

if [ "$email" == "" ]; then
    read -p "Email Address for account: " email
fi
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

# Set git globals
git config --global user.email $email
git config --global user.name $name
