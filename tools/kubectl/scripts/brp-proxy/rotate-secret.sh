PRIMARY_HASH=$(cat /dev/urandom | head -c 32 | base64)
SECONDARY_HASH=$(cat /dev/urandom | head -c 32 | base64)
PRIMARY_DATE=$(date '+%Y%m%d')
SECONDARY_DATE=$(date -d "1 day ago" '+%Y%m%d')
PRIMARY_DATE_HASH=$(kubectl get --ignore-not-found secret brp-hashes -o jsonpath="{.data.$PRIMARY_DATE}")
SECONDARY_DATE_HASH=$(kubectl get --ignore-not-found secret brp-hashes -o jsonpath="{.data.$SECONDARY_DATE}")

if [[ -z $PRIMARY_DATE_HASH ]] ; then
    if [[ -z $SECONDARY_DATE_HASH ]] ; then
        echo "No hashes exist for today or yesterday, so new hashes will be created."
        CONCAT_HASH="$SECONDARY_HASH,$PRIMARY_HASH"
        kubectl create secret generic brp-hashes --from-literal=$SECONDARY_DATE=$SECONDARY_HASH --from-literal=$PRIMARY_DATE=$PRIMARY_HASH --from-literal=brp_hash_array=$CONCAT_HASH --dry-run=client -o yaml | kubectl apply --server-side -f -
    else
        echo "No hash exists for today, only for yesterday. A new hash will be generated for today. Only yesterdays hash will be kept alongside todays hash."
        CONCAT_HASH="$SECONDARY_DATE_HASH,$PRIMARY_HASH"
        kubectl create secret generic brp-hashes --from-literal=$SECONDARY_DATE=$SECONDARY_DATE_HASH --from-literal=$PRIMARY_DATE=$PRIMARY_HASH --from-literal=brp_hash_array=$CONCAT_HASH --dry-run=client -o yaml | kubectl apply --server-side -f -
    fi
else
    if [[ -z $SECONDARY_DATE_HASH ]] ; then
        echo "A hash for today exists, but no hash was found for yesterday. For consistency, a hash for the previous day will be created"
        CONCAT_HASH="$SECONDARY_HASH,$PRIMARY_DATE_HASH"
        kubectl create secret generic brp-hashes --from-literal=$SECONDARY_DATE=$SECONDARY_HASH --from-literal=$PRIMARY_DATE=$PRIMARY_DATE_HASH --from-literal=brp_hash_array=$CONCAT_HASH --dry-run=client -o yaml | kubectl apply --server-side -f -

    else
        echo "A hash already exists for today and yesterday. No actions will be taken"
    fi
fi

CURRENT_PRIMARY_DATE_HASH=$(kubectl get --ignore-not-found secret brp-hashes -o jsonpath="{.data.$PRIMARY_DATE}")
CURRENT_SECONDARY_DATE_HASH=$(kubectl get --ignore-not-found secret brp-hashes -o jsonpath="{.data.$SECONDARY_DATE}")
CURRENT_CONCAT_HASH="$CURRENT_SECONDARY_DATE_HASH,$CURRENT_PRIMARY_DATE_HASH"

kubectl create secret generic brp-hashes --from-literal=$SECONDARY_DATE=$CURRENT_SECONDARY_DATE_HASH --from-literal=$PRIMARY_DATE=$CURRENT_PRIMARY_DATE_HASH --from-literal=brp_hash_array=$CURRENT_CONCAT_HASH --dry-run=client -o yaml | kubectl apply --server-side -f -