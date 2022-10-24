#!/usr/bin/env bash

export AWS_REGION=ap-northeast-2
export AWS_PROFILE_NAME=YOUR_PROFILE_NAME

NAMES=$(
    aws secretsmanager list-secrets \
        --query 'SecretList[?Name!=`null`].Name' \
        --output text
)

# Key : Value 형태로 AWS SecretsManager 에 저장된 것이 있는 반면
# Key : Value 가 아닌 형태로 저장되어있는 경우가 있음. 이에 따라 다른 형태로 출력 및 
저장하도록 하였으며
# 실제 이 스크립트를 사용했을때의 Json 파일 그대로 사용이 불가능 한 경우가 있을 수 
있음.
# Key : Value 가 아닌 형태의 secrets는 {'secrets' : 'value'} 형태로 저장되도록 
구현되었

for NAME in $NAMES; do
    SECRET=$(aws secretsmanager get-secret-value \
        --secret-id $NAME \
        --query 'SecretString' \
        --output text
    )
    if jq -e . >/dev/null 2>&1 <<<"$SECRET"; then
        echo "$NAME"
        echo "$SECRET" | jq . >> $NAME.json
    else
        echo "$NAME"
        echo "$SECRET" | jq -n --arg value "$SECRET" '{secrets: $value}' >> 
$NAME.json
    fi
done

