PRIMARY_KEY=$(cat /dev/urandom | head -c 32 | base64)
SECONDARY_KEY=$(cat /dev/urandom | head -c 32 | base64)
PRIMARY_DATE=$(date '+%Y%m%d')
SECONDARY_DATE=$(date -d "1 day ago" '+%Y%m%d')
PRIMARY_DATE_KEY=$(kubectl get --ignore-not-found secret brp-keys -o jsonpath="{.data.$PRIMARY_DATE}")
SECONDARY_DATE_KEY=$(kubectl get --ignore-not-found secret brp-keys -o jsonpath="{.data.$SECONDARY_DATE}")

if [[ -z $PRIMARY_DATE_KEY ]] ; then
    if [[ -z $SECONDARY_DATE_KEY ]] ; then
        echo "No keys exist for today or yesterday, so new keys will be created."
        CONCAT_KEY="$SECONDARY_KEY,$PRIMARY_KEY"
        kubectl create secret generic brp-keys --from-literal=$SECONDARY_DATE=$SECONDARY_KEY --from-literal=$PRIMARY_DATE=$PRIMARY_KEY --from-literal=brp_key_array=$CONCAT_KEY --dry-run=client -o yaml | kubectl apply --server-side -f -
    else
        echo "No key exists for today, only for yesterday. A new key will be generated for today. Only yesterdays key will be kept alongside todays key."
        CONCAT_KEY="$SECONDARY_DATE_KEY,$PRIMARY_KEY"
        kubectl create secret generic brp-keys --from-literal=$SECONDARY_DATE=$SECONDARY_DATE_KEY --from-literal=$PRIMARY_DATE=$PRIMARY_KEY --from-literal=brp_key_array=$CONCAT_KEY --dry-run=client -o yaml | kubectl apply --server-side -f -
    fi
else
    if [[ -z $SECONDARY_DATE_KEY ]] ; then
        echo "A key for today exists, but no key was found for yesterday. For consistency, a key for the previous day will be created"
        CONCAT_KEY="$SECONDARY_KEY,$PRIMARY_DATE_KEY"
        kubectl create secret generic brp-keys --from-literal=$SECONDARY_DATE=$SECONDARY_KEY --from-literal=$PRIMARY_DATE=$PRIMARY_DATE_KEY --from-literal=brp_key_array=$CONCAT_KEY --dry-run=client -o yaml | kubectl apply --server-side -f -
    else
        echo "A key already exists for today and yesterday. No actions will be taken"
    fi
fi

CURRENT_PRIMARY_DATE_KEY=$(kubectl get --ignore-not-found secret brp-keys -o jsonpath="{.data.$PRIMARY_DATE}")
CURRENT_SECONDARY_DATE_KEY=$(kubectl get --ignore-not-found secret brp-keys -o jsonpath="{.data.$SECONDARY_DATE}")
CURRENT_CONCAT_KEY="$CURRENT_SECONDARY_DATE_KEY,$CURRENT_PRIMARY_DATE_KEY"

kubectl create secret generic brp-keys --from-literal=$SECONDARY_DATE=$CURRENT_SECONDARY_DATE_KEY --from-literal=$PRIMARY_DATE=$CURRENT_PRIMARY_DATE_KEY --from-literal=brp_key_array=$CURRENT_CONCAT_KEY --dry-run=client -o yaml | kubectl apply --server-side -f -